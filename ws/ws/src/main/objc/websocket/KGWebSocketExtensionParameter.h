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

@class KGWebSocketExtension;

/**
 * If a parameter is marked as anonymous, the name of the parameter will 
 * not be put on the wire during the handshake. By default, a parameter 
 * is considered "named" and it's name will be put on the wire during 
 * the handshake.
 */
extern NSString * const ANONYMOUS;

/**
 * Parameters marked as required must be set for the entire extension
 * to be negotiated during the handshake. By default, a parameter is
 * considered to be optional.
 */
extern NSString * const REQUIRED;

/**
 * Parameter marked as temporal will not be negotiated during the
 * handshake.
 */
extern NSString * const TEMPORAL;

/**
 * KGWebSocketExtensionParameter represents an extension parameter.
 *
 */
@interface KGWebSocketExtensionParameter : NSObject<NSCopying>

/**
 * Returns the parent KGWebSocketExtension that this parameter is
 * defined in.
 *
 */
- (KGWebSocketExtension *) extension;

/**
 * Indicates whether the parameter is anonymous or named. If the parameter
 * is anonymous and it is not transient, then it's name is NOT put on the
 * wire during the handshake. However, it's value is put on the wire.
 */
- (BOOL) isAnonymous;

/**
 * Indicates whether the parameter is temporal. Temporal parameters are
 * not put on the wire during the handshake.
 */
- (BOOL) isTemporal;

/**
 * Indicates whether the parameter is required. If the required parameter
 * is not set, then the extension is not negotiated during the handshake.
 */
- (BOOL) isRequired;

/**
 * Returns the metadata characteristics of this extension parameter. The
 * returned EnumSet is a clone so any changes to it will not be picked by
 * by the extension parameter.
 */
- (NSSet *) metadata;

/**
 * Returns the name of the parameter.
 */
- (NSString *) name;

/**
 * Returns the type of the parameter value.
 */
- (Class) type;

@end


