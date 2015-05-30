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

#import "KGWebSocket.h"
#import "KGWebSocket+Internal.h"
#import "KGWebSocketFactory.h"
#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocketCompositeHandler.h"
#import "KGWebSocketExtensionParameter+Internal.h"
#import "KGParameterValuesContainer.h"
#import "NSString+KZNGAdditions.h"
#import "KGTracer.h"
#import "KGWebSocketExtension+Internal.h"
#import "KGResumableTimer.h"

//<KGWebSocketHandlerListener>
@interface KGWebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener> {
    //private event queue
    dispatch_queue_t _eventQueue;
}

@end

@implementation KGWebSocketHandlerListener_1 {
}

- (void) init0 {
    _eventQueue = dispatch_queue_create("WebSocket KGEvent", DISPATCH_QUEUE_SERIAL);
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    
    return self;
}

- (void) dealloc {
    _eventQueue = nil;
}

- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol {
    dispatch_async(_eventQueue, ^{
        
        KGWebSocket* ws = [((KGWebSocketCompositeChannel *) channel) webSocket];
        
        // trigger the event on the BLOCK
        if (ws.didOpen) {
            @try {
                ws.didOpen(ws);
            }
            @catch (NSException *exception) {
                [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
            }
        }
        
        // notify delegate
        id<KGWebSocketDelegate> delegate = [ws delegate];
        if (delegate) {
            @try {
                [delegate webSocketDidOpen:ws];
            }
            @catch (NSException *exception) {
                [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
            }
        }
        
    });
}

/**
 * This method is called when a message is received on the WebSocket
 */
- (void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *)buf {
#ifdef DEBUG
    NSLog(@"[KGWebSocket messageReceived]");
#endif

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    dispatch_async(_eventQueue, ^{
        @try {
            KGWebSocket* ws = [((KGWebSocketCompositeChannel *) channel) webSocket];
            NSData *dataReceived = [buf getDataAt:0 size:[buf remaining]];
            // trigger the event on the BLOCK
            if (ws.didReceiveMessage) {
                @try {
                    ws.didReceiveMessage(ws, dataReceived);
                }
                @catch (NSException *exception) {
                    [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
                }
            }
            
            // notify delegate
            id<KGWebSocketDelegate> delegate = [ws delegate];
            if (delegate) {
                @try {
                    [delegate webSocket:ws didReceiveMessage:dataReceived];
                }
                @catch (NSException *exception) {
                    [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
                }
            }
        }
        @finally {
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    // Wait for the block execution to complete to avoid overwriting the buffers.
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    semaphore = nil;
}

/**
 * This method is called when a message is received on the WebSocket
 */
- (void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
        dispatch_async(_eventQueue, ^{
            
            KGWebSocket* ws = [((KGWebSocketCompositeChannel *) channel) webSocket];
    
            // trigger the event on the BLOCK
            if (ws.didReceiveMessage) {
                @try {
                    ws.didReceiveMessage(ws, text);
                }
                @catch (NSException *exception) {
                    [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
                }
            }
            
            // notify delegate
            id<KGWebSocketDelegate> delegate = [ws delegate];
            if (delegate) {
                @try {
                    [delegate webSocket:ws didReceiveMessage:text];
                }
                @catch (NSException *exception) {
                    [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
                }
            }
        });
}

/**
 * This method is called when the WebSocket is closed
 */
- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
        dispatch_async(_eventQueue, ^{
            
            KGWebSocket* ws = [((KGWebSocketCompositeChannel *) channel) webSocket];
            [ws cleanUpAfterClose];
            
            // trigger the event on the BLOCK
            if (ws.didClose) {
                @try {
                    ws.didClose(ws, code, reason, wasClean);
                }
                @catch (NSException *exception) {
                    [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
                }
            }
            
            // notify delegate
            id<KGWebSocketDelegate> delegate = [ws delegate];
            if (delegate) {
                @try {
                    [delegate webSocket:ws didCloseWithCode:code reason:reason wasClean:wasClean];
                }
                @catch (NSException *exception) {
                    [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
                }
            }
            
            [((KGWebSocketCompositeChannel *) channel) setWebSocket:nil];
            [[((KGWebSocketCompositeChannel *) channel) selectedChannel] setParent:nil];
            [[((KGWebSocketCompositeChannel *) channel) selectedChannel] setChallengeResponse:nil];
            [((KGWebSocketCompositeChannel *) channel) setSelectedChannel:nil];
            
            ws->_done = YES;

            // Make sure that the _webSocketThread exits for resources to be reclaimed.
            NSThread *currThread = [NSThread currentThread];
            if (currThread != ws->_webSocketThread) {
                [self performSelector:@selector(cancelWebSocketThread) onThread:ws->_webSocketThread withObject:NULL waitUntilDone:NO];
            }
            else {
                [self cancelWebSocketThread];
            }
        });
}

- (void) cancelWebSocketThread {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void) connectionClosed:(KGWebSocketChannel *)channel exception:(NSException *)ex {
    [self connectionClosed:channel wasClean:NO code:1006 reason:[ex reason]];
}

// NOTE: If the establish a WebSocket connection algorithm fails, it triggers the fail the WebSocket
// connection algorithm, which then invokes the close the WebSocket connection algorithm, which then
// establishes that the WebSocket connection is closed, which fires the close event as described below.

// When the WebSocket connection is closed, possibly cleanly, the user agent must queue a task to run
// the following substeps:

// 1. Change the readyState attribute's value to CLOSED (3).

// 2. If the user agent was required to fail the WebSocket connection or the WebSocket connection
//    is closed with prejudice, fire a simple event named error at the WebSocket object.
- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    dispatch_async(_eventQueue, ^{
        NSString *reason = [ex reason] ? [ex reason] : @"Failed to establish WebSocket connection";
        KGWebSocket* ws = [((KGWebSocketCompositeChannel *) channel) webSocket];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:reason, NSLocalizedFailureReasonErrorKey, nil];
        NSError *error = [NSError errorWithDomain:@"KGWebSocketErrorDomain" code:-1 userInfo:userInfo];
        
        // trigger the event on the BLOCK
        if (ws.didReceiveError) {
            @try {
                ws.didReceiveError(ws, error);
            }
            @catch (NSException *exception) {
                [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
            }
        }
        
        // notify delegate
        id<KGWebSocketDelegate> delegate = [ws delegate];
        if (delegate) {
            @try {
                [delegate webSocket:ws didReceiveError:error];
            }
            @catch (NSException *exception) {
                [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]]];
            }
        }
    });
}

- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    // Should never be fired from KGWebSocketCompositeHandler
}

- (void) authenticationRequested:(KGWebSocketChannel *) channel
                        location:(NSString*)location
                       challenge:(NSString*) challenge {
    // Should never be fired from KGWebSocketCompositeHandler
}

@end

@implementation KGWebSocket {
    KGWSURI                      *_uri;
    NSArray                      *_enabledProtocols;
    NSString                     *_negotiatedProtocol;
    KGWebSocketCompositeChannel  *_channel;
    KGWebSocketCompositeHandler  *_handler;
    id<KGWebSocketDelegate>      _delegate;
    NSMutableArray               *_negotiatedExtensions;
    NSMutableArray               *_enabledExtensions;
    NSMutableDictionary          *_enabledParameters; /*<NSString,KGWsExtensionParameterValuesContainer>*/
    NSMutableDictionary          *_negotiatedParameters; /*<NSString,KGWsExtensionParameterValuesContainer>*/
    KGChallengeHandler           *_challengeHandler;
    SecIdentityRef               _clientIdentity;
    int                          _connectTimeout;
}

static id<KGWebSocketHandlerListener> _handlerListener;

+ (void) initialize {
    _handlerListener = [[KGWebSocketHandlerListener_1 alloc] init];
}


-(void) dealloc {
    if (_channel != nil) {
        [_channel setWebSocket:nil];
        [[_channel selectedChannel] setParent:nil];
        [_channel setSelectedChannel:nil];
        [_channel setChallengeHandler:nil];
    }

    if (_negotiatedExtensions != nil) {
        [_negotiatedExtensions removeAllObjects];
    }
    
    if (_enabledExtensions != nil) {
        [_enabledExtensions removeAllObjects];
    }
    
    if (_negotiatedParameters != nil) {
        [_negotiatedParameters removeAllObjects];
    }

    if (_enabledParameters != nil) {
        [_enabledParameters removeAllObjects];
    }
    
    _uri = nil;
    _handler = nil;
    _delegate = nil;
    _enabledProtocols = nil;
    _negotiatedProtocol = nil;
    _channel = nil;
    _negotiatedExtensions = nil;
    _enabledExtensions = nil;
    _enabledParameters = nil;
    _negotiatedParameters = nil;
    _challengeHandler = nil;
    _webSocketThread = nil;
}

- (void) init0 {
    _enabledParameters = [[NSMutableDictionary alloc] init];
    _negotiatedParameters = [[NSMutableDictionary alloc] init];
    _connectTimeout = 0;

    //start wsRunLoop
    _webSocketThread = [[NSThread alloc] initWithTarget:self selector:@selector(startWsRunLoop) object:NULL];
    [_webSocketThread start];
}


- (id) init {
    NSString *msg = @"init is not a valid initializer for KGWebSocket. Please use KGWebSocketFactory to create KGWebSocket.";
    NSException *exception = [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                                     reason:msg
                                                   userInfo:nil];
    @throw exception;
}


#pragma mark <Internal Constructor>

- (id) initWithURL:(NSURL*)url
 enabledExtensions:(NSArray *)enabledExtensions
  enabledProtocols:(NSArray *)enabledProtocols
 enabledParameters:(NSDictionary *)enabledParameters
  challengeHandler:(KGChallengeHandler *)challengeHandler
    clientIdentity:(SecIdentityRef)clientIdentity
    connectTimeout:(int)connectTimeout {
    self = [super init];
    if (self) {
        [self init0];
        KGWSCompositeURI *compositeUri = [[KGWSCompositeURI alloc] initWithNSURL:url];
        _uri = [compositeUri WSEquivalent];
        _clientIdentity = clientIdentity;
        [self setEnabledExtensions:enabledExtensions];
        _challengeHandler = challengeHandler;
        _enabledProtocols = [NSArray arrayWithArray:enabledProtocols];
        [_enabledParameters addEntriesFromDictionary:enabledParameters];
        _channel = [[KGWebSocketCompositeChannel alloc] initWithLocation:compositeUri
                                                                  binary:NO];
        [_channel setWebSocket:self];
        [self setConnectTimeout:connectTimeout];
    }
    
    return self;
}

#pragma mark <Public Methods>

- (void) connect {
    if (self.readyState != KGReadyState_CLOSED) {
        [NSException raise:@"Illegal State"
                    format:@"Attempt to reconnect an existing open WebSocket."];
    }
    
    [_channel setClientIdentity:_clientIdentity];
    NSString  *extensions = [self rfc3864FormattedExtensions];
    [_channel setChallengeHandler:_challengeHandler];
    [_channel setEnabledExtensions:extensions];
    [self performSelector:@selector(connectInternal) onThread:_webSocketThread withObject:NULL waitUntilDone:NO];
}

- (void) close {
    [self close:0 reason:@""];
}

- (void) close:(NSInteger)code {
    [self close:code reason:@""];
}

- (void) close:(NSInteger)code reason:(NSString *)reason {
    [self validateCloseCode:code reason:reason];
    
    if (([self readyState] == KGReadyState_CLOSED) ||
        ([self readyState] == KGReadyState_CLOSING)) {
        // WebSocket is either closed or about to be closed.
        return;
    }
    
    // Wrap code an reason into an array to invoke selector
    NSNumber *codeNumber = [NSNumber numberWithInteger:code];
    NSArray  *closeParams = [NSArray arrayWithObjects:codeNumber, reason, nil];
    [self performSelector:@selector(closeInternal:)
                 onThread:_webSocketThread
               withObject:closeParams
            waitUntilDone:NO];
}

- (void) send:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        [self performSelector:@selector(sendText:) onThread:_webSocketThread withObject:data waitUntilDone:NO];
    }
    else if ([data isKindOfClass:[NSData class]]) {
        [self performSelector:@selector(sendBinary:) onThread:_webSocketThread withObject:data waitUntilDone:NO];
    }
    else {
        [NSException raise:@"NSInvalidArgumentException"
                    format:@"Invalid data type. It should be either NSString or NSData."];
    }
}

- (NSURL*) url {
    if (_channel == nil) {
        return nil;
    }
    
    return [_channel URL];
}

- (KGReadyState) readyState {
    if (_channel == nil) {
        return KGReadyState_CLOSED;
    }
    
    return [_channel readyState];
}

- (NSString *) negotiatedProtocol {
    return _negotiatedProtocol;
}

- (NSArray *) enabledProtocols {
    return [NSArray arrayWithArray:_enabledProtocols];
}

- (void) setEnabledProtocols:(NSArray *)protocols {
    _enabledProtocols = [NSArray arrayWithArray:protocols];
}

- (NSArray *) enabledExtensions {
    return [NSArray arrayWithArray:_enabledExtensions];
}

- (void) setEnabledExtensions:(NSArray *)extensions {
    if ([self readyState] != KGReadyState_CLOSED) {
        [NSException raise:@"Illegal State"
                    format:@"Extensions can be enabled only when the WebSocket is closed"];
    }
    
    if (extensions == nil) {
        _enabledExtensions = nil;
        return;
    }
    
    if (_enabledExtensions == nil) {
        _enabledExtensions = [[NSMutableArray alloc] init];
    }
    
    [_enabledExtensions addObjectsFromArray:extensions];
}

- (NSArray *) negotiatedExtensions {
    if ([self readyState] != KGReadyState_OPEN) {
        [NSException raise:@"Illegal State"
                    format:@"Extensions have not been negotiated as the webSocket as the WebSocket connection is not yet established"];
    }
    return [NSArray arrayWithArray:_negotiatedExtensions];
}


- (id) enabledParameter:(KGWebSocketExtensionParameter *)parameter {
    NSString *extensionName = [[parameter extension] name];
    KGParameterValuesContainer *paramValueContainer = [_enabledParameters objectForKey:extensionName];
    if (paramValueContainer == nil) {
        return nil;
    }
    
    return [paramValueContainer valueForParameter:parameter];

}

- (id) negotiatedParameter:(KGWebSocketExtensionParameter *)parameter {
    if ([self readyState] != KGReadyState_OPEN) {
        [NSException raise:@"Illegal State"
                    format:@"Extensions have not been negotiated as the webSocket is not yet connected"];
    }
    NSString *extensionName = [[parameter extension] name];
    KGParameterValuesContainer *paramValueContainer = [_negotiatedParameters objectForKey:extensionName];
    if (paramValueContainer == nil) {
        return nil;
    }
    return [paramValueContainer valueForParameter:parameter];

}

- (void) setEnabledParameter:(KGWebSocketExtensionParameter *)parameter value:(id)value {
    if ([self readyState] != KGReadyState_CLOSED) {
        [NSException raise:@"Illegal State"
                    format:@"ExtensionParameters can be set only when the WebSocket is closed"];
    }
    
    // If the type of the value does not match the type specified in
    // corresponding KGWebSocketExtensionParameter, throw an exception.
    if (![value isKindOfClass:[parameter type]]) {
        [NSException raise:@"NSInvalidArgumentException"
                    format:@"Invalid value type. It should %@.", NSStringFromClass([parameter type])];
        
    }
    
    NSString *extensionName = [[parameter extension] name];
    
    KGParameterValuesContainer *paramValueContainer = [_enabledParameters objectForKey:extensionName];
    if (paramValueContainer == nil) {
        paramValueContainer = [[KGParameterValuesContainer alloc] init];
        [_enabledParameters setObject:paramValueContainer forKey:extensionName];
    }
    
    [paramValueContainer setValue:value forParameter:parameter];
}

- (id<KGWebSocketDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate:(id<KGWebSocketDelegate>)delegate {
    _delegate = delegate;
}

- (KGChallengeHandler *) challengeHandler {
    return _challengeHandler;
}

- (void) setChallengeHandler:(KGChallengeHandler *)challengeHandler {
    _challengeHandler = challengeHandler;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}

- (void) setClientIdentity:(SecIdentityRef)clientIdentity {
    _clientIdentity = clientIdentity;
}

- (int) connectTimeout {
    return _connectTimeout;
}

- (void) setConnectTimeout:(int)connectTimeout {
    if (connectTimeout < 0) {
        NSException *exception = [[NSException alloc] initWithName:@"NSInvalidArgumentException"
                                                            reason:@"Connect timeout cannot be negative"
                                                          userInfo:nil];
        @throw exception;
    }

    _connectTimeout = connectTimeout;
}

#pragma mark <Methods accessible within framework>

- (void) setHandler:(KGWebSocketCompositeHandler *)handler {
    _handler = handler;
    [_handler setListener:_handlerListener];
}

- (void) addNegotiatedExtension:(NSString *)extension {
    if (_negotiatedExtensions == nil) {
        _negotiatedExtensions = [[NSMutableArray alloc] init];
    }
    
    NSArray              *extensionElements = [extension componentsSeparatedByString:@";"];
    NSString             *extensionName = extensionElements[0];
    KGWebSocketExtension *negotiatedExtension = [KGWebSocketExtension extensionWithName:extensionName];
    
    // The negotiated extension should be one of the enabled extensions
    if (![_enabledExtensions containsObject:extensionName]) {
        NSString *reason = [NSString stringWithFormat:@"Extension '%@' is not an enabled extension. So it should not have been negotiated", extensionName];
        NSException *exception = [NSException exceptionWithName:@"WebSocketException" reason:reason userInfo:nil];
        [self handleException:exception];
        return;
    }
    
    [_negotiatedExtensions addObject:extensionName];
    if ([extensionElements count] > 1) {
        
        for (int i = 1; i < [extensionElements count]; i++) {
            NSString                      *paramValueString = extensionElements[1];
            NSArray                       *paramValueElements = [paramValueString componentsSeparatedByString:@"="];
            NSArray                       *anonymousParameters = [negotiatedExtension parametersWithMetadata:[NSArray arrayWithObjects:ANONYMOUS, nil]];
            NSEnumerator                  *anonymousParameterEnumerator = [anonymousParameters objectEnumerator];
            KGWebSocketExtensionParameter *parameter = nil;
            NSString                      *paramValue = nil;
            
            // Occassionally, negotiated extension can have value sent by the server
            // For example: In case of revalidate extension, server sends the escape key
            if ([paramValueElements count] == 1) {
                parameter = [anonymousParameterEnumerator nextObject];
                paramValue = [paramValueElements[0] trim];
            }
            else if ([paramValueElements count] == 2) {
                parameter = [negotiatedExtension parameter:paramValueElements[0]];
                paramValue = [paramValueElements[1] trim];
            }
            id value;
            if ([parameter type] == [NSString class]) {
                value = paramValue;
            }
            else {
                value = [negotiatedExtension stringToParameterValue:parameter value:paramValue];
            }
            [self setNegotiatedParameter:parameter value:value];
        }
    }    
}

- (void) setNegotiatedProtocol:(NSString *)protocol {
    _negotiatedProtocol = protocol;
}

- (void) cleanUpAfterClose {
    [_negotiatedParameters removeAllObjects];
    _negotiatedExtensions= nil;
    _negotiatedProtocol = nil; 
}

#pragma mark <Private Methods>

- (void) setNegotiatedParameter:(KGWebSocketExtensionParameter *)parameter value:(id)value {
    NSString *extensionName = [[parameter extension] name];
    KGParameterValuesContainer *paramValueContainer = [_negotiatedParameters objectForKey:extensionName];
    if (paramValueContainer == nil) {
        paramValueContainer = [[KGParameterValuesContainer alloc] init];
        [_negotiatedParameters setObject:paramValueContainer forKey:extensionName];
    }
    [paramValueContainer setValue:value forParameter:parameter];
}

// The method creates extension string to negotiate from
// extension elements - definition objects (KGWebSocketExtension) and
// corresponding value objects (KGWsExtensionParameterValue).
// It is used internally by the KGCreateHandler and KGWebSocketNativeHandshakeHandler
// during handshake to set extension header.
- (NSString *) rfc3864FormattedExtensions {
    NSMutableArray *extensionStringArray = [[NSMutableArray alloc] init];
    for (NSString *extensionName in _enabledExtensions) {
        // Step 1. The first part of extension string is the extension name
        NSMutableArray *currentExtensionElements = [[NSMutableArray alloc] initWithObjects:extensionName, nil];
        KGWebSocketExtension *extension = [KGWebSocketExtension extensionWithName:extensionName];
        NSArray *parameters = [extension parameters];
        KGParameterValuesContainer *paramValueContainer = [_enabledParameters objectForKey:extensionName];
        for (KGWebSocketExtensionParameter *parameter in parameters) {
            id value = [paramValueContainer valueForParameter:parameter];
            
            // Pre-Condition: The value of the parameter(s) marked required should be available
            if ((paramValueContainer == nil) || (value == nil)) {
                if ([parameter isRequired]) {
                    [NSException raise:@"Illegal State"
                                format:@"Extension '%@': Required parameter '%@' must be set.", extensionName, [parameter name]];
                }
                else {
                    // if parameter is not required and value is not set, skip it
                    continue;
                }
            }
            
            // If the parameter is temporal, it is not meant to be put on wire
            if (![parameter isTemporal]) {
                
                NSMutableString *paramValueString = [[NSMutableString alloc] init];
                
                // If the parameter is anonymous, the name of the parameter is not
                // put on the wire
                if (![parameter isAnonymous]) {
                    [paramValueString appendFormat:@"%@=",[parameter name]];
                }
                NSString *valueAsString;
                if ([value isKindOfClass:[NSString class]]) {
                    valueAsString = (NSString *)value;
                }
                else {
                    valueAsString = [extension parameterValueToString:parameter value:value];
                }
                [paramValueString appendString:valueAsString];
                [currentExtensionElements addObject:paramValueString];
            }
        }
        NSString *extensionString = [currentExtensionElements componentsJoinedByString:@";"];
        [extensionStringArray addObject:extensionString];
    }
    
    // multiple extensions are separated by ','
    return [extensionStringArray componentsJoinedByString:@","];
}

- (void) connectInternal {
    @try {
        // If _connectTimeout == 0, then it means there is no timeout.
        if (_connectTimeout > 0) {
            KGResumableTimer *connTimer = [[KGResumableTimer alloc] initWithTarget:self
                                                                             delay:_connectTimeout
                                                             updateDelayWhenPaused:NO];
            connTimer.didTimerFire = ^(id target) {
                KGWebSocket *ws = (KGWebSocket *)target;
                
                if ([ws readyState] == KGReadyState_CONNECTING) {
                    // Inform the app by raising the CLOSE event.
                    [_handler doClose:_channel wasClean:NO code:1006 reason:@"Connection timeout"];
                    
                    // Try closing the connection all the way down. This may
                    // block when there is a network loss. That's why we are
                    // first informing the application about the connection
                    // timeout.
                    [_handler processClose:_channel code:0 reason:@"Connection timeout"];
                }
                [_channel setConnectTimer:nil];
            };
            
            [_channel setConnectTimer:connTimer];
            [connTimer start];
        }

        [_handler processConnect:_channel location:_uri requestedProtocols:_enabledProtocols];
    }
    @catch (NSException* exception) {
        [self handleException:exception];
    }
}

- (void) sendBinary:(NSData *)data {
    KGByteBuffer * buffer = [KGByteBuffer wrapData:data];
    @try {
        [_handler processBinaryMessage:_channel buffer:buffer];
    }
    @catch (NSException *exception) {
        [self handleException:exception];
    }

}

- (void) sendText:(NSString *)data {
    @try {
        [_handler processTextMessage:_channel text:data];
    }
    @catch (NSException *exception) {
        [self handleException:exception];
    }
}

- (void) closeInternal:(NSArray *)closeParams {
    NSNumber  *codeNumber = [closeParams objectAtIndex:0];
    NSInteger code = [codeNumber integerValue];
    NSString  *reason = [closeParams objectAtIndex:1];

    @try {
        
        [_handler processClose:_channel code:code reason:reason];
    }
    @catch (NSException* exception) {
        [self handleException:exception];
    }
}

- (void) handleException:(NSException*)exception {
#ifdef DEBUG
    NSLog(@"EXCEPTION: %@", [exception reason]);
#endif
    // close the connection
    if ([self readyState] == KGReadyState_OPEN) {
        [self closeInternal:[NSArray arrayWithObjects:@0, @"", nil]];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[exception reason], NSLocalizedFailureReasonErrorKey, nil];
    NSError *error = [NSError errorWithDomain:@"KGWebSocketErrorDomain" code:-1 userInfo:userInfo];
    if (_didReceiveError) {
        _didReceiveError(self, error);
    }
    
    if (_delegate) {
        [_delegate webSocket:self didReceiveError:error];
    }
}

- (void) validateCloseCode:(NSInteger)code reason:(NSString *)reason {
    // If code is present, it must equal to 1000 or in range 3000 to 4999
    // If the code is 0, it is regarded as not present
    if ((code > 0) &&
        (code != 1000) &&
        (code < 3000 || code > 4999)) {
        [NSException raise:NSInvalidArgumentException
                    format:@"code must be equal to 1000 or in range 3000 to 4999"];
        
    }
    
    // If reason is present, it must not be longer than 123 bytes
    if ((reason != nil) &&
        ([reason length] > 0)) {
        NSData *encodedReason = [reason dataUsingEncoding:NSUTF8StringEncoding];
        if ([encodedReason length] > 123) {
            [NSException raise:NSInvalidArgumentException
                        format:@"reason cannot be longer than 123 bytes"];
        }
    }
}

- (void) startWsRunLoop {
    _done = NO;
    
    while (!_done) {
        CFRunLoopRun();
    }
    [KGTracer trace:@"wsRunLoop finished"];
}

@end

