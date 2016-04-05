/**
 * Copyright 2007-2015, Kaazing Corporation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import "KGUpstreamHandler.h"
#import "KGHttpRequest.h"
#import "KGHttpRequestHandler.h"
#import "KGHttpRequestIoHandler.h"
#import "KGHttpRequestListener.h"
#import "KGWebSocketEmulatedEncoder.h"
#import "KGWebSocketEmulatedHandshakeHandler.h"
#import "KGTransportFactory.h"
#import "KGTracer.h"
#import "KGConstants.h"

// "Constants":
NSMutableData* RECONNECT_EVENT_BYTES;
unsigned char WSF_COMMAND_FRAME_START = 0x01;
unsigned char CLOSE_EVENT_BYTE1 = 0x30;
unsigned char CLOSE_EVENT_BYTE2 = 0x31;
unsigned char WSF_COMMAND_FRAME_END = 0xff;
unsigned char WSE_PONG_FRAME_CODE = 0x8a;

// "Listener" Interface to 'observe' the underlying NSURLConnection (KGHttpRequest)
@interface KGUpstreamHandlerHttpRequestListener : NSObject <KGHttpRequestListener>
-initWithUpstreamHandler:(KGUpstreamHandler *)upstreamHandler;
@end

// "Listener" IMPL to 'observe' the underlying NSURLConnection (KGHttpRequest)
@implementation KGUpstreamHandlerHttpRequestListener {
    KGUpstreamHandler * parent;
}

- (void) init0 {
    //

    RECONNECT_EVENT_BYTES = [[NSMutableData alloc] init];
    [RECONNECT_EVENT_BYTES appendBytes:&WSF_COMMAND_FRAME_START length:1];
    [RECONNECT_EVENT_BYTES appendBytes:&CLOSE_EVENT_BYTE1 length:1];
    [RECONNECT_EVENT_BYTES appendBytes:&CLOSE_EVENT_BYTE2 length:1];
    [RECONNECT_EVENT_BYTES appendBytes:&WSF_COMMAND_FRAME_END length:1];

}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(id)initWithUpstreamHandler:(KGUpstreamHandler *)upstreamHandler {
   self =  [self init];
    if (self) {
        parent = upstreamHandler;
    }
    return self;
}



// Delegate... KGHttpRequestListener
- (void) requestReady:(KGHttpRequest *)request{
    KGUpstreamChannel * channel = (KGUpstreamChannel *)request.parent;
    
    KGByteBuffer * payload = [KGByteBuffer allocate:1024];
    // not empty ?
    @synchronized(channel.sendQueue) {
        for (NSData* data in channel.sendQueue) {
            [payload putData:data];
        }
        [channel.sendQueue removeAllObjects];
    }
    
    // reconnect event bytes *required* to terminate upstream
    [payload putData:RECONNECT_EVENT_BYTES];
    [payload flip];
    
    [[parent nextHandler] processSend:request buffer:payload];
}


/// ---------- package private stuff -----------

// package private
- (void) requestOpened:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"Upstream: requestOpened");
#endif
}

// package private
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload{
#ifdef DEBUG
    NSLog(@"Upstream: requestProgressed");
#endif
}

// package private
- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response{
#ifdef DEBUG
    NSLog(@"Upstream: requestLoaded");
#endif
    [[parent nextHandler] processAbort:request]; //close the request

    
}

// package private
- (void) requestAborted:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"Upstream: requestAborted");
#endif
    [[parent nextHandler] processAbort:request]; //close the request

}

// package private
- (void) requestClosed:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"Upstream: requestClosed");
#endif
    [[parent nextHandler] processAbort:request]; //close the request
    [request setParent:nil];
}

// package private
- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception {
#ifdef DEBUG
    NSLog(@"Upstream: errorOccurred");
#endif
    KGUpstreamChannel * channel = (KGUpstreamChannel *) [request parent];
    channel.sendInFlight = NO;
    [[parent listener] upstreamFailed:channel exception:exception];
    [request setParent:nil];
}

@end
/// END OF THAT "HTTP" LISTNER...

//@interface UpstreamHandlerFactory : NSObject <KGHttpRequestHandlerFactory>
//@end
//
//@implementation UpstreamHandlerFactory
//-(id)createHandler {
//    return [[KGHttpRequestIoHandler alloc] init];
//}
//@end




///////// the actual implementation of the KGUpstreamHandler...
@implementation KGUpstreamHandler {
    id <KGHttpRequestHandler> _nextHandler;
    id <KGUpstreamHandlerListener> _listener;
    KGWebSocketEmulatedEncoder * _encoder;
}


// "constructors..."
- (void) init0 {
    // init stuff...
    _encoder = [[KGWebSocketEmulatedEncoder alloc] init];
    
//    [self setNextHandler:[[KGUpstreamHandler UPSTREAM_HANDLER_FACTORY] createHandler]];
    
    id <KGHttpRequestHandler> transportHandler = [KGTransportFactory createHttpRequestHandler];
    [self setNextHandler:transportHandler];
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}



// implementation of interface


//+ (id <KGHttpRequestHandlerFactory>) UPSTREAM_HANDLER_FACTORY {
//    // not really correct...
//    return [[UpstreamHandlerFactory alloc] init];
//}

-(void) processBinaryMessage:(KGUpstreamChannel *)channel message: (KGByteBuffer *)message {
#ifdef DEBUG
    NSLog(@"[KGUpstreamHandler processBinaryMessage] (%@)", channel );
#endif
    
    KGByteBuffer * encodedPayload = [_encoder encodeBinaryMessage:channel message:message encoderOutput:nil];
    
    NSData* _payload = [encodedPayload data];
    @synchronized(channel.sendQueue) {
        [channel.sendQueue addObject:_payload];
    }
    // SendIfReady(channel...
    
    KGHttpRequest * request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"POST" uri:[channel location] async:YES];
    [request setHeader:HEADER_CONTENT_TYPE value:@"application/octet-stream"];
    NSString *sequence = [NSString stringWithFormat:@"%qi", [channel nextSequence]];
    [request setHeader:HEADER_SEQUENCE_NO value:sequence];

    // stash the channel:
    [request setParent:channel];
    
    KGWebSocketChannel *parentChannel = (KGWebSocketChannel *)[channel parent];
    SecIdentityRef identity = [parentChannel clientIdentity];
    [request setClientIdentity:identity];
    
    // GO!
    [_nextHandler processOpen:request];
}

-(void) processTextMessage:(KGUpstreamChannel *)channel message: (NSString*)message {
#ifdef DEBUG
    NSLog(@"[KGUpstreamHandler processTextMessage] (%@)", [channel location]);
#endif
    KGByteBuffer* encodedPayload = [_encoder encodeTextMessage:channel message:message encoderOutput:nil];
    NSData* _payload = [encodedPayload data];
    @synchronized(channel.sendQueue) {
        [channel.sendQueue addObject:_payload];
    }
    // SendIfReady(channel...
    
    KGHttpRequest * request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"POST" uri:[channel location] async:YES];
    [request setHeader:HEADER_CONTENT_TYPE value:@"application/octet-stream"];
    NSString *sequence = [NSString stringWithFormat:@"%qi", [channel nextSequence]];
    [request setHeader:HEADER_SEQUENCE_NO value:sequence];
    
    // stash the channel:
    [request setParent:channel];
    
    // GO!
    [_nextHandler processOpen:request];
    
}
-(void) processClose:(KGUpstreamChannel *)channel code:(NSInteger)code reason:(NSString *)reason {
#ifdef DEBUG
    NSLog(@"Upstream: CLOSE");
#endif
    
    // TODO: handle code and reason
    
    unsigned char WSF_COMMAND_FRAME_START = 0x01;
    unsigned char CLOSE_EVENT_BYTE1 = 0x30;
    unsigned char CLOSE_EVENT_BYTE2 = 0x32;
    unsigned char WSF_COMMAND_FRAME_END = 0xff;
    
    //private static final byte[] CLOSE_EVENT_BYTES =     { WSF_COMMAND_FRAME_START, 0x30, 0x32, WSF_COMMAND_FRAME_END };
//    WS_TEXT_FRAME_START = 0x0;
//    WS_TEXT_FRAME_END = 0xFF;
//    WS_BINARY_FRAME_START = 0x80;
//    private static final byte WSF_COMMAND_FRAME_START = (byte) 0x01;
//    private static final byte WSF_COMMAND_FRAME_END = (byte) 0xff;
    
    
    NSMutableData* closeFrame = [[NSMutableData alloc] init];
    [closeFrame appendBytes:&WSF_COMMAND_FRAME_START length:1];
    [closeFrame appendBytes:&CLOSE_EVENT_BYTE1 length:1];
    [closeFrame appendBytes:&CLOSE_EVENT_BYTE2 length:1];
    [closeFrame appendBytes:&WSF_COMMAND_FRAME_END length:1];

    @synchronized(channel.sendQueue) {
        [channel.sendQueue addObject:closeFrame];
    }
    
    // SendIfReady(channel...
    
    KGHttpRequest * request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"POST" uri:[channel location] async:YES];
    NSString *sequence = [NSString stringWithFormat:@"%qi", [channel nextSequence]];
    [request setHeader:HEADER_SEQUENCE_NO value:sequence];
    
    // stash the channel:
    [request setParent:channel];
    
    // GO!
    [_nextHandler processOpen:request];
    
}
-(void) processOpen:(KGUpstreamChannel *)channel {
    
}

- (void) processPong:(KGUpstreamChannel *)channel {
    [KGTracer trace:@"Sending PONG"];
    unsigned char pongFrameBuffer[2];
    pongFrameBuffer[0] = WSE_PONG_FRAME_CODE;
    pongFrameBuffer[1] = 0x00;
    NSData *pongFrame = [NSData dataWithBytes:pongFrameBuffer length:2];
    
    @synchronized(channel.sendQueue) {
        [channel.sendQueue addObject:pongFrame];
    }
    
    // SendIfReady(channel...
    
    KGHttpRequest * request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"POST" uri:[channel location] async:YES];
    NSString *sequence = [NSString stringWithFormat:@"%qi", [channel nextSequence]];
    [request setHeader:HEADER_SEQUENCE_NO value:sequence];
    
    // stash the channel:
    [request setParent:channel];
    
    // GO!
    [_nextHandler processOpen:request];
}

-(void) setListener:(id <KGUpstreamHandlerListener>)listener{
    _listener = listener;
}
-(id<KGUpstreamHandlerListener>) listener {
    return _listener;
}
-(void) setNextHandler:(id<KGHttpRequestHandler>)nextHandler {
    _nextHandler = nextHandler;
    [_nextHandler setListener: [[KGUpstreamHandlerHttpRequestListener alloc] initWithUpstreamHandler:self]];
}
-(id <KGHttpRequestHandler>) nextHandler {
    return _nextHandler;
}

// "private" helpers...

@end
