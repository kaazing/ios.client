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
#import "KGChallengeResponse.h"

@implementation KGChallengeResponse {
    NSString* _credentials;
    KGChallengeHandler * _nextChallengeHandler;

}

-(void)dealloc {
    _credentials = nil;
    _nextChallengeHandler = nil;
}
// init stuff:
- (void) init0 {
    // Initialization code here.
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}
-(id) initWithCredentials:(NSString*) credentials nextChallengeHandler:(KGChallengeHandler *)nextChallengeHandler {
    self = [self init];
    if (self) {
        _credentials = credentials;
        _nextChallengeHandler = nextChallengeHandler;
    }
    return self;
}

-(NSString*) credentials {
    return _credentials;
}
-(void) setCredentials:(NSString*) credentials {
    _credentials = credentials;
}

-(KGChallengeHandler *) nextChallengeHandler {
    return _nextChallengeHandler;
}
-(void) setNextChallengeHandler:(KGChallengeHandler *) nextChallengeHandler {
    _nextChallengeHandler = nextChallengeHandler;
}

-(void) clearCredentials {
    _credentials = nil;
}


@end
