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

#import "KGHttpResponse.h"

@implementation KGHttpResponse {
    KGByteBuffer * _responseBuffer;
    int _statusCode;
    NSString* _message;
    NSMutableDictionary* _headers;
}

- (void)dealloc
{
    _responseBuffer = nil;
    
    if (_headers != nil) {
        [_headers removeAllObjects];
    }
    
    _message = nil;
    _headers = nil;
}

- (void) init0 {
    _statusCode = 0;
    _headers = [[NSMutableDictionary alloc] init];    
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(void)setBody:(KGByteBuffer *)responseBuffer {
    _responseBuffer = responseBuffer;
}
-(KGByteBuffer *) body {
    return [_responseBuffer duplicate];
}

-(void) setStatusCode:(int) statusCode {
    _statusCode = statusCode;
}
-(int) statusCode {
    return _statusCode;
}

-(void) setMessage:(NSString*) message {
    _message = message;
}
-(NSString*) message {
    return _message;
}

-(void) setHeader:(NSString*) header value:(NSString*) value {
    [_headers setValue:value forKey:header];
}
-(NSString*) header:(NSString*) header {
    return [_headers objectForKey:header];
}
-(NSString*) allHeaders {
    //todo!
    return @"";
}





@end
