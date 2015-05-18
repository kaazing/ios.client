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

#import <CommonCrypto/CommonDigest.h>
#import <CFNetwork/CFHTTPMessage.h>


#import "KGWebSocketDelegateImpl.h"
#import "KGBase64Util.h"
#import "KGByteBuffer.h"
#import "KGTracer.h"
#import "KGConstants.h"

@interface KGWebSocketDelegateImpl (private) <NSStreamDelegate>
// private static
+ (BOOL) isHTTPResponse:(NSData*)buf;

// private static
+ (NSArray */*NSString*/) getLines:(NSData*)buf;

// private
//- (void) negotiateWebSocketConnection:(id <BridgeSocket>)socket;

// private
- (int) getEncodeRequestSize:(NSURL*)requestURI names:(NSArray */*NSString*/)names values:(NSArray */*NSString*/)values;

// private
- (int) send:(NSData*)frame;

// private
- (void) closeSocket;

// private
- (void) handleClose;

// private
- (void) handleError:(NSException*)e;

// private
- (NSData*) randomBytes:(int)size;

@end

// public
@implementation KGWebSocketDelegateImpl {
    // private
    BOOL                              _stopReaderThread;
    BOOL                              _connectionUpgraded;
    NSURL                            *_url;
    NSString                         *_origin;
    NSArray                          *_requestedProtocols;
    BOOL                              _secure;
    id <KGWebSocketDelegateListener>  _listener;
    NSString                         *_authorize;
    //KCAtomicBoolean* _closed;
    bool                              _closed;
    KGConnectionStatus                _connectionStatus;
    KGSocketState                     _socketState;
    KGDecodingState                   _decodeState;
    KGConnectionStatus                _state;
    bool                              _upgradeReceived;
    bool                              _connectionReceived;
    bool                              _websocketAcceptReceived;
    NSString                         *_secProtocol;
    NSString                         *_extensions;
    BOOL                              _wasClean;
    int                               _code;
    NSString                         *_reason;
    
    // package private
    NSInputStream                    *_inputStream;
    NSOutputStream                   *_outputStream;
    CFReadStreamRef                   _readStream;
    CFWriteStreamRef                  _writeStream;

    KGOpCode                          _opcode;
    int                               _fin;
    bool                              _masked;
    int                               _maskkey;
    int                               _dataLength;
    KGByteBuffer                     *_maskkeyBuf;
    KGByteBuffer                     *_payLoadLengthBuf;
    KGByteBuffer                     *_data;
    SecIdentityRef                    _clientIdentity;
    
    int                               _idleTimeout;
    long long                         _lastMessageTimestamp;
    NSTimer                          *_idleTimer;
    dispatch_semaphore_t              _semaphore;
    NSException                      *_bytesAvailableException;
}

// private static final
NSString* _CLASS_NAME;
// private static final
NSString* const _WWW_AUTHENTICATE = @"WWW-Authenticate: ";
NSString* const _WEBSOCKET_GUID = @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
NSString* const _HEADER_ORIGIN = @"Origin";
NSString* const _HEADER_CONNECTION = @"Connection";
NSString* const _HEADER_HOST = @"Host";
NSString* const _HEADER_UPGRADE = @"Upgrade";
NSString* const _HEADER_WEBSOCKET_KEY = @"Sec-WebSocket-Key";
NSString* const _HEADER_WEBSOCKET_VERSION = @"Sec-WebSocket-Version";
NSString* const _HEADER_VERSION = @"13";
NSString* const _HEADER_LOCATION = @"Location";
NSString* const _WEB_SOCKET = @"WebSocket";
NSString* const _WEB_SOCKET_LOWERCASE = @"websocket";
NSString* const _HEADER_COOKIE = @"Cookie";
NSString* const _HTTP_101_MESSAGE = @"HTTP/1.1 101 Web Socket Protocol Handshake";
NSString* const _UPGRADED_MESSAGE_HEADER = @"Upgrade: ";
NSString* const _UPGRADED_MESSAGE_VALUE = @"upgrade: websocket";
NSString* const _CONNECTION_MESSAGE = @"Connection: Upgrade";
NSString* const _WEBSOCKET_ACCEPT = @"Sec-WebSocket-Accept";

