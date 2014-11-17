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

#import "KGChallengeRequestTest.h"
#import "KGChallengeRequest.h"
#import "RealmUtils.h"

@implementation KGChallengeRequestTest

static NSString *DEFAULT_LOCATION;

+ (void) initialize {
    DEFAULT_LOCATION = @"http://localhost:8000";
}

- (void) testNullLocation {
    id challengeRequest = [KGChallengeRequest alloc];
    XCTAssertThrowsSpecificNamed([challengeRequest initWithLocation:nil challenge:nil], NSException, NSInvalidArgumentException, @"exception expected");
}

- (void) testBasicChallenge {
    KGChallengeRequest *challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic"];
    XCTAssertEqualObjects(@"Basic", [challengeRequest authenticationScheme], @"expected Basic");
    XCTAssertNil([challengeRequest authenticationParameters], @"expected authentication parameter(s) to be nil");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic "];
    XCTAssertEqualObjects(@"Basic", [challengeRequest authenticationScheme], @"expected Basic");
    XCTAssertNil([challengeRequest authenticationParameters], @"expected authentication parameter(s) to be nil");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic AuthData"];
    XCTAssertEqualObjects(@"Basic", [challengeRequest authenticationScheme], @"expected Basic");
    XCTAssertEqualObjects(@"AuthData", [challengeRequest authenticationParameters], @"expected AuthData");
}

- (void) testRealmParameter {
    KGChallengeRequest *challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic"];
    XCTAssertNil([RealmUtils realm:challengeRequest], @"expected realm to be nil");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=missingQuotes"];
    XCTAssertNil([RealmUtils realm:challengeRequest], @"expected realm to be nil");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=\"\""];
    XCTAssertEqualObjects(@"", [RealmUtils realm:challengeRequest], @"expected realm to be empty string");
    
    challengeRequest = [[KGChallengeRequest alloc] initWithLocation:DEFAULT_LOCATION challenge:@"Basic realm=\"realmValue\""];
    XCTAssertEqualObjects(@"realmValue", [RealmUtils realm:challengeRequest], @"expected realm to be 'realmValue'");
}

@end
