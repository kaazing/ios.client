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

#import <Foundation/Foundation.h>


@interface KGByteBuffer : NSObject {
@private
    NSMutableData* _data;
    int _capacity;
    int _limit;
    int _mark;
    int _position;
    int _arrayOffset;
    
@public
    id  peer; // stores peer KCByteArray
}

- (int) remaining;
- (int) position;
- (void) setPosition:(int)position;
- (int) limit;
- (void) setLimit:(int)limit;
- (BOOL) hasRemaining;
- (int) arrayOffset;

+ (KGByteBuffer *) allocate:(int)size;
- (KGByteBuffer *) duplicate;
- (KGByteBuffer *) slice;
- (KGByteBuffer *) compact;
- (void) skip:(int)length;
- (void) mark;
- (void) flip;
- (void) reset;
- (void) clear;
- (KGByteBuffer *) clone;
- (KGByteBuffer *) subBuffer;
- (int) capacity;
- (int) indexOf:(char)byte;

- (char) get;
- (char) getAt:(int)index;
- (unsigned short) getUnsignedShort;
- (short) getShort;
//- (unsigned int) getUnsignedInt;
- (int) getInt;
- (int) getIntAt:(int)index;
- (long long) getLong;
- (NSString*) getString;
- (NSString*) getStringWithEncoding:(NSStringEncoding)charset;

- (void) put:(char)value;
- (void) putShort:(short)value;
- (void) putUnsignedShort:(unsigned short)value;
- (void) putUnsignedInt:(unsigned int)value;
- (void) putInt:(int)value;
- (void) putLong:(long long)value;
- (void) putBuffer:(KGByteBuffer *)buffer;
- (void) putString:(NSString*)string;
- (void) putString:(NSString*)string withEncoding:(NSStringEncoding)charset;

// Non-portable Core implementation
- (NSMutableData*) data;
+ (KGByteBuffer *) wrapData:(NSData*)array;
//+ (KGByteBuffer*) wrapData:(NSData*)array offset:(int)offset length:(int)length;
//- (void) getData:(NSData*)data offset:(int)offset length:(int)length;
- (NSData*) getData:(int)size;
- (NSData*) getDataAt:(int)index size:(int)size;
- (void) putData:(NSData*)data;
- (void) putBytes:(uint8_t*)bytes length:(int)length;

// Portable Chai implementation (defined elsewhere)
//- (KCByteArray*) array;
//+ (KGByteBuffer*) wrap:(KCByteArray*)array;
//+ (KGByteBuffer*) wrap:(KCByteArray*)array offset:(int)offset length:(int)length;
//- (void) get:(KCByteArray*)byteArray offset:(int)offset length:(int)length;
//- (KCByteArray*) getBytes:(int)size;
//- (KCByteArray*) getBytesAt:(int)index size:(int)size;
//- (void) putBytes:(KCByteArray*)byteArray;

- (void *) bytesFrom:(int)index;
- (void *) bytesFromPosition;

@end