- (void) init0 {
    //_CLASS_NAME = [[KGWebSocketDelegateImpl class] name];
    //_LOG = [KCLogger getLogger:_CLASS_NAME];
    //websocketqueue = dispatch_queue_create("websocket", DISPATCH_QUEUE_SERIAL);
    _connectionUpgraded = NO;
    _cookies = nil;
    _authorize = nil;
    _closed = NO;
    //_readyState = KGHttpReadyState._CONNECTING;
    _wasClean = NO;
    _code = 1006;
    _reason = @"";
    //_HTTP_REQUEST_DELEGATE_FACTORY = [[HttpRequestDelegateFactory_2 alloc] initWithOuter:self];
    //_BRIDGE_SOCKET_FACTORY = [[BridgeSocketFactory_3 alloc] initWithOuter:self];
    _inputStream = nil;
    _outputStream = nil;
    _connectionStatus = START;
    _socketState = WEBSOCKET_CONNECTING;
    _decodeState = START_OF_FRAME;
    _upgradeReceived = NO;
    _connectionReceived = NO;
    _websocketAcceptReceived = NO;
    _payLoadLengthBuf = [KGByteBuffer allocate:8];
    _maskkeyBuf = [KGByteBuffer allocate:4];
    _semaphore = nil;
    _bytesAvailableException = nil;
}

// public
//- (KGHttpReadyState*) readyState {
//    return _readyState;
//}


// public
- (int) bufferedAmount {
    return _bufferedAmount;
}


// public
- (NSString*) secProtocol {
    return _secProtocol;
}


// public
- (NSString*) extensions {
    return _extensions;
}
// protected
- (NSURL*) url{
    return _url;
}

// public
- (KGWebSocketDelegateImpl *) initWithUrl:(NSURL*)url requestedProtocols:(NSArray *)requestedProtocols clientIdentity:(SecIdentityRef)identity{
    self = [super init];
    if (self) {
        [self init0];
        //[_LOG entering:_CLASS_NAME string1:@"<init>" object[]2:new KCObject[] { url,origin,protocols }];
        if (url == nil) {
            @throw [NSException
                    exceptionWithName:@"IllegalArgumentException"
                    reason:@"Please specify the target for the WebSocket connection"
                    userInfo:nil];
        }
        _url = url;
        _secure = [[url scheme] isEqualToString:@"wss"];
        if ([url scheme] == nil || [url host] == nil) {
            _origin = @"null";
        }
        else {
            NSString *originHost = [url host];
            int originPort = [[url port] intValue];
            if (originPort == 0) {
                originPort = _secure ? 443 : 80;
            }
            _origin = [NSString stringWithFormat:@"privileged://%@:%i", originHost, originPort];
        }
        _requestedProtocols = requestedProtocols;
        _clientIdentity = identity;
    }
    return self;
}

- (void) dealloc {
    [self stopIdleTimer];
    [self closeStreams];
    
    _authorize = nil;
    _cookies = nil;
    _websocketKey = nil;
    _origin = nil;
    _extensions = nil;
    _url = nil;
    _listener = nil;
    _payLoadLengthBuf = nil;
    _maskkeyBuf = nil;
    _data = nil;
    _reason = nil;
    _clientIdentity = nil;
    _semaphore = nil;
    _bytesAvailableException = nil;
}

// public
- (void) processSend:(NSData *)data {
    if (_socketState == WEBSOCKET_OPEN) {
        [KGTracer trace:[NSString stringWithFormat:@"processSend:%@", data]];
        [self send:data];
    }
    else {
        [KGTracer trace:@"processSend error: websocket is not OPEN"];
    }
}

//public
-(void)processDisconnect{
    [self processDisconnect:0 reason:NULL];
}

//public
-(void)processDisconnect:(short)code reason:(NSString *)reason{
    if (_socketState == WEBSOCKET_OPEN){
        _socketState = WEBSOCKET_CLOSING;
        //send close frame
        NSMutableData* data = [self createCloseFrame:code reason:reason];
        [self send:data];
    }
    if (_socketState == WEBSOCKET_CONNECTING || _socketState == WEBSOCKET_REQUEST_SENT) {
        _socketState = WEBSOCKET_CLOSED;
        //dispatch_async(websocketqueue,^{
        if (reason != nil) {
            _wasClean = NO;
            _reason = reason;
        }
        [self handleClose];
        //});
    }
    _reason = (reason != nil) ? reason : _reason;
    //else do nothing for CLOSING and CLOSED
}

- (void) processAuthorize:(NSString*)authorize{
    //nothing
}

// public
- (void) processOpen {
    [self nativeConnect];
}

