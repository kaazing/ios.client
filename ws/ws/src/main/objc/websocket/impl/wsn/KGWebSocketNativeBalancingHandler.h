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

#import "KGWebSocketHandlerAdapter.h"

/*
 * WebSocket Native KGHandler Chain
 * NativeHandler - AuthenticationHandler - HandshakeHandler - {BalancingHandler} - Codec - BridgeHandler
 * Responsibilities:
 *     a) handle balancer messages
 *     		balancer message is the first message after connection is established
 *     		if message is "\uf0ff" + 'N' - fire connectionOpen event
 *     		if message is "\uf0ff" + 'R' + redirectURl - start reConnect process
 *
 * 	  b) server will remove balancer message. instead, server will sent a 'HTTP 301' to redirect client
 * 			client needs to change accordingly  
 */
@interface KGWebSocketNativeBalancingHandler : KGWebSocketHandlerAdapter

- (void) reconnect:(KGWebSocketChannel *) channel uri:(KGWSURI *) uri protocol:(NSString*) protocol;
- (void) handleBinaryMessageReceived:(KGWebSocketChannel *) channel message:(KGByteBuffer *) message;
- (void) handleTextMessageReceived:(KGWebSocketChannel *) channel message:(NSString*) message;

@end
