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
#import "KGWebSocketSelectedChannel.h"

@implementation KGWebSocketSelectedChannel {
    // todo: change me:
    KGReadyState                 _readyState;
    KGWebSocketSelectedHandler   *_handler;
    NSArray                      *_requestedProtocols;
    
}

// init stuff:
- (void) init0 {
    // Initialization code here.
    _readyState = KGReadyState_CONNECTING;
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

-(KGReadyState) readyState {
    return _readyState;
}
-(void) setReadyState:(KGReadyState) readyState {
    _readyState = readyState;
}

-(KGWebSocketSelectedHandler *) handler {
    return _handler;
}
-(void)setHandler:(KGWebSocketSelectedHandler *)handler {
    _handler = handler;
}
- (void) setRequestedProtocols:(NSArray *)requestedProtocols {
    _requestedProtocols = [NSArray arrayWithArray:requestedProtocols];
}

- (NSArray *) requestedProtocols {
    return [NSArray arrayWithArray:_requestedProtocols];
}



@end