- (void) setIdleTimeout:(int)timeout {
    if (timeout > 0) {
        _idleTimeout = timeout;
        _lastMessageTimestamp = (long long) [[NSDate date] timeIntervalSince1970] * 1000;
        
        // We used to start the idle-timer here. Since we changed our thread strategy
        // to address memory leaks, this method gets executed on the short-lived
        // child thread that was spawned to process the message. But, we want the
        // idle-timer to be started on the long-living parent thread(aka WebSocket thread).
        // So, if we start the idle-timer on the short-lived child thread, the timer will
        // not fire(or get scheduled) once the child thread exits the system. That's why
        // we will be starting the idle-timer on the parent WebSocket thread while dealing
        // with NSStreamEventHasBytesAvailable event.
    }
}

// protected
//- (void) postProcessOpen:(id <HttpRequestDelegate>)cookiesRequest {
//}


// protected
- (void) nativeConnect {
    //[_LOG entering:_CLASS_NAME string1:@"nativeConnect"];
    NSString* host = [_url host];
    int port = [[_url port] intValue];
    NSString* scheme = [_url scheme];
    if (port == 0) {
        port = [scheme isEqualToString:@"wss"] ? 443 : 80;
        //NSURl
    }
    @try {
        //[_LOG fine:[@"KGWebSocketNaiveDelegate.nativeConnect(): Connecting to " stringByAppendingString:host] + @":" + port];
        //CFStringRef cfhost = host;
        _readStream = nil;
        _writeStream = nil;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) host, port, &_readStream, &_writeStream);

        // Indicate that we want socket to be closed whenever streams are closed.
        CFReadStreamSetProperty(_readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(_writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

        if (_secure) {
            //Setup SSL properties
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                             //[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
                                             //[NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                                             //[NSNumber numberWithBool:NO],  kCFStreamSSLValidatesCertificateChain,
                                             //kCFNull,kCFStreamSSLPeerName,
                                             kCFStreamSocketSecurityLevelTLSv1, kCFStreamSSLLevel,
                                             nil];
            // add client certificate if application provided
            if (_clientIdentity != nil) {
                // add client identity certificate
                NSMutableArray *certificates = [NSMutableArray arrayWithCapacity: 1];
                
                // The first object in the array is our SecIdentityRef
                [certificates addObject:(__bridge id)(_clientIdentity)];
                
                // If we've added any additional certificates, add them too
                //add certificates array to settings dictionary
                [settings setObject:certificates forKey:(NSString *)kCFStreamSSLCertificates];
            }
            CFReadStreamSetProperty(_readStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef)settings);
            CFWriteStreamSetProperty(_writeStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef)settings);
        }

        _inputStream = (__bridge NSInputStream *)_readStream;
        _outputStream = (__bridge NSOutputStream *)_writeStream;
        
        [_inputStream setDelegate:self];
        [_outputStream setDelegate:self];
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream open];
        [_outputStream open];
        _socketState = WEBSOCKET_CONNECTING;
    }
    @catch (NSException* e) {
        //[_LOG log:Level._FINE string1:[@"KGWebSocketDelegateImpl nativeConnect(): " stringByAppendingString:[e message]] object2:e];
        //_readyState = KGHttpReadyState._CLOSED;
        [_listener errorOccurred:[[KGErrorEvent alloc] initWithException:e]];
        return;
    }
}

//implement NSStreamDelegate protocol
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
        {
            [KGTracer trace:@"EVENT: NSStreamEventOpenCompleted encountered."];
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [KGTracer trace:@"EVENT: NSStreamEventEndEncountered encountered."];
            _socketState = WEBSOCKET_CLOSED;
            [self closeStreams];
            [self handleClose];
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            [KGTracer trace:@"EVENT: HasSpaceAvailable encountered."];
            //has data to read
            if(_socketState == WEBSOCKET_CONNECTING && theStream == _outputStream) {
                //send handshake request
                [self negotiateWebSocketConnection];
                _socketState = WEBSOCKET_REQUEST_SENT; //request sent
            }
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            if (_semaphore != nil) {
                @throw [[NSException alloc] initWithName:@"ConcurrentAvailableBytesHandlingException"
                                                  reason:@"Thread is already active. Available bytes should not have been delivered yet."
                                                userInfo:nil];
            }
            
            _semaphore = dispatch_semaphore_create(0);
            _bytesAvailableException = nil;
            
            // Spwan a child thread that would handle available bytes.
            NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(handleBytesAvailable:) object:theStream];
            [thread start];
            
            // Wait for the child thread to complete till the semaphore
            // is signaled.
            dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            _semaphore = nil;

            if (_socketState == WEBSOCKET_ERROR) {
                [self closeStreams];
                [self handleError:_bytesAvailableException];
            }
            else if ((_idleTimer == nil) && (_idleTimeout > 0)) {
                // We should start the idle-timer just once on the parent/WebSocket thread.
                [self startIdleTimer:_idleTimeout];
            }

            break;
        }
        case NSStreamEventErrorOccurred:
        {
            _socketState = WEBSOCKET_ERROR;
            NSError *theError = [theStream streamError];
            [KGTracer trace:[NSString stringWithFormat:@"EVENT: ErrorOccurred encountered. %@ = %@", theStream == _inputStream ? @"inputStream":@"outputStream", [theError description]]];
            [self closeStreams];
            //dispatch_async(websocketqueue, ^{
                [self handleError:[NSException exceptionWithName:@"CFStreamError" reason:[theError description] userInfo:[theError userInfo]]];
            // });
            break;
        }
        case NSStreamEventNone:
        {
            [KGTracer trace:@"EVENT: None."];
            break;
        }
        default:
            break;
    }
}

