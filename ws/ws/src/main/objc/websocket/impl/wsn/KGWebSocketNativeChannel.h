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
#import "KGWebSocketSelectedChannel.h"

@interface KGWebSocketNativeChannel : KGWebSocketSelectedChannel

// ctor:
-(id)initWithLocation:(KGWSURI *)location binary:(BOOL)isBinary;

-(void)setRedirectUri:(KGWSURI *) redirectUri;
-(KGWSURI *) redirectUri;

-(void)setDelegate:(NSObject*) delegate;
-(NSObject*)delegate;

-(void)setBalanced:(int) balanced;
-(int) balanced;

-(void)setReconnecting:(BOOL) reconnecting;
-(BOOL)reconnecting;

-(void)setReconnected:(BOOL) reconnected;
-(BOOL)reconnected;


@end
