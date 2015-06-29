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

#import "KGWebSocketEmulatedHandshakeHandler.h"
#import "KGCreateChannel.h"
#import "KGCreateHandlerListener.h"
#import "KGUpstreamChannel.h"
#import "KGUpstreamHandlerListener.h"
#import "KGDownstreamChannel.h"
#import "KGDownstreamHandlerListener.h"
#import "KGWebSocketEmulatedChannel.h"
#import "KGCreateHandler.h"
#import "KGDownstreamHandler.h"
#import "KGUpstreamHandler.h"
#import "KGHttpURI.h"

///////// "inner classes"
/// NEED TO BE ON THE TOP
@interface  KGCreateHandlerListener_1 : NSObject <KGCreateHandlerListener>

-initWithWebSocketEmulatedHandshakeHandler:(KGWebSocketEmulatedHandshakeHandler *)webSocketEmulatedHandshakeHandler;

@end
@implementation KGCreateHandlerListener_1 {
    KGWebSocketEmulatedHandshakeHandler * _parent;
}

// init stuff:
- (void) init0 {
    // Initialization code here.
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}
-(id)initWithWebSocketEmulatedHandshakeHandler:(KGWebSocketEmulatedHandshakeHandler *)webSocketEmulatedHandshakeHandler {
    self = [self init];
    if (self) {
        _parent = webSocketEmulatedHandshakeHandler;
    }
    return self;
}

-(void)createCompleted:(KGCreateChannel *)channel upstreamUri:(KGHttpURI *)upstreamUri downstreamUri:(KGHttpURI *)downstreamUri {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler (KGCreateHandlerListener_1) createCompleted]");
#endif
    long long sequence = [channel currentSequence];
    
    KGWebSocketEmulatedChannel * parent = (KGWebSocketEmulatedChannel *) [channel parent];
    parent.createChannel = nil;
    KGUpstreamChannel * upstreamChannel = [[KGUpstreamChannel alloc] initWithLocation:upstreamUri cookie:[channel cookie] sequence:sequence];
    [upstreamChannel setParent:parent];
    [parent setUpstreamChannel:upstreamChannel];
    KGWebSocketChannel *parentChannel = (KGWebSocketChannel *)[channel parent];
    [upstreamChannel setClientIdentity:[parentChannel clientIdentity]];
    
    // ios specific setting...
    downstreamUri = (KGHttpURI *) [downstreamUri addQueryParameter:@".kc=text/plain;charset=windows-1252"];
    KGDownstreamChannel * downstreamChannel = [[KGDownstreamChannel alloc] initWithLocation:downstreamUri cookie:[channel cookie] sequence:sequence];
    [downstreamChannel setParent:parent];
    [parent setDownstreamChannel:downstreamChannel];
    [downstreamChannel setClientIdentity:[parentChannel clientIdentity]];
    
    parent.cookie = channel.cookie;

    // connect the downstream:
    [[_parent downstreamHandler]processConnect:[parent downstreamChannel] uri:downstreamUri protocol:[parent protocol]];
    
}

-(void)createFailed:(KGCreateChannel *)channel exception:(NSException *)exception {
    KGWebSocketEmulatedChannel * parent = (KGWebSocketEmulatedChannel *) [channel parent];
    [[_parent listener] connectionFailed:parent exception:exception];
    [channel setParent:nil];
}
@end

@interface KGUpstreamHandlerListener_1 : NSObject <KGUpstreamHandlerListener> {
    
}
@end
@implementation KGUpstreamHandlerListener_1 {
    KGWebSocketEmulatedHandshakeHandler * _parent;
}

