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
#import "KGHttpRequestIoHandler.h"
#import "KGHttpRequestListener.h"
#import "KGHttpRequest.h"
#import "KGTracer.h"

@implementation KGHttpRequestIoHandler {

    // the listener:
    id <KGHttpRequestListener> _listener;
    // live HttpRequests
    NSMutableArray            *_httpRequests;

}

- (void)dealloc
{
    _listener = nil;
    if (_httpRequests != nil) {
        [_httpRequests removeAllObjects];
        _httpRequests = nil;
    }
}

// init stuff:
- (void) init0 {
    // Initialization code here.
    if (_httpRequests == nil) {
        _httpRequests = [[NSMutableArray alloc] init];
    }
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (void) processOpen:(KGHttpRequest *)request {
    
    // add the request to array
    @synchronized(_httpRequests) {
        [_httpRequests addObject:request];
    }
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler processOpen, active request=%@]", request]];
    //TODO: store the ASYNC information....
    
    //NSURL* nsUrl = [NSURL URLWithString:[[request uri] URI]];
    NSURL* nsUrl = [[request uri] URI];

    // create the 'request url'
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:nsUrl];

    // set the HTTP method:
    [urlRequest setHTTPMethod: [KGHttpRequest methodTypeToString:[request method]]];
    
    [request setUrlRequest:urlRequest];
    [self handleRequestCreated:request];
}

// package private
- (void) processSend:(KGHttpRequest *)request buffer:(KGByteBuffer *)buffer {
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler processSend %@]", request]];
    // Request is in the process of sending.  No further data can be written at this time
    [request setReadyState:SENDING];
    
    if (buffer != nil) {
        NSData* wsPayload = [buffer getData:buffer.remaining];

        [[request urlRequest] setHTTPBody:wsPayload];
    }

    // some kaazing identifier:
    [[request urlRequest] setValue:@"Kaazing iOS client" forHTTPHeaderField:@"User-Agent"];
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:[request urlRequest] delegate:self];
    [request setUrlConnection:connection];
    
    // If you pass NO (startImmediately), the connection is not scheduled with a run loop.
    // You can then schedule the connection in the run loop and mode
    // of your choice by calling scheduleInRunLoop:forMode:.
    //[_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];

    [request setReadyState:SENT];
}

// package private
- (void) processAbort:(KGHttpRequest *)request{
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)processAbort %@]", request]];
    @synchronized(_httpRequests) {
        [_httpRequests removeObject:request];
    }
}

// package private
- (void) setListener:(id <KGHttpRequestListener>)listener{
    _listener = listener;
}

// private methods...:

- (void) handleRequestCreated:(KGHttpRequest *) request_ {
    [request_ setReadyState:READY];
    
    
    // copy all the headers......:
    NSArray * headerKeys = [[request_ headers] allKeys];
    
    for (int i=0; i<[headerKeys count]; i++) {
        NSString* key = [headerKeys objectAtIndex:i];
        NSString* value = [[request_ headers] valueForKey:key];
        
        [[request_ urlRequest] setValue:value forHTTPHeaderField:key];
    }
    
    // Nothing has been sent
    if ([request_ method] == POST) {
        // invoked for Up/Downstream...
        [_listener requestReady:request_];
    }
    else {
        [self processSend:request_ buffer:nil];
    }
}

-(void) handleRequestLoaded:(KGHttpRequest *) request_ responseBuffer:(KGByteBuffer *) responseBuffer_ {
    [request_ setReadyState:LOADED];
    KGHttpResponse * response = [request_ response];
    
    [response setBody:responseBuffer_];
    [_listener requestLoaded:request_ response:response];
}

//find httpRequest for this connection
-(KGHttpRequest*) findKGHttpRequest:(NSURLConnection* ) connection {
    
    KGHttpRequest * request = nil;
    @synchronized(_httpRequests) {
        for (KGHttpRequest * r in _httpRequests) {
            if ([r urlRConnection] == connection) {
                request = r;
                break;
            }
        }
    }
    return request;
}

// =================== NSURLConnection delegates..... 

// server sends 302 redirect
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse != nil) {
        return nil; //let KGHttpRedirectHandler handle redirect response
    }
    return request;
}
// server started to send the response..
-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    [KGTracer trace:@"[KGHttpRequestIoHandler (delegate)didReceiveResponse]"];
    //find httpRequest for this connection
    KGHttpRequest * request = [self findKGHttpRequest:connection];
    if (request == nil) {
        [KGTracer trace:[NSString stringWithFormat:@"KGHttpRequestIoHandler: cannot find KGHttpRequest for this connection %@", connection]];
        return;
    }
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)didReceiveResponse %@]", request]];
    NSHTTPURLResponse* hr = (NSHTTPURLResponse*) response;
    [request setData:[NSMutableData alloc]];
    KGHttpResponse * resp = [[KGHttpResponse alloc] init];
    
    [request setResponse:resp];
    
    [resp setStatusCode:hr.statusCode];
    
    
    NSDictionary* responseHeaders = [hr allHeaderFields];
    NSArray * keys = [responseHeaders allKeys];
    for (int i = 0; i < [keys count]; i++) {
        NSString* key = [keys objectAtIndex:i];
        NSString* value = [responseHeaders valueForKey:key];
        [resp setHeader:key value:value];
    }

    [request setReadyState:OPENED];
    [_listener requestOpened:request];
}


