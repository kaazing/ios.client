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

#import "KGHttpRequestAuthenticationHandler.h"
#import "KGWebSocketEmulatedChannel.h"
#import "KGWebSocketCompositeChannel.h"
#import "NSURL+KZNGAdditions.h"
#import "KGAuthenticationUtil.h"
#import "KGHttpRequest.h"
#import "KGConstants.h"
#import "KGTracer.h"



@interface KGAuthentication_HttpRequestListener_1 : NSObject <KGHttpRequestListener>

-initWithHttpRequestHandler:(KGHttpRequestAuthenticationHandler *)handler;

@end

@implementation KGAuthentication_HttpRequestListener_1 {
    KGHttpRequestAuthenticationHandler * _parent;
}

static KGByteBuffer *httpStartBuffer;

+ (void) initialize {
    httpStartBuffer = [[KGByteBuffer alloc] init];
    [httpStartBuffer putString:HTTP_1_1_START];
}

- (void)dealloc
{
    _parent = nil;
    httpStartBuffer = nil;
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

-initWithHttpRequestHandler:(KGHttpRequestAuthenticationHandler *)handler {
    self = [self init];
    if (self) {
        _parent = handler;
    }
    return self;
    
}

// Delegate... KGHttpRequestListener
- (void) requestReady:(KGHttpRequest *)request{
    [[_parent listener] requestReady:request];
}

// package private
- (void) requestOpened:(KGHttpRequest *)request{
    [[_parent listener] requestOpened:request];
}

// package private
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload{
    [[_parent listener] requestProgressed:request payload:payload];
}

// package private
- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response{
    
    int responseCode = [response statusCode];
    
    switch (responseCode) {
        case 200: {
            KGByteBuffer * buf = [response body];
            if ([self isHttpResponse:buf]) {
                @try {
                    [_parent onLoadWrappedHTTPResponse:request response:response];
                } @catch (NSException *e) {
                    [KGTracer trace:[e debugDescription]];
                    [[_parent listener] errorOccurred:request exception:e];
                }
            }
            else {
                [_parent handleRemoveAuthenticationData:request];
                [[_parent listener] requestLoaded:request response:response];
            }
        }
        break;

        case 401: {
            NSString* challenge = [response header:HEADER_WWW_AUTHENTICATE];
            [_parent handle401:request challenge:challenge];
        }
        break;
            
        default:
            [_parent handleRemoveAuthenticationData:request];
            [[_parent listener] requestLoaded:request response:response];
            break;
    }
}

- (BOOL) isHttpResponse:(KGByteBuffer *)buffer {
    int httpStartLength = [HTTP_1_1_START length];
    if ([buffer remaining] < httpStartLength) {
        return NO;
    }
    
    // always reset before checking as this buffer is reused
    [httpStartBuffer flip];
    for(int i = 0; i < httpStartLength; i++) {
        if([buffer getAt:i] != [httpStartBuffer getAt:i]) {
            return NO;
        }
    }
    
    return YES;
}

- (void) requestClosed:(KGHttpRequest *)request{
    [_parent handleRemoveAuthenticationData:request];
}

- (void) requestAborted:(KGHttpRequest *)request{
    [_parent handleRemoveAuthenticationData:request];
    [[_parent listener] requestAborted:request];
}

- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)ex {
    [_parent handleRemoveAuthenticationData:request];
    [[_parent listener] errorOccurred:request exception:ex];
}
@end



@implementation KGHttpRequestAuthenticationHandler

-(void) handleClearAuthenticationData:(KGHttpRequest *) request {
    KGChannel * channel = [super getWebSocketChannel:request];
    if(channel == nil)
        return;
    KGChallengeHandler * nextChallengeHandler = nil;
    if ([channel challengeResponse] != nil) {
        nextChallengeHandler = channel.challengeResponse.nextChallengeHandler;
        [channel.challengeResponse clearCredentials];
        channel.challengeResponse = nil;
    }
    channel.challengeResponse = [[KGChallengeResponse alloc] initWithCredentials:nil nextChallengeHandler:nextChallengeHandler];
}

-(void) handleRemoveAuthenticationData:(KGHttpRequest *) request {
    [self handleClearAuthenticationData:request];
}

