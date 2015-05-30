/**
 * Copyright (c) 2007-2014 Kaazing Corporation. All rights reserved.
 * 
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "KGMessageEvent.h"
#import "KGByteBuffer.h"

// package org.kaazing.gateway.client.transport

// public
@implementation KGMessageEvent {
    // private
    KGByteBuffer * _data;
    // private
    NSString* _origin;
    // private
    NSString* _lastEventId;
    // private
    NSString* _messageType;
}

- (void) init0 {

}

// public
- (KGMessageEvent *) initWithData:(KGByteBuffer *)data origin:(NSString*)origin lastEventId:(NSString*)lastEventId messageType:(NSString*)messageType {
    self = [super initWithType:_MESSAGE];
    if (self) {
        [self init0];
        _data = data;
        _origin = origin;
        _lastEventId = lastEventId;
        _messageType = messageType;
    }
    return self;
}

// public
- (KGByteBuffer *) data {
    return _data;
}


// public
- (NSString*) origin {
    return _origin;
}


// public
- (NSString*) lastEventId {
    return _lastEventId;
}


// public
- (NSString*) messageType {
    return _messageType;
}


// public
- (NSString*) toString {
    NSString* ret = [NSString stringWithFormat: @"KGMessageEvent [type=%@ messageType=%@ data=%@  origin=%@ lastEventId=%@ {", [self type], _messageType, _data, _origin, _lastEventId];
    for (id a in [self params]) {
        ret = [NSString stringWithFormat:@"%@%@ ", ret,  a];
    }
    return [ret stringByAppendingString:@"}]"];
}


- (void)dealloc {
    _data = nil;
    _origin = nil;
    _lastEventId = nil;
    _messageType = nil;
}

@end
