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

#import "KGWebSocketDelegate.h"
#import "KGByteBuffer.h"
#import "KGChallengeHandler.h"

@class KGWebSocketFactory;

typedef enum {
    KGReadyState_CONNECTING   = 0,
    KGReadyState_OPEN         = 1,
    KGReadyState_CLOSING      = 2,
    KGReadyState_CLOSED       = 3,
} KGReadyState;

/**
 * The KGWebSocket provides the API for creating and managing a WebSocket 
 * connection, as well as sending and receiving data on the connection.
 *
 * Refer to http://www.w3.org/TR/websockets/ for the published 
 * standard W3C WebSocket API specification.
 *
 * KGWebSocket's delegate methods - defined by KGWebSocketDelegate protocol 
 * allows an object to define callbacks for events such as connection opened, 
 * message received, connection closed, error occured. The callbacks for such 
 * events can also be provided as blocks using block properties.
 *
 */
@interface KGWebSocket : NSObject {
    @package
    NSThread       *_webSocketThread;
    bool            _done;
}

#pragma mark <Public Methods>

/**
 * The NSURL that refers to the server location.
 */
- (NSURL *) url;

/**
 * The current state of the connection. The value can be one of
 * 0(CONNECTING), 1(OPEN), 2(CLOSING), 3(CLOSED).
 */
- (KGReadyState) readyState;

/**
 * A string indicating the name of the sub-protocol the server selected.
 * this will be one of the strings specified in the protocols parameter 
 * when creating the WebSocket object.
 */
- (NSString *) negotiatedProtocol;

/**
 *
 * Gets the names of all the protocols that are enabled for this
 * connection. Returns an empty array if protocols are not enabled.
 *
 */
- (NSArray *) enabledProtocols;

/**
 * Registers the protocols to be negotiated with the server during the
 * handshake. This method must be invoked before method connect is called. 
 * If this method is invoked after a connection has been successfully
 * established, an exception is thrown.
 * 
 *
 */
- (void) setEnabledProtocols:(NSArray *)protocols;

/**
 *
 * Gets names of all the enabled extensions that have been successfully
 * negotiated between the client and the server during the initial
 * handshake.
 *
 * Returns an empty array if no extensions were negotiated between the
 * client and the server. The negotiated extensions will be a subset of the
 * enabled extensions.
 * 
 * If this method is invoked before a connection is successfully established,
 * exception is thrown.
 *
 */
- (NSArray *) negotiatedExtensions;

/**
 *
 * Gets the names of all the extensions that have been enabled for this
 * connection. The enabled extensions are negotiated between the client
 * and the server during the handshake. The names of the negotiated
 * extensions can be obtained using method negotiatedExtensions.
 * An empty array is returned if no extensions have been enabled for
 * this connection.
 *
 */
- (NSArray *) enabledExtensions;

/**
 *
 * Registers the names of all the extensions that must be negotiated between
 * the client and the server during the handshake. This method must be
 * invoked before invoking the method connect.
 *
 * If this method is invoked after connection is successfully established,
 * an exception is thrown.
 *
 * NOTE: If the required parameter is missing for any of the enabled extensions,
 *       the KGWebSocket won't be able to establish WebSocket connection and will
 *       throw exception on connect
 * 
 *
 */
- (void) setEnabledExtensions:(NSArray *)extensions;

/**
 * Establishes the websocket connection to the server.
 * It uses server url specified when creating this instance 
 * using KGWebSocketFactory.
 */
- (void) connect;

/**
 * Closes the WebSocket connection or connection attempt, if any. 
 * If the connection is already closed, this method does nothing.
 *
 */
- (void) close;

/**
 * Closes the WebSocket connection or connection attempt, if any with
 * the code specified. If the connection is already closed,
 * this method does nothing.
 *
 * @param code A numeric value indicating the status code explaining why the connection is being closed.
 *             It must equal to 1000 or in range 3000 to 4999.
 *
 * @exception NSException If code and/or reason is invalid.
 */
- (void) close:(NSInteger)code;