+(NSArray *) getLines:(NSData*) buf {
    NSString* gatewayResponse = [[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding];
    NSArray * lines = [gatewayResponse componentsSeparatedByString:@"\r\n"];
    return lines;
}

-(void) onLoadWrappedHTTPResponse:(KGHttpRequest *) request response:(KGHttpResponse *) response {
    KGByteBuffer * buf = [response body];
    NSData* responseBody = [buf data];
    
    NSArray * lines = [KGHttpRequestAuthenticationHandler getLines:responseBody];
    int statusCode = [[[[lines objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:1] intValue];
    if (statusCode == 401) {
        NSString* wwwAuthenticate = nil;
        for (int i = 1; i < lines.count; i++) {
            if ([[lines objectAtIndex:i] hasPrefix:WWW_AUTHENTICATE]) {
                wwwAuthenticate = [[lines objectAtIndex:i] substringFromIndex:[WWW_AUTHENTICATE length]];
                break;
            }
        }
        
        NSString* rawChallenge = [wwwAuthenticate substringFromIndex:[APPLICATION_PREFIX length]];
        
        [self handle401:request challenge:rawChallenge];
    }
}


-(void) handle401:(KGHttpRequest *) request challenge:(NSString*) challenge {

    KGHttpURI * uri = [request uri];
    KGWebSocketEmulatedChannel *channel = (KGWebSocketEmulatedChannel *)[self getWebSocketChannel:request];
    if(channel == nil) {
        // throw new IllegalStateException("There is no KGWebSocketChannel associated with this request");
        return;
    }
    
    if ([super isWebSocketClosing:request]) {
        // WebSocket is closing/closed, no need to authenticate.
        return;
    }

    KGWebSocketCompositeChannel *compChannel = (KGWebSocketCompositeChannel *) [channel parent];
    KGResumableTimer *connectTimer = nil;
    
    if (compChannel != nil) {
        connectTimer = [compChannel connectTimer];
        if (connectTimer != nil) {
            [connectTimer pause];
        }
    }

    [channel setAuthenticationReceived:YES];
    NSString* challengeUrl = [[channel location] description];
    if ([channel redirectUri] != nil) {
        challengeUrl = [NSString stringWithFormat:@"%@%@%@%@", [[channel redirectUri] scheme], @"://", [[[channel redirectUri] URI] authority ],  [[channel redirectUri] path]];

    //        // path "/;e/cb" was added in KGWebSocketEmulatedHandler, this is returned by balancer, remove it
    //        challengeUrl = challengeUrl.replace("/;e/cb", ""); 
    }
    KGChallengeRequest * challengeRequest = [[KGChallengeRequest alloc] initWithLocation:challengeUrl challenge:challenge];
    
    @try {
        channel.challengeResponse = [KGAuthenticationUtil challengeResponse:channel challengeRequest:challengeRequest challengeResponse:channel.challengeResponse];
    } @catch (id exception) {
    //        LOG.log(Level.FINE, e.getMessage());
    //        handleClearAuthenticationData(request);
        [self doError:request exception:(NSException *)exception];
    //        throw new IllegalStateException("Unexpected error processing challenge "+challenge, e);
    }
        
    if (channel.challengeResponse == nil || [channel.challengeResponse credentials] == nil) {
    //        throw new IllegalStateException("No response possible for challenge "+challenge);
        NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:@"No response possible for challenge " userInfo:nil];
        [self doError:request exception:ex];
        return;
    }
        
    @try {
        KGHttpRequest * newRequest =  [[KGHttpRequest alloc] initWithMethod:request.method uri:uri async:[request isAsync]];
        newRequest.parent = request.parent;
            
        //[[newRequest headers] setValue:@"text/plain" forKey:@"Content-Type"];
        NSArray * keys = [[request headers] allKeys];
        for (int i=0; i<[keys count]; i++) {
            NSString* key = [keys objectAtIndex:i];
            NSString* value = [[request headers] valueForKey:key];
            [[newRequest headers] setValue:value forKey:key];
        }
        
        if (connectTimer != nil) {
            [connectTimer resume];
        }

        [self processOpen:newRequest];
    }
    @catch (id exception) {
    //        LOG.log(Level.FINE, e1.getMessage(), e1);
    //        throw new Exception("Unable to authenticate user", e1);
        @throw exception;
    }
}


- (void) doError:(KGHttpRequest *)request exception:(NSException *)ex {
    [_listener errorOccurred:request exception:ex];

}

- (void) processOpen:(KGHttpRequest *)request {
#ifdef DEBUG
    NSLog(@"[KGHttpRequestAuthenticationHandler processOpen]");
#endif
    
    KGChannel *channel = [self getWebSocketChannel:request];
    if (channel != nil) {
        if ([super isWebSocketClosing:request]) {
             // WebSocket is closing/closed, no need to authenticate.
            return;
        }

        if ([[channel challengeResponse] credentials] != nil) {
            NSString* credentials = [[channel challengeResponse] credentials];
            [request setHeader:HEADER_AUTHORIZATION value:credentials];
            [self handleClearAuthenticationData:request];
        }
    }
    [_nextHandler processOpen:request];
}

- (void) setNextHandler:(id <KGHttpRequestHandler>)handler {
    KGAuthentication_HttpRequestListener_1 * listener = [[KGAuthentication_HttpRequestListener_1 alloc] initWithHttpRequestHandler:self];
    [handler setListener:listener];
    
    [super setNextHandler:handler];
}

- (void) setListener:(id <KGHttpRequestListener>)listener {
    _listener = listener;
}

@end
