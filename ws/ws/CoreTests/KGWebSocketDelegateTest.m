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

#import "KGWebSocketDelegateTest.h"
#import "KGWebSocketDelegate.h"
#import "KGWebSocketCompositeHandler.h"
#import "KGWebSocket+Internal.h"
#import "TestUtil.h"

#import <OCMock/OCMock.h>

@interface TestDelegate : NSObject<KGWebSocketDelegate> {
    @package
    BOOL didOpenInvoked;
    BOOL didCloseInvoked;
    BOOL didReceiveMessageInvoked;
    BOOL didReceiveErrorInvoked;
}

@end

@implementation TestDelegate

- (void) webSocketDidOpen:(KGWebSocket *)webSocket {
    didOpenInvoked = YES;
}

- (void) webSocket:(KGWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    didCloseInvoked = YES;
}

- (void) webSocket:(KGWebSocket *)webSocket didReceiveMessage:(id)data {
    didReceiveMessageInvoked = YES;
}

- (void) webSocket:(KGWebSocket *)webSocket didReceiveError:(NSError *)error {
    didReceiveErrorInvoked = YES;
}

@end

@implementation KGWebSocketDelegateTest

static NSURL *DEFAULT_LOCATION;

+ (void) initialize {
    DEFAULT_LOCATION = [NSURL URLWithString:@"ws://localhost:8001/echo"];
}

- (void) testWebSocketDidOpenInvoked {
    id mockCompositeHandler = [OCMockObject mockForClass:[KGWebSocketCompositeHandler class]];
    
    __block id handlerListener;
    
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
    }] processConnect:[OCMArg any] location:[OCMArg any] requestedProtocols:[OCMArg any]];
    KGWebSocket *webSocket = [[KGWebSocket alloc]
                              initWithURL:DEFAULT_LOCATION
                              enabledExtensions:nil
                              enabledProtocols:nil
                              challengeHandler:nil
                              clientIdentity:nil
                              connectTimeout:5000];
    [webSocket setHandler:mockCompositeHandler];
    TestDelegate *testDelegate = [[TestDelegate alloc] init];
    [webSocket setDelegate:testDelegate];
    
    [webSocket connect];
    //[webSocket send:@"test"];
    //[webSocket close];
    
    [TestUtil waitForVerifiedMock:mockCompositeHandler delay:5.0];
    
    XCTAssertNoThrow([mockCompositeHandler verify], @"One of the expections could not be met");
    XCTAssertTrue(testDelegate->didOpenInvoked, @"expected call to didOpen");
    
}

- (void) testDidReceiveMessageInvoked {
    id mockCompositeHandler = [OCMockObject mockForClass:[KGWebSocketCompositeHandler class]];
    
    __block id handlerListener;
    
    [[mockCompositeHandler expect] setListener:[OCMArg checkWithBlock:^BOOL(id listener) {
        handlerListener = listener;
        return YES;
    }]];
    
    [[[mockCompositeHandler expect] andDo:^(NSInvocation *invocation) {
        KGWebSocketChannel *channel;
        [invocation getArgument:&channel atIndex:2];
        [handlerListener textmessageReceived:channel text:@"test"];
    }] processTextMessage:[OCMArg any] text:[OCMArg any]];
    
    KGWebSocket *webSocket = [[KGWebSocket alloc]
                              initWithURL:DEFAULT_LOCATION
                              enabledExtensions:nil
                              enabledProtocols:nil
                              challengeHandler:nil
                              clientIdentity:nil
                              connectTimeout:5000];
    [webSocket setHandler:mockCompositeHandler];
    TestDelegate *testDelegate = [[TestDelegate alloc] init];
    [webSocket setDelegate:testDelegate];
    [webSocket send:@"test"];
    [TestUtil waitForVerifiedMock:mockCompositeHandler delay:5.0];
    
    XCTAssertNoThrow([mockCompositeHandler verify], @"One of the expections could not be met");
    XCTAssertTrue(testDelegate->didReceiveMessageInvoked, @"expected call to didReceiveMessage");
}

@end
