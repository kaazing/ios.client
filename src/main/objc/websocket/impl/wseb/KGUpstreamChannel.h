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

#import "KGChannel.h"
#import "KGHttpURI.h"
#import "KGHttpRequest.h"
@class KGWebSocketEmulatedChannel;

@interface KGUpstreamChannel : KGChannel

// fields:
@property (nonatomic, retain) KGHttpURI * location;
@property (nonatomic, retain) NSString* cookie;
@property (nonatomic, retain) NSMutableArray * sendQueue;
@property (atomic) BOOL sendInFlight;
@property (nonatomic, retain) KGHttpRequest * request;
@property (nonatomic, retain) KGWebSocketEmulatedChannel * parent;

// methods:
- (id) initWithLocation:(KGHttpURI *) location cookie:(NSString*)cookie;

- (void) setClientIdentity:(SecIdentityRef) clientIdenity;
- (SecIdentityRef) clientIdentity;

@end
