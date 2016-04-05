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
#import "KGHttpRequest.h"
#import "KGHttpRequestFactory.h"
#include <libkern/OSAtomic.h>

@interface KGHttpRequestFactoryImpl : NSObject <KGHttpRequestFactory>
@end

@implementation KGHttpRequestFactoryImpl

- (KGHttpRequest *) createHttpRequest:(NSString*)method_ uri:(KGHttpURI *)uri_ async:(BOOL)async_ {
#ifdef DEBUG
    NSLog(@"KGHttpRequestFactoryImpl -> createHttpRequest");
#endif
    
    KGHttpMethod method;
    if ([method_ isEqualToString:@"POST"]) {
        method = POST;
    }
    else {
        method = GET;
    }
    
    KGHttpRequest * request = [[KGHttpRequest alloc] initWithMethod:method uri:uri_ async:async_];
    //request.parent = channel;
    return request;
}
@end


@implementation KGHttpRequest {
    // private
    KGHttpMethod _method;
    // private
    KGHttpURI           *_uri;
    // private
    BOOL                 _async;
    
    KGHttpReadyState     _readyState;
    KGHttpResponse      *_response;
    KGChannel           *_parent;
    
    NSMutableDictionary *_headers;
    
    NSMutableURLRequest *_urlRequest;
    NSURLConnection     *_urlConnection;
    NSMutableData       *_data;
    SecIdentityRef       _clientIdentity;
    volatile uint32_t   _errorOccuredFired;
}

- (void)dealloc
{
    if (_headers != nil) {
        [_headers removeAllObjects];
    }
    
    _urlRequest = nil;
    _urlConnection = nil;
    _headers = nil;
    _uri = nil;
    _response = nil;
    _parent = nil;
    _data = nil;
    _clientIdentity = nil;
}

// init stuff:

- (void) init0 {
    /** Current ready state for this request */
    _readyState = UNSENT;
    _headers = [[NSMutableDictionary alloc] init];
    _errorOccuredFired = 0;
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

+(id<KGHttpRequestFactory>) HTTP_REQUEST_FACTORY {
    // hrm...:
    // per instance...:
    KGHttpRequestFactoryImpl * factory = [KGHttpRequestFactoryImpl new];
    return factory;
}

+ (NSString*) methodTypeToString:(KGHttpMethod)method {
     NSString* result = nil;
    
    switch(method) {
        case POST:
            result = @"POST";
            break;
        case GET:
            result = @"GET";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected METHOD."];
    }
    return result;    
}

-(KGHttpRequest *)initWithMethod:(KGHttpMethod)method uri:(KGHttpURI *)uri async:(BOOL)async {
   self =  [self init];
    if (self) {
        _method = method;
        _uri = uri;
        _async = async;
    }
    return self;
}

-(KGHttpMethod) method {
    return _method;
}

-(KGHttpURI *) uri{
    return _uri;
}

-(BOOL) isAsync {
    return _async;
}

- (void) setReadyState:(KGHttpReadyState) readyState {
    _readyState = readyState;
}

- (KGHttpReadyState) readyState {
    return _readyState;
}

- (void) setResponse:(KGHttpResponse *) response {
    _response = response;
}

- (KGHttpResponse *) response {
    return _response;
}

- (void) setParent:(KGChannel *) parent {
    _parent = parent;
}
- (KGChannel *) parent {
    return _parent;
}

-(NSDictionary*) headers {
    return _headers;
}

-(void)setHeader:(NSString*) header value:(NSString *)value {
    [_headers setValue:value forKey:header];
}

- (void) setData:(NSMutableData*) data {
    _data = data;
}

- (NSMutableData*) data {
    return _data;
}

- (void) setUrlRequest:(NSMutableURLRequest*) request {
    _urlRequest = request;
}

- (NSMutableURLRequest*) urlRequest {
    return _urlRequest;
}

- (void) setUrlConnection:(NSURLConnection*) conn {
    _urlConnection = conn;
}

- (NSURLConnection*) urlRConnection {
    return _urlConnection;
}

- (void) setClientIdentity:(SecIdentityRef)clientIdenity {
    _clientIdentity = clientIdenity;
}

- (SecIdentityRef) clientIdentity {
    return _clientIdentity;
}

- (BOOL) hasErrorOccuredFired {
    return _errorOccuredFired != 0;
}

- (void)setErrorOccuredFired:(BOOL)fired {
    if (fired) {
        OSAtomicOr32Barrier(1, & _errorOccuredFired); //Atomic bitwise OR of two 32-bit values with barrier
    }
    else {
        OSAtomicAnd32Barrier(0, & _errorOccuredFired); //Atomic bitwise AND of two 32-bit values with barrier.
    }
}

@end
