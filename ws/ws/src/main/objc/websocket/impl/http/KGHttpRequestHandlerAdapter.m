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
#import "KGHttpRequestHandlerAdapter.h"
#import "KGWebSocketCompositeChannel.h"

@implementation KGHttpRequestHandlerAdapter


- (void)dealloc
{
}

// init stuff:
- (void) init0 {
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (void) processOpen:(KGHttpRequest *)request {
    [_nextHandler processOpen:request];
}

// package private
- (void) processSend:(KGHttpRequest *)request buffer:(KGByteBuffer *)buffer {
    [_nextHandler processSend:request buffer:buffer];
}

// package private
- (void) processAbort:(KGHttpRequest *)request {
    [_nextHandler processAbort:request];
}

// package private
- (void) setListener:(id <KGHttpRequestListener>)listener {
    _listener = listener;
}

- (id<KGHttpRequestListener>) listener {
    return _listener;
}

- (void) setNextHandler:(id <KGHttpRequestHandler>)handler {
    _nextHandler = handler;
}

- (id <KGHttpRequestHandler>)nextHandler {
    return _nextHandler;
}

- (KGChannel *) getWebSocketChannel:(KGHttpRequest *)request {
    if (request.parent != nil) {
        return request.parent.parent;
    }
    else {
        return nil;
    }
}

- (BOOL) isWebSocketClosing:(KGHttpRequest *)request {
    KGChannel *channel = [self getWebSocketChannel:request];
    if (channel != nil) {
        KGWebSocketCompositeChannel *parent = (KGWebSocketCompositeChannel *) [channel parent];
        if (parent != nil) {
            KGReadyState readyState = [parent readyState];
            return ((readyState == KGReadyState_CLOSED) || (readyState == KGReadyState_CLOSING));
        }
    }
    
    return NO;
}

@end
