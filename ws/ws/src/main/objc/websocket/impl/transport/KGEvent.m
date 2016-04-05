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
#import "KGEvent.h"

// package org.kaazing.gateway.client.transport

// public
@implementation KGEvent

// private static final
NSArray */*NSString*/ _EMPTY_PARAMS;

+ (void) initialize {
    _EMPTY_PARAMS = [[NSArray alloc] init];
}

- (void) init0 {
}

// public
- (KGEvent *) initWithType:(NSString*)type {
//    [self initWithType:type params:_EMPTY_PARAMS];
    if (self) {
    }
    return self;
}

// public
- (KGEvent *) initWithType:(NSString*)type params:(NSArray */*KCObject*/)params {
    self = [super init];
    if (self) {
        [self init0];
        _type = type;
        _params = params;
    }
    return self;
}

// public
- (NSString*) type {
    return _type;
}

// public
- (NSArray */*KCObject*/) params {
    return _params;
}


// public
- (NSString*) toString {
    NSString* ret = [NSString stringWithFormat:@"KGEvent[type:%@{", _type];
    for (id a in _params) {
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%@ ", a]];
    }
    return [ret stringByAppendingString:@"}]"];
}


- (void)dealloc {
    _params = nil;
    _type = nil;
}

@end