- (void) handleBytesAvailable:(NSStream *)theStream {
    @autoreleasepool {
        [KGTracer trace:@"EVENT: HasBytesAvailable encountered."];
        @try {
            if (_socketState == WEBSOCKET_REQUEST_SENT && theStream == _inputStream) {
                _socketState = READING_WEBSOCKET_HEADERS;    //parse handshake response header
                [self parseHeader:_inputStream];
            }
            else {
                [self process:_inputStream];
            }
        }
        @catch (NSException *exception) {
            _socketState = WEBSOCKET_ERROR;
            _bytesAvailableException = exception;
        }
        @finally {
            // Signal the semaphore for the parent thread to continue as
            // this(or the child) thread is done.
            dispatch_semaphore_signal(_semaphore);
        }
    }
}

// private
- (void) negotiateWebSocketConnection {
    //[_LOG entering:_CLASS_NAME string1:@"negotiateWebSocketConnection" object2:socket];
    @try {
        if (_websocketKey == nil) {
            _websocketKey = [KGBase64Util encode:[self randomBytes:16]];
        }
        NSString* authority = [_url host];
        if([_url port] > 0) {
            authority = [authority stringByAppendingFormat:@":%@", [_url port]];
        }
        CFURLRef myURL = (__bridge CFURLRef)(_url);
        
        CFStringRef requestMethod = CFSTR("GET");
        CFHTTPMessageRef myRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL, kCFHTTPVersion1_1);
        CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_UPGRADE), (__bridge CFStringRef)(_WEB_SOCKET_LOWERCASE));
        CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_CONNECTION), (__bridge CFStringRef)(_HEADER_UPGRADE));
        CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_HOST), (__bridge CFStringRef)([NSString stringWithFormat:@"%@", authority]));
        CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_ORIGIN), (__bridge CFStringRef)(_origin));        
        CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_WEBSOCKET_VERSION), (__bridge CFStringRef)(_HEADER_VERSION));
        CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_WEBSOCKET_KEY), (__bridge CFStringRef)(_websocketKey));
       
        if (_requestedProtocols != nil && _requestedProtocols.count > 0) {
            NSString *requestedProtocolsString = [_requestedProtocols componentsJoinedByString:@","];
            CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(HEADER_SEC_PROTOCOL), (__bridge CFStringRef)(requestedProtocolsString));
        }
        if (_cookies != nil) {
            CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(_HEADER_COOKIE), (__bridge CFStringRef)(_cookies));        }
        if (_authorize != nil) {
            CFHTTPMessageSetHeaderFieldValue(myRequest, (__bridge CFStringRef)(HEADER_AUTHORIZATION), (__bridge CFStringRef)(_authorize));
        }
        
        //serialize request
        CFDataRef mySerializedRequest = CFHTTPMessageCopySerializedMessage(myRequest);
        NSData* payload = (__bridge NSData *)(mySerializedRequest);
        [KGTracer trace:[NSString stringWithFormat:@"negotiate websocket: %@", [NSString stringWithUTF8String:[payload bytes]]]];
        //release request
        CFRelease(myRequest);
        CFRelease(mySerializedRequest);
        //send request
        [self send:payload];
    }
    @catch (NSException* e) {
        //[_LOG severe:[e toString]];
        [self handleError:e];
    }
}
- (int) send: (NSData*)data {
    int len = [_outputStream write:[data bytes] maxLength: [data length]];
    return len;
}

- (NSData*) randomBytes:(int)size {
    @autoreleasepool {
        uint8_t iv[size];
        arc4random_buf(&iv, size);
        return [[NSData alloc] initWithBytes:iv length:size];
    }
}



