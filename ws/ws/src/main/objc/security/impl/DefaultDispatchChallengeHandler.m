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
#import "DefaultDispatchChallengeHandler.h"
#import "Token.h"
#import "Node.h"

#import "NSURL+KZNGAdditions.h"
#import "NSString+KZNGAdditions.h"
#import "NSArray+KZNGAdditions.h"

NSString *const SCHEME_URI = @"^(.*)://(.*)";



// =============================
// the actual class:
// =============================
@implementation DefaultDispatchChallengeHandler {
    Node* _rootNode;
    NSMutableDictionary* defaultPortsByScheme;

}

-(void)dealloc {
    _rootNode = nil;
    defaultPortsByScheme = nil;
}
// init stuff:
- (void) init0 {
    // Initialization code here.
    _rootNode = [[Node alloc] init];
    defaultPortsByScheme = [[NSMutableDictionary alloc] init];
    
    // add the ports for each scheme:
    [defaultPortsByScheme setValue:@"80" forKey:@"http"];
    [defaultPortsByScheme setValue:@"80" forKey:@"ws"];
    [defaultPortsByScheme setValue:@"443" forKey:@"wss"];
    [defaultPortsByScheme setValue:@"443" forKey:@"https"];

}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}




-(void) clear {
    _rootNode = [[Node alloc] init];
}

//override:
-(BOOL) canHandle:(KGChallengeRequest *) challengeRequest {
    return ([self lookup:challengeRequest] != nil);
}
//override:
-(KGChallengeResponse *) handle:(KGChallengeRequest *) challengeRequest {
    KGChallengeHandler * challengeHandler = [self lookup:challengeRequest];
    if (challengeHandler == nil) {
        return nil;
    }
    return [challengeHandler handle:challengeRequest];
}

-(KGDispatchChallengeHandler *) registerChallengeHandler:(NSString*) locationDescription challengeHandler:(KGChallengeHandler *) challengeHandler {
//    if (locationDescription == null || locationDescription.length() == 0) {
//        throw new IllegalArgumentException("Must specify a location to handle challenges upon.");
//    }
//    
//    if (challengeHandler == null) {
//        throw new IllegalArgumentException("Must specify a handler to handle challenges.");
//    }

    [self addChallengeHandlerAtLocation:locationDescription challengeHandler:challengeHandler];    
    
    return self;
}
-(KGChallengeHandler *) unregisterChallengeHandler:(NSString*) locationDescription challengeHandler:(KGChallengeHandler *) challengeHandler {
//    if (locationDescription == null || locationDescription.length() == 0) {
//        throw new IllegalArgumentException("Must specify a location to un-register challenge handlers upon.");
//    }
//    
//    if (challengeHandler == null) {
//        throw new IllegalArgumentException("Must specify a handler to un-register.");
//    }

    [self delChallengeHandlerAtLocation:locationDescription challengeHandler:challengeHandler];
    return self;
}

// public API:
-(NSArray *) lookupByLocation:(NSString*) location {
    NSArray * emptyList = [[NSArray alloc] init];
    
    if (location != nil) {
        Node* resultNode = [self findBestMatchingNode:location];
        if (resultNode != nil) {
            return [resultNode values];
        }
    }
    return emptyList;
}

/// privte things:
-(KGChallengeHandler *) lookup:(KGChallengeRequest *) challengeRequest {
    KGChallengeHandler * result = nil;
    NSString* location = [challengeRequest location];
    if (location != nil) {
        Node* resultNode = [self findBestMatchingNode:location];
        
        //
        // If we found an exact or wildcard match, try to find a handler
        // for the requested challenge.
        //
        if (resultNode != nil) {
            NSArray * handlers = [resultNode values];
            if (handlers != nil) {
                for (int i =0; i< [handlers count]; i++) {
                    KGChallengeHandler * challengeHandler = [handlers objectAtIndex:i];
                    
                    if ([challengeHandler canHandle:challengeRequest]) {
                        result = challengeHandler;
                        break;
                    }
                }
            }
        }
    }
    return result;
}

-(Node*) findBestMatchingNode:(NSString*) location {
    NSArray * tokens = [self tokenize:location];
    int tokenIdx = 0;
    
    return [_rootNode findBestMatchingNode:tokens tokenIdx:tokenIdx];
}

-(void)delChallengeHandlerAtLocation:(NSString*) locationDescription challengeHandler:(KGChallengeHandler *) challengeHandler {
    NSArray * tokens = [self tokenize:locationDescription];
    Node* cursor = _rootNode;
    for (int i =0;i<[tokens count]; i++) {
        Token* t = [tokens objectAtIndex:i];
        if (! [cursor hasChild:[t name] kind:[t kind]]) {
            return; // silently remove nothing
        } else {
            cursor = [cursor child:[t name]];
        }
    }
    [cursor removeValue:challengeHandler];
    
}
-(void)addChallengeHandlerAtLocation:(NSString*) locationDescription challengeHandler:(KGChallengeHandler *) challengeHandler {
    NSArray * tokens = [self tokenize:locationDescription];

    Node* cursor = _rootNode;
    for (int i =0;i<[tokens count]; i++) {
        Token* t = [tokens objectAtIndex:i];
        if (! [cursor hasChild:[t name] kind:[t kind]]) {
            cursor = [cursor addChild:[t name] kind:[t kind]];
        } else {
            cursor = [cursor child:[t name]];
        }
    }
    
    [cursor appendValues: [NSArray arrayWithObject:challengeHandler]];
}

