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
#import "KGAuthenticationUtil.h"
#import "KGChallengeHandler.h"
#import "KGWebSocketCompositeChannel.h"

@implementation KGAuthenticationUtil

+ (KGChallengeResponse *) challengeResponse:(KGWebSocketChannel *)channel challengeRequest:(KGChallengeRequest *) challengeRequest challengeResponse:(KGChallengeResponse *)challengeResponse {
    KGChallengeHandler * challengeHandler;
    KGWebSocketCompositeChannel *compositeChannel = (KGWebSocketCompositeChannel *)[channel parent];
    if ([challengeResponse nextChallengeHandler] == nil) {
        challengeHandler = [compositeChannel challengeHandler];
    } else {
        challengeHandler = [challengeResponse nextChallengeHandler];
    }
    
    if (challengeHandler == nil) {
        return nil;
    }
    
    @try {
        challengeResponse = [challengeHandler handle:challengeRequest];
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    return challengeResponse;
}

@end
