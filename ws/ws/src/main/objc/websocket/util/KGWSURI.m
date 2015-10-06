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
#import "KGWSURI.h"
#import "NSURL+KZNGAdditions.h"

@implementation KGWSURI

- (void) init0 {
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


-(BOOL) isValidScheme:(NSString*) scheme {
    return ([@"ws" isEqualToString:scheme] || [@"wss" isEqualToString:scheme]);
}

-(KGWSURI *) duplicate:(NSURL*) uri {
    return [[KGWSURI alloc] initWithNSURL:uri];
}

+(KGWSURI *) replaceScheme:(NSURL*) uri scheme:(NSString*)scheme {
    NSURL* wsURI = [uri URLByReplacingScheme:scheme];
    return [[KGWSURI alloc] initWithNSURL:wsURI];
}

-(BOOL) isSecure {
    NSString* _scheme = self.scheme;
    return [@"wss" isEqualToString:_scheme];
}

-(NSString*) HttpEquivalentScheme {
    NSString* uriScheme = _uri.scheme;
    return [uriScheme isEqualToString:@"ws"] ? @"http" : @"https";
}

@end
