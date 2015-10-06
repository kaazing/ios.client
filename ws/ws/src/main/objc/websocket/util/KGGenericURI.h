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
#import <Foundation/Foundation.h>

@interface KGGenericURI : NSObject {
    @protected
    NSURL* _uri;
}

-initWithNSURL:(NSURL*) uri;
-initWithURI:(NSString*) uri;

//abstract protected boolean isValidScheme(String scheme);
-(BOOL) isValidScheme:(NSString*) scheme;

//private void validateScheme() throws URISyntaxException;
//-(void)validateScheme:(NSError**) error;
-(void)validateScheme;

//abstract protected T duplicate(URI uri);
-(id) duplicate:(NSURL*) uri;

//public T replacePath(String path)
-(NSObject*) replacePath:(NSString*) path; 

//public T addQueryParameter(String newParam)
-(NSObject*)addQueryParameter:(NSString*) newParam;

-(NSURL*) URI;
-(NSString*) scheme;
-(NSString*) path;
-(NSString*) query;
-(NSString*) host;
-(NSNumber*) port;

@end
