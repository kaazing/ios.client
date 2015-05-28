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

#import "TestUtil.h"

@implementation TestUtil

// The function is used to retry the verify until the time specified in delay is reached.
// This is useful when tryin to unit test in scenarios where we are expecting an asynchronous callback
// to be executed.
+ (void) waitForVerifiedMock:(id)mockObject delay:(NSTimeInterval)delay {
    NSTimeInterval i = 0;
    while (i < delay) {
        @try {
            [mockObject verify];
            break;
        }
        @catch (NSException *exception) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            i += 0.5;
        }
    }
}

@end