// init stuff:
- (void) init0 {
    // Initialization code here.
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(id)initWithWebSocketEmulatedHandshakeHandler:(KGWebSocketEmulatedHandshakeHandler *)webSocketEmulatedHandler {
    self = [self init];
    if (self) {
        _parent = webSocketEmulatedHandler;
    }
    return self;
}

-(void) createCompleted:(KGUpstreamChannel *)channel {
    
}

-(void) createFailed:(KGUpstreamChannel *)channel exception:(NSException *)exception {
    [channel setParent:nil];
}

-(void)upstreamCompleted:(KGUpstreamChannel *)channel{
    
}

-(void)upstreamFailed:(KGUpstreamChannel *)channel exception:(NSException *)exception {
    [channel setParent:nil];
}

@end

@interface KGDownstreamHandlerListener_1 : NSObject <KGDownstreamHandlerListener> {
    
}
@end

@implementation KGDownstreamHandlerListener_1 {
    KGWebSocketEmulatedHandshakeHandler * _parent;
}
// init stuff:
- (void) init0 {
    // Initialization code here.
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}
-(id)initWithWebSocketEmulatedHandshakeHandler:(KGWebSocketEmulatedHandshakeHandler *)webSocketEmulatedHandler {
    self = [self init];
    if (self) {
        _parent = webSocketEmulatedHandler;
    }
    return self;
}

-(void) downstreamOpened:(KGDownstreamChannel *)channel {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler (KGDownstreamHandlerListener_1) downstreamOpened]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *) [channel parent];
    [[_parent listener] connectionOpened:wsebChannel protocol:[wsebChannel protocol]];
    
}
-(void) messageReceived:(KGDownstreamChannel *)channel data:(KGByteBuffer *)data {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler (KGDownstreamHandlerListener_1) messageReceived]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *) [channel parent];
    [[_parent listener] messageReceived:wsebChannel buffer:data];
    
}
-(void) textmessageReceived:(KGDownstreamChannel *)channel data:(NSString *)data {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler (KGDownstreamHandlerListener_1) textmessageReceived]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *) [channel parent];
    [[_parent listener] textmessageReceived:wsebChannel text:data];
}

-(void) revalidateReceived:(KGDownstreamChannel *) channel revalidateURL:(NSString*) revalidateURL {
//    KGWebSocketEmulatedChannel wsebChannel = (KGWebSocketEmulatedChannel)channel.Parent;
//    _parentHandler.ProcessRevalidate(wsebChannel, revalidateURL);
}

-(void) downstreamFailed:(KGDownstreamChannel *)channel exception:(NSException *)exception {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler (KGDownstreamHandlerListener_1) downstreamFailed]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *) [channel parent];
    [[_parent listener] connectionFailed:wsebChannel exception:exception];
    [channel setParent:nil];
    [wsebChannel setUpstreamChannel:nil];
    [wsebChannel setDownstreamChannel:nil];
}

-(void) downstreamClosed:(KGDownstreamChannel *)channel {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler (KGDownstreamHandlerListener_1) downstreamClosed]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *) [channel parent];
    [[_parent listener] connectionClosed:wsebChannel  wasClean:YES code:1000 reason:NULL];
    [channel setParent:nil];
    [wsebChannel setUpstreamChannel:nil];
    [wsebChannel setDownstreamChannel:nil];
}

- (void) pingReceived:(KGDownstreamChannel *)channel {
    
    // Reply PING with PONG via upstream handler
    KGWebSocketEmulatedChannel *wsebChannel = (KGWebSocketEmulatedChannel *) [channel parent];
    KGUpstreamChannel *upstreamChannel = [wsebChannel upstreamChannel];
    [[_parent upstreamHandler] processPong:upstreamChannel];
}

@end






NSString *const HEADER_CONTENT_TYPE = @"Content-Type";
@implementation KGWebSocketEmulatedHandshakeHandler {
    id <KGWebSocketHandlerListener> _listener;
}

