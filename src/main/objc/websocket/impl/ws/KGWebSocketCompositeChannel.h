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

#import "KGWebSocketChannel.h"
#import "KGWebSocketSelectedChannel.h"
#import "KGWSCompositeURI.h"
#import "KGWebSocketFactory.h"
#import "KGResumableTimer.h"

@interface KGWebSocketCompositeChannel : KGWebSocketChannel {
    @protected
    NSMutableArray * _connectionStrategies;
}

// "Constructor"
- (id) initWithLocation:(KGWSCompositeURI *)location
                binary:(BOOL)isBinary;

- (id) initWithLocation:(KGWSCompositeURI *)location
                binary:(BOOL)isBinary 
               factory:(KGWebSocketFactory *)delegate;

- (KGReadyState) readyState;

- (void) setReadyState:(KGReadyState)readyState;

- (BOOL) closing;

- (void) setClosing:(BOOL)closing;

- (void) setWebSocket:(NSObject*)webSocket;

- (KGWebSocket*) webSocket;

- (NSObject*) byteSocket;

- (NSURL*) URL;

- (KGWebSocketFactory *) factory;

- (NSString*) compositeScheme;

- (NSString*) nextStrategy;

- (void) addConnectionStrategy:(NSString*)scheme;

- (KGWebSocketSelectedChannel *) selectedChannel;

- (void) setSelectedChannel:(KGWebSocketSelectedChannel *)selectedChannel;

- (void) setRequestedProtocols:(NSArray *)requestedProtocols;

- (NSArray *) requestedProtocols;

- (KGChallengeHandler *) challengeHandler;

- (void) setChallengeHandler:(KGChallengeHandler *)challengeHandler;

- (KGResumableTimer *) connectTimer;

- (void) setConnectTimer:(KGResumableTimer *)connectTimer;
@end