/************** Gateway Response ********************
 HTTP/1.1 101 Web Socket Protocol Handshake
 Upgrade: WebSocket
 Connection: Upgrade
 Sec-WebSocket-Origin: http://localhost:8001
 Sec-WebSocket-Location: ws://localhost:8001/echo?.kl=Y
 Server: Kaazing Gateway
 Date: Mon, 20 Aug 2012 15:43:21 GMT
 Sec-WebSocket-Accept: ax3PZp7NXvLM02bTzCC+uG7kkoU=
 Sec-WebSocket-Protocol: x-kaazing-handshake
 X-Frame-Type: binary
 
 ï¿N  (82,04,ef,83,bf,4e)
 ***********************************************/

- (void)parseHeader:(NSInputStream*)inputStream {
    
    NSString* output = @"";
    while ([inputStream hasBytesAvailable]) {
        uint8_t byte;
        int len = [inputStream read:&byte maxLength:1];
        if (len > 0) {
            output = [output stringByAppendingFormat:@"%c", byte];
            if ([output rangeOfString:@"\r\n\r\n"].location == NSNotFound ) {
                continue; //headers are not complete
            }
            [KGTracer trace:[NSString stringWithFormat:@"server said: %@", output]];
            //headers
            NSString *reason = @"";
            NSArray * lines = [output componentsSeparatedByString:@"\r\n"];
            for (NSString* line in lines) {
                [KGTracer trace:[NSString stringWithFormat:@"line:%@", line]];
                //get WebSocket-Protocol:
                if ([line hasPrefix:HEADER_SEC_EXTENSIONS]) {
                    _extensions = [line substringFromIndex:[HEADER_SEC_EXTENSIONS length] + 2];
                    continue;
                }
                if ([line hasPrefix:HEADER_SEC_PROTOCOL]) {
                    _secProtocol = [line substringFromIndex:[HEADER_SEC_PROTOCOL length] + 2];
                    continue;
                }
                else {
                    [self processLine:line];
                    if (_connectionStatus == ERRORED) {
                        reason = line;
                        break;
                    }
                }
                    
            } //end of for loop
            
            //finish parsing header, check all required headers for WebSocket rfc 6455
            _connectionUpgraded = _websocketAcceptReceived && _upgradeReceived && _connectionReceived;
            if (_connectionUpgraded) {
                _socketState = WEBSOCKET_OPEN; //start parse response body
                [_listener opened:[[KGOpenEvent alloc] initWithProtocol:_secProtocol]];
                [self process:_inputStream];
                return;
            }
            else {
                NSString *msg = [NSString stringWithFormat:@"WebSocket Connection upgrade unsuccessful: %@", reason];
                @throw [NSException exceptionWithName:@"WebSocketUpgradeFailException" reason:msg userInfo:nil];
            }
        }
    }
}

// private
- (void) processLine:(NSString*)line /* throws Exception */ {
    switch (_connectionStatus)
    {
        case START:
            if ([line compare:_HTTP_101_MESSAGE options:NSCaseInsensitiveSearch] == 0) {
                _connectionStatus = STATUS_101_READ;
            }
            else {
                //[KGWebSocketDelegateImpl._LOG severe:[@"WebSocket upgrade failed: " stringByAppendingString:line]];
                _connectionStatus = ERRORED;
            }
            break;
        case STATUS_101_READ:
            if (line == nil || [line length] == 0) {
                _connectionStatus = COMPLETED;
            }
            else if ([line hasPrefix:_UPGRADED_MESSAGE_HEADER]) {
                if ([[line lowercaseString] isEqualToString:_UPGRADED_MESSAGE_VALUE]) {
                  _upgradeReceived = YES;
                }
            }
            else if ([line isEqualToString:_CONNECTION_MESSAGE]) {
                _connectionReceived = YES;
            }
            else if ([line hasPrefix:_WEBSOCKET_ACCEPT]) {
                NSString* hashedKey = [self AcceptHash:[_websocketKey stringByAppendingString:_WEBSOCKET_GUID]];
                _websocketAcceptReceived = [hashedKey isEqualToString: [line substringFromIndex:[_WEBSOCKET_ACCEPT length] + 2]];
            }
            break;
        case COMPLETED:
            break;
        default:
            break;
    }
}

// private
- (NSString*) AcceptHash:(NSString*)input /* throws NoSuchAlgorithmException */ {
        
    NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);

    NSString* output = [KGBase64Util encode:[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH]];
    return output;
}


