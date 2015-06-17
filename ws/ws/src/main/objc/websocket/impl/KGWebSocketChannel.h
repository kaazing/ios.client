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
#import "KGWebSocketHandler.h"
#import "KGByteBuffer.h"
#import "KGWSURI.h"
#import "KGWebSocketExtension.h"

extern int nextId;
@interface KGWebSocketChannel : KGChannel

// "Constructor"
- (id) initWithLocation:(KGWSURI *)location binary:(BOOL)isBinary;

- (int) bufferedAmount;

- (void) setLocation:(KGWSURI *)location;
- (KGWSURI *) location;

- (void) setProtocol:(NSString*)protocol;
- (NSString*) protocol;

- (NSString *) enabledExtensions;
- (void) setEnabledExtensions:(NSString *)extensions;

- (NSString *) negotiatedExtensions;
- (void) setNegotiatedExtensions:(NSString *)extensions;

- (NSArray *) extensionPipeline;
- (void) addExtensionToPipeline:(KGWebSocketExtension *)extension;

- (BOOL) isBinary;

- (void) setHandshakePayload:(NSString*) handshakePayload;
- (NSString*) handshakePayload;

- (void) setTransportHandler:(id<KGWebSocketHandler>) handler;
- (id<KGWebSocketHandler>) transportHandler;
  
- (int) _id;

- (void) setClientIdentity:(SecIdentityRef) clientIdenity;
- (SecIdentityRef) clientIdentity;

@end
