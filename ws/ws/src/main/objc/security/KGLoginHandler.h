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

/**
 * A login handler is responsible for obtaining credentials from an arbitrary source.
 *
 * Login Handlers can be associated with one or more KGChallengeHandler
 * objects, to ensure that when a Challenge Handler requires credentials for a KGChallengeResponse,
 * the work is delegated to a KGLoginHandler.
 *
 * At client configuration time, a KGLoginHandler can be associated with a KGChallengeHandler as follows:
 
      `MyLoginHandler* loginHandler = [[MyLoginHandler alloc] init];
       KGBasicChallengeHandler* challengeHandler = [KGBasicChallengeHandler create];
       [challengeHandler setLoginHandler:loginHandler];
 
       @interface MyLoginHandler : KGLoginHandler
       @end
 
       @implementation MyLoginHandler {
           int counter;
       }
 
       - (id)init {
           NSLog(@"[MyLoginHandler init]");
           self = [super init];
           if (self) {
               counter = 0;
           }
           return self;
       }
 
       -(NSURLCredential*) credentials {
           NSLog(@"providing incorrect credential");
           if (counter++ < 3) {
               return [[NSURLCredential alloc] initWithUser:@"joe" password:@"NOT - welcome"
                      persistence:NSURLCredentialPersistenceNone];
           }
          else {
              counter = 0;
              return nil;
           }
       }
       @end`
 
 */
@interface KGLoginHandler : NSObject

/**
 * Gets the password authentication credentials from an arbitrary source.
 *
 * @return the password authentication obtained.
 */
- (NSURLCredential*)credentials;

@end
