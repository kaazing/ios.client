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

#import "KGWebSocketSelectedChannel.h"
#import "KGCreateChannel.h"
#import "KGDownstreamChannel.h"

@class KGUpstreamChannel;

@interface KGWebSocketEmulatedChannel : KGWebSocketSelectedChannel

// ctor:
-(id)initWithLocation:(KGWSURI *)location binary:(BOOL)isBinary;

// package private
-(void) setCreateChannel:(KGCreateChannel *)createChannel;
-(KGCreateChannel *)createChannel;
-(void) setUpstreamChannel:(KGUpstreamChannel *)upstreamChannel;
-(KGUpstreamChannel *)upstreamChannel;
-(void) setDownstreamChannel:(KGDownstreamChannel *)downstreamChannel;
-(KGDownstreamChannel *)downstreamChannel;

-(void) setRedirectUri:(KGHttpURI *) redirectUri;
-(KGHttpURI *) redirectUri;

//protected:
-(void) setCookie:(NSString*)cookie;
-(NSString*) cookie;

@end
