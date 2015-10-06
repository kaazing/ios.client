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
#import "KGWebSocketCompositeHandler.h"
#import "KGWebSocketEmulatedChannel.h"
#import "KGWebSocketEmulatedHandler.h"
#import "KGWebSocketCompositeChannel.h"
#import "KGWebSocketSelectedChannel.h"
#import "KGWebSocketNativeHandler.h"
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketExtension.h"
#import "KGWebSocketFactory.h"
#import "KGWebSocket+Internal.h"
#import "NSString+KZNGAdditions.h"

@protocol KGWebSocketSelectedChannelFactory <NSObject>

-(KGWebSocketSelectedChannel *) createChannel:(KGWSURI *) location binary:(BOOL)binary;

@end


@interface KGWebSocketStrategy : NSObject {
    @protected
    NSString* _nativeEquivalent;
    id<KGWebSocketHandler> _handler;
    id<KGWebSocketSelectedChannelFactory> _channelFactory;
}
-(id)initWithNativeEquivalent:(NSString*) nativeEquivalent handler:(id<KGWebSocketHandler>)handler channelFactory:(id<KGWebSocketSelectedChannelFactory>) channelFactory;
-(id<KGWebSocketHandler>)handler;
-(id<KGWebSocketSelectedChannelFactory>)channelFactory;

@end

@implementation KGWebSocketStrategy

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithNativeEquivalent:(NSString*) nativeEquivalent handler:(id<KGWebSocketHandler>)handler channelFactory:(id<KGWebSocketSelectedChannelFactory>) channelFactory {
    self = [self init];
    if (self) {
        _nativeEquivalent = nativeEquivalent;
        _handler = handler;
        _channelFactory = channelFactory;
    }
    return self;
}

-(id<KGWebSocketHandler>)handler {
    return _handler;
}

-(id<KGWebSocketSelectedChannelFactory>)channelFactory {
    return _channelFactory;
}

@end

// another factory..
@interface WebSocketSelectedHandlerFactoryImpl : NSObject<KGWebSocketSelectedHandlerFactory>
@end

@implementation WebSocketSelectedHandlerFactoryImpl

-(KGWebSocketSelectedHandler *)createSelectedHandler {
    KGWebSocketSelectedHandler * selectedHandler = [[KGWebSocketSelectedHandler alloc] init];
    return selectedHandler;
}

@end


@interface WebSocketSelectedChannelFactory_Emulated : NSObject<KGWebSocketSelectedChannelFactory>
@end

@implementation WebSocketSelectedChannelFactory_Emulated

- (id) init {
    self = [super init];
    return self;
}

-(KGWebSocketSelectedChannel *) createChannel:(KGWSURI *) location binary:(BOOL)binary{
    KGWebSocketEmulatedChannel * emulatedChannel = [[KGWebSocketEmulatedChannel alloc] initWithLocation:location binary:binary];
    
    return emulatedChannel;
}
@end


@interface WebSocketSelectedChannelFactory_Native : NSObject<KGWebSocketSelectedChannelFactory>
@end

@implementation WebSocketSelectedChannelFactory_Native

- (id)init {
    self = [super init];
    return self;
}

-(KGWebSocketSelectedChannel *) createChannel:(KGWSURI *) location binary:(BOOL)binary{
    KGWebSocketNativeChannel * nativeChannel = [[KGWebSocketNativeChannel alloc] initWithLocation:location binary:binary];
    return nativeChannel;
}
@end


@interface Composite_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>
@end

@implementation Composite_WebSocketHandlerListener_1
    KGWebSocketCompositeHandler * _parentHandler;

- (id)init {
    self = [super init];
    return self;
}

-(id)initWithWebSocketCompositeHandler:(KGWebSocketCompositeHandler *)webSocketCompositeHandler {
    self = [self init];
    if (self) {
        _parentHandler = webSocketCompositeHandler;
    }
    return self;
}


//// "Listener" / Delegate:
/**
 * This method is called when the WebSocket is opened
 */
- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler connectionOpened]");
#endif
    KGWebSocketCompositeChannel *parent = (KGWebSocketCompositeChannel *)channel.parent;
    [parent setProtocol:protocol];
    [_parentHandler doOpen:parent];
}

/**
 * This method is called when a message is received on the WebSocket
 */
-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler messageReceived]");
#endif
    KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel.parent;
    id <KGWebSocketHandlerListener> listener = [_parentHandler listener];
    
    [listener messageReceived:parent buffer:buf];
}

