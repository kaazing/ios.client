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
#import "KGRedirectEvent.h"

// package org.kaazing.gateway.client.transport

// public
@implementation KGRedirectEvent {
    // private
    NSString* _location;
}

- (void) init0 {

}

// public
- (KGRedirectEvent *) initWithLocation:(NSString*)location {
    self = [super initWithType:_REDIRECT];
    if (self) {
        [self init0];
        _location = location;
    }
    return self;
}

// public
- (NSString*) location {
    return _location;
}


// public
- (NSString*) toString {

    NSString* ret = [NSString stringWithFormat: @"KGMessageEvent [type=%@ location=%@ {", [self type], _location];
    for (id a in [self params]) {
        ret = [NSString stringWithFormat:@"%@%@ ", ret,  a];
    }
    return [ret stringByAppendingString:@"}]"];
}


- (void)dealloc {
    _location = nil;
}

@end
