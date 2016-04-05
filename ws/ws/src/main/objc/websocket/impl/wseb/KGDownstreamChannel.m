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
#import "KGDownstreamChannel.h"

@implementation KGDownstreamChannel {
    NSString                   *_cookie;
    KGWebSocketEmulatedDecoder *_decoder;
    SecIdentityRef             _clientIdentity;
    int                        _idleTimeout;
    long long                  _lastMessageTimestamp;
    NSTimer                    *_idleTimer;
}

@synthesize location = _location;
@synthesize protocol = _protocol;

- (void) init0 {
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
        _cookie = cookie;
        _location = location;
        _decoder = [[KGWebSocketEmulatedDecoder alloc] init];
    }
    return self;
}

- (void) dealloc {
    _clientIdentity = nil;
    _idleTimer = nil;
    _decoder = nil;
    _cookie = nil;
}

- (KGWebSocketEmulatedDecoder *) decoder {
    return _decoder;
}

- (void) setClientIdentity:(SecIdentityRef)clientIdenity {
    _clientIdentity = clientIdenity;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}

- (int) idleTimeout {
    return _idleTimeout;
}

- (void) setIdleTimeout:(int)idleTimeout {
    _idleTimeout = idleTimeout;
}

- (long long) lastMessageTimestamp {
    return _lastMessageTimestamp;
}

- (void) setLastMessageTimestamp:(long long)timestamp {
    _lastMessageTimestamp = timestamp;
}

- (NSTimer *) idleTimer {
    return _idleTimer;
}

- (void) setIdleTimer:(NSTimer *)timer {
    _idleTimer = timer;
}

@end
