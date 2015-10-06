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
#import "KGChallengeRequest.h"
#import "NSString+KZNGAdditions.h"
#import "KGConstants.h"

@implementation KGChallengeRequest {
    NSString* _location;
    NSString* _authenticationScheme;
    NSString* _authenticationParameters;
}

-(void)dealloc {
    _location = nil;
    _authenticationScheme = nil;
    _authenticationParameters = nil;
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
-(id) initWithLocation:(NSString*) location challenge:(NSString*)challenge{
    self = [self init];
    if (self) {
        if (location == nil) {
            [NSException raise:NSInvalidArgumentException format:@"location cannot be nil"];
        }
        if (challenge == nil) {
            //return;
        }
            
        if ([challenge hasPrefix:APPLICATION_PREFIX]) {
            challenge = [challenge substringFromIndex:[APPLICATION_PREFIX length]];
        }
        _location = location;
        _authenticationParameters = nil;
 
        int space = [challenge indexOf:@" "];
        if ( space == -1 ) {
            _authenticationScheme = challenge;
        } else
        {
            _authenticationScheme = [challenge substringWithRange:NSMakeRange(0, space)];
            if ( [challenge length] > (space+1)) {
                _authenticationParameters = [challenge substringFromIndex:(space+1)];
            }
        }
    }
    return self;
}

-(NSString *) location {
    return _location;
}
-(NSString *)authenticationScheme {
    return _authenticationScheme;
}
-(NSString *)authenticationParameters {
    return _authenticationParameters;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@: %@ %@", [super description], _location, _authenticationScheme, _authenticationParameters];
}

@end