/**
 * This method is called when a message is received on the WebSocket
 */
-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString *)text {
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler textmessageReceived]");
#endif
    KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel.parent;
    id <KGWebSocketHandlerListener> listener = [_parentHandler listener];
    
    [listener textmessageReceived:parent text:text];
}

/**
 * This method is called when the WebSocket is closed
 */
- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason {
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler connectionClosed]");
#endif
    KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel.parent;
    if (parent.readyState == KGReadyState_CONNECTING && !channel.authenticationReceived) {
        [self cleanup:channel];
        [_parentHandler fallbackNext:parent exception:nil];
    }
    else {
        [_parentHandler doClose:parent wasClean:wasClean code:code reason:reason];
        [self cleanup:channel];
    }
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
#ifdef DEBUG
    //NSLog(@"[KGWebSocketCompositeHandler connectionFailed]");
#endif
    KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel.parent;
    if (parent.readyState == KGReadyState_CONNECTING &&!channel.authenticationReceived) {
        [self cleanup:channel];
        [_parentHandler fallbackNext:parent exception:ex];
    }
    else {
        if (ex == nil) {
            [_parentHandler doClose:parent wasClean:NO code:1006 reason:nil];
        }
        else {
            [_parentHandler doClose:parent exception:ex];
        }
        [self cleanup:channel];
    }
}

/**
 * This method is called when a connection fails
 */
- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
#ifdef DEBUG
    //NSLog(@"[KGWebSocketCompositeHandler connectionFailed]");
#endif
    KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel.parent;
    if (parent.readyState == KGReadyState_CONNECTING &&!channel.authenticationReceived) {
        [self cleanup:channel];
        [_parentHandler fallbackNext:parent exception:ex];
    }
    else {
        [_parentHandler doClose:parent wasClean:NO code:1006 reason:NULL];
        [self cleanup:channel];
    }
}

/**
 * This method is called when a redirect response is 
 */
- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    // redirect should not reach here
}

/**
 * This method is called when authentication is requested 
 */
- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    // authenticate should not reach here
}

- (void) cleanup:(KGWebSocketChannel *)channel {
    KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel.parent;
    
    // Clean up the references to the KGWebSocketCompositeChannel in the
    // selected channel so that it can be garbage collected.
    KGWebSocketSelectedChannel *selectedChannel = (KGWebSocketSelectedChannel *)channel;
    if (selectedChannel != nil) {
        [selectedChannel setParent:nil];
        if ([selectedChannel class] == [KGWebSocketNativeChannel class]) {
            [((KGWebSocketNativeChannel *)selectedChannel) setDelegate:nil];
        }
        else if ([selectedChannel class] == [KGWebSocketEmulatedChannel class]) {
            // ### TODO -- If there is any more cleanup needed for emulated.
        }
    }
    
    // Similarly, clean up the reference to the KGWebSocketSelectedChannel in
    // composite channel.
    [parent setSelectedChannel:nil];
}

@end

/// the class
///
///
static id<KGWebSocketSelectedHandlerFactory> selectHandlerFactory = nil;

@implementation KGWebSocketCompositeHandler {
    id<KGWebSocketHandlerListener> _listener;
    NSMutableDictionary* strategyChoices;
    NSMutableDictionary* strategyMap;
    id<KGWebSocketSelectedChannelFactory> EMULATED_FACTORY;
    id<KGWebSocketSelectedChannelFactory> NATIVE_FACTORY;
}

-(void)dealloc{
    _listener = nil;
    strategyChoices = nil;
    strategyMap = nil;
    EMULATED_FACTORY = nil;
    NATIVE_FACTORY = nil;
    selectHandlerFactory = nil;
}

