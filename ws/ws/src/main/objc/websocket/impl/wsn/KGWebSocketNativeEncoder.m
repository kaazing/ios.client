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
#import "KGWebSocketNativeEncoder.h"

@implementation KGWebSocketNativeEncoder {
    unsigned char WS_TEXT_FRAME_START;
    unsigned char WS_TEXT_FRAME_END;
    unsigned char WS_BINARY_FRAME_START;
}

- (void) init0 {
    // Top level class - no reason to call init0
    WS_TEXT_FRAME_START = 0x0;
    WS_TEXT_FRAME_END = 0xFF;
    WS_BINARY_FRAME_START = 0x80;
}

- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


-(KGByteBuffer *) encodeTextMessage:(KGWebSocketChannel *) channel message:(NSString*) msg encoderOutput:(NSObject*) encoderOutput {
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeEncoder encodeTextMessage]");
#endif
    NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    KGByteBuffer * buf =  [KGByteBuffer wrapData:data];
#ifdef DEBUG
    int position = [buf position];
    NSLog(@"send message: %@", [buf getString]);
    [buf setPosition:position];
#endif
    return [self encodeRFC6455:buf isBinary:NO];
    
}
-(KGByteBuffer *) encodeBinaryMessage:(KGWebSocketChannel *) channel message:(KGByteBuffer *)msg encoderOutput:(NSObject*)output {
#ifdef DEBUG
    NSLog(@"[KGWebSocketNativeEncoder encodeBinaryMessage]");
#endif
    
    return [self encodeRFC6455:msg isBinary:YES];
}

// public static
- (KGByteBuffer *) encodeRFC6455:(KGByteBuffer *)buf isBinary:(bool)isBinary {
    BOOL mask = YES;
    BOOL fin = YES;
    int maskValue = rand();
    int remaining = [buf remaining];
    int offset = 2 + (mask ? 4 : 0) + [self calculateLengthSize:remaining];
    KGByteBuffer * b = [KGByteBuffer allocate:offset + remaining];
    int start = [b position];
    uint8_t b1 = (fin ? 0x80 : 0x00);
    uint8_t b2 = (mask ? 0x80 : 0x00);
    b1 = [self doEncodeOpcode:b1 isBinary:isBinary];
    b2 |= [self lenBits:remaining];
    [b put:b1];
    [b put:b2];
    [self doEncodeLength:b length:remaining];
    if (mask) {
        [b putInt:maskValue];
    }
    [b putBuffer:buf];
#ifdef DEBUG
    int postion = [buf position];
    NSLog(@"encoded message: %@", [b getString]);
    [b setPosition:postion];
#endif
    
    if (mask) {
        [b setPosition:offset];
        [self mask:b mask:maskValue];
    }
    [b setLimit:[b position]];
    [b setPosition:start];
    return b;
}

- (uint8_t) doEncodeOpcode:(uint8_t) b isBinary:(bool) isBinary {
    return (b | (isBinary ? 0x02 : 0x01));
}

// private static
- (int) calculateLengthSize:(int)length {
    if (length < 126) {
        return 0;
    }
    else if (length < 65535) {
        return 2;
    }
    else {
        return 8;
    }
}



// private static
- (uint8_t) lenBits:(int)length {
    if (length < 126) {
        return length;
    }
    else if (length < 65535) {
        return 126;
    }
    else {
        return 127;
    }
}


// private static
- (void) doEncodeLength:(KGByteBuffer *)buf length:(int)length {
    if (length < 126) {
        return;
    }
    else if (length < 65535) {
        [buf putShort:(short)length];
    }
    else {
        [buf putLong:(long)length];
    }
}


// public static
- (void) mask:(KGByteBuffer *)buf mask:(int)mask {
    [self unmask:buf mask:mask];
}


// public static
- (void) unmask:(KGByteBuffer *)buf mask:(int)mask {
    uint8_t b;
    int remainder = [buf remaining] % 4;
    int remaining = [buf remaining] - remainder;
    int end_ = remaining + [buf position];
    // xor a 32bit word at a time as long as po
    while ([buf position] < end_) {
        int plaintext = [buf getIntAt:[buf position]] ^ mask;
        [buf putInt:plaintext];
    }
    //buf.position(s
    switch (remainder)
    {
        case 3:
            b = ([buf getAt:[buf position]] ^ mask >> 24 & 0xff);
            [buf put:b];
            b = ([buf getAt:[buf position]] ^ mask >> 16 & 0xff);
            [buf put:b];
            b = ([buf getAt:[buf position]] ^ mask >> 8 & 0xff);
            [buf put:b];
            break;
        case 2:
            b = ([buf getAt:[buf position]] ^ mask >> 24 & 0xff);
            [buf put:b];
            b = ([buf getAt:[buf position]] ^ mask >> 16 & 0xff);
            [buf put:b];
            break;
        case 1:
            b = ([buf getAt:[buf position]] ^ (mask >> 24 & 0xff));
            [buf put:b];
            break;
        case 0:
        default:
            break;
    }
}

@end

