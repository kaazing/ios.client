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

#import "KGWebSocketNativeDelegateHandler.h"
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketHandshakeObject.h"
#import "KGWSURI.h"
#import "KGWebSocketDelegateImpl.h"

@interface KGDelegate_WebSocketHandlerListener_1 : NSObject<KGWebSocketDelegateListener>

// ctor:
-(id)initWithWebSocketNativeDelegateHandler:(KGWebSocketNativeDelegateHandler *)handler wsnChannel:(KGWebSocketNativeChannel *)wsnChannel;

@end
@implementation KGDelegate_WebSocketHandlerListener_1 {
    __weak KGWebSocketNativeDelegateHandler * _parent;
    KGWebSocketNativeChannel * _channel;
}

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithWebSocketNativeDelegateHandler:(KGWebSocketNativeDelegateHandler *)handler wsnChannel:(KGWebSocketNativeChannel *)wsnChannel{
    self =  [self init];
    if (self) {
        _parent = handler;
        _channel = wsnChannel;
    }
    return self;
}

- (void) dealloc {
    _channel = nil;
    _parent = nil;
}

// package private
- (void) opened:(KGOpenEvent *)event {
    //LOG.entering(CLASS_NAME, "opened");
    NSString* protocol = [event protocol];
    [[_parent listener] connectionOpened:_channel protocol:protocol];
}

// package private
- (void) closed:(KGCloseEvent *)event{
    //LOG.entering(CLASS_NAME, "closed");
    
    [[_parent listener] connectionClosed:_channel  wasClean:[event wasClean] code:[event code] reason:[event reason]];

    // move setDelegate:nil after event fired due to crashes on iphone device
    // on real iPhone device, setDelegate to nil causes _channel to be set to nil too.
    //
    
    //KG-5670 _channel was set to nil this cause connect to load balancer failed
    // moved this code into KGWebSocketCompositeHandler to do clean up at last stage
    //[_channel setDelegate:nil];
    
}

// package private
- (void) redirected:(KGRedirectEvent *)redirectEvent{
    //LOG.entering(CLASS_NAME, "redirected");
    NSString* redirectUrl = [redirectEvent location];
    [[_parent listener] redirected:_channel location:redirectUrl];
}

// package private
- (void) authenticationRequested:(KGAuthenticateEvent *)authenticateEvent{
    //LOG.entering(CLASS_NAME, "authenticationRequested");
    NSString* location = [[[_channel location] URI] absoluteString];
    NSString* chllenge = [authenticateEvent challenge];
    [[_parent listener] authenticationRequested:_channel location:location challenge:chllenge];
}

// package private
- (void) messageReceived:(KGMessageEvent *)messageEvent{
    //LOG.entering(CLASS_NAME, "messageReceived");
//    KGByteBuffer messageBuffer = KGByteBuffer.wrap(messageEvent.getData());
//    String messageType = messageEvent.getMessageType();
//
//    if (LOG.isLoggable(Level.FINEST)) {
//        LOG.log(Level.FINEST, messageBuffer.getHexDump());
//    }
//
//    if (messageType == null) {
//        throw new NullPointerException("Message type is null");
//    }
//
//    if ("TEXT".equals(messageType)) {
//        String text = messageBuffer.getString(UTF8);
//        listener.textMessageReceived(wsnChannel, text);
 //   }
//    else {
//        listener.binaryMessageReceived(wsnChannel, messageBuffer);
//    }
    if([@"TEXT" isEqualToString:[messageEvent messageType]]) {
        NSString* t = [[messageEvent data] getString];
        [[_parent listener] textmessageReceived:_channel text:t];
    }
    else {
        KGByteBuffer * buf = [messageEvent data];
        [[_parent listener] messageReceived:_channel buffer:buf];
    }
}

// package private
- (void) errorOccurred:(KGErrorEvent *)event{
    [[_parent listener] connectionFailed:_channel exception:[event exception]];
}
@end


@implementation KGWebSocketNativeDelegateHandler


-(void)dealloc {
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



-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *)requestedProtocols{
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeDelegateHandler processConnect ");
#endif
    KGWebSocketNativeChannel * wsnChannel = (KGWebSocketNativeChannel *)channel;
    KGWebSocketChannel *parentChannel = (KGWebSocketChannel *)[channel parent];
    SecIdentityRef identity = [parentChannel clientIdentity];
    @try {
        KGWebSocketDelegateImpl * delegate = [[KGWebSocketDelegateImpl alloc] initWithUrl:[location URI] requestedProtocols:requestedProtocols clientIdentity:identity];
        [wsnChannel setDelegate:delegate];
        KGDelegate_WebSocketHandlerListener_1 * listener = [[KGDelegate_WebSocketHandlerListener_1 alloc] initWithWebSocketNativeDelegateHandler:self wsnChannel:wsnChannel];
        [delegate setListener:listener];
    
        [delegate processOpen];
    }@catch (NSException* e) {
        //LOG.log(Level.FINE, "During close processing: "+e.getMessage(), e);
        [_listener connectionFailed:wsnChannel exception:e];
    }
}

-(void)processClose:(KGWebSocketChannel *)channel code:(NSInteger)code reason:(NSString *)reason  {
    KGWebSocketNativeChannel * wsnChannel = (KGWebSocketNativeChannel *)channel;
    @try {
        KGWebSocketDelegateImpl * delegate = (KGWebSocketDelegateImpl *)[wsnChannel delegate];
        [delegate processDisconnect:code reason:reason];
    } @catch (NSException* e) {
        //LOG.log(Level.FINE, "During close processing: "+e.getMessage(), e);
        [_listener connectionFailed:wsnChannel exception:e];
    }
}

-(void)processTextMessage:(KGWebSocketChannel *)channel text:(NSString *)text {
    @throw [[NSException alloc] initWithName:@"IllegalStateException" reason:@"not implemented" userInfo:NULL];
  
}

-(void)processBinaryMessage:(KGWebSocketChannel *)channel buffer:(KGByteBuffer *)buffer {
    KGWebSocketNativeChannel * wsnChannel = (KGWebSocketNativeChannel *)channel;
    KGWebSocketDelegateImpl * delegate = (KGWebSocketDelegateImpl *)[wsnChannel delegate];
    [delegate processSend:[buffer data]];
}


-(void)setIdleTimeout:(KGWebSocketChannel *)channel timeout:(NSInteger)timeout {
    KGWebSocketNativeChannel * wsnChannel = (KGWebSocketNativeChannel *)channel;
    KGWebSocketDelegateImpl * delegate = (KGWebSocketDelegateImpl *)[wsnChannel delegate];
    [delegate setIdleTimeout:timeout];
}

-(void)processAuthorize:(KGWebSocketChannel *)channel authorizeToken:(NSString *)authorizeToken {
    KGWebSocketNativeChannel * wsnChannel = (KGWebSocketNativeChannel *)channel;
    KGWebSocketDelegateImpl * delegate = (KGWebSocketDelegateImpl *)[wsnChannel delegate];
    [delegate processAuthorize:authorizeToken];
}

-(void)setListener:(id<KGWebSocketHandlerListener>)listener{
    _listener = listener;
}
@end
