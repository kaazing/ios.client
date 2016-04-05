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
#include <Foundation/Foundation.h>
#import "KGByteBuffer.h"

@implementation KGByteBuffer {
}

- (void) init0 {
    _data = [[NSMutableData alloc] init];
}

// private
- (id) init {
    self = [super init];
    if (self) {
        [self init0];
    }
    return self;
}

- (void) dealloc {
    _data = nil;
}

+ (KGByteBuffer *) allocate:(int)length {
    return [[KGByteBuffer alloc] initWithLenth:length];
}


- (KGByteBuffer *) duplicate {
    KGByteBuffer *ret = [[KGByteBuffer alloc] init];
    ret->_data = _data;
    ret->_arrayOffset = _arrayOffset;
    ret->_capacity = _capacity;
    ret->_position = _position;
    ret->_limit = _limit;
    ret->_mark = _mark;
    return ret;
}

- (KGByteBuffer *) slice {
    KGByteBuffer *ret = [[KGByteBuffer alloc] init];
    ret->_data = _data;
    ret->_arrayOffset = _arrayOffset + _position;
    ret->_capacity = _capacity - _position; //is this right?
    ret->_position = 0;
    ret->_limit = _limit - _position;
    ret->_mark = -1;
    return ret;
}

/*
 The bytes between the buffer's current position and its limit, if any,
 are copied to the beginning of the buffer. That is, the byte at index p = position() 
 is copied to index zero, the byte at index p + 1 is copied to index one, 
 and so forth until the byte at index limit() - 1 is copied to index 
 n = limit() - 1 - p. The buffer's position is then set to n+1 and its limit is set 
 to its capacity. The mark, if defined, is discarded.
 
 The buffer's position is set to the number of bytes copied, rather than to zero, 
 so that an invocation of this method can be followed immediately by an invocation 
 of another relative put method.
 */
- (KGByteBuffer *) compact {
    int size = [self remaining];
    NSRange range = {0, size};
    void *src = [self bytesFrom:_position];
    [_data replaceBytesInRange:range withBytes:src length:size];
    _position = size;
    
    // discard the mark
    _mark = -1;
    return self;
}

+ (KGByteBuffer *) wrapData:(NSData*)data {
    return [[KGByteBuffer alloc] initWithBytes:[data bytes] length:[data length]];
}

- (id) initWithBytes:(const void*)bytes length:(int) len {
    self = [super init];
    if (self) {
        _data = [NSMutableData dataWithBytes:bytes length:len];
        _capacity = [_data length];
        _arrayOffset = 0;
        _position = 0;
        _limit = _capacity;
        _mark = -1;
    }
    return self;
}

- (id) initWithLenth:(int) len {
    self = [super init];
    if (self) {
        _data = [NSMutableData dataWithLength:len];
        _capacity = len;
        _arrayOffset = 0;
        _position = 0;
        _limit = _capacity;
        _mark = -1;
    }
    return self;
}

- (NSMutableData*) data {
    return _data;
}

- (int) arrayOffset {
    return _arrayOffset;
}

- (int) position {
    return _position;
}

- (void) setPosition:(int)val {
    _position = val;
}

-(int)limit {
    return _limit;
}

-(void)setLimit:(int)val {
    _limit = val;
}

-(int) remaining {
    return _limit - _position;
}

-(BOOL)hasRemaining{
    return _limit > _position;
}

-(void)flip {
    _limit = _position;
    _position = 0;
}

-(void)skip:(int)length {
    _position += length;
}

-(void)mark {
    _mark = _position;
}

-(void)reset {
    if (_mark >= 0) {
        _position = _mark;
    }
}

- (void) clear {
    _position = 0;
    _limit = _capacity;
    _mark = -1;
}

- (KGByteBuffer *) clone {
    int len = [_data length];
    char *buf = malloc(len);
    [_data getBytes:buf length:len];
    
    KGByteBuffer *ret = [[KGByteBuffer alloc] initWithBytes:buf length:len];
    free(buf);
    return ret;
}

- (KGByteBuffer *) subBuffer {
    NSRange range = {[self position], [self remaining]};
    NSData* data = [[self data] subdataWithRange:range];
    return [KGByteBuffer wrapData:data];
}

- (int) capacity {
    return _capacity;
}

- (void) autoExpand:(int)expectedRemaining {
    int remain = [self remaining];
    if (remain >= expectedRemaining) {
        return; // there is enough room
    }
    int expandLength = expectedRemaining - remain;
    [_data increaseLengthBy:expandLength];
    _limit += expandLength;
    _capacity += expandLength;
}

- (void) putBytes:(uint8_t*)bytes length:(int)length {
    [self autoExpand:length];
    
    if (bytes == nil || length == 0) {
        return;
    }
    
    NSRange range = {_arrayOffset + _position, length};
    [_data replaceBytesInRange:range withBytes:bytes];
    _position += length;
}

