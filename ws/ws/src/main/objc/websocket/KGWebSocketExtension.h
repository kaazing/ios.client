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

#import "KGWebSocket.h"

@protocol KGWebSocketExtensionCallback <NSObject>

/**
 * KGWebSocketExtensionCallback is the callback protocol
 *
 */

/**
 * This funnction is called when the extension is successful negotiated with server
 */
-(BOOL) extensionNegotiated:(NSDictionary *) wsContext response:(NSString *) response;

/**
 * This funnction is called when a text message is about to send to server
 */
-(NSString*) processTextMessage:(NSString*) text;

/**
 * This funnction is called when a binary message is about to send to server
 */
-(KGByteBuffer*) processBinaryMessage:(KGByteBuffer *) buffer;

/**
 * This funnction is called when a text message is received from server
 */
-(NSString*) textMessageReceived:(NSString*) text;

/**
 * This funnction is called when a binary message is received from server
 */
-(KGByteBuffer*) binaryMessageReceived:(KGByteBuffer *) buffer;

@end

/**
 * KGWebSocketExtension is an abstract class that should be extended to 
 * define custom extension. The custom extension can include one or more 
 * parameter constants that defines the key/value pair
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
 *
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
 *
 * + (void) initialize {
 *      CUSTOM_EXTENSION = [[CustomExtension alloc] initWithName:CUSTOM_EXTENSION_NAME];
 *      [CUSTOM_EXTENSION setParameter:@"FOO" key:@"foo"];
 *      [CUSTOM_EXTENSION setParameter:@"BAR" key:@"bar"];
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
 * @end
 * </pre></code>
 */
@interface KGWebSocketExtension : NSObject <KGWebSocketExtensionCallback>


/**
 * init the KGWebSocketExtension with the specified name.
 */
- (id) initWithName:(NSString *)name;

/**
 * Returns the name of the extension.
 */
- (NSString *) name;

/**
 * Returns Parameter value with paramenter name.
 * nil is returned if there
 * are no arameter with this name defined.
 */
- (NSString*) parameter:(NSString*)paramenterName;

/**
 * Set Parameter with name and value pair */
- (void) setParameter:(NSString*)value key:(NSString*)key;

/**
 * Returns the string format of the extension.
 */
- (NSString *) toString;

@end
