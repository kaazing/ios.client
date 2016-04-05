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
#import "KGDownstreamHandler.h"
#import "KGHttpRequest.h"
#import "KGHttpRequestHandler.h"
#import "KGHttpRequestIoHandler.h"
#import "KGHttpRequestListener.h"
#import "KGTransportFactory.h"
#import "KGHexUtil.h"
#import "KGWebSocketHandshakeObject.h"
#import "KGWebSocketEmulatedChannel.h"
#import "KGWebSocketEmulatedDecoder.h"
#import "KGTracer.h"
#import "KGConstants.h"


@interface KGDS_WebSocketEmulatedDecoderListener_1 : NSObject <KGWebSocketEmulatedDecoderListener>
@end

@implementation KGDS_WebSocketEmulatedDecoderListener_1 {
    KGDownstreamHandler * parent;
}

- (void) init0 {
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(id)initWithDownstreamHandler:(KGDownstreamHandler *)downstreamHandler {
    self = [self init];
    if (self) {
        parent = downstreamHandler;
    }
    return self;
}

- (void)dealloc
{
    parent = nil;
}


// Delegate... KGWebSocketEmulatedDecoderListener
- (void) messageDecoded:(KGChannel *)channel message:(KGByteBuffer *)message {
    [parent processMessage:(KGDownstreamChannel *)channel message:message];
}

-(void)textmessageDecoded:(KGChannel *)channel message:(NSString *)message{
     [parent processTextMessage:(KGDownstreamChannel *)channel message:message];
}

-(void) commandDecoded:(KGChannel *)channel command:(KGByteBuffer *)command {
    int commandByte0 = [command get];
    int commandByte1 = [command get];
    if (commandByte0 == 0x30 && commandByte1 == 0x31) { //reconnect
        //no reconnect?
    }
    else if (commandByte0 == 0x30 && commandByte1 == 0x32) {
        //close frame received
        short code = 1000;
        NSString* reason = @"";
        if ([command hasRemaining]) {
            code = [command getShort];
        }
        if ([command hasRemaining]) {
            reason = [command getString];
        }
    }
}

- (void) pingReceived:(KGChannel *)channel {
    id<KGDownstreamHandlerListener> listener = [parent listener];
    [listener pingReceived:(KGDownstreamChannel *)channel];
}

@end

@interface KGDS_HttpRequestListener_1 : NSObject <KGHttpRequestListener>
@end
    
@implementation KGDS_HttpRequestListener_1 {
    KGDownstreamHandler * parent;
}

- (void) init0 {
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(id)initWithDownstreamHandler:(KGDownstreamHandler *)downstreamHandler {
    self = [self init];
    if (self) {
        parent = downstreamHandler;
    }
    return self;
}
- (void)dealloc
{
    parent = nil;
}


// Delegate... KGHttpRequestListener
- (void) requestReady:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 requestReady]");
#endif
    //[[parent nextHandler] processSend:request buffer:[KGByteBuffer wrap:[@">|<" dataUsingEncoding:NSUTF8StringEncoding]]];
    [[parent nextHandler] processSend:request buffer:nil];
}

// package private
- (void) requestOpened:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 requestOpened]");
#endif
    KGDownstreamChannel * channel = (KGDownstreamChannel *) [request parent];
    [parent downstreamOpened:channel request:request];
}

// package private
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 requestProgressed]");
#endif
#ifdef DEBUG
    NSLog(@"payload:%@",[payload data]);
#endif
    KGDownstreamChannel * channel = (KGDownstreamChannel *) request.parent;
    [parent processProgressEvent:channel payload:payload];
}

// package private
- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 requestLoaded]");
#endif

    KGDownstreamChannel * channel = (KGDownstreamChannel *) request.parent;
    [parent downstreamClosed:channel];
    [request setParent:nil];
}

// package private
- (void) requestAborted:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 requestAborted]");
#endif
}

// package private
- (void) requestClosed:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 requestClosed]");
#endif
}

// package private
- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception {
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler HttpRequestListener_1 errorOccurred]");
#endif
    
    KGDownstreamChannel * channel = (KGDownstreamChannel *) request.parent;
    [parent downstreamFailed:channel exception:exception];
    [request setParent:nil];
}

@end // of HttpRequestListener_1 listener..

@implementation KGDownstreamHandler {
    id<KGDownstreamHandlerListener> _listener;
    id <KGHttpRequestHandler> nextHandler;
}

- (void) init0 {
    
    KGHttpRequestIoHandler * ioHandler = [[KGHttpRequestIoHandler alloc] init];
    [self setNextHandler:ioHandler];
//    id <KGHttpRequestHandler> transportHandler = [KGTransportFactory createHttpRequestHandler];
//    [self setNextHandler:transportHandler];
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler dealloc]");
#endif
    _listener = nil;
    nextHandler =nil;

}

-(void) processConnect:(KGDownstreamChannel *) channel uri: (KGHttpURI *)uri protocol:(NSString*) protocol {
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler processConnect]: %@", uri);
#endif
    KGHttpRequest * request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"POST" uri:uri async:YES];
    NSString *sequence = [NSString stringWithFormat:@"%qi", [channel nextSequence]];
    [request setHeader:HEADER_SEQUENCE_NO value:sequence];
    [request setParent:channel];
    KGWebSocketChannel *parentChannel = (KGWebSocketChannel *)[channel parent];
    SecIdentityRef identity = [parentChannel clientIdentity];
    [request setClientIdentity:identity];
    [nextHandler processOpen:request];
}

