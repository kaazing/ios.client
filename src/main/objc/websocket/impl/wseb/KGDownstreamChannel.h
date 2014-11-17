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

#import <Foundation/Foundation.h>
#import "KGChannel.h"
#import "KGHttpURI.h"
#import "KGWebSocketEmulatedDecoder.h"

@interface KGDownstreamChannel : KGChannel
// fields:
@property (nonatomic, copy) KGHttpURI * location;
@property (nonatomic, copy) NSString* protocol;

// ctor::
- (id) initWithLocation:(KGHttpURI *) location cookie:(NSString*)cookie;

- (KGWebSocketEmulatedDecoder *) decoder;
- (void) setClientIdentity:(SecIdentityRef) clientIdenity;
- (SecIdentityRef) clientIdentity;
- (int) idleTimeout;
- (void) setIdleTimeout:(int)idleTimeout;
- (long long) lastMessageTimestamp;
- (void) setLastMessageTimestamp:(long long)timestamp;
- (NSTimer *) idleTimer;
- (void) setIdleTimer:(NSTimer *)timer;
@end
