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

#import "KGGenericURI.h"
#import "NSURL+KZNGAdditions.h"

// abstract class
@implementation KGGenericURI {
//    NSURL* _uri;
}


- (void)dealloc
{
    _uri = nil;
}

- (void) init0 {
#ifdef DEBUG
    NSLog(@"[KGGenericURI init0]");
#endif
    // Initialization code here:
    // Cannot create instance of abstract class directly
    if ([self isMemberOfClass:[KGGenericURI class]]) {
        [self doesNotRecognizeSelector:_cmd];
        //[self release];
        [NSException raise:@"NotImplementedException" format:@"Cannot create instance of class"];
    }
    
}

- (id)init {
#ifdef DEBUG
    NSLog(@"[KGGenericURI init]");
#endif
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(id)initWithNSURL:(NSURL*) uri; {
#ifdef DEBUG
    NSLog(@"[KGGenericURI initWithNSURL]");
#endif
    self = [self init];
    if (self) {
        _uri = uri;
        //[self validateScheme:NSError...];
        [self validateScheme];
    }
    return self;
}

-(id)initWithURI:(NSString*) uri {
#ifdef DEBUG
    NSLog(@"[KGGenericURI initWithURI]");
#endif
    NSURL* url = [NSURL URLWithString:uri];
    return [self initWithNSURL:url];
}

-(NSURL*) URI {
    return _uri;
    
}
-(NSString*) scheme {
    return _uri.scheme;
}

-(NSString*) path {
    return _uri.path;
}

-(NSString*) query {
    return _uri.query;
}

-(NSString*) host {
    return _uri.host;
}
-(NSNumber*) port {
    return _uri.port;
}

// abstract:
-(BOOL) isValidScheme:(NSString*) scheme {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}
//abstract:
-(id) duplicate:(NSURL*) uri {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)validateScheme {
    NSString* scheme = [self scheme];
    
#ifdef DEBUG
//    NSLog(@"");
#endif
    
    
    if (! [self isValidScheme:scheme]) {
        // throw..... up!
        [NSException raise:@"Invalid scheme" format:@"Invalid scheme"];
    }
    
}

-(id)addQueryParameter:(NSString*) newParam {
    NSURL* modifiedUri = [_uri URLByAppendingQueryString:newParam];
    return [self duplicate:modifiedUri];
}
-(id) replacePath:(NSString*) path {
    return [self duplicate:[_uri URLByReplacingPath:path]];
}



// not allowed with ARC:
//- (void)dealloc {
//    [super dealloc];
//}



@end
