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
#import "KGWebSocketFactory.h"
#import "KGWebSocketHandshakeObject.h"
#import "KGWebSocket+Internal.h"

@implementation KGWebSocketFactory {
    NSMutableArray      *_defaultEnabledExtensions;
    KGChallengeHandler  *_defaultChallengeHandler;
    SecIdentityRef      _clientIdentity;
    int                 _connectTimeout; // milliseconds
}

- (id) init {
    NSString *msg = @"init is not a valid initializer for KGWebSocketFactory. Please use static method sharedInstance.";
    NSException *exception = [NSException exceptionWithName: @"NSInternalInconsistencyException"
                                                     reason: msg
                                                   userInfo: nil];
    @throw exception;  
}

#pragma mark <Private Initializer>
- (id) initInternal {
    self = [super init];
    if (self) {
        _connectTimeout = 0;
    }
    return self;
}

- (void) dealloc {

}

#pragma mark <Public Methods>
+ (KGWebSocketFactory *) createWebSocketFactory {
    return [[KGWebSocketFactory alloc] initInternal];
}

- (KGWebSocket *) createWebSocket:(NSURL *)url {
    return [self createWebSocket:url protocols:nil];
}

- (KGWebSocket *) createWebSocket:(NSURL *)url protocols:(NSArray *)protocols {
    KGWebSocket *webSocket = [[KGWebSocket alloc] initWithURL:url
                                            enabledExtensions:_defaultEnabledExtensions
                                             enabledProtocols:protocols
                                            challengeHandler:_defaultChallengeHandler
                                               clientIdentity:_clientIdentity
                                               connectTimeout:_connectTimeout];
    [webSocket setHandler:[KGWebSocketCompositeHandler compositeHandler]];
    return webSocket;
}

- (NSArray *) defaultEnabledExtensions {
    return [NSArray arrayWithArray:_defaultEnabledExtensions];
}

- (void) setDefaultEnabledExtensions:(NSArray *)extensions {
    if (extensions == nil) {
        _defaultEnabledExtensions = nil;
        return;
    }
    
    if (_defaultEnabledExtensions == nil) {
        _defaultEnabledExtensions = [[NSMutableArray alloc] init];
    }
    
    [_defaultEnabledExtensions addObjectsFromArray:extensions];
}

- (KGChallengeHandler *) defaultChallengeHandler {
    return _defaultChallengeHandler;
}


- (void) setDefaultChallengeHandler:(KGChallengeHandler *)challengeHandler {
    _defaultChallengeHandler = challengeHandler;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}

- (void) setClientIdentity:(SecIdentityRef)clientIdentity {
    _clientIdentity = clientIdentity;
}

- (int) defaultConnectTimeout {
    return _connectTimeout;
}

- (void) setDefaultConnectTimeout:(int)connectTimeout; {
    if (connectTimeout < 0) {
        NSException *exception = [[NSException alloc] initWithName:@"NSInvalidArgumentException"
                                                            reason:@"Connect timeout cannot be negative"
                                                          userInfo:nil];
        @throw exception;
    }
    
    _connectTimeout = connectTimeout;
}

@end
