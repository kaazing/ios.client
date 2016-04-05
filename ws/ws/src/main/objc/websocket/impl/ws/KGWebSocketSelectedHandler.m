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
#import "KGWebSocketSelectedHandler.h"
#import "KGWebSocketSelectedChannel.h"
#import "KGWebSocketCompositeChannel.h"

///////// "inner classes"
/// NEED TO BE ON THE TOP
@interface KGSelected_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketSelectedHandler:(KGWebSocketSelectedHandler *)webSocketSelectedHandler;

@end
@implementation KGSelected_WebSocketHandlerListener_1
    KGWebSocketSelectedHandler * _parent;

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
-(id)initWithWebSocketSelectedHandler:(KGWebSocketSelectedHandler *)webSocketSelectedHandler {
   self =  [self init];
    if (self) {
        _parent = webSocketSelectedHandler;
    }
    return self;
}

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"[KGSelected_WebSocketHandlerListener_1 dealloc]");
#endif
    _parent = nil;
}

//// "Listener" / Delegate:
/**
 * This method is called when the WebSocket is opened
 */
- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
    [_parent handleConnectionOpened:channel protocol:protocol];
}

/**
 * This method is called when a redirect response is 
 */
- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    //nope
}

/**
 * This method is called when authentication is requested 
 */
- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    //nope
}

/**
 * This method is called when a message is received on the WebSocket
 */
-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    [_parent handleMessageReceived:channel message:buf];
}
/**
 * This method is called when a message is received on the WebSocket
 */
-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    [_parent handleTextMessageReceived:channel message:text];
}

/**
 * This method is called when the WebSocket is closed
 */
- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason {
#ifdef DEBUG
    NSLog(@"[KGWebSocketSelectedHandler (KGSelected_WebSocketHandlerListener_1) connectionClosed]");
#endif
    [_parent handleConnectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
#ifdef DEBUG
    NSLog(@"[KGWebSocketSelectedHandler (KGSelected_WebSocketHandlerListener_1) connectionClosed ]");
#endif
    [_parent handleConnectionClosed:channel wasClean:NO code:1006 reason:[ex reason]];
}

/**
 * This method is called when a connection fails
 */
- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [_parent handleConnectionFailed:channel exception:ex];
}
@end

/// the class
///
///
@implementation KGWebSocketSelectedHandler
    //id <KGWebSocketHandler> _nextHandler;

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

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"[KGWebSocketSelectedHandler dealloc]");
#endif
}



-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *)requestedProtocols{
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *) channel;
    if (selectedChannel.readyState == KGReadyState_CLOSED) {
        //        throw new IllegalStateException("WebSocket is already closed");
    }
    
    [_nextHandler processConnect:channel location:location requestedProtocols:requestedProtocols];
}

-(void) processClose:(KGWebSocketChannel *) channel  code:(NSInteger)code reason:(NSString *)reason {
#ifdef DEBUG
    NSLog(@"[KGWebSocketSelectedHandler processClose]");
#endif
    KGWebSocketSelectedChannel * ch = (KGWebSocketSelectedChannel *) channel;
    if (ch.readyState == KGReadyState_OPEN || ch.readyState == KGReadyState_CONNECTING) {
        ch.readyState = KGReadyState_CLOSING;
        [_nextHandler processClose:channel code:code reason:reason];
    }    
    
}
    

-(void) handleConnectionOpened:(KGWebSocketChannel *) channel protocol:(NSString*) protocol {
//    LOG.entering(CLASS_NAME, "handleConnectionOpened");
//    
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *) channel;
    if (selectedChannel.readyState == KGReadyState_CONNECTING) {
        selectedChannel.readyState = KGReadyState_OPEN;
        KGWebSocketCompositeChannel *parent = 
                       (KGWebSocketCompositeChannel *)[selectedChannel parent];
        [parent setProtocol:[selectedChannel protocol]];
        [_listener connectionOpened:channel protocol:protocol];
    }
}

-(void) handleMessageReceived:(KGWebSocketChannel *) channel message:(KGByteBuffer *) message {
//    LOG.entering(CLASS_NAME, "handleMessageReceived", message);
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *) channel;
    if (selectedChannel.readyState != KGReadyState_OPEN) {
        return;
    }
    [_listener messageReceived:channel buffer:message];
    
}

-(void) handleTextMessageReceived:(KGWebSocketChannel *) channel message:(NSString*) message {
    //    LOG.entering(CLASS_NAME, "handleTextMessageReceived", message);
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *) channel;
    if (selectedChannel.readyState != KGReadyState_OPEN) {
        return;
    }
    [_listener textmessageReceived:channel text:message];
    
}

-(void) handleConnectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
#ifdef DEBUG
    NSLog(@"[KGWebSocketSelectedHandler handleConnectionClosed]");
#endif

    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *)channel;
    if (selectedChannel.readyState != KGReadyState_CLOSED) {
        selectedChannel.readyState = KGReadyState_CLOSED;
        [_listener connectionClosed:channel  wasClean:wasClean code:code reason:reason];
    }
}
-(void)handleConnectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    KGWebSocketSelectedChannel * selectedChannel = (KGWebSocketSelectedChannel *)channel;
    if (selectedChannel.readyState != KGReadyState_CLOSED) {
        selectedChannel.readyState = KGReadyState_CLOSED;
        [_listener connectionFailed:channel exception:ex];
    }
}

- (void) setNextHandler:(id <KGWebSocketHandler>)handler{
    
    _nextHandler = handler;
    KGSelected_WebSocketHandlerListener_1 * webSocketHandlerListener = [[KGSelected_WebSocketHandlerListener_1 alloc] initWithWebSocketSelectedHandler:self];
    [_nextHandler setListener:webSocketHandlerListener];
    
}

@end
