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

#import "KGCreateHandler.h"
#import "KGHttpRequestIoHandler.h"
#import "KGHttpRequestRedirectHandler.h"
#import "KGTransportFactory.h"
#import "KGHttpRequestAuthenticationHandler.h"
#import "KGWebSocketHandshakeObject.h"
#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocket+Internal.h"
#import "KGConstants.h"
#import "NSString+KZNGAdditions.h"

@interface KGCH_HttpRequestListener_1 : NSObject <KGHttpRequestListener>

-initWithCreateHandler:(KGCreateHandler *)createHandler;

@end

@implementation KGCH_HttpRequestListener_1 {
    KGCreateHandler * _parent;
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

-(id)initWithCreateHandler:(KGCreateHandler *)createHandler {
    self = [self init];
    if (self) {
        _parent = createHandler;
    }
    return self;
    
}

// Delegate... KGHttpRequestListener
- (void) requestReady:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' requestReady]");
#endif
}

// package private
- (void) requestOpened:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' requestOpened]");
#endif
}

// package private
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload{
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' requestProgressed]");
#endif
}

// package private
- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response{
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' requestLoaded]");
#endif
    
    KGCreateChannel * channel = (KGCreateChannel *) [request parent];
    
    @try {

        if ([response statusCode] == 201) {
            //get extension header
            NSString* extensionsHeader = [response header:HEADER_SEC_EXTENSIONS_EMULATED];
            KGWebSocketCompositeChannel *compositeChannel = (KGWebSocketCompositeChannel *)[[channel parent] parent];
            [compositeChannel setNegotiatedExtensions:extensionsHeader];
            if (extensionsHeader != nil) {
                NSArray* extensions = [extensionsHeader componentsSeparatedByString:@","];
                for (int i=0; i< [extensions count]; i++) {
                    NSString* extension = [extensions objectAtIndex:i];
                    NSArray * tmp = [extension componentsSeparatedByString:@";"];
                    if ([tmp count] > 1) {
                        //has escape bytes
                        NSString* escape = [[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        //Integer.parseInt(escape, 16)
                        int key;
                        NSScanner *scanner = [NSScanner scannerWithString:escape];
                        [scanner scanHexInt:(unsigned int *)&key];
                        [[channel controlFrames] setValue:[[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:[[NSNumber numberWithInt:key] stringValue]];
                    }
                }    
            }
            
            NSString* payload = [[NSString alloc] initWithData:[[response body] data] encoding:NSUTF8StringEncoding];;

            NSUInteger del = [payload rangeOfString:@"\n"].location;
            KGHttpURI * upStream = [[KGHttpURI alloc] initWithURI:[payload substringToIndex:del]];
            NSString* mdownStream = [payload substringFromIndex:del+1];
            KGHttpURI * downStream = [[KGHttpURI alloc] initWithURI:[mdownStream substringWithRange:NSMakeRange(0, (mdownStream.length-1))]];

            [[_parent listener] createCompleted:channel upstreamUri:upStream downstreamUri:downStream];
            [channel setParent:nil];
        }
        else {
#ifdef DEBUG
            NSLog(@"WebSocketEmultion failed, response status code: %d", [response statusCode]);
#endif
            NSString *reason = [NSString stringWithFormat:@"WebSocketEmulation failed, response status code: %d", [response statusCode]];
            NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:reason userInfo:nil];
            [[_parent listener] createFailed:channel exception:ex];
            [channel setParent:nil];
        }
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        NSLog(@"WebSocketEmultion faild");
#endif
        NSString *reason = [NSString stringWithFormat:@"WebSocketEmulation failed with exception: %@", [exception reason]];
        NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:reason userInfo:nil];
        [[_parent listener] createFailed:channel exception:ex];
        [channel setParent:nil];
    }
    @finally {
        
    }
}

// package private
- (void) requestAborted:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' requestAborted]");
#endif
}

// package private
- (void) requestClosed:(KGHttpRequest *)request{
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' requestClosed]");
#endif
}

// package private
- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception {
#ifdef DEBUG
    NSLog(@"[KGCreateHandler 'HttpRequestListener_1' errorOccurred]");
#endif
    KGCreateChannel * createChannel = (KGCreateChannel *) [request parent];
    [[_parent listener] createFailed:createChannel exception:exception];
    [createChannel setParent:nil];
}
/// End of Delegate
@end


@implementation KGCreateHandler {
    id <KGHttpRequestHandler> _nextHandler;
    id <KGCreateHandlerListener> _listener;
    
    //KGHttpRequestAuthenticationHandler authHandler = new KGHttpRequestAuthenticationHandler();
    //KGHttpRequestRedirectHandler redirectHandler = new KGHttpRequestRedirectHandler();
    //HttpRequestBridgeHandler transportHandler = KGTransportFactory.createHttpRequestHandler();

    KGHttpRequestAuthenticationHandler * _authHandler;
    KGHttpRequestRedirectHandler * _redirectHandler;
    KGHttpRequestIoHandler * _transportHandler;
}

-(id <KGCreateHandlerListener>) listener {
    return _listener;
}

- (void)dealloc
{
    _nextHandler = nil;
    _listener = nil;
    _transportHandler = nil;
}

// init stuff:
- (void) init0 {
    _authHandler = [[KGHttpRequestAuthenticationHandler alloc] init];
    _redirectHandler = [[KGHttpRequestRedirectHandler alloc] init];
    _transportHandler = [KGTransportFactory createHttpRequestHandler];

    [_authHandler setNextHandler:_redirectHandler];
    [_redirectHandler setNextHandler:_transportHandler];
    [self setNextHandler:_authHandler];
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


-(void) processOpen:(KGCreateChannel *) createChannel location:(KGHttpURI *) location {
 
#ifdef DEBUG
    NSLog(@"[KGCreateHandler processOpen]");
#endif
    KGHttpRequest       *request = [[KGHttpRequest HTTP_REQUEST_FACTORY] createHttpRequest:@"GET" uri:location async:NO];
    NSMutableDictionary *headers = [request headers];
    KGWebSocketCompositeChannel *compositeChannel = (KGWebSocketCompositeChannel *)[[createChannel parent] parent];
    NSString *enabledExtensions = [compositeChannel enabledExtensions];
    NSString *trimmedExtensions = [enabledExtensions trim];
    if ([trimmedExtensions length] > 0) {
        [headers setValue:[compositeChannel enabledExtensions] forKey:HEADER_SEC_EXTENSIONS_EMULATED];
    }
    [[request headers] setValue:WEBSOCKET_VERSION forKey:HEADER_WEBSOCKET_VERSION];
    
    // Notify gateway that client supports PING/PONG
    [[request headers] setValue:@"ping" forKey:HEADER_ACCEPT_COMMANDS];
    [request setParent:createChannel];
    [request setClientIdentity:[createChannel clientIdentity]];
    [_nextHandler processOpen:request];
}

-(void) setNextHandler:(id <KGHttpRequestHandler>) handler {
#ifdef DEBUG
    NSLog(@"[KGCreateHandler setNextHandler]");
#endif
    _nextHandler = handler;
    KGCH_HttpRequestListener_1 * requestListener = [[KGCH_HttpRequestListener_1 alloc] initWithCreateHandler:self];
    [_nextHandler setListener:requestListener];
}

-(void) setListener:(id <KGCreateHandlerListener>) listener {
#ifdef DEBUG
    NSLog(@"[KGCreateHandler setListener]");
#endif
    _listener = listener;
}


@end
