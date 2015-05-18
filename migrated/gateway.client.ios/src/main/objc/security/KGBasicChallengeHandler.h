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

#import "KGChallengeHandler.h"
#import "KGLoginHandler.h"

/**
Challenge handler for Basic authentication as defined in [RFC 2617.](http://tools.ietf.org/html/rfc2617#section-2)
<p/>
This BasicChallengeHandler can be loaded and instantiated using KGChallengeHandlers load,
and registered at a location using KGDispatchChallengeHandler register.
<p/>
In addition, one can install general and realm-specific KGLoginHandler objects onto this
KGBasicChallengeHandler to assist in handling challenges associated
with any or specific realms.  This can be achieved using `setLoginHandler:(LoginHandler*)` and
`setRealmLoginHandler:(NSString *)realm loginHandler:(KGLoginHandler *)loginHandler` methods.
<p/>
The following example loads an instance of a KGBasicChallengeHandler, sets a login
handler onto it and registers the basic handler at a URI location.  In this way, all attempts to access
that URI for which the server issues "Basic" challenges are handled by the registered KGBasicChallengeHandler.

    @interface MyLoginHandler : KGLoginHandler
    @end
 
    @implementation MyLoginHandler
 
    -(NSURLCredential*) credentials {
        return [[NSURLCredential alloc] initWithUser:@"global" password:@"credentials" persistence:NSURLCredentialPersistenceNone];
    }
    @end
 
    -(void)initChallenge {
        // set up Login Handler:
        MyLoginHandler* loginHandler = [[MyLoginHandler alloc] init];
 
        KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];
        [challengeHandler setLoginHandler:loginHandler];
        
        // Attach the challenge handler as a default challenge handler to the KGWebSocketFactory
        // It can also be attached to the KGWebSocket created using [KGWebSocket setChallengeHandler:]
        [webSocketFactory setDefaultChallengeHandler:challengeHandler];
    }


see [RFC 2616 - HTTP 1.1](http://tools.ietf.org/html/rfc2616)
see [RFC 2617 Section 2 - Basic Authentication](http://tools.ietf.org/html/rfc2617#section-2)
 */
@interface KGBasicChallengeHandler : KGChallengeHandler

/**
 * Set a Login Handler to be used if and only if a challenge request has
 * a realm parameter matching the provided realm.
 *
 * @param realm  the realm upon which to apply the loginHandler.
 * @param loginHandler the login handler to use for the provided realm.
 */
-(void)setRealmLoginHandler:(NSString*)realm loginHandler:(KGLoginHandler *) loginHandler;

/**
 * Provide a general (non-realm-specific) login handler to be used in association with this challenge handler.
 * The login handler is used to assist in obtaining credentials to respond to any Basic
 * challenge requests when no realm-specific login handler matches the realm parameter of the request (if any).
 *
 * @param loginHandler a login handler for credentials.
 */
-(KGChallengeHandler *) setLoginHandler:(KGLoginHandler *) loginHandler;

/**
 * Get the general (non-realm-specific) login handler associated with this challenge handler.
 * A login handler is used to assist in obtaining credentials to respond to challenge requests.
 *
 * @return a login handler to assist in providing credentials, or nil if none has been established yet.
 */
-(KGLoginHandler *) loginHandler;

@end
