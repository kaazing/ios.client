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

#import "TestUtil.h"

#import "KGWebSocketTest.h"
#import "KGWebSocket.h"
#import "KGWebSocket+Internal.h"
#import "KGWebSocket+Internal.h"
#import "KGBasicChallengeHandler.h"

#import <OCMock/OCMock.h>

@implementation KGWebSocketTest

static NSURL *DEFAULT_LOCATION;

+ (void) initialize {
    DEFAULT_LOCATION = [NSURL URLWithString:@"ws://localhost:8001/echo"];
}

- (void) testInit {
    id webSocket = [KGWebSocket alloc];
    XCTAssertThrowsSpecificNamed([webSocket init], NSException, NSInternalInconsistencyException, @"call to init on KGWebSocket should throw exception");
}

// Verify whether or not [KGWebSocket send] will throw an exception if the argument type is neither NSString nor NSData
- (void) testSend {
    KGWebSocket *webSocket = [[KGWebSocket alloc] initWithURL:DEFAULT_LOCATION enabledExtensions:nil enabledProtocols:nil enabledParameters:nil challengeHandler:nil clientIdentity:nil connectTimeout:5000];
    NSNumber *invalidArgument = [NSNumber numberWithInt:10];
    
    XCTAssertThrowsSpecificNamed([webSocket send:invalidArgument], NSException, NSInvalidArgumentException, @"call to send on KGWebSocket with argument other than NSString or NSData should throw an exception");
}

// Verify that [KGWebSocket close] will throw exception if the close code is invalid
- (void) testCloseWithInvalidCloseCode {
    KGWebSocket *webSocket = [[KGWebSocket alloc] initWithURL:DEFAULT_LOCATION enabledExtensions:nil enabledProtocols:nil enabledParameters:nil challengeHandler:nil clientIdentity:nil connectTimeout:5000];
    XCTAssertThrowsSpecificNamed([webSocket close:1200 reason:@"test"], NSException, NSInvalidArgumentException, @"call to close on KGWebSocket with invalid close code should throw exception");
}

- (void) testDidOpen {
    id mockCompositeHandler = [OCMockObject mockForClass:[KGWebSocketCompositeHandler class]];
    
    __block id handlerListener;
    __block BOOL didOpenExecuted = NO;
    
    [[mockCompositeHandler expect] setListener:[OCMArg checkWithBlock:^BOOL(id listener) {
        handlerListener = listener;
        return YES;
    }]];
    
    [[[mockCompositeHandler expect] andDo:^(NSInvocation *invocation) {
        KGWebSocketChannel *channel;
        
        // Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively
        // Use indices 2 and greater for the arguments normally passed in a message.
        [invocation getArgument:&channel atIndex:2];
        [handlerListener connectionOpened:channel protocol:@""];
    }] processConnect:[OCMArg any] location:[OCMArg checkWithBlock:^BOOL(KGWSURI *url) {
        NSString *actualHost = [[url URI] host];
        NSString *originalHost = [DEFAULT_LOCATION host];
        NSString *actualScheme = [[url URI] scheme];
        NSString *originalScheme = [DEFAULT_LOCATION scheme];
        return [actualHost isEqualToString:originalHost] &&
        [actualScheme isEqualToString:originalScheme];
    }] requestedProtocols:[OCMArg any]];
    
    KGWebSocket *webSocket = [[KGWebSocket alloc] initWithURL:DEFAULT_LOCATION enabledExtensions:nil enabledProtocols:nil enabledParameters:nil challengeHandler:nil clientIdentity:nil connectTimeout:5000];
    [webSocket setHandler:mockCompositeHandler];
    webSocket.didOpen = ^(KGWebSocket *webSocket) {
        didOpenExecuted = YES;
    };
    [webSocket connect];
    
    [TestUtil waitForVerifiedMock:mockCompositeHandler delay:3.0];
    XCTAssertNoThrow([mockCompositeHandler verify], @"expected call to processConnect on KGWebSocketCompositeHandler");
    XCTAssertTrue(didOpenExecuted, @"expected the didOpen block to be executed");
}

