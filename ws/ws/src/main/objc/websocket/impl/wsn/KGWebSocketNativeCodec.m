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
#import "KGWebSocketNativeCodec.h"
#import "KGWebSocketNativeEncoder.h"
#import "KGEncoderOutput.h"

@interface KGWebSocketNativeCodec_WebSocketHandlerListener_1 : NSObject<KGWebSocketHandlerListener>

// ctor:
-(id)initWithWebSocketHandler:(KGWebSocketNativeCodec *)handler;

@end
@implementation KGWebSocketNativeCodec_WebSocketHandlerListener_1 {
    KGWebSocketNativeCodec * _parent;
}

- (id)init {
    self = [super init];
    return self;
}
-(id)initWithWebSocketHandler:(KGWebSocketNativeCodec *)handler {
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}

- (void) connectionOpened:(KGWebSocketChannel *) channel protocol:(NSString *)protocol{
    [[_parent listener] connectionOpened:channel protocol:protocol];
}

- (void) redirected:(KGWebSocketChannel *) channel location:(NSString*) location {
    [[_parent listener] redirected:channel location:location];
}

- (void) authenticationRequested:(KGWebSocketChannel *) channel location:(NSString*) location challenge:(NSString*) challenge {
    [[_parent listener] authenticationRequested:channel location:location challenge:challenge];
}

-(void) messageReceived:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buf {
    [[_parent listener] messageReceived:channel buffer:buf];
}

-(void) textmessageReceived:(KGWebSocketChannel *) channel text:(NSString*) text {
    [[_parent listener] textmessageReceived:channel text:text];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel  wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason{
    [[_parent listener] connectionClosed:channel  wasClean:wasClean code:code reason:reason];
}

- (void) connectionClosed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionClosed:channel  exception:ex];
}

- (void) connectionFailed:(KGWebSocketChannel *) channel exception:(NSException *)ex {
    [[_parent listener] connectionFailed:channel exception:ex];
}

@end

@interface KGWebSocketNativeCodecEncoderOutput : NSObject<KGEncoderOutput>
// ctor:
-(id)initWithWebSocketHandler:(KGWebSocketNativeCodec *)handler;
@end
@implementation KGWebSocketNativeCodecEncoderOutput {
    KGWebSocketNativeCodec * _parent;
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
-(id)initWithWebSocketHandler:(KGWebSocketNativeCodec *)handler {
    self =  [self init];
    if (self) {
        _parent = handler;
    }
    return self;
}


-(void)write:(KGWebSocketChannel *)channel buffer:(KGByteBuffer *)buffer {
    [[_parent nextHandler] processBinaryMessage:channel buffer:buffer];
}

@end

@implementation KGWebSocketNativeCodec {
    KGWebSocketNativeEncoder * encoder;
    id<KGEncoderOutput> output;
}

// init stuff:
- (void) init0 {
    // Initialization code here.
    encoder = [[KGWebSocketNativeEncoder alloc] init];
}


- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}



// override:
-(void) processTextMessage:(KGWebSocketChannel *) channel text:(NSString*) text {
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeCodec processTextMessage]");
#endif
    [_nextHandler processBinaryMessage:channel buffer:[encoder encodeTextMessage:channel message:text encoderOutput:output]];
}

// override:
-(void) processBinaryMessage:(KGWebSocketChannel *) channel buffer:(KGByteBuffer *) buffer {
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeCodec processBinaryMessage]");
#endif
    [_nextHandler processBinaryMessage:channel buffer: [encoder encodeBinaryMessage:channel message:buffer encoderOutput:output]];
}

- (void) setNextHandler:(id <KGWebSocketHandler>)handler {
    
    output = [[KGWebSocketNativeCodecEncoderOutput alloc] initWithWebSocketHandler:self];
    _nextHandler = handler;
    [_nextHandler setListener:[[KGWebSocketNativeCodec_WebSocketHandlerListener_1 alloc] initWithWebSocketHandler:self]];
}

@end
