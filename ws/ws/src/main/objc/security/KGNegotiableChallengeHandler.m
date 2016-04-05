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
#import "KGNegotiableChallengeHandler.h"

@implementation KGNegotiableChallengeHandler

-(void)dealloc {
    
}

- (void) init0 {
#ifdef DEBUG
    NSLog(@"[KGNegotiableChallengeHandler init0]");
#endif
    // Initialization code here:
    // Cannot create instance of abstract class directly
    if ([self isMemberOfClass:[KGNegotiableChallengeHandler class]]) {
        [self doesNotRecognizeSelector:_cmd];
        //[self release];
        [NSException raise:@"NotImplementedException" format:@"Cannot create instance of class"];
    }
    
}

- (id)init {
#ifdef DEBUG
    NSLog(@"[KGNegotiableChallengeHandler init]");
#endif
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

//abstract:
-(NSArray *) supportedOids {
    [self doesNotRecognizeSelector:_cmd];
    return nil;        
}

//abstract:
-(KGNegotiableChallengeHandler *) setLoginHandler:(KGLoginHandler *) loginHandler {
    [self doesNotRecognizeSelector:_cmd];
    return nil;        
}

//abstract:
-(KGLoginHandler *) loginHandler {
    [self doesNotRecognizeSelector:_cmd];
    return nil;        
}

@end