- (void) init0{
    // Top level class - no need to call [super init0]

    //hack... TODO: (for testing...)
    if (selectHandlerFactory == nil) {
        selectHandlerFactory = [[WebSocketSelectedHandlerFactoryImpl alloc] init];
    }

    NATIVE_FACTORY = [[WebSocketSelectedChannelFactory_Native alloc] init];
    nativeHandler = [self createNativeHandler];
    
    EMULATED_FACTORY = [[WebSocketSelectedChannelFactory_Emulated alloc] init];
    emulatedHandler = [self createEmulatedHandler];
    
    // init the 'maps':
    strategyChoices = [[NSMutableDictionary alloc] init];
    strategyMap = [[NSMutableDictionary alloc] init];
    
    
    NSMutableArray * wsStrategies = [[NSMutableArray alloc] init];
    [wsStrategies addObject:@"ios:ws"];
    [wsStrategies addObject:@"ios:wse"];
    
    NSMutableArray * wssStrategies = [[NSMutableArray alloc] init];
    [wssStrategies addObject:@"ios:wss"];
    [wssStrategies addObject:@"ios:wse+ssl"];
    
    [strategyChoices setValue:wsStrategies forKey:@"ws"];
    [strategyChoices setValue:wssStrategies forKey:@"wss"];
  
    [strategyMap setValue:[[KGWebSocketStrategy alloc] initWithNativeEquivalent:@"ws" handler:nativeHandler channelFactory:NATIVE_FACTORY] forKey:@"ios:ws"];
    [strategyMap setValue:[[KGWebSocketStrategy alloc] initWithNativeEquivalent:@"wss" handler:nativeHandler channelFactory:NATIVE_FACTORY] forKey:@"ios:wss"];
    [strategyMap setValue:[[KGWebSocketStrategy alloc] initWithNativeEquivalent:@"ws" handler:emulatedHandler channelFactory:EMULATED_FACTORY] forKey:@"ios:wse"];
    [strategyMap setValue:[[KGWebSocketStrategy alloc] initWithNativeEquivalent:@"wss" handler:emulatedHandler channelFactory:EMULATED_FACTORY] forKey:@"ios:wse+ssl"];
}


- (id)init {
    self = [super init];
    if (self) {
        // Top level class - must call init0
        [self init0];
    }
    return self;
}

static KGWebSocketCompositeHandler *handler;

+ (void) initialize {
    handler = [[KGWebSocketCompositeHandler alloc] init];
}

+ (KGWebSocketCompositeHandler *) compositeHandler {
    return handler;
}

//// private section ////
-(KGWebSocketSelectedHandler *) createEmulatedHandler {
    KGWebSocketSelectedHandler * _selectedHandler = [selectHandlerFactory createSelectedHandler];
    KGWebSocketEmulatedHandler * _emulatedHandler = [[KGWebSocketEmulatedHandler alloc] init];
    
    [_selectedHandler setListener:[self createListener]];
    [_selectedHandler setNextHandler:_emulatedHandler];
    
    
    return _selectedHandler;
}

-(KGWebSocketSelectedHandler *) createNativeHandler {
    KGWebSocketSelectedHandler * _selectedHandler = [selectHandlerFactory createSelectedHandler];
    KGWebSocketNativeHandler * _nativeHandler = [[KGWebSocketNativeHandler alloc] init];
    
    [_selectedHandler setListener:[self createListener]];
    [_selectedHandler setNextHandler:_nativeHandler];
    
    return _selectedHandler;
}


-(id<KGWebSocketHandlerListener>)createListener {
    Composite_WebSocketHandlerListener_1* listener = [[Composite_WebSocketHandlerListener_1 alloc] initWithWebSocketCompositeHandler:self];
    return listener;
}



-(void) fallbackNext:(KGWebSocketCompositeChannel *) channel exception:(NSException *)exception {
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler fallbackNext]");
#endif
    NSString* strategyName = [channel nextStrategy];
    if (strategyName == nil) {
        if (exception == nil) {
            [self doClose:channel wasClean:NO code:1006 reason:nil];
        }
        else {
            [self doClose:channel exception:exception];
        }
    }
    else {
        [self initDelegate:channel strategyName:strategyName];
    }
}

-(void) initDelegate:(KGWebSocketCompositeChannel *) channel strategyName:(NSString*) strategyName {
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler initDelegate]");
#endif

    KGWebSocketStrategy * strategy = [strategyMap valueForKey:strategyName];
    id<KGWebSocketSelectedChannelFactory> channelFactory = [strategy channelFactory];
    KGWSURI * location = [channel location];
    BOOL isBinary = [channel isBinary];
    
    NSArray *requestedProtocols = [channel requestedProtocols];
    KGWebSocketSelectedChannel * selectedChannel = [channelFactory createChannel:location binary:isBinary];
    KGWebSocketSelectedHandler *selectedHandler = (KGWebSocketSelectedHandler *) [strategy handler];
    [channel setSelectedChannel:selectedChannel];
    [selectedChannel setParent:channel];
    [selectedChannel setHandler: selectedHandler];
    [selectedChannel setRequestedProtocols:requestedProtocols];

    [selectedHandler processConnect:[channel selectedChannel] location:location requestedProtocols:requestedProtocols];
}

