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
#import "KGErrorEvent.h"

// package org.kaazing.gateway.client.transport

// public
@implementation KGErrorEvent {
    NSException *_exception;
}

- (void) init0 {
}

// public
- (id) init {
    self = [super initWithType:_ERROR];
    if (self) {
        [self init0];
    }
    return self;
}

- (id) initWithException:(NSException *)exception {
    self = [self init];
    if (self) {
        _exception = exception;
    }
    
    return self;
}

- (void)dealloc {
    _exception = nil;
}

- (NSException *) exception {
    return _exception;
}

- (void) setException:(NSException *)exception {
    _exception = exception;
}

@end
