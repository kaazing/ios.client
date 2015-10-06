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
#import "KGWebSocketNativeBalancingHandler.h"
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketHandshakeObject.h"
#import "KGWSURI.h"

@interface KGBalancer_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketNativeBalancingHandler:(KGWebSocketNativeBalancingHandler *)handler;

@end
@implementation KGBalancer_WebSocketHandlerListener_1 {
    KGWebSocketNativeBalancingHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithWebSocketNativeBalancingHandler:(KGWebSocketNativeBalancingHandler *)handler {
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}


- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
        /* We have to wait until the balancer responds for kaazing gateway */
    if (![KAAZING_EXTENDED_HANDSHAKE isEqualToString:protocol]) {
                //Non-kaazing gateway, fire open event
        KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
        [wsChannel setBalanced:(2)]; //turn off balancer message check
        [[_parent listener] connectionOpened:channel protocol:protocol];
    }
        
}

- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
#ifdef DEBUG
    NSLog(@"Balancer redirect location = %@", location);
#endif
    @try {
                
        KGWSURI * uri = [[KGWSURI alloc] initWithURI:location];
        [_parent reconnect:channel uri:uri protocol:channel.protocol];
                //nextHandler.processClose(channel, 0, null);
        [[_parent nextHandler] processClose:channel code:0 reason:@""];
    } @catch (id e) {
        [[_parent listener] connectionFailed:channel exception:e];
    }
}

- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    [[_parent listener] authenticationRequested:channel location:location challenge:challenge];
}

-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    [_parent handleTextMessageReceived:channel message:text];
}

-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    [_parent handleBinaryMessageReceived:channel message:buf];
        
    //    NSString* balancerMessage = [[NSString alloc] initWithData:[buf array] encoding:NSUTF8StringEncoding];
    //    [_parent handleTextMessageReceived:channel message:balacnerMessage];
        
}

- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
    KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
        
        // TODO use Chai's Atomic Boolean
        //if (wsChannel.reconnecting.compareAndSet(true, false)) {
    if ([wsChannel reconnecting] == YES) {
        [wsChannel setReconnecting:NO];

        //balancer redirect, open a new connection to redirectUri
        [wsChannel setReconnected:YES];
        NSMutableArray *nextProtocols = [[NSMutableArray alloc] init];
        NSArray        *requestedProtocols = [wsChannel requestedProtocols];
        [nextProtocols addObject:KAAZING_EXTENDED_HANDSHAKE];
        for (NSString *protocol in requestedProtocols) {
            if (protocol != nil) {
                NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *trimmedProtocol = [protocol stringByTrimmingCharactersInSet:charSet];
                if ([trimmedProtocol length] > 0) {
                    [nextProtocols addObject:trimmedProtocol];
                }
            }
        }
                
        [_parent processConnect:channel location:wsChannel.redirectUri requestedProtocols:nextProtocols];
    }
    else {
        [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
    }
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
    [[_parent listener] connectionClosed:channel  exception:ex];
    [wsChannel setDelegate:nil];
}

- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
    [[_parent listener] connectionFailed:channel exception:ex];
    [wsChannel setDelegate:nil];
}
@end



@implementation KGWebSocketNativeBalancingHandler


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
    NSLog(@"[KGWebSocketNativeBalancingHandler processConnect ");
#endif
    KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
    [wsChannel setBalanced:0];
    [_nextHandler processConnect:channel location:(KGWSURI *)[location addQueryParameter:@".kl=Y"] requestedProtocols:requestedProtocols];
} 
           
- (void) reconnect:(KGWebSocketChannel *) channel uri:(KGWSURI *) uri protocol:(NSString*) protocol {
     KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
       [wsChannel setRedirectUri:uri];
       [wsChannel setBalanced:0];
           // TODO: use AtomicBool
           //[wsChannel.reconnecting.compareAndSet(false, true);
       if ([wsChannel reconnecting] == NO) {
           [wsChannel setReconnecting:YES];
       }
}
           
- (void) handleBinaryMessageReceived:(KGWebSocketChannel *) channel message:(KGByteBuffer *) buf {
               
#ifdef DEBUG
   NSLog(@"[KGWebSocketNativeBalancingHandler handleBinaryMessageReceived ");
#endif
    KGWebSocketNativeChannel * wsChannel = (KGWebSocketNativeChannel *)channel;
                      
    if ([wsChannel balanced] > 1 ) {
        [[self listener] messageReceived:channel buffer:buf];
        return;
    }
    int position = [buf position];
    NSString* message = [buf getString];
    [buf setPosition:position];
    //if ([wsChannel balanced] <= 1 && [message length] > 2 && [message characterAtIndex:0] == '\uf0ff'){
    if ([message length] >= 2 && [message characterAtIndex:0] == 61695){
        int code = [message characterAtIndex:1];
        if (code == 'N') {
            /* Balancer responded, fire open event */
            // NOTE: this will cause OPEN to fire twice on the same channel, but it is currently
            // required because the Gateway sends a balancer message both before and after the
            // Extended Handshake.
        
            // TODO: Chai..
            int value = [wsChannel balanced] + 1;
            [wsChannel setBalanced:value];
            if (value == 1) {
                [[self listener] connectionOpened:channel protocol:KAAZING_EXTENDED_HANDSHAKE];
            }
            else {
                [[self listener] connectionOpened:channel protocol:@""];
            }
        }
        else if (code == 'R') {
            @try {
                NSString* reconnectLocation = [message substringFromIndex:2];
                //LOG.finest("Balancer redirect location = " + StringUtils.stripControlCharacters(reconnectLocation));
                
                KGWSURI * uri = [[KGWSURI alloc] initWithURI:reconnectLocation];
                [self reconnect:channel uri:uri protocol:[channel protocol]];
                [[self nextHandler] processClose:channel code:0 reason:@""];
            } @catch (id e) {
                //LOG.log(Level.WARNING, e.getMessage(), e);
                [[self listener] connectionFailed:channel exception:e];
            }
        }
        else {
            [[self listener] messageReceived:channel buffer:buf];
        }
    }
    else {
        [[self listener] messageReceived:channel buffer:buf];
    }
}
                                  
- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    _nextHandler = handler;
    id<KGWebSocketHandlerListener> listnerImpl = [[KGBalancer_WebSocketHandlerListener_1 alloc] initWithWebSocketNativeBalancingHandler:self];
                                          
    [_nextHandler setListener:listnerImpl];
}
                                  
-(void)handleTextMessageReceived:(KGWebSocketChannel *)channel message:(NSString *)message {
    [_listener textmessageReceived:channel text:message];
}
@end
