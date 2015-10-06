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
#import "KGWebSocketEmulatedChannel.h"

@implementation KGWebSocketEmulatedChannel {
    NSString* _cookie;
    KGCreateChannel * _createChannel;
    KGUpstreamChannel * _upstreamChannel;
    KGDownstreamChannel * _downstreamChannel;
    KGHttpURI * _redirectUri;
}

// init stuff:
- (void) init0 {
    // Initialization code here:
    _cookie = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

// "Constructor"
-(id)initWithLocation:(KGWSURI *)location binary:(BOOL)isBinary {
   self =  [self init];
    if (self) {
       self =  [super initWithLocation:location binary:isBinary];
    }
    return self;
}

// the interface impl:
// package private

-(void) setRedirectUri:(KGHttpURI *) redirectUri {
    _redirectUri = redirectUri;
}
-(KGHttpURI *) redirectUri {
    return _redirectUri;
}

-(void) setCreateChannel:(KGCreateChannel *)createChannel {
    _createChannel = createChannel;
}
-(KGCreateChannel *)createChannel {
    return _createChannel;
}
-(void) setUpstreamChannel:(KGUpstreamChannel *)upstreamChannel {
    _upstreamChannel = upstreamChannel;
}
-(KGUpstreamChannel *)upstreamChannel {
    return _upstreamChannel;
}
-(void) setDownstreamChannel:(KGDownstreamChannel *)downstreamChannel {
    _downstreamChannel = downstreamChannel;
}
-(KGDownstreamChannel *)downstreamChannel {
    return _downstreamChannel;
}

//protected:
-(void) setCookie:(NSString*)cookie {
    _cookie = cookie;
}
-(NSString*) cookie {
    return _cookie;
}



@end
