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

/**
 * KGWebSocketExtension is an abstract class that should be extended to 
 * define custom extension. The custom extension can include one or more 
 * theKGWebSocketExtensionParameter constants that defines the parameters corresponding 
 * to the custom extension.
 *
 * @warning This is an abstract class. This should not be created directly. It is inherited 
 *          by the subclasses such as KGApnsExtension.
 */

// TODO: this can be uncommented in future when custom WebSocket extension is exposed.
/*
 * *For Example*
 * Lets say you want to define a custom extension *CustomExtension* that is 
 * negotiated during WebSocket protocol handshake and the custom extension consists of 
 * two parameters - *foo* and *bar*. Let's say parameter *bar* is anonymous required parameter 
 * i.e only the value of the parameter is written on the wire.
 *
 * *IMPORTANT:* It is highly recommended to not to have multiple anonymous required
 *              parameters as it may result in ambiguity. The multiple anonymous
 *              parameters are usualy processed in the order they are defined.
 *
 * *CustomExtension.h*
 * <pre><code>
 * @interface CustomExtension : KGWebSocketExtension
 * + (CustomExtension *) customExtension;
 * + (KGWebSocketExtensionParamter *) foo;
 * + (KGWebSocketExtensionParamter *) bar;
 * @end
 * </pre></code>
 *
 * The CustomExtension implementation defines the singleton instances of the extension itself and 
 * the extension parameters. They are basically definition objects that does not change once defined.
 *
 * *CustomExtension.m*
 * <pre><code>
 * #import "CustomExtension.h"
 *
 * @implementation CustomExtension
 *
 * NSString * const CUSTOM_EXTENSION_NAME = @"custom-extension";
 * 
 * static CustomExtension                *CUSTOM_EXTENSION;
 * static KGWebSocketExtensionParameter  *FOO;
 * static KGWebSocketExtensionParameter  *BAR;
 *
 * + (void) initialize {
 *      CUSTOM_EXTENSION = [[CustomExtension alloc] init];
 *      FOO = [CUSTOM_EXTENSION createParameter:CUSTOM_EXTENSION name:@"foo" type:[NSString class] metadata:[NSSet setWithObjects:REQUIRED, nil]];
 *      BAR = [CUSTOM_EXTENSION CUSTOM_EXTENSION name:@"bar" type:[NSString class] metadata:[NSSet setWithObjects:REQUIRED, ANONYMOUS, nil]];
 * }
 * 
 * - (NSString *) name {
 *      return CUSTOM_EXTENSION_NAME;
 * }
 *
 * + (CustomExtension *) customExtension {
 *      return CUSTOM_EXTENSION;
 * }
 *
 * + (KGWebSocketExtensionParameter *) foo {
 *       return FOO;
 * }
 *
 * + (KGWebSocketExtensionParameter *) bar {
 *       return BAR;
 * }
 * @end
 * </pre></code>
 */
@interface KGWebSocketExtension : NSObject

/**
 * Creates KGWebSocketExtensionParamter.
 *
 * @param extension The KGWebSocketExtension instance that the parameter belongs to
 * @param parameterName The name of the parameter
 * @param parameterType Parameter type
 * @param parameterMetadata NSSet containing parameter metadata. The parameter metadata 
 *                          is one or more of following constants<br /> 
 *                          1. ANONYMOUS: The name of the parameter will not be put on the
 *                                       wire during the handshake.<br/>
 *                          2. REQUIRED: Parameter marked as required must be set for
 *                                      the entire extension to be negotiated during 
 *                                      the handshake. By default, a parameter is considered 
 *                                      to be optional.<br/>
 *                          3. TEMPORAL: Parameter marked as temporal will not be negotiated 
 *                                      during the handshake.
 *                          
 *
 * @exception NSException if parameter name is nil or empty
 * @exception NSException if parameter type is nil
 * 
 */
- (KGWebSocketExtensionParameter *) createParameter:(KGWebSocketExtension *)extension
                                               name:(NSString *)parameterName
                                               type:(Class)parameterType
                                           metadata:(NSSet *)parameterMetadata;

/**
 * Returns the KGWebSocketExtensionParameter defined in this
 * KGWebSoketExtension with the specified name.
 */
- (KGWebSocketExtensionParameter *) parameter:(NSString *)name;

/**
 * Returns KGWebSocketExtensionParameter(s) that are defined in
 * this KGWebSocketExtension. An empty array is returned if there
 * are no KGWebSocketExtensionParameter(s) defined.
 */
- (NSArray *) parameters;

/**
* Returns KGWebSocketExtensionParameter(s) defined in this
* KGWebSocketExtension that match all the specified metadata.
* An empty array is returned if none of the parameter(s) defined 
* in this class that match all the specified metadata.
*/
- (NSArray *) parametersWithMetadata:(NSArray *)metadata;

/**
 * Returns the name of the extension.
 */
- (NSString *) name;

/**
 * Returns the KGWebSocketExtension with the specified name.
 */
+ (KGWebSocketExtension *) extensionWithName:(NSString *)name;

@end
