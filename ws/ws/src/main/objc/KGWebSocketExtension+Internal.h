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

@interface KGWebSocketExtension (Internal)
// TODO: this will be formalized later by using Converters and Parsers
// that can be registered for each parameter

/**
 * Converts the parameter value obtained from the gateway to its corresponding type defined in
 * KGWebSocketExtensionParameter.
 */
- (id) stringToParameterValue:(KGWebSocketExtensionParameter *) parameter value:(NSString *)value;


/**
 * Converts the value specified to the NSString. The NSString returned is put on the wire
 * during WebSocket protocol handshake.
 */
- (NSString *) parameterValueToString:(KGWebSocketExtensionParameter *) parameter value:(id)value;

@end
