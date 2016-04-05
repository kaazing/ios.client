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
#import "KGWebSocketEmulatedEncoder.h"
@implementation KGWebSocketEmulatedEncoder {
    unsigned char WSE_BINARY_FRAME_START;
    unsigned char WSE_TEXT_FRAME_START;
}

- (void) init0 {
    WSE_BINARY_FRAME_START = 0x80;
    WSE_TEXT_FRAME_START = 0x81;
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

-(NSData*) encodeLength:(int)length {
    //length = CFSwapInt32HostToBig(length);
    int byteCount = 0;
    uint8_t encodeBytes[10]; //use 10 bytes to hold encoded Bytes (lower byte first
    NSMutableData* returnValue = [[NSMutableData alloc] init];
    
    do {
        encodeBytes[byteCount++] = (length % 128) & 0xff;
        length = length/128;
    }
    // continue if there are remaining set length bits
    while (length > 0);
    
    do {
        // get byte from encodedBytes in reverse order, hight byte first
        uint8_t encodedByte = encodeBytes[byteCount-1];
        // The last length byte does not have the highest bit set
        if (byteCount != 1) {
            // set highest bit if this is not the last
            encodedByte |= (char) 0x80;
        }
        // write encoded byte
        [returnValue appendBytes:&encodedByte length:1];
        
    }
    // decrement and continue if we have more bytes left
    while (--byteCount > 0);
    
    return returnValue;
}

-(KGByteBuffer*) encodeTextMessage:(KGChannel *) channel message:(NSString*)msg encoderOutput:(NSObject*)output {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedEncoder encodeTextMessage]");
#endif
    
    const char *payload = [msg UTF8String];
    int payloadLength = strlen(payload);
    NSData* data = [NSData dataWithBytes:payload length:payloadLength];

    return [self encodeMessage:channel opCode:WSE_TEXT_FRAME_START message:data encoderOutput:output];

}
-(KGByteBuffer *) encodeBinaryMessage:(KGChannel *) channel message:(KGByteBuffer *)msg encoderOutput:(NSObject*)output {
    return [self encodeMessage:channel opCode:WSE_BINARY_FRAME_START message:[msg getData:[msg remaining]] encoderOutput:output];
}



-(KGByteBuffer *) encodeMessage:(KGChannel *) channel opCode:(unsigned char)opcode message:(NSData *)msg encoderOutput:(NSObject*)output {
#ifdef DEBUG
    NSLog(@"[KGWebSocketEmulatedEncoder encodeBinaryMessage]");
#endif
    
    int length = [msg length];
    NSData* encodedBytes = [self encodeLength:length];
    
    KGByteBuffer * frame = [KGByteBuffer allocate:(length + 5 + [encodedBytes length])];

    // create NSData container for all 'content':
    NSMutableData* binaryStartWrapper = [[NSMutableData alloc] init];
    
    // write binary type header
    [binaryStartWrapper appendBytes:&opcode length:1];  // write binary type header
    
    // write length prefix
    [binaryStartWrapper appendData:encodedBytes];

    // write payload
    [binaryStartWrapper appendData:msg];
    
    

    //RECONNECT:
    uint8_t WSE_COMMAND_FRAME_START = 0x01;
    uint8_t CLOSE_EVENT_BYTE1 = 0x30;
    uint8_t CLOSE_EVENT_BYTE2 = 0x31;
    uint8_t WSE_COMMAND_FRAME_END = 0xff;
    
    
    uint8_t reconnectFrame[4] = {WSE_COMMAND_FRAME_START,CLOSE_EVENT_BYTE1,CLOSE_EVENT_BYTE2,WSE_COMMAND_FRAME_END};
    [binaryStartWrapper appendBytes:reconnectFrame length:4];

#ifdef DEBUG
    NSLog(@"binary frame:%@", binaryStartWrapper);
#endif
    // write the container into the ByteBoffer;
    [frame putData:binaryStartWrapper];
    

    
    return frame;
}
@end
