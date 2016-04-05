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
#import "KGWebSocketHandshakeObject.h"
#import "KGWebSocketNativeHandshakeHandler.h"
#import "KGWebSocketSelectedChannel.h"
#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocket+Internal.h"
#import "NSString+KZNGAdditions.h"
#import "KGConstants.h"
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketDelegateImpl.h"

//NSString *const APPLICATION_PREFIX = @"Application";
NSString *const GET = @"GET";
NSString *const HTTP_1_1 = @"HTTP/1.1";
NSString *const COLON = @":";
NSString *const SPACE = @" ";
NSString *const CRLF = @"\r\n";

@interface KGNativeHandshake_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketHandler:(KGWebSocketNativeHandshakeHandler *)handler;

@end

@implementation KGNativeHandshake_WebSocketHandlerListener_1 {
    KGWebSocketNativeHandshakeHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithWebSocketHandler:(KGWebSocketNativeHandshakeHandler *)handler {
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}

- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
    //check response for "x-kaazing-handshake protocol"
    if ([KAAZING_EXTENDED_HANDSHAKE isEqualToString:protocol]) {
        [_parent sendHandshakePayload:channel authToken:nil];
    } else {
        [[_parent listener] connectionOpened:channel protocol:channel.protocol];
    }

}

- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    [[_parent listener] redirected:channel location:location];
}

- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    [[_parent listener] authenticationRequested:channel location:location challenge:challenge];
}

-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    [_parent handleMessageReceived:channel buffer:buf];
}

-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    [_parent handletextMessageReceived:channel text:text];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
    [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionClosed:channel  exception:ex];
}

- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionFailed:channel exception:ex];
}

@end


@implementation KGWebSocketNativeHandshakeHandler {
    /// uuuh, should be a const, but does not work...
    NSData* GET_BYTES;
    NSData* HTTP_1_1_BYTES;
    NSData* COLON_BYTES;
    NSData* SPACE_BYTES;
    NSData* CRLF_BYTES;
}

-(void)dealloc {
    
}

// init stuff:
- (void) init0 {
    // Initialization code here.
    GET_BYTES = [GET dataUsingEncoding:NSUTF8StringEncoding];
    HTTP_1_1_BYTES = [HTTP_1_1 dataUsingEncoding:NSUTF8StringEncoding];
    COLON_BYTES = [COLON dataUsingEncoding:NSUTF8StringEncoding];
    SPACE_BYTES = [SPACE dataUsingEncoding:NSUTF8StringEncoding];
    CRLF_BYTES = [CRLF dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *)requestedProtocols {
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeHandshakeHandler processConnect]");
#endif
    // add kaazing protocol header
    NSMutableArray *nextProtocols = [[NSMutableArray alloc] init];
    [nextProtocols addObject:KAAZING_EXTENDED_HANDSHAKE];
    for (NSString *protocol in requestedProtocols) {
        if (protocol != nil) {
            NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmedProtocol = [protocol stringByTrimmingCharactersInSet:charSet];
            if ([trimmedProtocol length] > 0) {
                [nextProtocols addObject:trimmedProtocol];
            }
        }
    }

    [_nextHandler processConnect:channel location:location requestedProtocols:nextProtocols];
}

-(void) processAuthorize:(KGWebSocketChannel *) channel authorizeToken:(NSString*) authorizeToken {
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeHandshakeHandler processAuthorize]");
#endif
    [self sendHandshakePayload:channel authToken:authorizeToken];
}

//NativeHandshake_
- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    _nextHandler = handler;
    id<KGWebSocketHandlerListener> listnerImpl =
    [[KGNativeHandshake_WebSocketHandlerListener_1 alloc] initWithWebSocketHandler:self];
    [_nextHandler setListener:listnerImpl];
}

+(NSArray *) getLines:(NSString*) payload {
    NSArray * lines = [payload componentsSeparatedByString:@"\r\n"];
    return lines;
}

-(void)handletextMessageReceived:(KGWebSocketChannel *)channel text:(NSString *)text{
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *) channel;
    if (selectedChannel.readyState == KGReadyState_OPEN) {
        [[self listener] textmessageReceived:channel text:text];
    } 
    else {
        [self handleHandshakeMessage:channel message:text];
    }
}

-(void) handleMessageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *) channel;
    if (selectedChannel.readyState == KGReadyState_OPEN) {
        [[self listener] messageReceived:channel buffer:buf];
    } 
    else {
        [self handleHandshakeMessage:channel message:[buf getString]];
    }
}         