// package private
- (void) process:(NSInputStream*)inputStream /* throws IOException */ {
    //[_LOG entering:_CLASS_NAME string1:@"process"];
    uint8_t b = 0;

    for (;;) {
        switch (_decodeState)
        {
            case START_OF_FRAME:
            { 
                if (![inputStream hasBytesAvailable]) {
                    return;
                }
                int num = [inputStream read:&b maxLength:1];
                if (num < 0) {
                    //balancer closed socket, cause num = -1 -- end of frame
                    _socketState = WEBSOCKET_CLOSED;
                    [self closeStreams];
                    [self handleClose];
                    return;
                }
                _fin = (b & 0x80) != 0;
                _opcode = b & 0x0f;
                _decodeState = READING_PAYLOADLENGTH; //start read mask & payload length
                break;
            }
            case READING_PAYLOADLENGTH:
            {
                if (![inputStream hasBytesAvailable]) {
                    return;
                }
                [inputStream read:&b maxLength:1];
                _masked = (b & 0x80) != 0;
                if (_masked) {
                    //_maskkeyBuf = [KGByteBuffer allocate:4]; //4 byte maxlength
                    _maskkeyBuf.position = 0;
                    _maskkeyBuf.limit = 4;
                }
                _dataLength = b & 0x7f;
                if (_dataLength == 126) {
                    _decodeState = READING_PAYLOADLENGTH_EXT;
                    //reset _payLoadLengthBuf here
                    //_payLoadLengthBuf = [KGByteBuffer allocate:4];
                    _payLoadLengthBuf.position = 0;
                    _payLoadLengthBuf.limit = 4;
                    [_payLoadLengthBuf put:'\0']; //prefill first two bytes with 0
                    [_payLoadLengthBuf put: '\0'];
                }
                else if (_dataLength == 127) {
                    _decodeState = READING_PAYLOADLENGTH_EXT;
                    //reset _payLoadLengthBuf here
                    //_payLoadLengthBuf = [KGByteBuffer allocate:8];
                    _payLoadLengthBuf.position = 0;
                    _payLoadLengthBuf.limit = 8;
                }
                else {
                    _decodeState = READING_MASK_KEY;
                }
                break;
            }
            case READING_PAYLOADLENGTH_EXT:
            {
                // TODO: Read directly into _payLoadLengthBuf
                if (![inputStream hasBytesAvailable]) {
                    return;
                }
                int r = [_payLoadLengthBuf remaining];
                
                int num = [_inputStream read:[_payLoadLengthBuf bytesFromPosition] maxLength:r];
                [_payLoadLengthBuf skip:num];
                if (![_payLoadLengthBuf hasRemaining]) {
                    [_payLoadLengthBuf flip];
                    if ([_payLoadLengthBuf remaining] == 4) {
                        _dataLength = [_payLoadLengthBuf getInt];
                    }
                    else {
                        _dataLength = (int)[_payLoadLengthBuf getLong];
                    }
                    _decodeState = READING_MASK_KEY;
                    break;
                }
                break;
            }
            case READING_MASK_KEY:
            {
                if (!_masked) {
                    if (_data == nil) {
                        _data = [KGByteBuffer allocate:_dataLength];
                    }
                    else {
                        int capacity = [_data capacity];
                        if (capacity < _dataLength) {
                            _data = nil;
                            _data = [KGByteBuffer allocate:_dataLength];
                        }
                        else {
                            // Reuse KGByteBuffer, if capacity is large enough.
                            [_data setPosition:0];
                            [_data setLimit:_dataLength];
                            [[_data data] resetBytesInRange:NSMakeRange(0, [_data capacity])];
                        }
                    }

                    // _data = [KGByteBuffer allocate:_dataLength];
                    _decodeState = READING_PAYLOAD;
                    break;
                }

                if (![inputStream hasBytesAvailable]) {
                    return;
                }
		
                int remaining = [_maskkeyBuf remaining];
                int num = [inputStream read:[_maskkeyBuf bytesFromPosition] maxLength:remaining];
                [_maskkeyBuf skip:num];
                if (![_maskkeyBuf hasRemaining]) {
                    [_maskkeyBuf flip]; //move postion
                    _maskkey = [_maskkeyBuf getInt];

                    if (_data == nil) {
                        _data = [KGByteBuffer allocate:_dataLength];
                    }
                    else {
                        int capacity = [_data capacity];
                        if (capacity < _dataLength) {
                            _data = nil;
                            _data = [KGByteBuffer allocate:_dataLength];
                        }
                        else {
                            // Reuse KGByteBuffer, if capacity is large enough.
                            [_data setPosition:0];
                            [_data setLimit:_dataLength];
                            [[_data data] resetBytesInRange:NSMakeRange(0, [_data capacity])];
                        }
                    }

                    // _data = [KGByteBuffer allocate:_dataLength];
                    _decodeState = READING_PAYLOAD;
                }
                break;
            }
            case READING_PAYLOAD:
            {
                if (_dataLength == 0) {
                    [_data flip];
                    _decodeState = END_OF_FRAME;
                }
                else {
                    if (![inputStream hasBytesAvailable]) {
                        return;
                    }

                    // Read directly into the KGByteBuffer
                    uint8_t *bytes = [_data bytesFromPosition];
                    int remaining = [_data remaining];
                    int num = [inputStream read:bytes maxLength:remaining];
                    [_data skip:num];
                    if (![_data hasRemaining]) {
                        [_data flip];
                        _decodeState = END_OF_FRAME;
                    }
                }
                break;
            }
            case END_OF_FRAME:
            {
                //finished load p
                switch (_opcode)
                {
                    case BINARY:
                    {
                        if (_masked) {
                            [self unmask:_data mask:_maskkey];
                        }
                        [_listener messageReceived:[[KGMessageEvent alloc] initWithData:_data origin:NULL lastEventId:NULL messageType:@"BINARY"]];
                        break;
                    }
                    case TEXT:
                    {
                        if (_masked) {
                            [self unmask:_data mask:_maskkey];
                        }
                        [_listener messageReceived:[[KGMessageEvent alloc] initWithData:_data origin:NULL lastEventId:NULL messageType:@"TEXT"]];
                        break;
                    }
                    case PING:
                    {
                        //send PONG
                        uint8_t pongframe[6] = {0x8a,0x80,0x22,0x42,0x12,0x98};
                        //pongframe[0] = 0x8A;
                       // pongframe[1] = 0x80;
                        
                        [self send:[NSData dataWithBytes:pongframe length:6]];
                        break;
                    }
                    case PONG:
                    {
                        //do nothing
                        break;
                    }
                    case CLOSE:
                    {
                        int code = 0;
                        if ([_data remaining] > 1) {
                            code = [_data getShort];
                            if([_data hasRemaining]) {
                                _reason = [_data getString];
                            }
                        }
                        if(_socketState == WEBSOCKET_OPEN) {
                            _socketState = WEBSOCKET_CLOSING;
                            //echo back close message
                            NSMutableData* frame = [self createCloseFrame:code reason:_reason];
                            [self send:frame];
                        }
                        _wasClean = YES;
                        _code = code > 0 ? code:1005;
                        break;
                    }
                    default:
                        @throw [NSException exceptionWithName:@"WebSocketIlligalFrame" reason:@"decode error" userInfo:NULL];
                        break;
                }
                _decodeState = START_OF_FRAME;
                _lastMessageTimestamp = (long long) [[NSDate date] timeIntervalSince1970] * 1000;
                break;
            }
        }

    } //end of for loop
}

