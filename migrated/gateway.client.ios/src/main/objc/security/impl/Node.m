/**
 * Copyright (c) 2007-2014 Kaazing Corporation. All rights reserved.
 * 
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "Node.h"
#import "Token.h"
#import "OrderedDictionary.h"
#import "NSArray+KZNGAdditions.h"


@implementation Node {
    NSString* _name;
    NSMutableArray * _values;
    Node* _parent;
    UriElement _kind;
    //OrderedDictionary* _children;
    NSMutableDictionary* _children;
    
}

-(void)dealloc {
}
// init stuff:
- (void) init0 {
    // Initialization code here.
    _values = [[NSMutableArray alloc] init];
    //_children = [[OrderedDictionary alloc] init];
    _children = [[NSMutableDictionary alloc] init];
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (id)initWithName:(NSString*) name parent:(Node*)parent kind:(UriElement)kind {
    self = [super init];
    if (self) {
        [self init0];
        
        /// diff from java/flash:
        _name = name;
        _parent = parent;
        _kind = kind;
    }
    return self;
}

//getter:
-(NSString*) wildcardChar {
    return @"*";
}

-(Node*) addChild:(NSString*) name kind:(UriElement) kind {
    Node* result = [[Node alloc] initWithName:name parent:self kind:kind];
//    [_children addValue:result forKey:name];
    [_children setValue:result forKey:name];
    return result;
}
-(BOOL) hasChild:(NSString*) name kind:(UriElement) kind {
    return ((nil != [self child:name]) && (kind == [[self child:name] kind]));
}
-(Node*) child:(NSString*)name {
    return [_children valueForKey:name];
}
-(int)distanceFromRoot {
    int result = 0;
    Node* cursor = self;
    while (! [cursor isRootNode]) {
        result++;
        cursor = [cursor parent];
    }
    return result;
}

-(void) appendValues:(NSArray *) values {
    if ([self isRootNode]) {
//        @throw ([NSException r)
//        [NSException raise:@"Cannot set a values on the root node." format:<#(NSString *), ...#>];
        return;
    }
    if (values != nil) {
        [_values addObjectsFromArray:values];
    }
}
-(void) removeValue:(id)value {
    if ([self isRootNode]) {
        return;
    }
    [_values removeObject:value];
}
-(NSMutableArray *) values {
    return _values;
}

-(BOOL) hasValues {
    return ((_values !=nil) && ([_values count] >0));
}

-(Node*) parent {
    return _parent;
}
-(UriElement) kind {
    return _kind;
}
-(BOOL) isRootNode {
    return (_parent == nil);
}
-(NSString*) name {
    return _name;
}

-(BOOL) hasChildren {
    return ((_children !=nil) && ([_children count] >0));    
}
-(BOOL) isWildcard {
    return ((_name!=nil) && ([_name isEqualToString:[self wildcardChar]]));
    
}
-(BOOL) hasWildcardChild{
    //return (([self hasChildren]) && ([_children containsKey:[self wildcardChar]]));
    
    return (([self hasChildren]) && ([_children objectForKey:[self wildcardChar]] != nil));
    
}
-(NSString*) fullyQualifiedName {
    NSString* b = @""; 
    NSMutableArray * name = [[NSMutableArray alloc] init];
    Node* cursor = self;
    
    while (![cursor isRootNode]) {
        [name addObject:cursor.name];
        cursor = cursor.parent;
    }
    
    NSArray * reversedArray = [name reversedArray];
    for (int i =0; i< [reversedArray count]; i++) {
        
        b = [b stringByAppendingString:[reversedArray objectAtIndex:i]];
        b = [b stringByAppendingString:@"."];
    }
    
    
    if (([b length] >= 1) && ([b characterAtIndex:([b length] - 1)] == '.')){
        b = [b substringToIndex:([b length] - 1)];
    }

    return b;
}
-(NSArray *) childrenAsList {
    return [_children allValues];
}

-(Node*) findBestMatchingNode:(NSArray *) tokens tokenIdx:(int)tokenIdx {
    NSArray * matches = [self findAllMatchingNodes:tokens tokenIdx:tokenIdx];
    
    Node* resultNode = nil;
    int score = 0;
    for (int i =0; i< [matches count]; i++) {
        Node* node = [matches objectAtIndex:i];
        if ([node distanceFromRoot] > score) {
            score = [node distanceFromRoot];
            resultNode = node;
        }
    }
    return resultNode;
}

-(NSArray *) findAllMatchingNodes:(NSArray *) tokens tokenIdx:(int)tokenIdx {
    NSMutableArray * result = [[NSMutableArray alloc] init];

    NSArray * nodes = [self childrenAsList];
    
    for (int i =0; i< [nodes count]; i++) {
        Node* node = [nodes objectAtIndex:i];
        
        int matchResult = [node matches:tokens tokenIdx:(int)tokenIdx];
        if (matchResult < 0) {
            continue;
        }
        
        if (matchResult >= [tokens count]) {
            do {
                if ([node hasValues]) {
                    [result addObject:node];
                }
                if ( [node hasWildcardChild]) {
                    Node* child =  [node child:[self wildcardChar]];
                    if ([child kind] != [self kind]) {
                        node = nil;
                    } else {
                        node = child;
                    }
                } else {
                    node = nil;
                }
            } while (node != nil);
        } else {
            NSArray * re = [node findAllMatchingNodes:tokens tokenIdx:(int)matchResult];
            [result addObjectsFromArray:re];
        }
    }
    return result;
}
                           
-(int) matches:(NSArray *) tokens tokenIdx:(int)tokenIdx {
    if (tokenIdx < 0 || tokenIdx >= [tokens count]) {
        return  -1;
    }
    
    
    Token* token = [tokens objectAtIndex:tokenIdx];
    BOOL matchesToken = [self matchesToken:token];
    if (matchesToken) {
        return tokenIdx+1;
    }
    
    if (![self isWildcard]) {
        return -1;
    } else {
        if (_kind != [((Token*) [tokens objectAtIndex:tokenIdx]) kind]) {
            return -1;
        }
        
        do {
            tokenIdx = tokenIdx+1;
        } while (tokenIdx < [tokens count] && _kind == [((Token*) [tokens objectAtIndex:tokenIdx]) kind] );
        return (int)tokenIdx;
    }
}

-(BOOL) matchesToken:(Token*) token {
    return (([[self name] isEqualToString:[token name]]) && (_kind == [token kind]));
}

@end
