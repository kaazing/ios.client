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
#import "KGWsMessage.h"

// package org.kaazing.gateway.client.transport.ws

// public
@implementation KGWsMessage {
    // private
    KGKind _kind;
    // private final
    NSData* _buf;
}

- (void) init0 {
}

// public
- (KGKind) kind {
    return _kind;
}


// public
- (KGWsMessage *) initWithBuf:(NSData*)buf kind:(KGKind)kind {
    self = [super init];
    if (self) {
        [self init0];
        _buf = buf;
        _kind = kind;
    }
    return self;
}

// public
- (NSData*) bytes {
    return _buf;
}

//private
- (NSString*) kindname {
    switch (_kind) {
        case _BINARY:
            return @"BINARY";
            break;
        case _TEXT:
            return @"TEXT";
            break;
        case _CLOSE:
            return @"CLOSE";
            break;
        case _COMMAND:
            return @"COMMAND";
            break;
        case _PING:
            return @"PING";
            break;
        case _PONG:
            return @"PONG";
            break;
        default:
            return @"";
            break;
    }
}

// @Override
// public
- (NSString*) toString {
    NSString* ret = [self kindname];
    ret = [ret stringByAppendingString:@": "];
    ret = [ret stringByAppendingFormat:@"%@", _buf];
    return ret;
}


- (void)dealloc {
    _buf = nil;
}

@end