// init stuff:
- (void) init0 {
    _createHandler = [self createCreateHandler];
    _upstreamHandler = [self createUpstreamHandler];
    _downstreamHandler = [self createDownstreamHandler];
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


// return the downstream handler... to expose it to nested classes
-(KGDownstreamHandler *) downstreamHandler {
    return _downstreamHandler;
}

- (KGUpstreamHandler *) upstreamHandler {
    return _upstreamHandler;
}

// to expose the listener to the "inner" classes
-(id <KGWebSocketHandlerListener>) listener {
    return _listener;
}

-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *)requestedProtocols {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler processConnect]");
#endif
    NSString* path = [location path];
    
    if ([path hasSuffix:@"/"]) {
        path = [path substringWithRange:NSMakeRange(0, ([path length]-1))];
    }
    
    KGCreateChannel * createChannel = [[KGCreateChannel alloc] initWithSequence:0];
    [createChannel setParent:channel];
    KGWebSocketChannel *parentChannel = (KGWebSocketChannel *)[channel parent];
    [createChannel setClientIdentity:[parentChannel clientIdentity]];
    
    KGHttpURI * createUri = (KGHttpURI *) [[KGHttpURI replaceSchemeFromGenericURI:location scheme:[location HttpEquivalentScheme]] replacePath:[path stringByAppendingString:@"/;e/cbm"]];
    
    
    // CONNECT...
    [_createHandler processOpen:createChannel location:createUri];
}

-(void) processAuthorize:(KGWebSocketChannel *) channel authorizeToken:(NSString*) authorizeToken {
    
}

-(void) processRevalidate:(KGWebSocketChannel *) channel revalidateURL:(NSString*) revalidateURL {
    //_upstreamHandler.ProcessRevalidate(wsebChannel._upstreamChannel, revalidateURL);
    
}

-(void) processTextMessage:(KGWebSocketChannel *) channel text:(NSString*) text {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler processTextMessage]");
#endif
    // TODO: encoder.encodeTextMessage(channel, message, out);
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *)channel;
    [_upstreamHandler processTextMessage:[wsebChannel upstreamChannel] message:text];
    
}

-(void) processBinaryMessage:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buffer {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler processBinaryMessage]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *)channel;
    // encoder....
    [_upstreamHandler processBinaryMessage:[wsebChannel upstreamChannel] message:buffer];
    
}

-(void) processClose:(KGWebSocketChannel *) channel code:(NSInteger)code reason:(NSString *)reason {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler processClose]");
#endif
    KGWebSocketEmulatedChannel * wsebChannel = (KGWebSocketEmulatedChannel *)channel;
#ifdef DEBUG
    NSLog(@"%@", [wsebChannel upstreamChannel]);
#endif
    [_upstreamHandler processClose:[wsebChannel upstreamChannel] code:code reason:reason];
    
}

- (void) setListener:(id <KGWebSocketHandlerListener>)listener {
    _listener = listener;
}


//PRIVATE methods....
-(KGCreateHandler *) createCreateHandler {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedHandler createCreateHandler]");
#endif
    
    id<KGCreateHandlerListener> _createHandlerListener = [[KGCreateHandlerListener_1 alloc] initWithWebSocketEmulatedHandshakeHandler:self];
    KGCreateHandler * _handler = [[KGCreateHandler alloc] init];
    [_handler setListener:_createHandlerListener];
    return _handler;
}

-(KGDownstreamHandler *) createDownstreamHandler {
#ifdef DEBUG
    //NSLog(@"createDownstreamHandler()");
#endif

    id<KGDownstreamHandlerListener> _downstreamHandlerListener = [[KGDownstreamHandlerListener_1 alloc] initWithWebSocketEmulatedHandshakeHandler:self];
    KGDownstreamHandler * _handler = [[KGDownstreamHandler alloc] init];
    [_handler setListener:_downstreamHandlerListener];
    return _handler;
}

-(KGUpstreamHandler *) createUpstreamHandler {
#ifdef DEBUG
    //NSLog(@"createUpstreamHandler()");
#endif

    id<KGUpstreamHandlerListener> _upstreamHandlerListener = [[KGUpstreamHandlerListener_1 alloc] init];
    KGUpstreamHandler * _handler = [[KGUpstreamHandler alloc] init];
    [_handler setListener:_upstreamHandlerListener];
    return _handler;
}


@end

