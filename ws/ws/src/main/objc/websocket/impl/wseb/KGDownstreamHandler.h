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
#import "KGHandler.h"
#import "KGDownstreamChannel.h"
#import "KGDownstreamHandlerListener.h"
#import "KGHttpRequestHandlerFactory.h"

@interface KGDownstreamHandler : NSObject <KGHandler>

-(void) processProgressEvent:(KGDownstreamChannel *)channel payload:(KGByteBuffer *) payload;
-(void) processConnect:(KGDownstreamChannel *) channel uri: (KGHttpURI *)uri protocol:(NSString*) protocol;
-(void) processClose:(KGDownstreamChannel *)channel;
-(void) setListener:(id <KGDownstreamHandlerListener>)listener;
-(void) setNextHandler:(id <KGHttpRequestHandler>)handler;

- (void) downstreamOpened:(KGDownstreamChannel *)channel request:(KGHttpRequest *)request;
- (void) downstreamClosed:(KGDownstreamChannel *)channel;
- (void) downstreamFailed:(KGDownstreamChannel *)channel exception:(NSException*)exception;

// this is awful
-(id <KGHttpRequestHandler>) nextHandler;
-(id <KGDownstreamHandlerListener>)listener;
-(void) processMessage:(KGDownstreamChannel *) channel message:(KGByteBuffer *) message;
-(void) processTextMessage:(KGDownstreamChannel *) channel message:(NSString*) message;
@end
