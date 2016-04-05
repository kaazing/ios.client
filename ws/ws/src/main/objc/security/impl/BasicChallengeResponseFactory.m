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
#import "BasicChallengeResponseFactory.h"

@implementation BasicChallengeResponseFactory

+ (KGChallengeResponse *) createWithCredentials:(NSURLCredential*) credentials challengeHandler:(KGChallengeHandler *)challengeHandler {
    // different than in Java - but there are ObjC APIs, so we are using them:
    
    NSString* response = [BasicChallengeResponseFactory createResponseString:credentials];
    KGChallengeResponse * cres = [[KGChallengeResponse alloc] initWithCredentials:response nextChallengeHandler:challengeHandler];
    return cres;
}


+ (NSString*) createResponseString:(NSURLCredential*) creds {
    
    // create a (empty) dummy request:
    CFHTTPMessageRef dummyRequest =
    CFHTTPMessageCreateRequest(kCFAllocatorDefault,
                               CFSTR("GET"),
                               nil,
                               kCFHTTPVersion1_1);  

    // apply the given credentials:
    CFHTTPMessageAddAuthentication(dummyRequest,
                                   nil,
                                   (__bridge CFStringRef)[creds user],
                                   (__bridge CFStringRef)[creds password],
                                   kCFHTTPAuthenticationSchemeBasic,
                                   FALSE);

    // trick: read the Authorization header out of that dummy request, since that gives us:
    // "Basic am9lOndlbGNvbWU=" (which is the Base64 encoded user/password)
    NSString* responseString =
    (__bridge_transfer NSString *)CFHTTPMessageCopyHeaderFieldValue(dummyRequest,
                                                  CFSTR("Authorization"));
    
    // release the dummy request
    CFRelease(dummyRequest);

    return responseString;
}

@end
