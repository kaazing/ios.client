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
 * NativeHandler - AuthenticationHandler - {HandshakeHandler} - ControlFrameHandler - BalanceingHandler - Nodec - BridgeHandler
 * Responsibilities:
 * 		a). handle kaazing handshake
 *     		if response protocol is "x-kaazing-handshake", start handshake process
 *     		otherwise, fire connectionOpened event
 *      b). process 401
 *     		if response is enveloped 401 challenge, fire a authenticationRequested event
 * TODO:
 * 		a). add more hand shake objects in the future 
 */
@interface KGWebSocketNativeHandshakeHandler : KGWebSocketHandlerAdapter
-(void)handletextMessageReceived:(KGWebSocketChannel *)channel text:(NSString *)text;
-(void) handleMessageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf;
-(void) sendHandshakePayload:(KGWebSocketChannel *) channel authToken:(NSString*) authToken;

@end