-(void) putData:(NSData*)src {
    [self putBytes:(uint8_t*)[src bytes] length:[src length]];
}

- (void) putShort:(short)value {
    [self autoExpand:2];
    NSRange range = {_arrayOffset + _position, 2};
    int tmp = CFSwapInt16HostToBig(value);
    [_data replaceBytesInRange:range withBytes:&tmp];
    _position += 2;
}

- (void) putUnsignedShort:(unsigned short)value {
    [self autoExpand:2];
    NSRange range = {_arrayOffset + _position, 2};
    int tmp = CFSwapInt16HostToBig(value);
    [_data replaceBytesInRange:range withBytes:&tmp];
    _position += 2;
}

-(void) putInt:(int)value {
    [self autoExpand:4];
    NSRange range = {_arrayOffset + _position, 4};
    int tmp = CFSwapInt32HostToBig(value);
    [_data replaceBytesInRange:range withBytes:&tmp];
    _position += 4;
}
-(void) putUnsignedInt:(unsigned int)value {
    [self autoExpand:4];
    NSRange range = {_arrayOffset + _position, 4};
    int tmp = CFSwapInt32HostToBig(value);
    [_data replaceBytesInRange:range withBytes:&tmp];
    _position += 4;
}

-(void) putLong:(long long)value {
    [self autoExpand:8];
    
    long long tmp = CFSwapInt64HostToBig(value);
    NSRange range = {_arrayOffset + _position, 8};
    [_data replaceBytesInRange:range withBytes:&tmp];
    _position += 8;
}

-(void) put:(char)value {
    [self autoExpand:1];
    NSRange range = {_arrayOffset + _position, 1};
    [_data replaceBytesInRange:range withBytes:&value];
    _position++;

}

- (void) putBuffer:(KGByteBuffer *)buffer {
    [self autoExpand:[buffer remaining]];
     
    NSData* bytes = [buffer getDataAt:[buffer position] size:[buffer remaining]];
    [self putData:bytes];
}

- (char) get {
    char val = [self getAt:_position];
    _position++;
    return val;
}

-(char) getAt:(int)index {
    char val;
    NSRange range = {_arrayOffset + index, 1};
    [_data getBytes:&val range:range];
    return val;
}

- (NSData*) getData:(int)size {
    NSData *destination = [NSData dataWithBytes:((char *)_data.bytes)+_arrayOffset + _position length:size];
    _position += size;
    return destination;
}
- (NSData*) getDataAt:(int)index size:(int)size{
    @autoreleasepool {
        return [NSData dataWithBytes:((char *)_data.bytes)+_arrayOffset + index length:size];
    }
}

-(int)getIntAt:(int)index {
    NSRange range = {_arrayOffset + index, 4};
    int val;
    [_data getBytes:&val range:range];
    return CFSwapInt32BigToHost(val);
}

-(int)getInt {
    int val = [self getIntAt:_position];
    _position += 4;
    return val;
}

-(short)getShort {
    NSRange range = {_arrayOffset + _position, 2};
    short val;
    [_data getBytes:&val range:range];
    _position += 2;
    return CFSwapInt16BigToHost(val);
}

- (unsigned short) getUnsignedShort{
    NSRange range = {_arrayOffset + _position, 2};
    unsigned short val;
    [_data getBytes:&val range:range];
    _position += 2;
    return CFSwapInt16BigToHost(val);
}

- (long long)getLong {
    NSRange range = {_arrayOffset + _position, 8};
    long long val;
    [_data getBytes:&val range:range];
    _position += 8;
    return CFSwapInt64BigToHost(val);
}

- (NSString*) getString {
    //Default to UTF8
    @autoreleasepool {
        return [self getStringWithEncoding:NSUTF8StringEncoding];
    }
}

- (NSString*) getStringWithEncoding:(NSStringEncoding)encoding {
    @autoreleasepool {
        NSRange range = {_arrayOffset + _position, [self remaining]};
        NSString* result =  [[NSString alloc] initWithData:[_data subdataWithRange:range] encoding:encoding];
        _position = _limit;
        return result;
    }
}

- (int) indexOf:(char)c {
    int i = _position;
    while (i < _limit) {
        if ([self getAt:i] == c) {
            return i;
        }
        i++;
    }
    return -1;
}

- (void) putString:(NSString *)string {
    // Defaults to UTF8
    return [self putString:string withEncoding:NSUTF8StringEncoding];
}

- (void) putString:(NSString *)string withEncoding:(NSStringEncoding)charset {
    NSData* temp = [string dataUsingEncoding:charset];
    [self putData:temp];
}

- (void *) bytesFrom:(int)index {
    return &(((uint8_t*)[_data bytes])[_arrayOffset+index]);
}

- (void *) bytesFromPosition {
    return [self bytesFrom:_position];
}

@end
