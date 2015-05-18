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

#import "KGWebSocketReAuthenticateHandler.h"
#import "KGHttpRequestAuthenticationHandler.h"
#import "KGHttpRequestIoHandler.h"
#import "KGHttpRequest.h"
#import "KGHttpRequestListener.h"
#import "KGTransportFactory.h"


@interface KGRe_HttpRequestListener_1 : NSObject <KGHttpRequestListener>
@end
@implementation KGRe_HttpRequestListener_1 {
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

- (void) requestReady:(KGHttpRequest *)request{
}
- (void) requestOpened:(KGHttpRequest *)request{
#ifdef DEBUG
    //NSLog(@"[KGWebSocketReAuthenticateHandler HttpRequestListener_1 requestOpened]");
#endif
}
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload{
}

- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response{
    //exit thread
#ifdef DEBUG
    NSLog(@"[KGWebSocketReAuthenticateHandler HttpRequestListener_1 requestLoaded]");
#endif
    CFRunLoopStop(CFRunLoopGetCurrent());
    [NSThread exit];
}
- (void) requestAborted:(KGHttpRequest *)request{
    //exit thread
#ifdef DEBUG
    NSLog(@"[KGWebSocketReAuthenticateHandler HttpRequestListener_1 requestAborted]");
#endif
    CFRunLoopStop(CFRunLoopGetCurrent());
    [NSThread exit];
}
- (void) requestClosed:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGWebSocketReAuthenticateHandler HttpRequestListener_1 requestClosed]");
#endif
     [NSThread exit];
}
- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception {
#ifdef DEBUG
    NSLog(@"[KGWebSocketReAuthenticateHandler HttpRequestListener_1 errorOccurred]");
#endif
    CFRunLoopStop(CFRunLoopGetCurrent());
    [NSThread exit];
}

@end // of HttpRequestListener_1 listener..


@implementation KGWebSocketReAuthenticateHandler {
    id<KGHttpRequestHandler> _nextHandler;
    KGHttpRequestAuthenticationHandler * _authHandler;
    id<KGHttpRequestHandler> _transportHandler;

}

-(void)dealloc{
    _nextHandler = nil;
    _authHandler = nil;
    _transportHandler = nil;
}

// init stuff:
- (void) init0 {
    // main init:
    _authHandler = [[KGHttpRequestAuthenticationHandler alloc] init];
    _transportHandler = [KGTransportFactory createHttpRequestHandler];

    
    // ctor stuff:
    [self setNextHandler:_authHandler];
    [_authHandler setNextHandler:_transportHandler];
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}




-(void) processOpen:(KGChannel *) channel uri: (KGHttpURI *)location {
#ifdef DEBUG
    NSLog(@"[KGWebSocketReAuthenticateHandler processOpen]");
#endif
    
    KGHttpRequest * request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"GET" uri:location async:YES];

    /*
     * create a dummy channel in the middle to match emulated KGChannel structure
     * WebSoecktEmulatedChannel->KGCreateChannel->KGHttpRequest
     */
    request.parent = [[KGChannel alloc] init];
    [request.parent setParent:channel];
    //start a new thread to handle revalidate
    [self performSelectorInBackground:@selector(_processOpen:) withObject:request];
    //[_nextHandler processOpen:request];

}

-(void) _processOpen:(KGHttpRequest *)request {
    [_nextHandler processOpen:request];
    //start runloop
    while (YES) {
        CFRunLoopRun();
    }
}

-(void) setNextHandler:(id<KGHttpRequestHandler>) handler {
    _nextHandler = handler;
    [_nextHandler setListener:[[KGRe_HttpRequestListener_1 alloc] init]];
}


@end