- (void) _makeRequest:(KGDownstreamChannel *) channel uri: (NSString*)uri protocol:(NSString*) protocol {

}

-(void) processProgressEvent:(KGDownstreamChannel *)channel payload:(KGByteBuffer *) payload {
#ifdef DEBUG
    //NSLog(@"[KGDownstreamHandler processProgressEvent]: %@", [payload data]);
#endif
    
    long long currentTimestamp = (long long) [[NSDate date] timeIntervalSince1970] * 1000;
    [channel setLastMessageTimestamp:currentTimestamp];
    
    @try {
        @synchronized ([channel decoder]) {
            [[channel decoder] decode:channel payload:payload webSocketEmulatedDecoderListener:[[KGDS_WebSocketEmulatedDecoderListener_1 alloc] initWithDownstreamHandler:self]];
        }
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        NSLog(@"[KGDownstreamHandler Decode Error]: %@", [exception reason]);
#endif
        NSString *reason = [NSString stringWithFormat:@"[KGDownstreamHandler Decode Error]: %@", [exception reason]];
        NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:reason userInfo:nil];
        [_listener downstreamFailed:channel exception:ex];
    }

}

-(void) processMessage:(KGDownstreamChannel *) channel message:(KGByteBuffer *) message{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler processProgressEvent]: %@", [message data]);
#endif
    [_listener messageReceived:channel data:message];
}

-(void) processTextMessage:(KGDownstreamChannel *) channel message:(NSString*) text{
#ifdef DEBUG
    NSLog(@"[KGDownstreamHandler processProgressEvent]: %@", text);
#endif
        [_listener textmessageReceived:channel data:text];
}
     
-(void) processClose:(KGDownstreamChannel *)channel {
    
}

-(id <KGDownstreamHandlerListener>)listener {
    return _listener;
}

-(void) setListener:(id <KGDownstreamHandlerListener>)listener {
    _listener = listener;
}

-(id <KGHttpRequestHandler>) nextHandler {
    return nextHandler;
}

-(void) setNextHandler:(id <KGHttpRequestHandler>)handler {
    
    nextHandler = handler;
    
    // init with Downstreamm.... "parent" ...
    
    KGDS_HttpRequestListener_1 * listener = [[KGDS_HttpRequestListener_1 alloc] initWithDownstreamHandler:self];
    [handler setListener:listener];
    
}

// Called from KGHttpRequestListener when downstream is opened
// Check if X-Idle-Timeout header is sent by the gateway and start idle timer
- (void) downstreamOpened:(KGDownstreamChannel *)channel request:(KGHttpRequest *)request {
    KGHttpResponse *response = [request response];
    NSString *idleTimeoutHeaderValue = [response header:@"X-Idle-Timeout"];
    if (idleTimeoutHeaderValue != nil) {
        int idleTimeout = [idleTimeoutHeaderValue intValue];
        if (idleTimeout > 0) {
            
            // save in milliseconds
            idleTimeout = idleTimeout * 1000;
            [channel setIdleTimeout:idleTimeout];
            long long currentTimestamp = (long long) [[NSDate date] timeIntervalSince1970] * 1000;
            [channel setLastMessageTimestamp:currentTimestamp];
            [self startIdleTimer:channel delayInMilliseconds:idleTimeout];
        }
    }
    [_listener downstreamOpened:channel];
}

- (void) downstreamClosed:(KGDownstreamChannel *)channel {
    [self stopIdleTimer:channel];
    [_listener downstreamClosed:channel];
}

- (void) downstreamFailed:(KGDownstreamChannel *)channel exception:(NSException *)exception {
    [self stopIdleTimer:channel];
    [_listener downstreamFailed:channel exception:exception];
}

- (void) startIdleTimer:(KGDownstreamChannel *)channel delayInMilliseconds:(int) delayInMilliseconds {
    [KGTracer trace:@"Starting idle timer"];
    NSTimer *idleTimer = [channel idleTimer];
    
    if (idleTimer != nil) {
        [idleTimer invalidate];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:channel forKey:@"channel"];
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:(delayInMilliseconds / 1000) target:self selector:@selector(idleTimerHandler:) userInfo:userInfo repeats:NO];
    [channel setIdleTimer:idleTimer];

}

- (void) idleTimerHandler:(NSTimer *)timer {
    [KGTracer trace:@"Idle timer scheduled"];
    KGDownstreamChannel *channel = (KGDownstreamChannel *)[[timer userInfo] objectForKey:@"channel"];
    
    if (channel != nil) {
        long long currentTimestamp = (long long) [[NSDate date] timeIntervalSince1970] * 1000;
        int idleDuration = (int)(currentTimestamp - [channel lastMessageTimestamp]);
        int idleTimeout = [channel idleTimeout];
        if (idleDuration > idleTimeout) {
            NSString *message = [NSString stringWithFormat:@"idle duration - %d exceeded idle timeout - %d", idleDuration, idleTimeout];
            [KGTracer trace:message];
            NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:message userInfo:nil];
            [_listener downstreamFailed:channel exception:ex];
        }
        else {
            
            //Restart the timer
            [self startIdleTimer:channel delayInMilliseconds:(idleTimeout - idleDuration)];
        }
    }
}

- (void) stopIdleTimer:(KGDownstreamChannel *)channel {
    [KGTracer trace:@"Stopping idle timer"];
    NSTimer *idleTimer = [channel idleTimer];
    if (idleTimer != nil) {
        [idleTimer invalidate];
        [channel setIdleTimer:nil];
    }
}

@end
