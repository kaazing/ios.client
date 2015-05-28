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

#import "KGWebSocketEmulatedDecoder.h"
#import "KGWebSocketEmulatedDecoderListener.h"
#import "KGTracer.h"

@implementation KGWebSocketEmulatedDecoder {
    //private
    KGDecodingState processingState;
    int binaryFrameLength;
    NSMutableData* messageBuffer;
    int messageBufferPosition;
    uint8_t opCode;
}

//private static final
uint8_t const WSE_COMMAND_FRAME_START = 0x01;
uint8_t const  WSE_TEXT_FRAME_START = 0x00;
uint8_t const  WSE_TEXT_FRAME_END = 0xff;
uint8_t const  WSE_BINARY_FRAME_START = 0x80;
uint8_t const  WSE_PER_LENGTH_FRAME_START = 0x81;
uint8_t const  WSE_PING_FRAME_CODE = 0x89;

- (void) init0 {
    processingState = START_OF_FRAME;
    opCode = 0;
}
- (id)init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}


-(void) decode:(KGChannel *) channel payload:(KGByteBuffer *)payload webSocketEmulatedDecoderListener:(id<KGWebSocketEmulatedDecoderListener>) listener {
#ifdef DEBUG
    NSLog(@"process() START");
#endif
    
    while (true) {
        
        if(![payload hasRemaining]){
            return; //done with decode
        }
        
        switch (processingState) {
            case START_OF_FRAME:
            {
                opCode = [payload get];
                
                if (opCode == WSE_TEXT_FRAME_START) {
                    processingState = READING_TEXT_FRAME;
                    messageBuffer = [NSMutableData alloc];
                }
                else if (opCode == WSE_COMMAND_FRAME_START) {
                    processingState = READING_COMMAND_FRAME;
                    messageBuffer = [NSMutableData alloc];
                }
                else if (opCode == WSE_BINARY_FRAME_START || opCode == WSE_PER_LENGTH_FRAME_START) {
                    processingState = READING_BINARY_FRAME_HEADER;
                    binaryFrameLength = 0;
                }
                else if (opCode == WSE_PING_FRAME_CODE) {
                    // The wire representation of PING frame is 0x89 0x00
                    processingState = READING_PING_FRAME;
                }
                else {
                    //invalid frame opCode
                    @throw [NSException exceptionWithName:@"InvalidFrameException" reason:@"Invalid websocket frame" userInfo:NULL];
                }
                break;
            }
            case READING_BINARY_FRAME_HEADER:
            {
                uint8_t b = [payload get];
                int b_v = b & 0x7f;
                binaryFrameLength = binaryFrameLength * 128 + b_v;
                if ((b & 0x80) == 0x80) {
                    break;
                }
                
                else {
                    //got last byte
                    if(binaryFrameLength == 0 ) {
                        //length = 0 - skip READING_BINARY_FRAME case, fire messageDecoded event
                        processingState = START_OF_FRAME;
                        if (opCode == WSE_BINARY_FRAME_START) {
                            [listener messageDecoded:channel message:[KGByteBuffer wrapData:[@"" dataUsingEncoding:NSASCIIStringEncoding]]];
                        } else {
                            [listener textmessageDecoded:channel message:@""];
                        }
                            
                    }
                    else {
                        //LOG.finest("process() BINARY_FRAME_HEADER: " + binaryFrameLength);
                        processingState = READING_BINARY_FRAME;
                        messageBuffer = [NSMutableData dataWithCapacity:binaryFrameLength];
                        messageBufferPosition = 0;
                    }
                }
                break;
            }
            case READING_BINARY_FRAME:
            {
                int len = MIN([payload remaining], binaryFrameLength-messageBufferPosition);
                NSRange range = {messageBufferPosition, len};
                NSData* data1 = [payload getData:len];
#ifdef DEBUG
                NSLog(@"get Bytes:%@", data1);
#endif
#ifdef DEBUG
                NSLog(@"messageBuffer Bytes:%@", messageBuffer);
#endif
                
                [messageBuffer replaceBytesInRange:range withBytes:[data1 bytes]];
#ifdef DEBUG
                NSLog(@"messageBuffer Bytes:%@", messageBuffer);
#endif
                messageBufferPosition += len;
                if(messageBufferPosition == binaryFrameLength) {
                    //got all data
                    processingState = START_OF_FRAME;
                    if (opCode == WSE_BINARY_FRAME_START) {
                        [listener messageDecoded:channel message:[KGByteBuffer wrapData:messageBuffer]];
                    }
                    else {
                        [listener textmessageDecoded:channel message:[[NSString alloc] initWithData:messageBuffer encoding:NSUTF8StringEncoding]];
                    }
                
                }
                break;
            }
            case READING_TEXT_FRAME:
            case READING_COMMAND_FRAME:
            {
                //read byte until end of payload or got 'FF'
                while ([payload hasRemaining]) {
                    uint8_t b = [payload get];
                    if (b != 0xff) {
                        [messageBuffer appendBytes:&b length:1];
                    }
                    else {
                        //got 'FF'
                        if (processingState == READING_TEXT_FRAME)
                            [listener textmessageDecoded:channel message:[[NSString alloc] initWithData:messageBuffer encoding:NSUTF8StringEncoding]];
                        else
                            [listener commandDecoded:channel command:[KGByteBuffer wrapData:messageBuffer]];
                        processingState = START_OF_FRAME;
                        break;
                    }
                }
                break;
            }
            case READING_PING_FRAME:
            {
                uint8_t byteFollowingPingFrameCode = [payload get];
                processingState = START_OF_FRAME;
                
                if (byteFollowingPingFrameCode != 0x00) {
                    NSString *reason = [NSString stringWithFormat:@"Expected 0x00 after PING frame code but received - %d", byteFollowingPingFrameCode];
                    @throw [NSException exceptionWithName:@"InvalidFrameException" reason:reason userInfo:NULL];
                }
                else {
                    [KGTracer trace:@"PING frame received"];
                    [listener pingReceived:channel];
                }
                break;
            }
            default:
                break;
        }
    
    }
}

@end
