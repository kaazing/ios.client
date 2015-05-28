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

#import "KGAuthenticateEvent.h"
#import "KGCloseEvent.h"
#import "KGErrorEvent.h"
#import "KGMessageEvent.h"
#import "KGOpenEvent.h"
#import "KGRedirectEvent.h"

// package org.kaazing.gateway.client.transport.ws

// public
@protocol KGWebSocketDelegateListener <NSObject>
// package private
- (void) authenticationRequested:(KGAuthenticateEvent *)authenticateEvent;

// package private
- (void) opened:(KGOpenEvent *)event;

// package private
- (void) redirected:(KGRedirectEvent *)redirectEvent;

// package private
- (void) messageReceived:(KGMessageEvent *)messageEvent;

// package private
- (void) closed:(KGCloseEvent *)event;

// package private
- (void) errorOccurred:(KGErrorEvent *)event;

@end
