/*
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
#import "KGWebSocketLoggingHandler.h"
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketDelegateListener.h"

@interface KGWebSocketLoggingHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketLoggingHandler:(KGWebSocketLoggingHandler *)handler;

@end
@implementation KGWebSocketLoggingHandlerListener_1 {
    KGWebSocketLoggingHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithWebSocketLoggingHandler:(KGWebSocketLoggingHandler *)handler{
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}

- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
    NSLog(@"<-OPENED: %@ %@", channel, protocol);
    [[_parent listener] connectionOpened:channel protocol:protocol];
}
- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    NSLog(@"<-REDIRECTED: %@ %@", channel, location);
    [[_parent listener] redirected:channel location:location];
}
- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    NSLog(@"<-AUTHENTICATION REQUESTED: %@ %@ Challenge: %@", channel, location,challenge);
    [[_parent listener] authenticationRequested:channel location:location challenge:challenge];
}

-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    NSLog(@"<-TEXT: %@ %@", channel, text);
    [[_parent listener] textmessageReceived:channel text:text];
}

-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    NSLog(@"<-BINARY: %@ %@", channel, [buf data]);
    [[_parent listener] messageReceived:channel buffer:buf];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
    NSLog(@"<-CLOSED: %@ %i %i %@", channel, wasClean, code, reason);
    [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    NSLog(@"<-CLOSED: %@ %@", channel, [ex reason]);
    [[_parent listener] connectionClosed:channel  exception:ex];
}

- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    NSLog(@"<-FAILED: %@", channel);
    [[_parent listener] connectionFailed:channel exception:ex];
}
@end


@implementation KGWebSocketLoggingHandler


-(void)dealloc {
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



-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *)requestedProtocols {
    NSLog(@"->CONNECT: %@ %@ %@", channel, [location URI], requestedProtocols);
    [_nextHandler processConnect:channel location:location requestedProtocols:requestedProtocols];
}

-(void)processClose:(KGWebSocketChannel *)channel code:(NSInteger)code reason:(NSString *)reason  {
    NSLog(@"->CLOSE: %@", channel);
    [_nextHandler processClose:channel code:code reason:reason];
}

-(void)processTextMessage:(KGWebSocketChannel *)channel text:(NSString *)text {
    NSLog(@"->TEXT: %@ %@", channel, text);
    [_nextHandler processTextMessage:channel text:text];
}

-(void)processBinaryMessage:(KGWebSocketChannel *)channel buffer:(KGByteBuffer *)buffer {
    NSLog(@"->BINARY: %@ %@", channel, [buffer data]);
    [_nextHandler processBinaryMessage:channel buffer:buffer];
}

-(void)processAuthorize:(KGWebSocketChannel *)channel authorizeToken:(NSString *)authorizeToken {
    NSLog(@"->AUTHORIZE: %@ %@", channel, authorizeToken);
    [_nextHandler processAuthorize:channel authorizeToken:authorizeToken];
}

- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    _nextHandler = handler;
    [_nextHandler setListener:[[KGWebSocketLoggingHandlerListener_1 alloc] initWithWebSocketLoggingHandler:self]];
}

@end