/**
 * Closes the WebSocket connection or connection attempt, if any with 
 * the code and reason specified. If the connection is already closed, 
 * this method does nothing.
 *
 * @param code A numeric value indicating the status code explaining why the connection is being closed. 
 *             It must equal to 1000 or in range 3000 to 4999.
 * @param reason A human-readable string explaining why the connection is closing.
 *               This string must be no longer than 123 bytes of UTF-8 text (not characters).
 *
 * @exception NSException If code and/or reason is invalid.
 */
- (void) close:(NSInteger)code reason:(NSString *)reason;

/**
 * Transmits data to the server over the WebSocket connection.
 *
 * @param data The data to send over WebSocket connection. It can either 
 *             be NSString(for text message) or NSData(for binary message)
 * @exception NSException If data type is neither than NSData nor NSString
 */
- (void) send:(id)data;

/**
 * Returns the delegate set for the receiver.
 *
 */
- (id<KGWebSocketDelegate>) delegate;

/**
 * Sets the delegate for the receiver.
 *
 * @param delegate The delegate for the receiver.
 *                 The delegate must implement the KGWebSocketDelegate protocol.
 */
- (void) setDelegate:(id<KGWebSocketDelegate>)delegate;

/**
 * Gets the KGChallengeHandler that is used during authentication
 * both at the connect-time as well as at subsequent revalidation-time that
 * occurs at regular intervals.
 *
 */
- (KGChallengeHandler *) challengeHandler;

/**
 * Sets the KGChallengeHandler that is used during authentication
 * both at the connect-time as well as at subsequent revalidation-time that
 * occurs at regular intervals.
 *
 * @param challengeHandler   KGChallengeHandler used for authentication
 */
- (void) setChallengeHandler:(KGChallengeHandler *)challengeHandler;

/**
 * Returns the SecIdentityRef object used for client certificate authentication
 *
 * @return SecIdentityRef object
 */
- (SecIdentityRef) clientIdentity;

/**
 * Sets Client Identity for SSL client certificate authentication.
 *
 * @param clientIdentity SecIdentityRef for authentication
 */
- (void) setClientIdentity:(SecIdentityRef)clientIdentity;

/**
 * Gets the connect timeout in milliseconds. The timeout will expire if
 * there is no exchange of packets(for example, 100% packet loss) while
 * establishing the connection. A timeout value of zero indicates
 * no timeout. Default connect timeout is zero.
 *
 * @return connect timeout value in milliseconds
 */
- (int) connectTimeout;

/**
 * Sets the connect timeout in milliseconds. The timeout will expire if
 * there is no exchange of packets(for example, 100% packet loss) while
 * establishing the connection. A timeout value of zero indicates
 * no timeout.
 *
 * @param connectTimeout   timeout value in milliseconds
 * @exception NSException  if the connect timeout is being set
 *                          after the connection has been established
 * @exception NSException  if connectTimeout is negative
 */
- (void) setConnectTimeout:(int)connectTimeout;


#pragma mark <Block style callbacks>

/**
 * The block to execute when WebSocket connection's readyState changes to OPEN.
 * This indicates that the connection is ready to send and receive data.
 */
@property (copy) void (^didOpen)(KGWebSocket* websocket);

/**
 * The block to execute when the connection is closed. The block takes the following arguments:<br />
 * websocket - The KGWebSocket instance that is closed<br />
 * code      - The WebSocket connection close code provided by the server<br />
 * reason    - A string indicating the reason the connection is closed<br />
 * wasClean  - Indicates whether or not the connection was cleanly closed.
 * 
 */
@property (copy) void (^didClose)(KGWebSocket* websocket, NSInteger code, NSString* reason, BOOL wasClean);

/**
 * The block to execute when an error occurs.
 *
 */
@property (copy) void (^didReceiveError)(KGWebSocket* websocket, NSError* error);

/**
 * The block to execute when a message is received from the server.
 * The data 'is' either UTF8-String (type: NSString) or binary (type: NSData)
 *
 */
@property (copy) void (^didReceiveMessage)(KGWebSocket* websocket, id data);

@end
