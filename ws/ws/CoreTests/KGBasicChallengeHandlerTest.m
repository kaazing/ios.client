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

#import "KGBasicChallengeHandlerTest.h"
#import "KGDispatchChallengeHandler.h"
#import "KGBasicChallengeHandler.h"
#import "KGTestLoginHandler.h"

@interface SecondLoginHandler : KGLoginHandler
@end

@implementation SecondLoginHandler
-(void)dealloc {
    
}

- (id)init {
    self = [super init];
    return self;
}


-(NSURLCredential*) credentials {
    return [[NSURLCredential alloc] initWithUser:@"joe2" password:@"welcome2" persistence:NSURLCredentialPersistenceNone];
}
@end


@implementation KGBasicChallengeHandlerTest {
    KGBasicChallengeHandler      *_basicChallengeHandler;
    KGDispatchChallengeHandler   *_dispatchChallengeHandler;
    KGLoginHandler               *_loginHandler;
    KGLoginHandler               *_secondLoginHandler;
}

static NSString *DEFAULT_LOCATION;

+ (void) initialize {
    DEFAULT_LOCATION = @"http://localhost:8000";
}

- (void) setUp {
    _dispatchChallengeHandler = [KGDispatchChallengeHandler create];
    _basicChallengeHandler    = [KGBasicChallengeHandler create];
    _loginHandler             = [[KGTestLoginHandler alloc] init];
    _secondLoginHandler      = [[SecondLoginHandler alloc] init];
}

- (void) testShouldAlwaysHandleABasicRequestIfBasicChallengeHandlerIsRegistered {
    [_basicChallengeHandler setLoginHandler:_loginHandler]; 
    [_basicChallengeHandler setRealmLoginHandler:@"Test Realm" loginHandler:_secondLoginHandler];
    [_dispatchChallengeHandler registerChallengeHandler:DEFAULT_LOCATION challengeHandler:_basicChallengeHandler];
    
    KGChallengeRequest *challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic"];
    XCTAssertTrue([_dispatchChallengeHandler canHandle:challengeRequest], @"DispatchChallengeHandler should be able to handler the challenge for DEFAULT_LOCATION");
    KGChallengeResponse *challengeResponse = [_dispatchChallengeHandler handle:challengeRequest];
    NSString *credentials = [challengeResponse credentials];
    XCTAssertEqualObjects(@"Basic am9lOndlbGNvbWU=", credentials, @"credentials should have been 'Basic am9lOndlbGNvbWU='");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=\"Not matching\""];
    XCTAssertTrue([_dispatchChallengeHandler canHandle:challengeRequest], @"DispatchChallengeHandler should be able to handler the challenge for DEFAULT_LOCATION");
    challengeResponse = [_dispatchChallengeHandler handle:challengeRequest];
    credentials = [challengeResponse credentials];
    XCTAssertEqualObjects(@"Basic am9lOndlbGNvbWU=", credentials, @"credentials should have been 'Basic am9lOndlbGNvbWU='");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=\"Test Realm\""];
    XCTAssertTrue([_dispatchChallengeHandler canHandle:challengeRequest], @"DispatchChallengeHandler should be able to handler the challenge for DEFAULT_LOCATION");
    challengeResponse = [_dispatchChallengeHandler handle:challengeRequest];
    credentials = [challengeResponse credentials];
    
    // NOTE: we should be encoding joe2/welcome2 because the realm handler is handling it
    //       using the loginHandler2.
    XCTAssertEqualObjects(@"Basic am9lMjp3ZWxjb21lMg==", credentials, @"credentials should have been 'Basic am9lMjp3ZWxjb21lMg=='");
}

- (void) testShouldOnlyHandleRealmSpecificRequestsWithRealmSpecificRegisteredHandler {
    [_basicChallengeHandler setLoginHandler:nil];
    [_basicChallengeHandler setRealmLoginHandler:@"Test Realm" loginHandler:_secondLoginHandler];
    [_dispatchChallengeHandler registerChallengeHandler:DEFAULT_LOCATION challengeHandler:_basicChallengeHandler];
    
    KGChallengeRequest *challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic"];
    XCTAssertTrue([_dispatchChallengeHandler canHandle:challengeRequest], @"DispatchChallengeHandler should be able to handler the challenge for DEFAULT_LOCATION");
    KGChallengeResponse *challengeResponse = [_dispatchChallengeHandler handle:challengeRequest];
    XCTAssertNil(challengeResponse, @"challenge response should be nil");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=\"Not matching\""];
    XCTAssertTrue([_dispatchChallengeHandler canHandle:challengeRequest], @"DispatchChallengeHandler should be able to handler the challenge for DEFAULT_LOCATION");
    challengeResponse = [_dispatchChallengeHandler handle:challengeRequest];
    XCTAssertNil(challengeResponse, @"challenge response should be nil");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=\"Test Realm\""];
    XCTAssertTrue([_dispatchChallengeHandler canHandle:challengeRequest], @"DispatchChallengeHandler should be able to handler the challenge for DEFAULT_LOCATION");
    challengeResponse = [_dispatchChallengeHandler handle:challengeRequest];
    NSString *credentials = [challengeResponse credentials];
    
    // NOTE: we should be encoding joe2/welcome2 because the realm handler is handling it
    //       using the loginHandler2.
    XCTAssertEqualObjects(@"Basic am9lMjp3ZWxjb21lMg==", credentials, @"credentials should have been 'Basic am9lMjp3ZWxjb21lMg=='");
}

@end
