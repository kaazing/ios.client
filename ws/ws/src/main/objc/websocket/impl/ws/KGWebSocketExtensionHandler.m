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

#import "KGWebSocketExtensionHandler.h"
#import "KGWebSocketExtension.h"
#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketEmulatedChannel.h"

NSArray* Kaazing_Enterprise_Extensions = nil;

@interface KGExtension_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketExtensionHandler:(KGWebSocketExtensionHandler *)handler;

@end
@implementation KGExtension_WebSocketHandlerListener_1 {
    KGWebSocketExtensionHandler * _parent;
}

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithWebSocketExtensionHandler:(KGWebSocketExtensionHandler *)handler {
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}


- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{

    // add negotiated extensions from compositeChannel to this channel if extensionNegotiated returns YES
    KGWebSocketCompositeChannel* compChannel = (KGWebSocketCompositeChannel*)[channel parent];
    if ([[compChannel negotiatedExtensions] length] > 0) {
        NSURL *redirecturl = nil;
        if ([channel isKindOfClass:[KGWebSocketNativeChannel class]] && [(KGWebSocketNativeChannel*)channel redirectUri] != nil) {
            redirecturl = [[(KGWebSocketNativeChannel*)channel redirectUri] URI];
        }
        else if ([channel isKindOfClass:[KGWebSocketEmulatedChannel class]]) {
            redirecturl = [[(KGWebSocketEmulatedChannel*)channel redirectUri] URI];
        }
        NSMutableArray* notfound = [[NSMutableArray alloc] init];
        NSArray * extensions = [[compChannel negotiatedExtensions] componentsSeparatedByString:@","];
        for (int i=0; i< [extensions count]; i++) {
            NSString* extension = [extensions objectAtIndex:i];
            NSArray * tmp = [extension componentsSeparatedByString:@";"];
            NSString* extName = [[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            // found the extension in kaazing enterprise extensions
            KGWebSocketExtension* found = nil;
            if (Kaazing_Enterprise_Extensions != nil) {
                Class class =  NSClassFromString(@"KGWebSocketExtensions");
                SEL selector = NSSelectorFromString(@"getExtension:");
                if (class != nil && selector != nil) {
                    for (NSString* enterpriseExt in Kaazing_Enterprise_Extensions) {
                        if ([enterpriseExt isEqualToString:extName]) {
                            found = [class performSelector:selector withObject:extName];
                            break;
                        }
                    }
                    if (found != nil) {
                        NSMutableDictionary* wsContext = [[NSMutableDictionary alloc] init];
                        [wsContext setObject:[compChannel webSocket]  forKey:@"websocket"];
                        if (redirecturl != nil) {
                            [wsContext setObject:redirecturl forKey:@"redirecturl"];
                        }
                        if([found extensionNegotiated:wsContext response:extension]) {
#ifdef DEBU
                            NSLog(@"KGWebSocketExtensionHandler add extension %@ to pipeline", [found name]);
#endif
                            [channel addExtensionToPipeline:found];
                        }
                    }
                    else {
                        [notfound addObject:extName];
                    }
                }
            }
        }
        NSString* notfoundNames = @"";
        for (int i = 0; i < [notfound count]; i++) {
            if (i == 0) {
                notfoundNames = [notfound objectAtIndex:0];
            }
            else {
                notfoundNames = [notfoundNames stringByAppendingFormat:@", %@", [notfound objectAtIndex:i] ];
            }
        }
        [compChannel setNegotiatedExtensions:notfoundNames];
    }
    [[_parent listener] connectionOpened:channel protocol:protocol];
}
                
- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    [[_parent listener] redirected:channel location:location];
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
    [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionClosed:channel  exception:ex];
}

- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionFailed:channel exception:ex];
}
@end



@implementation KGWebSocketExtensionHandler


-(void)dealloc {
}

+ (void) initialize {
    //initialize enterprise extensions if framework is loaded
    if (Kaazing_Enterprise_Extensions == nil) {
        Kaazing_Enterprise_Extensions = [[NSMutableArray alloc] init];
        Class class =  NSClassFromString(@"KGWebSocketExtensions");
        SEL selector = NSSelectorFromString(@"addEnterpriseExtensions:");
        if (class != nil && selector != nil) {
            [class performSelector:selector withObject:Kaazing_Enterprise_Extensions];
#ifdef DEBUG
            NSLog(@"KGWebSocketExtensionHandler load Kaazing enterprise extensions");
#endif
        }
    }
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
           
- (void) handleBinaryMessageReceived:(KGWebSocketChannel *) channel message:(KGByteBuffer *) buf {
               
#ifdef DEBUG
   NSLog(@"[KGWebSocketExtensionHandler handleBinaryMessageReceived ");
#endif
    KGByteBuffer* buf1 = buf;
    for (KGWebSocketExtension* ext in [channel extensionPipeline]) {
        buf1 = [ext binaryMessageReceived: buf1];
        if (buf1 == nil) {
#ifdef DEBUG
            NSLog(@"[KGWebSocketExtensionHandler message handled by %@", [ext name]);
#endif
            return;
        }
    }
    [[self listener] messageReceived:channel buffer:buf1];
}

-(void)handleTextMessageReceived:(KGWebSocketChannel *)channel message:(NSString *)message {
#ifdef DEBUG
    NSLog(@"[KGWebSocketExtensionHandler handleTextMessageReceived ");
#endif
    NSString* msg = message;
    for (KGWebSocketExtension* ext in [channel extensionPipeline]) {
        msg = [ext textMessageReceived:msg];
        if (msg == nil) {
#ifdef DEBUG
            NSLog(@"[KGWebSocketExtensionHandler message handled by %@", [ext name]);
#endif
            return;
        }
    }
    [_listener textmessageReceived:channel text:msg];
}
                                  
- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    _nextHandler = handler;
    id<KGWebSocketHandlerListener> listnerImpl = [[KGExtension_WebSocketHandlerListener_1 alloc] initWithWebSocketExtensionHandler:self];
                                          
    [_nextHandler setListener:listnerImpl];
}
@end
