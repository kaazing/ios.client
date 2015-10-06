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
#import "KGWSCompositeURI.h"
#import "KGWSURI.h"
#import "NSString+KZNGAdditions.h"

@implementation KGWSCompositeURI {
    NSMutableDictionary* wsEquivalent;
    NSString* _scheme;
}


- (void) init0 {
    // Initialization code here:
    wsEquivalent = [[NSMutableDictionary alloc] init];
    
    [wsEquivalent setValue:@"ws" forKey:@"ws"];
    [wsEquivalent setValue:@"wss" forKey:@"wss"];
    [wsEquivalent setValue:@"ws" forKey:@"ios:ws"];
    [wsEquivalent setValue:@"ws" forKey:@"ios:wse"];
    [wsEquivalent setValue:@"wss" forKey:@"ios:wss"];
    [wsEquivalent setValue:@"wss" forKey:@"ios:wse+ssl"];
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


-(BOOL) isValidScheme:(NSString*) scheme {
    return ([wsEquivalent valueForKey:scheme] != nil);
}

-(id) duplicate:(NSURL*) uri {
    return [[KGWSCompositeURI alloc] initWithNSURL:uri];
}

-(BOOL) isSecure {
    return ([[wsEquivalent valueForKey:@"ios:wss"] isEqualToString:@"wss"]);
}

-(KGWSURI *) WSEquivalent{
    NSString* wsEquivScheme = [wsEquivalent valueForKey:[self scheme]];
    return [KGWSURI replaceScheme:_uri scheme:wsEquivScheme];
}

-(NSString*) scheme {
    // Workaround URI behavior that returns only "ios" instead of "ios:ws"
    if (_scheme == nil) {
        NSString* location = [_uri absoluteString];
        int schemeEndIndex = [location indexOf:@"://"];
        if (schemeEndIndex != -1) {
            _scheme = [location substringWithRange:NSMakeRange(0, schemeEndIndex)];
        } else {
            _scheme = [_uri absoluteString];
        }
    }
    return _scheme;
}

@end
