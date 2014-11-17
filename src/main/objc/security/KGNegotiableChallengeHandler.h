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
 * A NegotiableChallengeHandler can be used to directly respond to
 * "Negotiate" challenges, and in addition, can be used indirectly in conjunction
 * with a KGNegotiateChallengeHandler
 * to assist in the construction of a challenge response using object identifiers.
 *
 * see [RFC 4178 Section 4.2.1](http://tools.ietf.org/html/rfc4178#section-4.2.1) for details
 *      about how the supported object identifiers contribute towards the initial context token in the challenge response.
 *
 * <p/>
 *
 */
@interface KGNegotiableChallengeHandler : KGChallengeHandler

/**
 * Return a collection of string representations of object identifiers
 * supported by this challenge handler implementation, in dot-separated notation.
 * For example, {1.3.5.1.5.2}.
 *
 * @return a collection of string representations of object identifiers
 *         supported by this challenge handler implementation.
 */
-(NSArray *) supportedOids;

/**
 * Provide a general login handler to be used in association with this challenge handler.
 * The login handler is used to assist in obtaining credentials to respond to any
 * challenge requests when this challenge handler handles the request.
 *
 * @param loginHandler a login handler for credentials.
 *
 * @return this challenge handler object, to support chained calls
 */
-(KGNegotiableChallengeHandler *) setLoginHandler:(KGLoginHandler *) loginHandler;

/**
 * Get the general login handler associated with this challenge handler.
 * A login handler is used to assist in obtaining credentials to respond to challenge requests.
 *
 * @return a login handler to assist in providing credentials, or `nil` if none has been established yet.
 */
-(KGLoginHandler *) loginHandler;

@end
