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

#import <Foundation/Foundation.h>
#import "KGHttpRequestFactory.h"
#import "KGHttpResponse.h"
#import "KGChannel.h"
#import "KGHttpURI.h"

typedef enum {
    /** Request has not yet been sent */
    UNSENT,
    /** Request is ready to be sent.  Data can be sent at this time for POST requests */
    READY,
    /** Request is in the process of sending.  No further data can be written at this time. */
    SENDING,
    /** Request has been sent, but no response has been received */ 
    SENT,
    /** Response has been partially received.  All headers are available. */
    OPENED,
    /** Response has been partially received.  Some data is available. */
    LOADING,
    /** Response has been completed.  All data is available. */
    LOADED,
    /** An error occurred during the request or response. */
    ERROR
} KGHttpReadyState;

/** Methods available for KGHttpRequest */
typedef enum {
    GET,
    POST
} KGHttpMethod;



@interface KGHttpRequest : NSObject

// public static final KGHttpRequestFactory HTTP_REQUEST_FACTORY = new KGHttpRequestFactory() {...};
+ (id <KGHttpRequestFactory>) HTTP_REQUEST_FACTORY;

+ (NSString*) methodTypeToString:(KGHttpMethod)method;


- (KGHttpRequest *) initWithMethod:(KGHttpMethod)method uri:(KGHttpURI *)uri async:(BOOL)async;

// public
- (KGHttpMethod) method;

// public
- (KGHttpURI *) uri;

// public
- (BOOL) isAsync;

- (void) setReadyState:(KGHttpReadyState) readyState;
- (KGHttpReadyState) readyState;

- (void) setResponse:(KGHttpResponse *) response;
- (KGHttpResponse *) response;

// the channel
- (void) setParent:(KGChannel *) parent;
- (KGChannel *) parent;

// http headers
-(NSMutableDictionary*) headers;
-(void)setHeader:(NSString*) header value:(NSString *)value;
//-(void) setHeaders

//payload data
- (void) setData:(NSMutableData*) data;
- (NSMutableData*) data;

//ios native http objects
- (void) setUrlRequest:(NSMutableURLRequest*) request;
- (NSMutableURLRequest*) urlRequest;

- (void) setUrlConnection:(NSURLConnection*) connection;
- (NSURLConnection*) urlRConnection;

- (void) setClientIdentity:(SecIdentityRef) clientIdenity;
- (SecIdentityRef) clientIdentity;

- (BOOL) hasErrorOccuredFired;
- (void) setErrorOccuredFired:(BOOL)fired;
@end
