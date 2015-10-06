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
#import "KGEvent.h"
#import "KGOpenEvent.h"

// package org.kaazing.gateway.client.transport

// public
@implementation KGOpenEvent {
    // private
    NSString* _protocol;
}

// private static final
NSString* _CLASS_NAME;


- (void) init0 {

}

// public
- (id) init {
    self = [super initWithType: _OPEN];
    if (self) {
        [self init0];
    }
    return self;
}

// public
- (KGOpenEvent *) initWithProtocol:(NSString*)protocol_ {
    self = [super initWithType:_OPEN];
    if (self) {
        [self init0];
        _protocol = protocol_;
    }
    return self;
}

// public
- (NSString*) toString {
    NSString* ret = [NSString stringWithFormat: @"KGOpenEvent [type=%@ {", [self type]];
    for (id a in [self params]) {
        ret = [NSString stringWithFormat:@"%@%@ ", ret,  a];
    }
    return [ret stringByAppendingString:@"}]"];
}


// public
- (NSString*) protocol {
    return _protocol;
}


// public
- (void) setProtocol:(NSString*)protocol_ {
    _protocol = protocol_;
}


- (void)dealloc {
    _protocol = nil;
}

@end
