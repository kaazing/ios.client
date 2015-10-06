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
#import "KGHttpRequestRedirectHandler.h"
#import "KGWebSocketEmulatedChannel.h"
#import "KGTracer.h"

@interface KGHttpRequestRedirectHandler_HttpRequestListener_1 : NSObject <KGHttpRequestListener>

-initWithHttpRequestHandler:(KGHttpRequestRedirectHandler *)handler;

@end

@implementation KGHttpRequestRedirectHandler_HttpRequestListener_1 {
    KGHttpRequestRedirectHandler * _parent;
}

- (void)dealloc
{
    _parent = nil;
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

-initWithHttpRequestHandler:(KGHttpRequestRedirectHandler *)handler {
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
    [KGTracer trace:@"[KGHttpRequestRedirectHandler requestLoaded]"];
    int responseCode = [response statusCode];
    
    switch (responseCode) {
        case 301:
        case 302:
        case 307:{
            // handle the redirect (possibly cross-scheme)
            NSString* redirectedLocation = [response header:@"Location"];
//            if (LOG.isLoggable(Level.FINEST)) {
//                LOG.finest("redirectedLocation = " + StringUtils.stripControlCharacters(redirectedLocation));
//            }
//            
            if (redirectedLocation == nil) {
                // hrm... really??
                NSLog(@"Redirect response missing location header: %d", responseCode);
                [[_parent listener] requestLoaded:request response:response];
                return;
            }
            
            @try {
                KGHttpURI * uri = [[KGHttpURI alloc] initWithURI:redirectedLocation];
                
                KGHttpRequest * redirectRequest = [[KGHttpRequest alloc] initWithMethod:request.method uri:uri async:[request isAsync]];
                redirectRequest.parent = request.parent;
                KGWebSocketEmulatedChannel * channel = (KGWebSocketEmulatedChannel *) request.parent.parent;
                channel.redirectUri = uri;               
                
                // transfer the headers over..
                NSDictionary* requestHeaders = [request headers];
                NSArray * keys = [requestHeaders allKeys];
                for (int i = 0; i < [keys count]; i++) {
                    NSString* key = [keys objectAtIndex:i];
                    NSString* value = [requestHeaders valueForKey:key];
                    [redirectRequest setHeader:key value:value];
                }
                
                [[_parent nextHandler] processOpen:redirectRequest];
                
            } @catch (id e) {
                //LOG.log(Level.WARNING, e.getMessage(), e);
                NSLog(@"redirectedLocation is invalid: %@", redirectedLocation);
                [[_parent listener] requestLoaded:request response:response];
            }
        }
            break;
            
        default:
            [[_parent listener] requestLoaded:request response:response];
            break;
    }
}

- (void) requestClosed:(KGHttpRequest *)request{
    [[_parent listener] requestClosed:request];
}

- (void) requestAborted:(KGHttpRequest *)request{
    [[_parent listener] requestAborted:request];
}

- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception {
    [[_parent listener] errorOccurred:request exception:exception];
}
@end


@implementation KGHttpRequestRedirectHandler

- (void)dealloc
{
}

// init stuff:
- (void) init0 {
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (void) setNextHandler:(id <KGHttpRequestHandler>)handler {
    KGHttpRequestRedirectHandler_HttpRequestListener_1 * listener =
           [[KGHttpRequestRedirectHandler_HttpRequestListener_1 alloc] initWithHttpRequestHandler:self];

    [handler setListener:listener];
    [super setNextHandler:handler];
}


@end
