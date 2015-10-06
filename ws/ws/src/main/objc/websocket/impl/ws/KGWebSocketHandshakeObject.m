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
#import "KGWebSocketHandshakeObject.h"

NSString *const KAAZING_EXTENDED_HANDSHAKE = @"x-kaazing-handshake";
NSString *const KAAZING_SEC_EXTENSION_IDLE_TIMEOUT = @"x-kaazing-idle-timeout";

@implementation KGWebSocketHandshakeObject

// init stuff
- (void) init0 {
    // nope...
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


// getter/setter:
- (void) setName:(NSString*)name {
    _name = name;
}
-(NSString*) name {
    return _name;
}

- (void) setEscape:(NSString*)escape {
    _escape = escape;
}
-(NSString*) escape {
    return _escape;
}

-(void) setStatus:(KGHandshakeStatus)status {
    _status = status;
}
-(KGHandshakeStatus)status {
    return _status;
}

@end
