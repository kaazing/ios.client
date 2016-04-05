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
#import "KGHttpRequestLoggingHandler.h"
#import "KGTracer.h"


@interface KGLogging_HttpRequestListener_1 : NSObject <KGHttpRequestListener>

-initWithHttpRequestHandler:(KGHttpRequestLoggingHandler *)handler;

@end

@implementation KGLogging_HttpRequestListener_1 {
    KGHttpRequestLoggingHandler * _parent;
}

- (void)dealloc
{
    _parent = nil;
}

- (void) init0 {
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-initWithHttpRequestHandler:(KGHttpRequestLoggingHandler *)handler {
    self = [self init];
    if (self) {
        _parent = handler;
    }
    return self;
    
}

// Delegate... KGHttpRequestListener
- (void) requestReady:(KGHttpRequest *)request{
    [KGTracer trace:[NSString stringWithFormat:@"<- READY: %@", request]];
    [[_parent listener] requestReady:request];
}

// package private
- (void) requestOpened:(KGHttpRequest *)request{
    [KGTracer trace:[NSString stringWithFormat:@"<- OPENED: %@", request]];
    [[_parent listener] requestOpened:request];
}

// package private
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload{
    [KGTracer trace:[NSString stringWithFormat:@"<- PROGRESSED: %@ %@", request, payload]];
    [[_parent listener] requestProgressed:request payload:payload];
}

// package private
- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response{
    [KGTracer trace:[NSString stringWithFormat:@"<- LOADED: %@ %@", request, response]];
    [[_parent listener] requestLoaded:request response:response];
}

- (void) requestAborted:(KGHttpRequest *)request{
    [KGTracer trace:[NSString stringWithFormat:@"<- ABORTED: %@", request]];
    [[_parent listener] requestAborted:request];
}

- (void) requestClosed:(KGHttpRequest *)request{
    [KGTracer trace:[NSString stringWithFormat:@"<- CLOSED: %@", request]];
    [[_parent listener] requestClosed:request];
}

- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception {
    [KGTracer trace:[NSString stringWithFormat:@"<- ERROR OCCURRED: %@", request]];
    [[_parent listener] errorOccurred:request exception:exception];
}
@end


@implementation KGHttpRequestLoggingHandler

- (void) processOpen:(KGHttpRequest *)request {
    [KGTracer trace:[NSString stringWithFormat:@"<- OPEN: %@", request]];
    [super processOpen:request];
}

- (void) processSend:(KGHttpRequest *)request buffer:(KGByteBuffer *)buffer {
    [KGTracer trace:[NSString stringWithFormat:@"<- SEND: %@ %@", request, buffer]];
    [super processSend:request buffer:buffer];
}

- (void) processAbort:(KGHttpRequest *)request {
    [KGTracer trace:[NSString stringWithFormat:@"<- ABORT: %@", request]];
    [super processAbort:request];
}

- (void) setNextHandler:(id <KGHttpRequestHandler>)handler {
    _nextHandler = handler;
    
    // create the KGHttpRequestListener IMPL and attach:
    KGLogging_HttpRequestListener_1 * listener = [[KGLogging_HttpRequestListener_1 alloc] initWithHttpRequestHandler:self];
    [_nextHandler setListener:listener];
}

@end
