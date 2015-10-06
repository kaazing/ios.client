/*
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
#import "KGBasicChallengeHandler.h"
#import "KGChallengeHandler+Internal.h"

@implementation KGBasicChallengeHandler

- (void) init0 {
#ifdef DEBUG
    NSLog(@"[KGBasicChallengeHandler init0]");
#endif
    // Initialization code here:
    // Cannot create instance of abstract class directly
    if ([self isMemberOfClass:[KGBasicChallengeHandler class]]) {
        [self doesNotRecognizeSelector:_cmd];
        //[self release];
        [NSException raise:@"NotImplementedException" format:@"Cannot create instance of class"];
    }
    
}

- (id)init {
#ifdef DEBUG
    NSLog(@"[KGBasicChallengeHandler init]");
#endif
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

// abstract:
-(void)setRealmLoginHandler:(NSString*)realm loginHandler:(KGLoginHandler *) loginHandler {
    [self doesNotRecognizeSelector:_cmd];
}

// abstract:
-(KGChallengeHandler *) setLoginHandler:(KGLoginHandler *) loginHandler {
    [self doesNotRecognizeSelector:_cmd];
    return nil;        
}

// abstract:
-(KGLoginHandler *) loginHandler {
    [self doesNotRecognizeSelector:_cmd];
    return nil;        
}

+ (id) create {
    return [super createFromClassString:@"KGBasicChallengeHandler"];
}

@end
