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

#import "KGByteBufferTest.h"
#import "KGByteBuffer.h"

@implementation KGByteBufferTest

- (void) testPutShort {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    [byteBuffer putShort:23];
    [byteBuffer flip];
    short value = [byteBuffer getShort];
    XCTAssertTrue(value == 23, @"value should be 23");
}

- (void) testDuplicate {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    [byteBuffer putShort:23];
    [byteBuffer putString:@"test"];
    [byteBuffer flip];
    KGByteBuffer *copiedBuffer = [byteBuffer duplicate];
    short shortVal = [copiedBuffer getShort];
    NSString *stringVal = [copiedBuffer getString];
    XCTAssertTrue(shortVal == 23, @"short value should be 23");
    XCTAssertEqualObjects(stringVal, @"test", @"string value should be - test");
}

- (void) testSlice {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    [byteBuffer putShort:23];
    [byteBuffer putString:@"test"];
    [byteBuffer flip];
    [byteBuffer getShort];
    KGByteBuffer *slicedBuffer = [byteBuffer slice];
    XCTAssertTrue([slicedBuffer position] == 0, @"the position of sliced buffer should be zero");
    NSString *stringVal = [slicedBuffer getString];
    XCTAssertEqualObjects(stringVal, @"test", @"string value should be - test");
    
}

/*The bytes between the buffer's current position and its limit, if any, are copied to the beginning of the buffer. 
 That is, the byte at index p = position() is copied to index zero, the byte at index p + 1 is copied to index one, 
 and so forth until the byte at index limit() - 1 is copied to index n = limit() - 1 - p. The buffer's position is 
 then set to n+1 and its limit is set to its capacity. The mark, if defined, is discarded.

 The buffer's position is set to the number of bytes copied, rather than to zero, so that an invocation of this 
 method can be followed immediately by an invocation of another relative put method.
 */
- (void) testCompact {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    [byteBuffer putShort:23];
    [byteBuffer putString:@"test"];
    [byteBuffer flip];
    [byteBuffer getShort];
    KGByteBuffer *compactBuffer = [byteBuffer compact];
    XCTAssertEqual(byteBuffer, compactBuffer, @"compact should return the same instance");
    XCTAssertTrue([compactBuffer position] == 4, @"the position of the compact buffer should be the number of bytes copied - 4");
    [compactBuffer flip];
    NSString *stringVal = [compactBuffer getString];
    XCTAssertEqualObjects(stringVal, @"test", @"string value should be - test");
}

- (void) testWrapData {
    const unsigned char bytes[] = {1,2,3,4,5};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    KGByteBuffer *byteBuffer = [KGByteBuffer wrapData:data];
    XCTAssertTrue([byteBuffer remaining] == 5, @"The remaining bytes should be equal to 5");
    XCTAssertTrue([byteBuffer get] == 1, @"get should return 1");
    XCTAssertTrue([byteBuffer get] == 2, @"get should return 2");
    XCTAssertTrue([byteBuffer get] == 3, @"get should return 3");
    XCTAssertTrue([byteBuffer get] == 4, @"get should return 4");
    XCTAssertTrue([byteBuffer get] == 5, @"get should return 5");
}

- (void) testPutData {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    const unsigned char bytes[] = {1,2,3,4,5};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [byteBuffer putData:data];
    XCTAssertTrue([byteBuffer getAt:0] == 1, @"get should return 1");
    XCTAssertTrue([byteBuffer getAt:1] == 2, @"get should return 2");
    XCTAssertTrue([byteBuffer getAt:2] == 3, @"get should return 3");
    XCTAssertTrue([byteBuffer getAt:3] == 4, @"get should return 4");
    XCTAssertTrue([byteBuffer getAt:4] == 5, @"get should return 5");
}

- (void) testGetData {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    const unsigned char bytes[] = {1,2,3,4,5};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [byteBuffer putData:data];
    [byteBuffer flip];
    NSData *dataFromByteBuffer = [byteBuffer getData:3];
    unsigned char buffer[3];
    [dataFromByteBuffer getBytes:buffer length:3];
    XCTAssertTrue(buffer[0] == 1, @"expected 1");
    XCTAssertTrue(buffer[1] == 2, @"expected 2");
    XCTAssertTrue(buffer[2] == 3, @"expected 3");
}

- (void) testGetIntAt {
    KGByteBuffer *byteBuffer = [[KGByteBuffer alloc] init];
    [byteBuffer putInt:20];
    [byteBuffer putInt:3456];
    [byteBuffer putInt:7892];
    [byteBuffer putInt:12345];
    [byteBuffer putInt:543];
    XCTAssertTrue([byteBuffer getIntAt:4*4] == 543, @"expected 543");
    XCTAssertTrue([byteBuffer getIntAt:2*4] == 7892, @"expected 7892");
    XCTAssertTrue([byteBuffer getIntAt:3*4] == 12345, @"expected 12345");
    XCTAssertTrue([byteBuffer getIntAt:0] == 20, @"expected 20");
    XCTAssertTrue([byteBuffer getIntAt:1*4] == 3456, @"expected ");
    
}

@end
