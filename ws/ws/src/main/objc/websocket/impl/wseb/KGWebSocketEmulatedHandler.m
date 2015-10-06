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
#import "KGWebSocketEmulatedHandler.h"
#import "KGWebSocketExtensionHandler.h"
#import "KGWebSocketEmulatedHandshakeHandler.h"
#import "KGTracer.h"

@interface KGEmulated_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketEmulatedHandler:(KGWebSocketEmulatedHandler *)webSocketEmulatedHandler;

@end

@implementation KGEmulated_WebSocketHandlerListener_1 {
    KGWebSocketEmulatedHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}
-(id)initWithWebSocketEmulatedHandler:(KGWebSocketEmulatedHandler *)webSocketEmulatedHandler {
    self =  [self init];
    if (self) {
        _parent = webSocketEmulatedHandler;
    }
    return self;
}


//// "Listener" / Delegate:
/**
 * This method is called when the WebSocket is opened
 */
- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
    [[_parent listener] connectionOpened:channel protocol:protocol];
}

/**
 * This method is called when a redirect response is
 */
- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    //nope
}

/**
 * This method is called when authentication is requested
 */
- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    //nope
}

/**
 * This method is called when a message is received on the WebSocket
 */
-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    [[_parent listener] messageReceived:channel buffer:buf];
}

/**
 * This method is called when a message is received on the WebSocket
 */
-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    [[_parent listener] textmessageReceived:channel text:text];
}

/**
 * This method is called when the WebSocket is closed
 */
- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
    [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionClosed:channel  exception:ex];
}

/**
 * This method is called when a connection fails
 */
- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionFailed:channel exception:ex];
}
@end


@implementation KGWebSocketEmulatedHandler {
    KGWebSocketExtensionHandler * _extensionHandler;
    KGWebSocketEmulatedHandshakeHandler * _handshakeHandler;
}


- (void) init0 {
    _extensionHandler = [[KGWebSocketExtensionHandler alloc] init];
    _handshakeHandler = [[KGWebSocketEmulatedHandshakeHandler alloc] init];
    
    // Build the pipeline:
    [_extensionHandler setNextHandler:_handshakeHandler];
    [self setNextHandler:_extensionHandler];
    
    //_nextHandler = _srDelegate;
    KGEmulated_WebSocketHandlerListener_1 * listener = [[KGEmulated_WebSocketHandlerListener_1 alloc] initWithWebSocketEmulatedHandler:self];
    [[self nextHandler] setListener:listener];
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
    NSLog(@"\n\n[KGWebSocketEmulatedHandler processConnect]  => %@", _nextHandler);
#endif
    
    [[self nextHandler] processConnect:channel location:location requestedProtocols:requestedProtocols];
}



@end