-(void) doOpen:(KGWebSocketCompositeChannel *) channel {
    @synchronized (channel) {
        if (channel.readyState == KGReadyState_CONNECTING)
        {
            channel.readyState = KGReadyState_OPEN;
            
            KGWebSocket        *ws = [channel webSocket];
            NSString           *extnHeaders = [channel negotiatedExtensions];
            NSCharacterSet     *whitespace = [NSCharacterSet whitespaceCharacterSet];

            if ([extnHeaders length] > 0) {
                NSArray *extensions = [extnHeaders componentsSeparatedByString:@","];
                for (int i = 0; i < [extensions count]; i++) {
                    NSString   *extension = [extensions objectAtIndex:i];
                    
                    // Trim off any leading/trailing whitespace left by the split
                    extension = [extension stringByTrimmingCharactersInSet:whitespace];
                    if ([extension length] > 0) {
                        [ws addNegotiatedExtension:extension];
                    }
                }
            }

            [_listener connectionOpened:channel protocol:[channel protocol]];
        }
    }
}

//
// NOTE: If the establish a WebSocket connection algorithm fails, it triggers the fail the WebSocket
// connection algorithm, which then invokes the close the WebSocket connection algorithm, which then
// establishes that the WebSocket connection is closed, which fires the close event as described below.

// When the WebSocket connection is closed, possibly cleanly, the user agent must queue a task to run
// the following substeps:

// 1. Change the readyState attribute's value to CLOSED (3).

// 2. If the user agent was required to fail the WebSocket connection or the WebSocket connection
//    is closed with prejudice, fire a simple event named error at the WebSocket object.
-(void) doClose:(KGWebSocketCompositeChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
    if (channel == nil) {
        return;
    }

    @synchronized (channel) {
        if (channel.readyState == KGReadyState_CONNECTING ||
            channel.readyState == KGReadyState_CLOSING ||
            channel.readyState == KGReadyState_OPEN)
        {
            KGReadyState oldState = channel.readyState;
            channel.readyState = KGReadyState_CLOSED;
            
            KGResumableTimer *connectTimer = [channel connectTimer];
            if (connectTimer != nil) {
                [connectTimer cancel];
                [channel setConnectTimer:nil];
            }

            if ((oldState == KGReadyState_CONNECTING) &&
                (wasClean == NO) &&
                (code == 1006)) {
                if (reason == nil) {
                    reason = @"Failed to establish WebSocket connection";
                }
                
                NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:reason userInfo:nil];
                [_listener connectionFailed:channel exception:ex];
            }
            
            [_listener connectionClosed:channel  wasClean:wasClean code:code reason:reason];
        }
        else {
    #ifdef DEBUG
            NSLog(@"Connection is already closed");
    #endif
        }
    }
}

-(void) doClose:(KGWebSocketCompositeChannel *) channel  exception:(NSException*) ex {
    if (channel == nil) {
        return;
    }

    @synchronized (channel) {
        if (channel.readyState == KGReadyState_CONNECTING ||
            channel.readyState == KGReadyState_CLOSING ||
            channel.readyState == KGReadyState_OPEN)
        {
            KGReadyState oldState = channel.readyState;
            channel.readyState = KGReadyState_CLOSED;

            KGResumableTimer *connectTimer = [channel connectTimer];
            if (connectTimer != nil) {
                [connectTimer cancel];
                [channel setConnectTimer:nil];
            }
            
            if (oldState == KGReadyState_CONNECTING) {
                [_listener connectionFailed:channel exception:ex];
            }

            [_listener connectionClosed:channel exception:ex];
        }
    }
}

