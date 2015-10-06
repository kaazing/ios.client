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
#import "KGWebSocketExtension.h"

// Abstract class
@implementation KGWebSocketExtension {
    NSString            *_name;
    NSMutableDictionary *_parameters;
}


- (id) init {
    self = [super init];
    if (self) {
        _parameters = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (id) initWithName:(NSString*) name {
    self = [super init];
    if (self) {
        _name = name;
        _parameters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *) parameters {
    return _parameters;
}

- (void) setParameter:(NSString*)value key:(NSString *)key {
    [_parameters setObject:value forKey:key];
}

- (NSString*) parameter:(NSString*)paramenterName {
    return [_parameters objectForKey:paramenterName];
}

- (NSString *) name {
    return _name;
}

- (NSString *) toString {
    return _name;
}

// Default implementaion of KGWebSocketExtensionCallbacks
-(BOOL) extensionNegotiated:(NSDictionary *) wsContext response:(NSString *) response {
    return  NO;
}
-(NSString*) processTextMessage:(NSString*) text {
    return text;
}

-(KGByteBuffer*) processBinaryMessage:(KGByteBuffer *) buffer {
    return buffer;
}
-(NSString*) textMessageReceived:(NSString*) text {
    return text;
}
-(KGByteBuffer*) binaryMessageReceived:(KGByteBuffer *) buffer {
    return buffer;
}
@end
