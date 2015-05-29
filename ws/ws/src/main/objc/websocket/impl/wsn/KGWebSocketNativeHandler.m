/**
 * Copyright (c) 2007-2014 Kaazing Corporation. All rights reserved.
 * 
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "KGWebSocketNativeHandler.h"
#import "KGWebSocketNativeAuthenticationHandler.h"
#import "KGWebSocketNativeHandshakeHandler.h"
#import "KGWebSocketNativeBalancingHandler.h"
#import "KGWebSocketNativeCodec.h"
#import "KGWebSocketNativeDelegateHandler.h"
#import "KGWebSocketLoggingHandler.h"
#import "KGTracer.h"

@interface KGNative_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketNativeHandler:(KGWebSocketNativeHandler *)webSocketNativeHandler;

@end

@implementation KGNative_WebSocketHandlerListener_1 {
    KGWebSocketNativeHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}
-(id)initWithWebSocketNativeHandler:(KGWebSocketNativeHandler *)webSocketNativeHandler {
    self =  [self init];
    if (self) {
        _parent = webSocketNativeHandler;
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


@implementation KGWebSocketNativeHandler {
    KGWebSocketNativeAuthenticationHandler * _authHandler;
    KGWebSocketNativeHandshakeHandler * _handshakeHandler;
    KGWebSocketNativeBalancingHandler * _balancingHandler;
    KGWebSocketNativeCodec * _codec;
    KGWebSocketLoggingHandler * _loggingHandler;
    KGWebSocketNativeDelegateHandler * _delegate;
    
}


- (void) init0 {
    _authHandler = [[KGWebSocketNativeAuthenticationHandler alloc] init];
    _handshakeHandler = [[KGWebSocketNativeHandshakeHandler alloc] init];
    _balancingHandler = [[KGWebSocketNativeBalancingHandler alloc] init];
    _codec = [[KGWebSocketNativeCodec alloc] init];
    _delegate = [[KGWebSocketNativeDelegateHandler alloc] init];
    
    // Build the pipeline:
    [_authHandler setNextHandler:_handshakeHandler];
    [_handshakeHandler setNextHandler:_balancingHandler];
    
    //add logging handler if KGTracerDebug is YES
    if (KGTracerDebug) {
        _loggingHandler = [[KGWebSocketLoggingHandler alloc] init];
        [_balancingHandler setNextHandler:_loggingHandler];
        [_loggingHandler setNextHandler:_codec];
    }
    else {
        [_balancingHandler setNextHandler:_codec];
    }
    [_codec setNextHandler:_delegate];
    
    [self setNextHandler:_authHandler];
    
    //_nextHandler = _srDelegate;
    KGNative_WebSocketHandlerListener_1 * listener = [[KGNative_WebSocketHandlerListener_1 alloc] initWithWebSocketNativeHandler:self];
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
    NSLog(@"\n\n[KGWebSocketNativeHandler processConnect]  => %@", _nextHandler);
#endif
    
    [[self nextHandler] processConnect:channel location:location requestedProtocols:requestedProtocols];   
}




@end
