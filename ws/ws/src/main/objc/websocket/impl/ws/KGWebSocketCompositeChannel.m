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

#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocketSelectedChannel.h"

@implementation KGWebSocketCompositeChannel {
    __weak NSObject                     *_webSocket;
    __weak KGWebSocketSelectedChannel   *_selectedChannel;

    NSArray                      *_requestedProtocols;
    NSString                     *_compositeScheme;
    KGWebSocketFactory           *_factory;
    KGReadyState                  _readyState;
    BOOL                          _closing;
    KGChallengeHandler           *_challengeHandler;
    KGResumableTimer             *_connectTimer;
}

- (void) dealloc {
    if (_selectedChannel != nil) {
        [_selectedChannel setParent:nil];
    }
    
    if (_connectionStrategies != nil) {
        [_connectionStrategies removeAllObjects];
        _connectionStrategies = nil;
    }

    _webSocket = nil;
    _compositeScheme = nil;
    _selectedChannel = nil;
    _factory = nil;
    
    if (_connectionStrategies != nil) {
        [_connectionStrategies removeAllObjects];
        _connectionStrategies = nil;
    }
    
    if (_connectTimer != nil) {
        [_connectTimer cancel];
    }
    _connectTimer = nil;
    _challengeHandler = nil;
}

- (void) init0 {
    _readyState = KGReadyState_CLOSED;
    _closing = NO;
    _connectionStrategies = [[NSMutableArray alloc] init ];
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

// "Constructor"
-(id) initWithLocation:(KGWSCompositeURI *)location
                binary:(BOOL)isBinary {
    self = [self initWithLocation:location
                           binary:isBinary 
                          factory:nil];
    return self;
}

-(id) initWithLocation:(KGWSCompositeURI *)location 
                binary:(BOOL)isBinary 
               factory:(KGWebSocketFactory *)factory {
    self = [self init];
    if (self) {
        self = [super initWithLocation:[location WSEquivalent]
                                binary:isBinary];
        _compositeScheme = [location scheme];
        _factory = factory;
    }
    return self;

}

-(KGReadyState) readyState {
    return _readyState;
}

-(void) setReadyState:(KGReadyState) readyState {
    _readyState = readyState;
}

-(BOOL) closing {
    return _closing;
}

-(void) setClosing:(BOOL)closing{
    _closing = closing;
}

-(void) setWebSocket:(NSObject*)webSocket {
    _webSocket = webSocket;
}

-(KGWebSocket*) webSocket {
    return (KGWebSocket*)_webSocket;
}

-(NSObject*) byteSocket {
    return _webSocket;    
}

-(NSURL*) URL {
    return [[self location] URI];
    
}

- (KGWebSocketFactory *) factory {
    return _factory;
}

-(KGWebSocketSelectedChannel *) selectedChannel {
    return _selectedChannel;
}

-(void)setSelectedChannel:(KGWebSocketSelectedChannel *)selectedChannel {
    _selectedChannel = selectedChannel;
}

-(void) addConnectionStrategy:(NSString*)scheme {
    [_connectionStrategies addObject:scheme];
}

-(NSString*) compositeScheme {
    return _compositeScheme;
}

-(NSString*) nextStrategy {
    if (_connectionStrategies == nil || [_connectionStrategies count] == 0) {
        return nil;
    }
    else {
        NSString* strat = [_connectionStrategies objectAtIndex:0];
        // remove it...:
        [_connectionStrategies removeObjectAtIndex:0];
        return strat;
    }
}

- (void) setRequestedProtocols:(NSArray *)requestedProtocols {
    _requestedProtocols = [NSArray arrayWithArray:requestedProtocols];
}

- (NSArray *) requestedProtocols {
    return [NSArray arrayWithArray:_requestedProtocols];
}

- (KGChallengeHandler *) challengeHandler {
    return _challengeHandler;
}

- (void) setChallengeHandler:(KGChallengeHandler *)challengeHandler {
    _challengeHandler = challengeHandler;
}

- (KGResumableTimer *) connectTimer {
    return _connectTimer;
}

- (void) setConnectTimer:(KGResumableTimer *)connectTimer {
    if (_connectTimer != nil) {
        [_connectTimer cancel];
        _connectTimer = nil;
    }
    
    _connectTimer = connectTimer;
}
@end
