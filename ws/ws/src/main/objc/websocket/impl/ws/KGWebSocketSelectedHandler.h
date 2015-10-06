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
#import <Foundation/Foundation.h>
#import "KGWebSocketHandler.h"
#import "KGWebSocketHandlerAdapter.h"

@interface KGWebSocketSelectedHandler : KGWebSocketHandlerAdapter <KGWebSocketHandler>

- (void) handleConnectionOpened:(KGWebSocketChannel *)channel 
                       protocol:(NSString*)protocol;
- (void) handleMessageReceived:(KGWebSocketChannel *)channel 
                       message:(KGByteBuffer *)message;
- (void) handleTextMessageReceived:(KGWebSocketChannel *)channel
                           message:(NSString*) message;
- (void) handleConnectionClosed:(KGWebSocketChannel *)channel  
                       wasClean:(BOOL)wasClean 
                           code:(short)code 
                         reason:(NSString*)reason;

- (void) handleConnectionFailed:(KGWebSocketChannel *)channel exception:(NSException *)ex;

- (void) setNextHandler:(id<KGWebSocketHandler>)handler;



@end