// every time new data is received from the server, the didReceiveData method is invoked
-(void)connection:(NSURLConnection *)connection didReceiveData:
(NSData *)incomingData
{
    [KGTracer trace:@"[KGHttpRequestIoHandler (delegate)didReceiveData]"];
    KGHttpRequest * request = [self findKGHttpRequest:connection];
    if (request == nil) {
        [KGTracer trace:[NSString stringWithFormat:@"KGHttpRequestIoHandler didReceiveData: cannot find KGHttpRequest for this connection %@", connection]];
        return;
    }
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)didReceiveData %@]", request]];
    [[request data] appendData:incomingData];
    [_listener requestProgressed:request payload:[KGByteBuffer wrapData:incomingData]];
}

//authentication
-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
#ifdef DEBUG
    NSLog(@"[KGHttpRequestIoHandler (delegate)canAuthenticateAgainstProtectionSpace]");
#endif
    KGHttpRequest * request = [self findKGHttpRequest:connection];
    if (request == nil) {
        NSLog(@"KGHttpRequestIoHandler canAuthenticateAgainstProtectionSpace: cannot find KGHttpRequest for this connection %@", connection);
        return NO;
    }
    if([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        return ([request clientIdentity] != nil);
    }
    else {
        return NO;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
#ifdef DEBUG
    NSLog(@"[KGHttpRequestIoHandler (delegate)didReceiveAuthenticationChallenge]");
#endif
    KGHttpRequest * request = [self findKGHttpRequest:connection];
    if (request == nil) {
        NSLog(@"KGHttpRequestIoHandler didReceiveAuthenticationChallenge: cannot find KGHttpRequest for this connection %@", connection);
        [challenge.sender cancelAuthenticationChallenge:challenge];
        return;
    }
    if([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        
        @try {
            if (challenge.previousFailureCount < 5) {
                // Extract certificate.
                if ([request clientIdentity] != nil) {
                    
                    //add aditional certificates
                    //NSArray *certificates = nil;
                    
                    // Initialise credential, "Always Trust".
                    NSURLCredential* credential = [NSURLCredential credentialWithIdentity:[request clientIdentity]
                                                                             certificates:nil
                                                                              persistence:NSURLCredentialPersistencePermanent];
#ifdef DEBUG
                    NSLog(@"[KGHttpRequestIoHandler challenge.sender useCredential:credential ...]");
#endif
                    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
                }
                else {
#ifdef DEBUG
                    NSLog(@"[KGHttpRequestIoHandler challenge.sender continueWithoutCredentialForAuthenticationChallenge");
#endif
                    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
                }
            }
            else {
                @throw [NSException exceptionWithName:@"InvalidPasswordException" reason:@"Login failed" userInfo:NULL];
            }
        }
        @catch (NSException *exception) {
#ifdef DEBUG
            NSLog(@"[KGHttpRequestIoHandler (delegate)didReceiveAuthenticationChallenge] Exception: %@", [exception reason]);
#endif
            [challenge.sender cancelAuthenticationChallenge:challenge];
            
        }
    }
    else if([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge: challenge];
    }
    else {
#ifdef DEBUG
        NSLog(@"[KGHttpRequestIoHandler (delegate)didReceiveAuthenticationChallenge] unhandled authenticationMethod: %@", [[challenge protectionSpace] authenticationMethod]);
#endif
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}


// we are done with the request...
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [KGTracer trace:@"[KGHttpRequestIoHandler (delegate)connectionDidFinishLoading]"];
    KGHttpRequest * request = [self findKGHttpRequest:connection];
    if (request == nil) {
        [KGTracer trace:[NSString stringWithFormat:@"KGHttpRequestIoHandler: cannot find KGHttpRequest for this connection %@", connection]];
        return;
    }
    
    @try {
        [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)connectionDidFinishLoading %@]", request]];
        KGByteBuffer * respBuffer = [KGByteBuffer wrapData:[request data]];
        [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler connectionDidFinishLoading, active request=%@]", request]];
        @synchronized(_httpRequests) {
            [_httpRequests removeObject:request]; //remove this request from array
        }
        [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler connectionDidFinishLoading, active request=%lu]", [_httpRequests count]]];
        [self handleRequestLoaded:request responseBuffer:respBuffer];
    }
    @catch (NSException *ex) {
        // Under 64-bit, we see some strange behavior in this method. For instance,
        // once the local variable 'request' is initialized, we check whether it's nil.
        // If it is nil, we just log and return out of this method. However, with 64-bit,
        // we see a crash on the subsequent lines that is trying to create a NSString for
        // trace purposes. And, the debugger indicates that 'request' is nil. It's a
        // mystery -- a) the check for (request == nil) did not succeed, b) how did
        // 'request' become nil if it wasn't earlier. To avoid the app from crashing
        // under such mysterious conditions, we are just going to swallow the exception
        // as the connection has finished anyways.
        [KGTracer trace:@"Swallowing exception in KGHttpRequestIoHandler's connectionDidFinishLoading selector."];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)Error: %@", [error localizedDescription]]];
    KGHttpRequest * request = [self findKGHttpRequest:connection];
    if (request == nil) {
        [KGTracer trace:[NSString stringWithFormat:@"KGHttpRequestIoHandler: cannot find KGHttpRequest for this connection %@", connection]];
        return;
    }
    [KGTracer trace:[NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)Error: %@", request]];
    @synchronized(_httpRequests) {
        [_httpRequests removeObject:request]; //remove this request from array
        
        if (![request hasErrorOccuredFired]) {
            [request setErrorOccuredFired:YES];
            
            NSString *reason = [NSString stringWithFormat:@"[KGHttpRequestIoHandler (delegate)Error: %@", [error localizedDescription]];
            NSException *ex = [[NSException alloc] initWithName:@"NSException" reason:reason userInfo:nil];
            [_listener errorOccurred:request exception:ex];
        }
    }
}

@end
