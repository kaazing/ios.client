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
#import "DefaultBasicChallengeHandler.h"
#import "BasicChallengeResponseFactory.h"
#import "RealmUtils.h"

@implementation DefaultBasicChallengeHandler{
    NSMutableDictionary* _loginHandlersByRealm;
    KGLoginHandler * _loginHandler;
    
}

- (void)dealloc
{
}

// init stuff:

- (void) init0 {
    _loginHandlersByRealm = [[NSMutableDictionary alloc] init];
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(void)setRealmLoginHandler:(NSString*)realm loginHandler:(KGLoginHandler *) loginHandler {
    if (realm == nil) {
        // TODO
    }
    if (loginHandler == nil) {
        // TODO
    }

    [_loginHandlersByRealm setObject:loginHandler forKey:realm];
}

-(KGChallengeHandler *) setLoginHandler:(KGLoginHandler *) loginHandler {
    _loginHandler = loginHandler;
    return self;
}

-(KGLoginHandler *) loginHandler {
    return _loginHandler;
}

-(BOOL) canHandle:(KGChallengeRequest *) challengeRequest {
    return ((challengeRequest != nil) && ([@"Basic" isEqual:[challengeRequest authenticationScheme]]));
}

-(KGChallengeResponse *) handle:(KGChallengeRequest *) challengeRequest {
    
    
    if ([challengeRequest location] != nil) {
        KGLoginHandler * loginHandler = [self loginHandler];
        NSString* realm = [RealmUtils realm:challengeRequest];
        
        if((realm != nil) && ([_loginHandlersByRealm objectForKey:realm]!= nil)) {
            loginHandler = [_loginHandlersByRealm objectForKey:realm];
        }
        
        if (loginHandler != nil) {
            NSURLCredential* creds = [loginHandler credentials];
            if (creds != nil && [creds user] != nil && [creds password] != nil) {
                return [BasicChallengeResponseFactory createWithCredentials:creds challengeHandler:self];
            }
        }
    }
    return nil;
}

@end
