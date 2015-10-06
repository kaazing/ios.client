/**
 * Copyright 2007-2015, Kaazing Corporation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <Foundation/Foundation.h>
#import "KGWebSocketExtension.h"
#import "KGWebSocket.h"

/**
 * KGWebSocketFactory is used to create KGWebSocket instance(s) by specifying 
 * the end-point and the enabled protocols.
 * 
 * Using KGWebSocketFactory instance, application developers can set
 * KGWebSocketParameter that will be inherited by all the KGWebSocket instances 
 * created from the factory. Application developers can override the parameter(s) 
 * at the individual KGWebSocket level too.
 */
@interface KGWebSocketFactory : NSObject

/**
 * Creates a KGWebSocket to establish a full-duplex connection to the
 * target location.
 * 
 * The default extension parameters that were set on the KGWebSocketFactory 
 * prior to this call are inherited by the newly created KGWebSocket instance.
 */
+ (KGWebSocketFactory *) createWebSocketFactory;


/**
 * Creates a KGWebSocket to establish a full-duplex connection to the
 * target location.
 * 
 * The default extension parameters that were set on the
 * KGWebSocketFactory prior to this call are inherited by the newly
 * newly created KGWebSocket instance.
 *
 * @param location    NSURL to server
 *
 * @exception NSException If the scheme is invalid
 */
- (KGWebSocket *) createWebSocket:(NSURL *)url;

/**
 * Creates a KGWebSocket to establish a full-duplex connection to the
 * target location.
 *
 * The default extension parameters that were set on the
 * KGWebSocketFactory prior to this call are inherited by the newly
 * newly created KGWebSocket instance.
 *
 * @param location    URI of the WebSocket service for the connection
 * @param protocols   protocols to be negotiated over the WebSocket
 *
 * @exception NSException If the scheme is invalid
 *
 */
- (KGWebSocket *) createWebSocket:(NSURL *)url protocols:(NSArray *)protocols;

/**
 * Gets the names of the default enabled extensions that will be inherited
 * by all the KGWebSocket objectes created using this factory. These
 * extensions are negotiated between the client and the server during the
 * WebSocket handshake only if all the required parameters belonging to the
 * extension have been set as enabled parameters. An empty Collection is
 * returned if no extensions have been enabled for this factory.
 *
 */
- (NSArray *) defaultEnabledExtensions;

/**
 * Registers the names of all the default enabled extensions to be inherited
 * by all the KGWebSocket objects created using this factory. The extensions
 * will be negotiated between the client and the server during the WebSocket
 * handshake if all the required parameters belonging to the extension have
 * been set.
 *
 * @warning If the required parameter is missing for any of the enabled extension, 
 *       the KGWebSocket created won't be able to connect and will throw exception
 *       on [KGWebSocket connect]
 * 
 */
- (void) setDefaultEnabledExtensions:(NSArray *)extensions;

/**
 * Gets the default KGChallengeHandler that is used during
 * authentication both at the connect-time as well as at subsequent
 * revalidation-time that occurs at regular intervals.
 *
 */
- (KGChallengeHandler *) defaultChallengeHandler;

/**
 * Sets the default KGChallengeHandler that is used during
 * authentication both at the connect-time as well as at subsequent
 * revalidation-time that occurs at regular intervals. All the
 * KGWebSocket instances created using this factory will inherit 
 * the default ChallengeHandler.
 */
- (void) setDefaultChallengeHandler:(KGChallengeHandler *)challengeHandler;

/**
 * Returns the SecIdentityRef object used for client certificate authentication
 *
 * @return SecIdentityRef object
 */
- (SecIdentityRef) clientIdentity;

/**
 * Sets Client Identity for SSL client certificate authentication.
 * The Client Identity set in KGWebSocketFactory will be inherited by 
 * the KGWebSocket created from this factory.
 *
 * @param clientIdentity SecIdentityRef for authentication
 */
- (void) setClientIdentity:(SecIdentityRef)clientIdentity;

/**
 * Gets the default connect timeout in milliseconds. Default value of the
 * default connect timeout is zero -- which means no timeout.
 *
 * @return default connect timeout value in milliseconds
 */
- (int) defaultConnectTimeout;

/**
 * Sets the default connect timeout in milliseconds. The specified
 * timeout is inherited by all the WebSocket instances that are created
 * using this WebSocketFactory instance. The timeout will expire if there is
 * no exchange of packets(for example, 100% packet loss) while establishing
 * the connection. A timeout value of zero indicates no timeout.
 *
 * @param connectTimeout    timeout value in milliseconds
 * @exception NSInvalidArgumentException if connectTimeout is negative
 */
- (void) setDefaultConnectTimeout:(int)connectTimeout;
@end
