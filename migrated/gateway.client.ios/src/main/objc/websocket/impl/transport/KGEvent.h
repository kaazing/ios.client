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

static NSString* const _OPEN = @"open";
static NSString* const _MESSAGE = @"message";
static NSString* const _CLOSED = @"closed";
static NSString* const _REDIRECT = @"redirect";
static NSString* const _AUTHENTICATE = @"authenticate";
static NSString* const _ERROR = @"error";
static NSString* const _READY_STATE_CHANGE = @"readystatechange";
static NSString* const _LOAD = @"load";
static NSString* const _ABORT = @"abort";
static NSString* const _PROGRESS = @"progress";

// public
@interface KGEvent : NSObject {
    // package private
    NSArray */*KCObject*/ _params;
    // package private
    NSString* _type;
}

// public
- (KGEvent *) initWithType:(NSString*)type;

// public
- (KGEvent *) initWithType:(NSString*)type params:(NSArray */*KCObject*/)params;

// public
- (NSString*) type;

// public
- (NSArray */*KCObject*/) params;

// public
- (NSString*) toString;

@end
