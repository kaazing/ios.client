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
//#import "KGWebSocketChannel.h"
@class KGWebSocketChannel;
#import "KGByteBuffer.h"

@protocol KGWebSocketHandlerListener <NSObject>

/**
 * This method is called when the WebSocket is opened
 */
- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString*)protocol;

/**
 * This method is called when a redirect response is 
 */
- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location;

/**
 * This method is called when authentication is requested 
 */
- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge;

/**
 * This method is called when a binary message is received on the WebSocket
 */
-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf;
/**
 * This method is called when a text message is received on the WebSocket
 */
-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text;

/**
 * This method is called when the WebSocket is closed
 */
- (void) connectionClosed:(KGWebSocketChannel *) channel wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason;

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex;

/**
 * This method is called when a connection fails
 */
- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex;


@end