// public static
- (void) mask:(KGByteBuffer *)buf mask:(int)mask {
    [self unmask:buf mask:mask];
}


// public static
- (void) unmask:(KGByteBuffer *)buf mask:(int)mask {
    uint8_t b;
    int start = [buf position];
    int remainder = [buf remaining] % 4;
    int remaining = [buf remaining] - remainder;
    int end_ = remaining + [buf position];
    // xor a 32bit word at a time as long as po
    while ([buf position] < end_) {
        int plaintext = [buf getIntAt:[buf position]] ^ mask;
        [buf putInt:plaintext];
    }
    //buf.position(s
    switch (remainder)
    {
        case 3:
            b = ([buf getAt:[buf position]] ^ mask >> 24 & 0xff);
            [buf put:b];
            b = ([buf getAt:[buf position]] ^ mask >> 16 & 0xff);
            [buf put:b];
            b = ([buf getAt:[buf position]] ^ mask >> 8 & 0xff);
            [buf put:b];
            break;
        case 2:
            b = ([buf getAt:[buf position]] ^ mask >> 24 & 0xff);
            [buf put:b];
            b = ([buf getAt:[buf position]] ^ mask >> 16 & 0xff);
            [buf put:b];
            break;
        case 1:
            b = ([buf getAt:[buf position]] ^ mask >> 24);
            [buf put:b];
            break;
        case 0:
        default:
            break;
    }
[buf setPosition:start];
}

