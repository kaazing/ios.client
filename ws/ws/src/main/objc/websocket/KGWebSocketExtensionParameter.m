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

#import "KGWebSocketExtensionParameter.h"
#import "KGWebSocketExtensionParameter+Internal.h"

NSString * const ANONYMOUS  = @"anonymous";
NSString * const REQUIRED   = @"required";
NSString * const TEMPORAL  = @"temporal";

@implementation KGWebSocketExtensionParameter {
    KGWebSocketExtension     *_parent;
    NSString                 *_parameterName;
    Class                    _parameterType;
    NSSet                    *_parameterMetaData;
}

- (id) init {
    [NSException raise:@"NSInternalInconsistencyException"
                format:@"init is not a valid initializer for KGWebSocketExtensionParameter. Please use 'createParameter:name:type:metadata' method in KGWebSocketExtension instead."];
    return nil;
}

- (id) initWithParent:(KGWebSocketExtension *)parent
                 name:(NSString *)name
                 type:(Class)type
             metadata:(NSSet *)metadata {
    self = [super init];
    if (self) {
        _parent = parent;
        _parameterName = name;
        _parameterType = type;
        if (metadata == nil) {
            _parameterMetaData = [[NSSet alloc] init];
        }
        else {
            _parameterMetaData = [NSSet setWithSet:metadata];
        }
    }
    return self;
}

- (KGWebSocketExtension *) extension {
    return _parent;
}

- (BOOL) isAnonymous {
    return [_parameterMetaData containsObject:ANONYMOUS];
}

- (BOOL) isTemporal {
    return [_parameterMetaData containsObject:TEMPORAL];
}

- (BOOL) isRequired {
    return [_parameterMetaData containsObject:REQUIRED];
}

- (NSSet *) metadata {
    return [NSSet setWithSet:_parameterMetaData];
}

- (NSString *) name {
    return _parameterName;
}

- (Class) type {
    return _parameterType;
}

// Since it is a definition object, return self
- (id) copyWithZone:(NSZone *)zone {
    return self;
}
@end
