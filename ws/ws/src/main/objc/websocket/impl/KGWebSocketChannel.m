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
#import "KGWebSocketChannel.h"

// TODO: Change to WebSocketChannel_nextId
int nextId = 1;
@implementation KGWebSocketChannel {
    __weak id<KGWebSocketHandler>   _transportHandler;

    KGWSURI                 *_location;
    NSString                *_selectedProtocol;
    BOOL                     _isBinary;
    int                      _bufferedAmount;
    NSString                *_handshakePayload;
    int                      _nextId;
    int                      _id;
    NSString                *_enabledExtensions;
    NSString                *_negotiatedExtensions;
    NSMutableArray          *_extensionPipeline;
    SecIdentityRef          _clientIdentity;
}

- (void) init0 {
    [super init0];
    
    _bufferedAmount = 0;
    
    _id = nextId++;
}

- (id) init {
    self = [super init];
    return self;
}

- (id) initWithLocation:(KGWSURI *)location binary:(BOOL)isBinary {
    self = [self init];
    if (self) {
        _location = location;
        _isBinary = isBinary;
        _handshakePayload = @"";
    }
    return self;
}

/// public
- (int) bufferedAmount {
    return _bufferedAmount;
}

- (void) setLocation:(KGWSURI *)location {
    _location = location;
    
}

- (KGWSURI *) location {
    return _location;
    
}

- (void) setProtocol:(NSString*)protocol {
    _selectedProtocol = protocol;
}

- (NSString*) protocol {
    return _selectedProtocol;
}

- (NSString *) enabledExtensions {
    return _enabledExtensions;
}

- (void) setEnabledExtensions:(NSString *)extensions {
    _enabledExtensions = extensions;
}

- (NSString *) negotiatedExtensions {
    return _negotiatedExtensions;
}

- (void) setNegotiatedExtensions:(NSString *)extensions {
    _negotiatedExtensions = extensions;
}

- (NSArray *) extensionPipeline {
    return _extensionPipeline;
}

- (void) addExtensionToPipeline:(KGWebSocketExtension *)extension {
    if (_extensionPipeline == nil) {
        _extensionPipeline = [[NSMutableArray alloc] init];
    }
    [_extensionPipeline addObject:extension];
}

- (void) setHandshakePayload:(NSString*) handshakePayload {
    _handshakePayload = handshakePayload;
}

- (NSString*) handshakePayload {
    return _handshakePayload;
}

- (void) setTransportHandler:(id<KGWebSocketHandler>) handler {
    _transportHandler = handler;
}

- (id<KGWebSocketHandler>) transportHandler {
    return _transportHandler;
}

- (int) _id {
    return _id;
}

- (BOOL) isBinary {
    return _isBinary;    
}

- (void) setClientIdentity:(SecIdentityRef)clientIdentity {
    _clientIdentity = clientIdentity;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}

- (void) dealloc {
    _enabledExtensions = nil;
    _negotiatedExtensions = nil;
    _location = nil;
    _selectedProtocol = nil;
    _handshakePayload = nil;
    _transportHandler = nil;
    _clientIdentity = nil;
    if (_extensionPipeline != nil) {
        [_extensionPipeline removeAllObjects];
        _extensionPipeline = nil;
    }
}
@end
