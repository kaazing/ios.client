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

#import "KGWebSocketFactoryTest.h"
#import "KGWebSocketFactory.h"
#import "KGBasicChallengeHandler.h"

@implementation KGWebSocketFactoryTest

- (void) testInit {
    id webSocketFactory = [KGWebSocketFactory alloc];
    XCTAssertThrowsSpecificNamed([webSocketFactory init], NSException, NSInternalInconsistencyException, @"call to init on KGWebSocketFactory should throw exception");
}

- (void) testChallengeHandlerIsInherited {
    KGWebSocketFactory *factory = [KGWebSocketFactory createWebSocketFactory];
    KGChallengeHandler *challengeHandler = [KGBasicChallengeHandler create];
    [factory setDefaultChallengeHandler:challengeHandler];
    NSURL *dummyUrl = [NSURL URLWithString:@"ws://localhost:8001/echo"];
    KGWebSocket *webSocket = [factory createWebSocket:dummyUrl];
    KGChallengeHandler *inheritedChallengeHandler = [webSocket challengeHandler];
    XCTAssertEqual(challengeHandler, inheritedChallengeHandler, @"websocket should inherit the challenge handler set in corresponding websocket factory");
}

@end
