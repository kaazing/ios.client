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

#import <Foundation/Foundation.h>
#import "DefaultDispatchChallengeHandler.h"

@interface Node : NSObject
- (id)initWithName:(NSString*) name parent:(Node*)parent kind:(UriElement)kind;
-(NSString*) wildcardChar;
-(Node*) addChild:(NSString*) name kind:(UriElement) kind;
-(BOOL) hasChild:(NSString*) name kind:(UriElement) kind;
-(Node*) child:(NSString*)name;
-(int)distanceFromRoot;
-(void) appendValues:(NSArray *) values;
-(void) removeValue:(id)value;
-(NSMutableArray *) values;
-(BOOL) hasValues ;
-(Node*) parent;
-(UriElement) kind;
-(BOOL) isRootNode;
-(NSString*) name;
-(BOOL) hasChildren;
-(BOOL) isWildcard;
-(BOOL) hasWildcardChild;
-(NSString*) fullyQualifiedName;
-(NSArray *) childrenAsList;

-(Node*) findBestMatchingNode:(NSArray *) tokens tokenIdx:(int)tokenIdx;

@end
