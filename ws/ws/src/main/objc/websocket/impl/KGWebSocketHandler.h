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
#import "KGByteBuffer.h"
#import "KGWSURI.h"
//#import "KGWebSocketChannel.h"
#import "KGWebSocketHandlerListener.h"
@class KGWebSocketChannel;

@protocol KGWebSocketHandler <NSObject>

-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *) requestedProtocols;
-(void) processAuthorize:(KGWebSocketChannel *) channel authorizeToken:(NSString*) authorizeToken;
-(void) processTextMessage:(KGWebSocketChannel *) channel text:(NSString*) text;
-(void) processBinaryMessage:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buffer;
-(void) processClose:(KGWebSocketChannel *) channel code:(NSInteger)code reason:(NSString *)reason;
-(void) setIdleTimeout:(KGWebSocketChannel *) channel timeout:(NSInteger)timeout;

// package private
- (void) setListener:(id <KGWebSocketHandlerListener>)listener;
-(id <KGWebSocketHandlerListener>)listener;


@end
