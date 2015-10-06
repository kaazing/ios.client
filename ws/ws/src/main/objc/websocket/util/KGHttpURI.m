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
#import "KGHttpURI.h"
#import "NSURL+KZNGAdditions.h"

@implementation KGHttpURI

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
    return ([@"http" isEqualToString:scheme] || [@"https" isEqualToString:scheme]);
}

-(id) duplicate:(NSURL*) uri {
    return [[KGHttpURI alloc] initWithNSURL:uri];
}

+(KGHttpURI *) replaceScheme:(NSURL*) uri scheme:(NSString*)scheme {
    NSURL* wsURI = [uri URLByReplacingScheme:scheme];
    return [[KGHttpURI alloc] initWithNSURL:wsURI];
}
+(KGHttpURI *) replaceSchemeFromGenericURI:(KGGenericURI *) uri scheme:(NSString*)scheme {
    return [KGHttpURI replaceScheme:[uri URI] scheme:scheme];
}

-(BOOL) isSecure {
    NSString* _scheme = self.scheme;
    return [@"https" isEqualToString:_scheme];
}



@end
