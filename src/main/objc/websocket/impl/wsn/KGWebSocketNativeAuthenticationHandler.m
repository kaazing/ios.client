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

#import "KGWebSocketNativeAuthenticationHandler.h"
#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocketNativeChannel.h"
#import "KGAuthenticationUtil.h"
#import "KGWebSocketEmulatedChannel.h"
#import "KGWebSocketHandshakeObject.h"
#import "KGWebSocketReAuthenticateHandler.h"
#import "KGWSURI.h"
#import "NSURL+KZNGAdditions.h"

@interface KGNativeAuth_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketNativeAuthenticationHandler:(KGWebSocketNativeAuthenticationHandler *)handler;

@end
@implementation KGNativeAuth_WebSocketHandlerListener_1 {
    KGWebSocketNativeAuthenticationHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}
-(id)initWithWebSocketNativeAuthenticationHandler:(KGWebSocketNativeAuthenticationHandler *)handler {
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}


- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
    [_parent clearAuthenticationCredentials:channel];
    [[_parent listener] connectionOpened:channel protocol:protocol];
}

- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    [_parent clearAuthenticationCredentials:channel];
    [[_parent listener] redirected:channel location:location];
}

- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    [_parent handleAuthenticationRequested:channel location:location challenge:challenge];
}

/**
 * This method is called when a message is received on the WebSocket
 */
-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    [[_parent listener] textmessageReceived:channel text:text];
}

-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    [[_parent listener] messageReceived:channel buffer:buf];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason {
    [_parent clearAuthenticationCredentials:channel];
    [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [_parent clearAuthenticationCredentials:channel];
    [[_parent listener] connectionClosed:channel  exception:ex];
}

- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [_parent clearAuthenticationCredentials:channel];
    [[_parent listener] connectionFailed:channel exception:ex];
}
@end


@implementation KGWebSocketNativeAuthenticationHandler

-(void) handleAuthenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
#ifdef DEBUG
    NSLog(@"KGWebSocketNativeAuthenticationHandler handleAuthenticationRequested");
#endif
    channel.authenticationReceived = YES;
    
    //get server location
    KGWSURI * serverURI;
    KGWebSocketNativeChannel *ch = (KGWebSocketNativeChannel *)channel;
    KGWebSocketCompositeChannel *compChannel = (KGWebSocketCompositeChannel *) [channel parent];
    KGResumableTimer *connectTimer = nil;

    if (compChannel != nil) {
        connectTimer = [compChannel connectTimer];
        if (connectTimer != nil) {
            [connectTimer pause];
        }
    }

    if ([ch redirectUri] != nil) {
        //this connection has been redirected
        serverURI = [ch redirectUri];
    }
    else {
        serverURI =  [channel location];
    }
    
    //handle handshake 401 - use original url as KGChallengeHandler lookup
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //run challenge handler in background thread
    KGChallengeRequest * challengeRequest = [[KGChallengeRequest alloc] initWithLocation:[serverURI description] challenge:challenge];
    @try {
        channel.challengeResponse = [KGAuthenticationUtil challengeResponse:channel challengeRequest:challengeRequest challengeResponse:channel.challengeResponse];
        
    } @catch (id e) {
        [self clearAuthenticationCredentials:channel];
        [self doError:channel];
        //throw new IllegalStateException("Unexpected error processing challenge: "+challengeRequest, e);
        return;
    }
    
    if (channel.challengeResponse ==nil || [channel.challengeResponse credentials] == nil) {
        [self doError:channel];
        //throw new IllegalStateException("No response possible for challenge");
        return;
    }

    NSString* authResponse = [channel.challengeResponse credentials];
    if (authResponse == nil) {
        [self doError:channel];
    }

    if (connectTimer != nil) {
        [connectTimer resume];
    }

    [self processAuthorize:channel authorizeToken:authResponse];
    [self clearAuthenticationCredentials:channel];
    //});
}

-(void) doError:(KGWebSocketChannel *) channel {
    //LOG.entering(CLASS_NAME, "handleConnectionClosed");
    [[self nextHandler] processClose:channel code:1006 reason:NULL];
    [[self listener] connectionClosed:channel wasClean:NO code:1006 reason:NULL];
}


-(void) clearAuthenticationCredentials:(KGWebSocketChannel *) channel {
    KGChallengeHandler * nextChallengeHandler = nil;
    if ([channel challengeResponse] != nil) {
        nextChallengeHandler = [[channel challengeResponse]nextChallengeHandler];
        [[channel challengeResponse] clearCredentials];
        // prevent leak in case challengeResponse below throws an exception
        channel.challengeResponse = nil;
    }
    [channel setChallengeResponse: [[KGChallengeResponse alloc] initWithCredentials:nil nextChallengeHandler:nextChallengeHandler]];
}

- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    _nextHandler = handler;
    id<KGWebSocketHandlerListener> listnerImpl =
    [[KGNativeAuth_WebSocketHandlerListener_1 alloc] initWithWebSocketNativeAuthenticationHandler:self];
    [_nextHandler setListener:listnerImpl];
}




@end
