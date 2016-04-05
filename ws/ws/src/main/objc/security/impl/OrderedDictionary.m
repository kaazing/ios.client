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
#import "OrderedDictionary.h"

@implementation OrderedDictionary 

@synthesize elements = _elements;
@synthesize dictionary = _dictionary;

-(void)dealloc {
}
// init stuff:
- (void) init0 {
    // Initialization code here.
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

// API methods...
-(void)addValue:(id)value forKey:(NSString *)key
{
    // remove "previous key":
    [_elements removeObject:key];
    [_dictionary removeObjectForKey:key];
    
    // and add the key/value pair afterwards:
    [_elements addObject:key];
    [_dictionary setValue:value forKey:key];
    
}
-(id)valueForKey:(NSString *)key {
    return [_dictionary valueForKey:key];
}
-(NSUInteger)count {
    return [_elements count];
}
-(BOOL)containsKey:(id) key {
    return ([_dictionary objectForKey:key] != nil);
}
-(NSArray *)allValues {
    return [_dictionary allValues];
}


@end
