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
#import "KGUpstreamChannel.h"

@implementation KGUpstreamChannel {
    SecIdentityRef _clientIdentity;
}


@synthesize location = _location;
@synthesize cookie = _cookie;
@synthesize sendQueue = _sendQueue;
@synthesize sendInFlight = _sendInFlight;
@synthesize request = _request;
@synthesize parent = _parent;

- (void) init0 {
    // empty arry:
    _sendQueue = [NSMutableArray array];
    _sendInFlight = NO;
    
}
- (id)initWithSequence:(long long)sequence {
    self = [super initWithSequence:sequence];
    if (self) {
        [self init0];
    }
    return self;
}

- (id) initWithLocation:(KGHttpURI *) location
                 cookie:(NSString*)cookie
               sequence:(long long)sequence {
    self = [self initWithSequence:sequence];
    if (self) {
        _location = location;
        _cookie = cookie;
    }
    return self;
    
}

- (void) setClientIdentity:(SecIdentityRef)clientIdentity {
    _clientIdentity = clientIdentity;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}


@end
