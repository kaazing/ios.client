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

#import "KGChannel.h"
#import <libkern/OSAtomic.h>

@implementation KGChannel {
    KGChannel * _parent;
    KGChallengeResponse * _challengeResponse;
    BOOL _authenticationReceived;
    long long _sequence;
}

- (void) init0 {
    // Top level class - no reason to call [super init0]
    _challengeResponse = [[KGChallengeResponse alloc] init];
    _authenticationReceived = NO;
    _sequence = 0;
}

- (id)init {
    self = [super init];
    if (self) {
        // Only Top level class should call init0
        [self init0];
    }
    return self;
}

- (id) initWithSequence:(long long)sequence {
    self = [self init];
    if (self) {
        _sequence = sequence;
    }
    return self;
}

- (void)dealloc {
    _parent = nil;
    _challengeResponse = nil;
}

-(void)setAuthenticationReceived:(BOOL) authenticationReceived {
    _authenticationReceived = authenticationReceived;
}

-(BOOL)authenticationReceived {
    return _authenticationReceived;
}

// interface methods
-(void)setParent:(KGChannel *)parent {
    assert(_parent != self);
    _parent = parent;
}

-(KGChannel *) parent {
    return _parent;
}

-(void)setChallengeResponse:(KGChallengeResponse *)challengeResponse {
    _challengeResponse = challengeResponse;
}

-(KGChallengeResponse *)challengeResponse {
    return _challengeResponse;
}

- (long long) nextSequence {
    OSAtomicIncrement64(&_sequence);
    return _sequence;
}

- (long long) currentSequence {
    return _sequence;
}

@end