- (void) mask:(NSMutableData*)data maskPosition:(int)maskPos {
    //get mask key
    uint8_t mask[4];
    NSRange range = {maskPos,4};
    [data getBytes:mask range:range];
    
    int start = maskPos + 4; //payload start position
    int payloadLen = [data length] - start; //payload length
    uint8_t b[1];
    for (int i = 0; i < payloadLen; i++) {
        NSRange range = {start+i, 1};
        [data getBytes:b range:range];
        b[0] = b[0] ^ mask[i%4];
        [data replaceBytesInRange:range withBytes:b];
    }
}

-(NSMutableData*)createCloseFrame:(short)code reason:(NSString*)reason {
    NSMutableData* data = [NSMutableData alloc];
    uint8_t bytes[2] = {0x88,0x80};
    [data appendBytes:bytes length:2];
    [data appendBytes:[[self randomBytes:4] bytes] length:4];
    if (code > 0) {
        code = CFSwapInt16HostToBig(code);
        [data appendBytes:&code length:2];
    }
    if(reason != NULL && [reason length] > 0) {
        NSData* reasonBytes = [reason dataUsingEncoding:NSUTF8StringEncoding];
        [data appendBytes:[reasonBytes bytes] length:[reasonBytes length]];
    }
    //now update lenght byte
    NSRange range = {1,1};
    int payloadLength = [data length] - 6;
    uint8_t lenthByte[1];
    lenthByte[0] = 0x80 | payloadLength;
    [data replaceBytesInRange:range withBytes:lenthByte];
    //mask
    [self mask:data maskPosition:2];
    return data;
}

-(void)handleClose{
    [self stopIdleTimer];
    KGCloseEvent * evt = [[KGCloseEvent alloc] initWithCode:_code wasClean:_wasClean reason:_reason];
    [_listener closed:evt];
}

-(void)handleError:(NSException*)ex {
    [self stopIdleTimer];
    [_listener errorOccurred:[[KGErrorEvent alloc] initWithException:ex]];
}

// package private
- (void) setListener:(id <KGWebSocketDelegateListener>)listener{
    _listener = listener;
}

- (void) closeStreams {
    // KG-14003: If two threads end up calling closeStreams(), then there
    // can be a race and both the threads may end up calling CFRelease()
    // resulting in a crash. To prevent the race(and the crash), we
    // are synchronizing so that one thread wins and the next thread
    // will check whether _readStream(or _writeStream) is nil and just bail.
    @synchronized (self) {
        if (_readStream != nil) {
            [_inputStream close];
            [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [_inputStream setDelegate:nil];
            _inputStream = nil;

            CFReadStreamSetProperty(_readStream, kCFStreamPropertySSLSettings, nil);
            CFReadStreamClose(_readStream);
            CFRelease(_readStream);
            _readStream = nil;
        }

        if (_writeStream != nil) {
            [_outputStream close];
            [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [_outputStream setDelegate:nil];
            _outputStream = nil;
            
            CFWriteStreamSetProperty(_writeStream, kCFStreamPropertySSLSettings, nil);
            CFWriteStreamClose(_writeStream);
            CFRelease(_writeStream);
            _writeStream = nil;
        }
    }
}

- (void) startIdleTimer:(int) delayInMilliseconds {
    [KGTracer trace:@"Starting idle timer"];
    
    if (_idleTimer != nil) {
        [_idleTimer invalidate];
    }
    
    _idleTimer = [NSTimer scheduledTimerWithTimeInterval:(delayInMilliseconds / 1000) target:self selector:@selector(idleTimerHandler:) userInfo:NULL repeats:NO];
}

- (void) idleTimerHandler:(NSTimer *)timer {
    [KGTracer trace:@"Idle timer scheduled"];
    long long currentTimestamp = (long long) [[NSDate date] timeIntervalSince1970] * 1000;
    long idleDuration = currentTimestamp - _lastMessageTimestamp;
    if (idleDuration > _idleTimeout) {
        NSString *message = [NSString stringWithFormat:@"idle duration - %ld exceeded idle timeout - %d", idleDuration, _idleTimeout];
        [KGTracer trace:message];
        @try {
            _socketState = WEBSOCKET_CLOSED;
            [self closeStreams];
        }
        @catch (NSException *exception) {
            // error close socket ignored
             [KGTracer trace:[@"Error during close socket - " stringByAppendingString:[exception reason]]];
        }
        @finally {
            [self handleClose];
        }
    }
    else {
        
        //Restart the timer
        [self startIdleTimer:(_idleTimeout - idleDuration)];
    }
}

- (void) stopIdleTimer {
    [KGTracer trace:@"Stopping idle timer"];
    if (_idleTimer != nil) {
        [_idleTimer invalidate];
        _idleTimer = nil;
        _idleTimeout = 0;
    }
}
@end