- (void) testDidReceiveMessageForTextMessage {
    id mockCompositeHandler = [OCMockObject mockForClass:[KGWebSocketCompositeHandler class]];
    
    __block id handlerListener;
    __block BOOL didReceiveMessageInvoked = NO;
    __block NSString *receivedMessage = @"";
    
    [[mockCompositeHandler expect] setListener:[OCMArg checkWithBlock:^BOOL(id listener) {
        handlerListener = listener;
        return YES;
    }]];
    
    [[[mockCompositeHandler expect] andDo:^(NSInvocation *invocation) {
        KGWebSocketChannel *channel;
        NSString           *message;
        
        // Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively
        // Use indices 2 and greater for the arguments normally passed in a message.
        [invocation getArgument:&channel atIndex:2];
        [invocation getArgument:&message atIndex:3];
        [handlerListener textmessageReceived:channel text:message];
    }] processTextMessage:[OCMArg any] text:[OCMArg checkWithBlock:^BOOL(NSString *textMessage) {
        return [textMessage isEqualToString:@"text message"];
    }]];
    KGWebSocket *webSocket = [[KGWebSocket alloc] initWithURL:DEFAULT_LOCATION enabledExtensions:nil enabledProtocols:nil enabledParameters:nil challengeHandler:nil clientIdentity:nil connectTimeout:5000];
    [webSocket setHandler:mockCompositeHandler];
    webSocket.didReceiveMessage = ^(KGWebSocket *webSocket, id message) {
        didReceiveMessageInvoked = YES;
        receivedMessage = message;
    };
    [webSocket send:@"text message"];
    
    [TestUtil waitForVerifiedMock:mockCompositeHandler delay:3.0];
    XCTAssertNoThrow([mockCompositeHandler verify], @"expected call to processTextMessage  on KGWebSocketCompositeHandler");
    XCTAssertTrue(didReceiveMessageInvoked, @"expected the didReceiveMessage block to be executed");
    XCTAssertEqualObjects(@"text message", receivedMessage, @"received message expected to be - 'text message'");

}

- (void) testDidReceiveMessageForBinaryMessage {
    id mockCompositeHandler = [OCMockObject mockForClass:[KGWebSocketCompositeHandler class]];
    
    __block id handlerListener;
    __block BOOL didReceiveMessageInvoked = NO;
    __block NSString *receivedMessage;
    
    KGByteBuffer *messageToSend = [[KGByteBuffer alloc] init];
    [messageToSend putString:@"hello"];
    [messageToSend flip];
    
    [[mockCompositeHandler expect] setListener:[OCMArg checkWithBlock:^BOOL(id listener) {
        handlerListener = listener;
        return YES;
    }]];
    
    [[[mockCompositeHandler expect] andDo:^(NSInvocation *invocation) {
        KGWebSocketChannel     *channel;
        
        // Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively
        // Use indices 2 and greater for the arguments normally passed in a message.
        [invocation getArgument:&channel atIndex:2];
        [handlerListener messageReceived:channel buffer:messageToSend];
    }] processBinaryMessage:[OCMArg any] buffer:[OCMArg checkWithBlock:^BOOL(KGByteBuffer *binaryMessage) {
        return [[binaryMessage getString] isEqualToString:@"hello"];
    }]];
    KGWebSocket *webSocket = [[KGWebSocket alloc] initWithURL:DEFAULT_LOCATION enabledExtensions:nil enabledProtocols:nil enabledParameters:nil challengeHandler:nil clientIdentity:nil connectTimeout:5000];
    [webSocket setHandler:mockCompositeHandler];
    webSocket.didReceiveMessage = ^(KGWebSocket *webSocket, id message) {
        didReceiveMessageInvoked = YES;
        receivedMessage = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    };
    [webSocket send:[messageToSend data]];
    
    [TestUtil waitForVerifiedMock:mockCompositeHandler delay:3.0];
    XCTAssertNoThrow([mockCompositeHandler verify], @"expected call to processBinaryMessage  on KGWebSocketCompositeHandler");
    XCTAssertTrue(didReceiveMessageInvoked, @"expected the didReceiveMessage block to be executed");
    XCTAssertEqualObjects(@"hello", receivedMessage, @"string representation of received message should be - 'hello'");
}

@end
