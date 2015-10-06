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
#import "KGWebSocketNativeDelegate.h"

// package org.kaazing.gateway.client.transport.ws


typedef enum {
    START,
    STATUS_101_READ,
    CONNECTION_UPGRADE_READ,
    COMPLETED,
    ERRORED
} KGConnectionStatus;

typedef enum {
    WEBSOCKET_CONNECTING,
    WEBSOCKET_REQUEST_SENT,
    READING_WEBSOCKET_HEADERS,
    WEBSOCKET_OPEN,
    WEBSOCKET_CLOSING,
    WEBSOCKET_CLOSED,
    WEBSOCKET_ERROR
} KGSocketState;

typedef enum {
    START_OF_FRAME,
    READING_PAYLOADLENGTH,
    READING_PAYLOADLENGTH_EXT,
    READING_MASK_KEY,
    READING_PAYLOAD,
    END_OF_FRAME
} KGDecodingState;

typedef enum {
    CONTINUATION =0,
    TEXT =1,
    BINARY =2,
    RESERVED3 = 3,
    RESERVED4 = 4,
    RESERVED5 = 5,
    RESERVED6 = 6,
    RESERVED7 = 7,
    CLOSE = 8,
    PING = 9,
    PONG =10
} KGOpCode;

// public
@interface KGWebSocketDelegateImpl : NSObject <KGWebSocketNativeDelegate> {
    // protected
    NSString* _cookies;
    // package private
    NSString* _websocketKey;
    // package private
    int _bufferedAmount;
}

// public
//- (KGHttpReadyState*) readyState;

// public
- (int) bufferedAmount;

// public
- (NSString*) secProtocol;

// public
- (NSString*) extensions;

// public
- (KGWebSocketDelegateImpl *) initWithUrl:(NSURL*)url requestedProtocols:(NSArray *)requestedProtocosl clientIdentity:(SecIdentityRef)identity;

// public
- (void) processOpen;

// protected
//- (void) postProcessOpen:(id <HttpRequestDelegate>)cookiesRequest;

// protected
- (void) nativeConnect;

// public
- (void) processDisconnect; /* throws IOException */

// public
- (void) processDisconnect:(short)code reason:(NSString*)reason; /* throws IOException */

// public
- (void) processAuthorize:(NSString*)authorize;

- (void) setIdleTimeout:(int)timeout;

// protected
- (NSURL*) url;

- (void) closeStreams;

@end


