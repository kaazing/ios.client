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
#import "NSURL+KZNGAdditions.h"
#import "NSString+KZNGAdditions.h"

@implementation NSURL (KZNGAdditions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    return theURL;
}

- (NSURL *)URLByReplacingPath:(NSString *)pathString{
    if (![pathString length]) {
        return self;
    }
    NSString* path = self.path;
    NSString* URLString = [self absoluteString];
    
    // if there is no path... we need to append it...
    if (path.length ==0) {
        URLString = [URLString stringByAppendingString:pathString];
    }
    else {
        URLString = [URLString stringByReplacingOccurrencesOfString:path withString:pathString];    
    }

    NSURL *theURL = [NSURL URLWithString:URLString];
    return theURL;
}

- (NSURL *)URLByReplacingScheme:(NSString *)schemeString {
    NSString* URLString = [self absoluteString];
    NSUInteger index = [URLString rangeOfString:@"://"].location;
    
    NSURL *theURL = [NSURL URLWithString:[schemeString stringByAppendingString:[URLString substringFromIndex:index]]];
    return theURL;
}

- (NSString*) authority {
    NSString* hostAndPort = [self host];
    if ([self port] != nil) {
        hostAndPort = [hostAndPort stringByAppendingFormat:@":%@", [self port]];
    }
    
    NSString* qualifiedScheme;
    // should be never nil:
    if ([self scheme] != nil) {
        qualifiedScheme = [[self scheme] stringByAppendingString:@"://"];
    }
    
    int end = [[self absoluteString] indexOf:hostAndPort];
    
    
    // remove everything until host/port (including!!!) and the leading, qualified scheme (e.g. 'http://'), than append the host/post...
    NSString* authority = [[[[self absoluteString] substringToIndex:end] substringFromIndex:[qualifiedScheme length]] stringByAppendingString:hostAndPort];
    
    return authority;
}

@end
