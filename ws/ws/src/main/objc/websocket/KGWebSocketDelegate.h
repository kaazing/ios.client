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
@class KGWebSocket;

/**
 * The KGWebSocketDelegate protocol defines methods implemented by delegates of KGWebSocket 
 * objects.
 */
@protocol KGWebSocketDelegate <NSObject>

/**
 * Sent to the delegate when message is received from the server.
 *
 * @param webSocket The KGWebSocket instance sending the message.
 * @param data      The data from the server. It can be either NSString
 *                  or NSData.
 *
 */
- (void) webSocket:(KGWebSocket*)webSocket didReceiveMessage:(id)data;

/**
 * Sent to the delegate when WebSocket connection's readyState changes to OPEN.
 * This indicates that the connection is ready to send and receive data.
 *
 * @param webSocket The KGWebSocket instance sending the message.
 *
 */
- (void) webSocketDidOpen:(KGWebSocket*)webSocket;

/**
 * Sent to the delegate when WebSocket connection's readyState changes to CLOSED.
 * 
 * @param webSocket The KGWebSocket instance sending the message.
 * @param code      The WebSocket connection close code provided by the server.
 * @param reason    A string indicating the reason the server closed the connection.
 * @param wasClean  Indicates whether or not the connection was cleanly closed.
 *
 */
- (void) webSocket:(KGWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

/**
 * Sent to the delegate when error occurs.
 *
 * @param webSocket The KGWebSocket instance sending the message.
 * @param error     The error.
 *
 */
- (void) webSocket:(KGWebSocket *)webSocket didReceiveError:(NSError *)error;

@end