//// public section ////
-(void) processConnect:(KGWebSocketChannel *) channel location:(KGWSURI *) location requestedProtocols:(NSArray *) requestedProtocols{
#ifdef DEBUG
    NSLog(@"[KGWebSocketCompositeHandler processConnect]");
#endif
    KGWebSocketCompositeChannel * compositeChannel = (KGWebSocketCompositeChannel *) channel;
#ifdef DEBUG
    NSLog/*.finest*/(@"Current ready state = %d", compositeChannel.readyState);
#endif
    if (compositeChannel.readyState != KGReadyState_CLOSED) {
#ifdef DEBUG
        NSLog/*.warning*/(@"Attempt to reconnect an existing open WebSocket to a different location");
#endif
        [NSException raise:@"Illegal state"
                    format:@"Attempt to reconnect an existing open WebSocket to a different location"];
    }
    NSString* scheme = [compositeChannel compositeScheme];
    
    compositeChannel.readyState = KGReadyState_CONNECTING;
    [compositeChannel setRequestedProtocols:requestedProtocols];
    if ([scheme indexOf:@":"] >= 0) {
        // qualified scheme: e.g. "ios:wse"
        KGWebSocketStrategy * strategy = [strategyMap valueForKey:scheme];
        if (strategy == nil) {
            [NSException raise:@"Illegal state" format:@"WebSocket strategy not set"];
        }
        [compositeChannel addConnectionStrategy:scheme];
    }
    else {
        NSArray * connectionStrategies = [strategyChoices valueForKey:scheme];
        for (NSString *each in connectionStrategies) {
            [compositeChannel addConnectionStrategy:each];
        }
    }
    [self fallbackNext:compositeChannel exception:nil];
}


-(void) processAuthorize:(KGWebSocketChannel *) channel authorizeToken:(NSString*)authorizeToken {
    
}

-(void) processTextMessage:(KGWebSocketChannel *) channel text:(NSString*)text {
    @synchronized (channel) {
#ifdef DEBUG
        NSLog(@"[KGWebSocketCompositeHandler processTextMessage]");
#endif

        KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel;
        if (parent.readyState != KGReadyState_OPEN) {
#ifdef DEBUG
           NSLog/*.warning*/(@"Attempt to post message on unopened or closed web socket");
#endif
            [NSException raise:@"Illegal state" format:@"Attempt to post message on unopened or closed web socket"];
        }

        KGWebSocketSelectedChannel *selectedChannel = [parent selectedChannel];
        [[selectedChannel handler] processTextMessage:selectedChannel text:text];
    }
}

-(void) processBinaryMessage:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *)buffer {
    @synchronized (channel) {
#ifdef DEBUG
        NSLog(@"[KGWebSocketCompositeHandler processBinaryMessage]");
#endif
        KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel;
        if (parent.readyState != KGReadyState_OPEN) {
#ifdef DEBUG
            NSLog/*.warning*/(@"Attempt to post message on unopened or closed web socket");
#endif
            [NSException raise:@"Illegal state" format:@"Attempt to post message on unopened or closed web socket"];
        }
    
        KGWebSocketSelectedChannel *selectedChannel = [parent selectedChannel];
        [[selectedChannel handler] processBinaryMessage:selectedChannel buffer:buffer];
    }
}

-(void) processClose:(KGWebSocketChannel *) channel code:(NSInteger)code reason:(NSString *)reason {
    @synchronized (channel) {
#ifdef DEBUG
        NSLog(@"[KGWebSocketCompositeHandler processClose]");
#endif
        KGWebSocketCompositeChannel * parent = (KGWebSocketCompositeChannel *)channel;

        // When the connection timeout expires due to network loss, we first
        // invoke doClose() to inform the application immediately. Then, we
        // invoke processClose() to close the connection but it may take a
        // while to return. When doClose() is invoked, readyState is set to
        // KGReadyState_CLOSED. However, we do want to processClose() to be
        // invoked all the way down to close the connection. That's why we are
        // no longer throwing an exception here if readyState is CLOSED.
        // [NSException raise:@"Illegal state" format:@"WebSocket already closed"];

        if (!parent.closing) {
            parent.closing = YES;

            // If readyState is CLOSED, we should continue to close the
            // connection all the way down as the readyState may have been
            // may have been set in doClose when the connect timer expired.

            if (parent.readyState != KGReadyState_CLOSED) {
                parent.readyState = KGReadyState_CLOSING;
            }

            KGWebSocketSelectedChannel *selectedChannel = [parent selectedChannel];
            [[selectedChannel handler] processClose:selectedChannel code:code reason:reason];
        }
    }
}

- (void) setListener:(id <KGWebSocketHandlerListener>)listener{
    _listener = listener;
}

-(id <KGWebSocketHandlerListener>)listener{
    return _listener;
}

+(void) setSelectHandlerFactory:(id<KGWebSocketSelectedHandlerFactory>) factory{
    selectHandlerFactory = factory;
}

@end
