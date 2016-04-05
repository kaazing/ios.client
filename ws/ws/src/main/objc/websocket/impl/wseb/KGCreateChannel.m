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
#import "KGCreateChannel.h"

@implementation KGCreateChannel {
    NSString             *_cookie;
    SecIdentityRef       _clientIdentity;
}

- (void) init0 {
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (void)dealloc
{
    _clientIdentity = nil;
    _cookie = nil;
}

-(NSString*) cookie {
    return _cookie;
}

-(void)setCookie:(NSString*)cookie {
    _cookie = cookie;
}


- (void) setClientIdentity:(SecIdentityRef)clientIdentity {
    _clientIdentity = clientIdentity;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}

@end
