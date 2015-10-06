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
#import "KGConstants.h"

NSString *const HEADER_AUTHORIZATION = @"Authorization";
NSString *const HEADER_WWW_AUTHENTICATE = @"WWW-Authenticate";
NSString *const WWW_AUTHENTICATE = @"WWW-Authenticate: ";
NSString *const APPLICATION_PREFIX = @"Application ";
NSString *const HTTP_1_1_START = @"HTTP/1.1";

NSString *const HEADER_SEC_EXTENSIONS_EMULATED = @"X-WebSocket-Extensions";
NSString *const HEADER_WEBSOCKET_VERSION = @"X-WebSocket-Version";
NSString *const WEBSOCKET_VERSION = @"wseb-1.0";

NSString *const HEADER_PROTOCOL = @"WebSocket-Protocol";
NSString *const HEADER_SEC_PROTOCOL = @"Sec-WebSocket-Protocol";
NSString *const HEADER_SEC_EXTENSIONS = @"Sec-WebSocket-Extensions";
NSString *const HEADER_ACCEPT_COMMANDS = @"X-Accept-Commands";
NSString *const HEADER_SEQUENCE_NO = @"X-Sequence-No";

@implementation KGConstants

@end