-(void) handleHandshakeMessage:(KGWebSocketChannel *) channel message:(NSString*) message {
    if ([message length] > 0) {
        // Continue reading until an empty message is received.
        // wait for more messages
        [channel setHandshakePayload:[[channel handshakePayload] stringByAppendingString:message]];
        return;
    }

    NSArray * lines = [KGWebSocketNativeHandshakeHandler getLines:[channel handshakePayload]];
    [channel setHandshakePayload:@""];
    
    NSString* httpCode = @"";
    //parse the message for embedded http response, should read last one if there are more than one HTTP header
    for (int i = ([lines count] - 1); i >= 0; i--) {
        if ([[lines objectAtIndex:i] hasPrefix:@"HTTP/1.1"]) { //"HTTP/1.1 101 ..."
            NSArray * temp = [[lines objectAtIndex:i] componentsSeparatedByString:@" "];   //.split(" ");
            httpCode = [temp objectAtIndex:1];
            break;
        }
    }
    
    if ([@"101" isEqualToString:httpCode]) {
        //handshake completed, websocket Open
        
        //Get Protocol
        NSString* extensionsHeader = @"";
        for(int i = 0; i < [lines count]; i++) {
            NSString* line = [lines objectAtIndex:i];
            if (line != nil && [line hasPrefix:HEADER_SEC_PROTOCOL]) {
                NSString* protocol = [[line substringFromIndex:([HEADER_SEC_PROTOCOL length] + 1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [channel setProtocol:protocol];
            }
            //NOTE: extension header may be more than one
            if (line != nil && [line hasPrefix:HEADER_SEC_EXTENSIONS]) {
                NSString* val = [[line substringFromIndex:([HEADER_SEC_EXTENSIONS length] + 1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                extensionsHeader = ([extensionsHeader length] > 0) ? [extensionsHeader stringByAppendingFormat: @",%@", val] : val;
            }
        }
        
        // Parse extensions header
        NSString* negotiatedExtensions = @"";
        if ([extensionsHeader length] > 0) {
            NSArray * extensions = [extensionsHeader componentsSeparatedByString:@","];
            for (int i=0; i< [extensions count]; i++) {
                NSString* extension = [extensions objectAtIndex:i];
                NSArray * tmp = [extension componentsSeparatedByString:@";"];
                NSString* extName = [[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([tmp count] > 1) {
                    //has escape bytes
                    NSString* escape = [[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([extName isEqualToString: KAAZING_SEC_EXTENSION_IDLE_TIMEOUT]) {
                        //x-kaazing-idle-timeout extension, escape = "timeout=10000"
                        int timeout;
                        NSScanner *scaner = [NSScanner scannerWithString:[escape substringFromIndex:8]];
                        [scaner scanInt:&timeout];
                        if (timeout > 0) {
                            [_nextHandler setIdleTimeout:channel timeout:timeout];
                        }
                        //x-kaazing-idle-timeout is internal extension, hide it from negotiatedExtensions
                        continue;
                    }
                }
                negotiatedExtensions = ([negotiatedExtensions length] > 0) ? [negotiatedExtensions stringByAppendingFormat: @",%@", extension] : extension;
            }
        }
        KGWebSocketCompositeChannel *compositeChannel = (KGWebSocketCompositeChannel *)[channel parent];
        if ([negotiatedExtensions length] > 0) {
            [compositeChannel setNegotiatedExtensions:negotiatedExtensions];
        }
        //wait for balancer message
        //listener.connectionOpened(channel, supportProtocol);
    } else if ([@"401" isEqualToString:httpCode]) {
        //receive HTTP/1.1 401 from server, pass event to Authentication handler
        NSString* challenge = @"";
        for(int i = 0; i < [lines count]; i++) {
            NSString* line = [lines objectAtIndex:i];
            if ([line hasPrefix:HEADER_WWW_AUTHENTICATE]) {
                challenge = [[line substringFromIndex:([HEADER_WWW_AUTHENTICATE length] + 1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                break;
            }
        }
        [[self listener] authenticationRequested:channel location:channel.location.description challenge:challenge];
    } else {
        // Error during handshake, close connect, report connectionFailed
        //nextHandler.processClose(channel);
        KGWebSocketNativeChannel *nativeChannel = (KGWebSocketNativeChannel *)channel;
        KGWebSocketDelegateImpl *delegate = (KGWebSocketDelegateImpl *)[nativeChannel delegate];
        [delegate closeStreams];
        
        NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:@"Error during handshake" userInfo:nil];
        [[self listener] connectionFailed:channel exception:ex];
    }
}

-(void) sendHandshakePayload:(KGWebSocketChannel *) channel authToken:(NSString*) authToken {
    NSMutableArray * headerNames = [[NSMutableArray alloc] init];
    NSMutableArray * headerValues = [[NSMutableArray alloc] init];
    int currentHeaderIndex = 0;
    if (channel.protocol != nil) {
        NSString *trimmedProtocol = [channel.protocol trim];
        if ([trimmedProtocol length] > 0) {
            [headerNames insertObject:HEADER_SEC_PROTOCOL atIndex:currentHeaderIndex];
            [headerValues insertObject:trimmedProtocol atIndex:currentHeaderIndex];
            currentHeaderIndex++;
        }
    }
    
    NSString *extensions = [self getExtensions:channel];
    NSString* extNames = KAAZING_SEC_EXTENSION_IDLE_TIMEOUT;
    
    if (extensions != nil) {
        NSString *trimmedExtension = [extensions trim];
        if ([trimmedExtension length] > 0) {
            extNames = [NSString stringWithFormat:@"%@,%@", extNames, trimmedExtension];
        }
    }
    
    [headerNames insertObject:HEADER_SEC_EXTENSIONS atIndex:currentHeaderIndex];
    [headerValues insertObject:extNames atIndex:currentHeaderIndex];
    currentHeaderIndex++;
    if (authToken != nil) {
        NSString *trimmedAuthToken = [authToken trim];
        if ([trimmedAuthToken length] > 0) {
            [headerNames insertObject:HEADER_AUTHORIZATION atIndex:currentHeaderIndex];
            [headerValues insertObject:trimmedAuthToken atIndex:currentHeaderIndex];
        }
    }
    KGByteBuffer * payload = [self encodeGetRequest:[[channel location] URI] names:headerNames values:headerValues];
    [[self nextHandler] processTextMessage:channel text:[payload getString] ];
}


-(KGByteBuffer *) encodeGetRequest:(NSURL*) requestURI names:(NSArray *) names values:(NSArray *) values {
    // Any changes to this method should result in the getEncodeRequestSize method below
    // to get accurate length of the buffer that needs to be allocated.
    int requestSize = [self getEncodeRequestSize:requestURI names:names values:values];
    //NSMutableData* buf = [NSMutableData dataWithLength:requestSize];
    KGByteBuffer * buf = [KGByteBuffer allocate:requestSize];
    
    // Encode Request line
    [buf putData:GET_BYTES];
    [buf putData:SPACE_BYTES];
    NSString* path = [requestURI path]; // + "?.kl=Y&.kv=10.05";
    if([path length] == 0) {
        path = @"/";
    }
    if ([requestURI query] != nil) {
        path = [NSString stringWithFormat:@"%@%@%@", path, @"?", [requestURI query]];
    }
    [buf putData:[path dataUsingEncoding:NSUTF8StringEncoding]];
    [buf putData:SPACE_BYTES];
    [buf putData:HTTP_1_1_BYTES];
    [buf putData:CRLF_BYTES];
    
    // Encode headers
    for (int i = 0; i < names.count; i++) {
        NSString* headerName = [names objectAtIndex:i];
        NSString* headerValue = [values objectAtIndex:i];
        if (![headerName isEqual: [NSNull null]] && ![headerValue isEqual: [NSNull null]]) {
            [buf putData:[headerName dataUsingEncoding:NSUTF8StringEncoding]];
            [buf putData:COLON_BYTES];
            [buf putData:SPACE_BYTES];
            [buf putData:[headerValue dataUsingEncoding:NSUTF8StringEncoding]];
            [buf putData:CRLF_BYTES];
        }
    }
    
    // Encoding cookies, content length and content not done here as we
    // don't have it in the initial GET request.
    
    [buf putData:CRLF_BYTES];
    [buf flip];
    return buf;
}


-(int) getEncodeRequestSize:(NSURL*) requestURI names:(NSArray *) names values:(NSArray *) values {
    int size = 0;
    
    // Encode Request line
    size += GET_BYTES.length;
    size += SPACE_BYTES.length;
    NSString* path = [requestURI path]; // + "?.kl=Y&.kv=10.05";
    if([path length] == 0) {
        path = @"/";
    }
    if ([requestURI query] != nil) {
        path = [NSString stringWithFormat:@"%@%@%@", path, @"?", [requestURI query]];
    }
    size += [path dataUsingEncoding:NSUTF8StringEncoding].length;
    size += SPACE_BYTES.length;
    size += HTTP_1_1_BYTES.length;
    size += CRLF_BYTES.length;
    
    // Encode headers
    for (int i = 0; i < names.count; i++) {
        NSString* headerName = [names objectAtIndex:i];
        NSString* headerValue = [values objectAtIndex:i];
        if (![headerName isEqual: [NSNull null]] && ![headerValue isEqual: [NSNull null]]) {
            size += [headerName dataUsingEncoding:NSUTF8StringEncoding].length;
            size += COLON_BYTES.length;
            size += SPACE_BYTES.length;
            size += [headerValue dataUsingEncoding:NSUTF8StringEncoding].length;
            size += CRLF_BYTES.length;
        }
    }
    
    size += CRLF_BYTES.length;
    
    //LOG.fine("Returning a request size of " + size);
    return size;
}

#pragma mark <Private Implementation>
- (NSString *) getExtensions:(KGWebSocketChannel *)channel {
    if (channel == nil) {
        return @"";
    }
    KGWebSocketCompositeChannel *compositeChannel = (KGWebSocketCompositeChannel *)[channel parent];
    return [compositeChannel enabledExtensions];
}

@end