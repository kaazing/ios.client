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
#import "KGChannel.h"
#import "KGDecoderInput.h"
#import "KGWebSocketEmulatedDecoderListener.h"

@interface KGWebSocketEmulatedDecoder : NSObject

-(void) decode:(KGChannel *) channel payload:(KGByteBuffer *)payload webSocketEmulatedDecoderListener:(id<KGWebSocketEmulatedDecoderListener>) listener;

@end

/*
 * Processing state machine
 */
typedef enum DecodingState {
    START_OF_FRAME,
    READING_TEXT_FRAME,
    READING_COMMAND_FRAME,
    READING_BINARY_FRAME_HEADER,
    READING_BINARY_FRAME,
    READING_PING_FRAME
} KGDecodingState;
