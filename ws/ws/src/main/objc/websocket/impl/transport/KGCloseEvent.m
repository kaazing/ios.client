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
#import "KGCloseEvent.h"

// package org.kaazing.gateway.client.transport

// public
@implementation KGCloseEvent {
    // private
    int _code;
    // private
    NSString* _reason;
    // private
    BOOL _wasClean;
}

- (void) init0 {
}

// public
- (KGCloseEvent *) initWithCode:(int)code wasClean:(BOOL)wasClean reason:(NSString*)reason {
    self = [super initWithType:_CLOSED];
    if (self) {
        [self init0];
        _code = code;
        _wasClean = wasClean;
        _reason = reason;
    }
    return self;
}

// public
- (int) code {
    return _code;
}


// public
- (BOOL) wasClean {
    return _wasClean;
}


// public
- (NSString*) reason {
    return _reason;
}


- (void)dealloc {
    _reason = nil;
}

@end
