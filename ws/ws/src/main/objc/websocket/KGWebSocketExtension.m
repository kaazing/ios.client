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

#import "KGWebSocketExtension.h"
#import "KGWebSocketExtension+Internal.h"
#import "KGWebSocketExtensionParameter+Internal.h"
#import "NSString+KZNGAdditions.h"

// Abstract class
@implementation KGWebSocketExtension {
    NSMutableArray      *_parameters;
}

static NSMutableDictionary *_extensions;

+ (void) initialize {
    _extensions = [[NSMutableDictionary alloc] init];
}

- (id) init {
    self = [super init];
    if (self) {
        _parameters = [[NSMutableArray alloc] init];
        [_extensions setObject:self forKey:[self name]];
    }
    return self;
}

- (KGWebSocketExtensionParameter *) createParameter:(KGWebSocketExtension *)extension
                                      name:(NSString *)parameterName
                                      type:(Class)parameterType
                                  metadata:(NSSet *)parameterMetadata {
    if ([self isNilOrEmpty:parameterName]) {
        [NSException raise:@"NSInvalidArgumentException"
                    format:@"parameter name cannot be nil or empty."];
    }
    if (parameterType == nil) {
        [NSException raise:@"NSInvalidArgumentException"
                    format:@"parameter type cannot be nil."];
    }
    
    KGWebSocketExtensionParameter *parameter = [[KGWebSocketExtensionParameter alloc] initWithParent:extension
                                                                                                name:parameterName
                                                                                                type:parameterType
                                                                                            metadata:parameterMetadata];
    [_parameters addObject:parameter];
    return parameter;
}

- (KGWebSocketExtensionParameter *) parameter:(NSString *)name {
    NSArray *parameters = [self parameters];
    for (KGWebSocketExtensionParameter *extensionParameter in parameters) {
        if ([[extensionParameter name] isEqualToString:name]) {
            return extensionParameter;
        }
    }
    return nil;
}

- (NSArray *) parameters {
    return [NSArray arrayWithArray:_parameters];
}

- (NSArray *) parametersWithMetadata:(NSArray *)metadata {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (metadata == nil || ([metadata count] == 0)) {
        return result;
    }
    NSSet   *metadataSet = [NSSet setWithArray:metadata];
    NSArray *parameters = [self parameters];
    for (KGWebSocketExtensionParameter *extensionParameter in parameters) {
        NSSet *parameterMetadata = [extensionParameter metadata];
        if ([metadataSet isSubsetOfSet:parameterMetadata]) {
            [result addObject:extensionParameter];
        }
    }
    return result;
}

- (NSArray *) name {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *) parameterValueToString:(KGWebSocketExtensionParameter *) parameter value:(id)value {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) stringToParameterValue:(KGWebSocketExtensionParameter *) parameter value:(NSString *)value {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (KGWebSocketExtension *) extensionWithName:(NSString *)name {
    return [_extensions objectForKey:name];
}

# pragma mark <Private Implementation>
- (BOOL) isNilOrEmpty:(NSString *)value {
    if (value == nil) {
        return YES;
    }
    NSString *trimmedString = [value trim];
    if ([trimmedString length] == 0) {
        return YES;
    }
    
    return NO;
}
@end