-(NSArray *) tokenize:(NSString*) s {
    if (s == nil || [s length] == 0) {
        return [[NSArray alloc] init];
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:SCHEME_URI
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    // "Matcher"
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:s
                                                        options:0
                                                          range:NSMakeRange(0, [s length])];
    

    // matches ??
    if (numberOfMatches == 0) {
        s = [@"http://" stringByAppendingString:s];
    }
    
    NSURL* uri = [NSURL URLWithString:s];
    

    NSMutableArray * result = [[NSMutableArray alloc] init];
    NSString* scheme = @"http";
    if ([uri scheme] != nil) {
        scheme = [uri scheme];
    }
    
    //
    // A wildcard-ed hostname is parsed as an authority.
    //
    NSString* host = nil; // needs to be nil here, to do all the parsing...
    NSString* parsedPortFromAuthority = nil;
    NSString* parsedUserInfoFromAuthority = nil;
    NSString* userFromAuthority = nil;
    NSString* passwordFromAuthority = nil;
    
    if (host == nil) {
        NSString* authority = uri.authority;
        if (authority != nil) {
            host = authority;
            int asterixIdx = [host indexOf:@"@"];
            if (asterixIdx >= 0) {
                parsedUserInfoFromAuthority = [[host substringFromIndex:0] substringToIndex:asterixIdx];
                host = [host substringFromIndex:(asterixIdx+1)];
                int colonIdx = [parsedUserInfoFromAuthority indexOf:@":"];
                if (colonIdx >= 0) {
                    userFromAuthority = [[parsedUserInfoFromAuthority substringFromIndex:0] substringToIndex:colonIdx];
                    passwordFromAuthority = [parsedUserInfoFromAuthority substringFromIndex:(colonIdx+1)];
                }
            }
            int colonIdx = [host indexOf:@":"];
            if (colonIdx >=0) {
                parsedPortFromAuthority = [host substringFromIndex:(colonIdx+1)];
                host = [[host substringFromIndex:0] substringToIndex:colonIdx];
            }
        } else {
            // throw IllegalArgumentException("Hostname is required.");
        }
    }
    
    //
    // Split the host and reverse it for the tokenization.
    //
    NSArray * hostParts = [host componentsSeparatedByString:@"."];
    hostParts = [hostParts reversedArray];
    for (int i =0; i < [hostParts count]; i++) {
        [result addObject:[[Token alloc] initWithName:[hostParts objectAtIndex:i] element:HOST]];
    }
    
    if (parsedPortFromAuthority != nil) {
        [result addObject:[[Token alloc] initWithName:parsedPortFromAuthority element:PORT]];
    } else if (uri. port > 0) {
        [result addObject:[[Token alloc] initWithName:[[uri port] stringValue] element:PORT]];
    } else if ([self defaultPort:scheme] > 0) {
        [result addObject:[[Token alloc] initWithName:[NSString stringWithFormat:@"%d", [self defaultPort:scheme]] element:PORT]];
    }
    
    
    if (parsedUserInfoFromAuthority != nil) {
        if (userFromAuthority != nil) {
            [result addObject:[[Token alloc] initWithName:userFromAuthority element:USERINFO]];
        }
        if (passwordFromAuthority != nil) {
            [result addObject:[[Token alloc] initWithName:passwordFromAuthority element:USERINFO]];
        }
        // we don't need this here, in iOS - that's from Java; keeping it as a reminder
//        if (userFromAuthority != nil && passwordFromAuthority != nil) {
//            [result addObject:[[Token alloc] initWithName:parsedUserInfoFromAuthority element:USERINFO]];
//        }
    } else if (uri.user != nil || uri.password != nil) {
        if (uri.user != nil) {
            [result addObject:[[Token alloc] initWithName:uri.user element:USERINFO]];
        }
        if (uri.password != nil) {
            [result addObject:[[Token alloc] initWithName:uri.password element:USERINFO]];
        }
    }

    if ([self isNotBlank:uri.path]) {
        NSString* path = uri.path;
        if ([path hasPrefix:@"/"]) {
            path = [path substringFromIndex:1];
        }
        if ([self isNotBlank:path]) {
            NSArray * pathComponents = [path componentsSeparatedByString:@"/"];
            for (int i =0;i<[pathComponents count]; i++) {
               [result addObject:[[Token alloc] initWithName:[pathComponents objectAtIndex:i] element:PATH]]; 
            }
        }
    }
    return result;
}

-(int) defaultPort:(NSString*) scheme {
    NSString* portAsString = [defaultPortsByScheme objectForKey:[scheme lowercaseString]];
    
    if (portAsString != nil) {
        return [portAsString intValue];
    } else {
        return -1;
    }
}
-(BOOL) isNotBlank:(NSString*) s {
    return (s != nil && [s length] > 0);
}

@end
