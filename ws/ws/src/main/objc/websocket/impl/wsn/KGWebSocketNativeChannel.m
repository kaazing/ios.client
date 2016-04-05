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
#import "KGWebSocketNativeChannel.h"
#import "KGWebSocketDelegateImpl.h"

@implementation KGWebSocketNativeChannel {
    KGWSURI * _redirectUri;
    int _balanced;
    BOOL _reconnecting;
    BOOL _reconnected;
    
    KGWebSocketDelegateImpl* _delegate;
}

- (void) init0 {
    [super init0];
    _balanced = 0;
    _reconnecting = NO;
    _reconnected = NO;
}

- (id)init {
    self = [super init];
    return self;
}

// ctor:
// "Constructor"
-(id)initWithLocation:(KGWSURI *)location binary:(BOOL)isBinary {
    self =  [self init];
    if (self) {
        self =  [super initWithLocation:location binary:isBinary];
    }
    return self;
}

- (void) dealloc {
    if (_delegate != nil) {
        [_delegate setListener:nil];
    }
    _delegate = nil;
    _redirectUri = nil;
}

-(void)setRedirectUri:(KGWSURI *) redirectUri {
    _redirectUri = redirectUri;
}
-(KGWSURI *) redirectUri {
    return _redirectUri;
}

-(void)setDelegate:(NSObject*) delegate {
    _delegate = (KGWebSocketDelegateImpl *)delegate;
}
-(NSObject*)delegate {
    return _delegate;
}

-(void)setBalanced:(int) balanced {
    _balanced = balanced;
}
-(int) balanced {
    return _balanced;
}

-(void)setReconnecting:(BOOL) reconnecting {
    _reconnecting = reconnecting;
}
-(BOOL)reconnecting {
    return _reconnecting;
}

-(void)setReconnected:(BOOL) reconnected {
    _reconnected = reconnected;
}
-(BOOL)reconnected {
    return _reconnected;
}

@end
