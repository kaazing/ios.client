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
#import "KGChallengeHandler.h"

@class KGChallengeHandler;

/**
 * A challenge response contains a character array representing the response to the server,
 * and a reference to the next challenge handler to handle any further challenges for the request.
 *
 */
@interface KGChallengeResponse : NSObject

/**
 * Constructor from a set of credentials to send to the server in an 'Authorization:' header
 * and the next challenge handler responsible for handling any further challenges for the request.
 *
 * @param credentials a set of credentials to send to the server in an 'Authorization:' header
 * @param nextChallengeHandler the next challenge handler responsible for handling any further challenges for the request.
 */
-(id) initWithCredentials:(NSString*) credentials nextChallengeHandler:(KGChallengeHandler *)nextChallengeHandler;

/**
 * Return a set of credentials to send to the server in an 'Authorization:' header.
 *
 * @return a set of credentials to send to the server in an 'Authorization:' header.
 */
-(NSString*) credentials;

/**
 * Establish the credentials for this response.
 *
 * @param credentials the credentials to be used for this challenge response.
 */
-(void) setCredentials:(NSString*) credentials;

/**
 * Return the next challenge handler responsible for handling any further challenges for the request.
 *
 * @return the next challenge handler responsible for handling any further challenges for the request.
 */
-(KGChallengeHandler *) nextChallengeHandler;

/**
 * Establish the next challenge handler responsible for handling any further challenges for the request.
 *
 * @param nextChallengeHandler the next challenge handler responsible for handling any further challenges for the request.
 */
-(void) setNextChallengeHandler:(KGChallengeHandler *) nextChallengeHandler;

/**
 * Clear the credentials of this response.
 * <p/>
 * Calling this method once the credentials have been communicated to the network layer
 * protects credentials in memory.
 */
-(void) clearCredentials;

@end
