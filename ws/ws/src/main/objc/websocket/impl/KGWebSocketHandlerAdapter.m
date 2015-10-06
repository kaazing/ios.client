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
#import "KGWebSocketHandlerAdapter.h"

@implementation KGWebSocketHandlerAdapter {
}

- (id)init {
    self = [super init];
    return self;
}

-(void)dealloc {
    _listener = nil;
    _nextHandler = nil;
}

-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *)requestedProtocols {
    [_nextHandler processConnect:channel location:location requestedProtocols:requestedProtocols];
}
-(void) processAuthorize:(KGWebSocketChannel *) channel authorizeToken:(NSString*) authorizeToken {
    [_nextHandler processAuthorize:channel authorizeToken:authorizeToken];
}
-(void) processTextMessage:(KGWebSocketChannel *) channel text:(NSString*) text {
    [_nextHandler processTextMessage:channel text:text];    
}
-(void) processBinaryMessage:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buffer {
    [_nextHandler processBinaryMessage:channel buffer:buffer];
}
-(void) processClose:(KGWebSocketChannel *) channel code:(NSInteger)code reason:(NSString *)reason  {
    [_nextHandler processClose:channel code:code reason:reason];
}
-(void) setIdleTimeout:(KGWebSocketChannel *) channel timeout:(NSInteger)timeout {
    [_nextHandler setIdleTimeout:channel timeout:timeout];
}
// package private
- (void) setListener:(id <KGWebSocketHandlerListener>)listener {
    _listener=listener;   
}
-(id <KGWebSocketHandlerListener>)listener {
    return _listener;
}

- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    _nextHandler = handler;
}

-(id <KGWebSocketHandler>) nextHandler {
    return _nextHandler;
}

@end
