/**
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
#import "KGWebSocketHandlerAdapter.h"

/*
 * WebSocket Native KGHandler Chain
 * NativeHandler - AuthenticationHandler - ExtensionHandler - HandshakeHandler -  BalancingHandler - Codec - BridgeHandler
 * Responsibilities:
 *     a) handle control frame messages
 *     		call messageReceived on extensions pipeline, popup message if all extensions return non-null object
 */

@interface KGWebSocketExtensionHandler : KGWebSocketHandlerAdapter

- (void) handleBinaryMessageReceived:(KGWebSocketChannel *) channel message:(KGByteBuffer *) message;
- (void) handleTextMessageReceived:(KGWebSocketChannel *) channel message:(NSString*) message;

@end
