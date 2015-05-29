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
//
//  Created by Sanjay Saxena on 4/25/14.
//  Copyright (c) 2014 Kaazing. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KGResumableTimer.h"

@interface KGResumableTimerTest : XCTestCase

@end


@implementation KGResumableTimerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testTimerStart
{
    __block BOOL didFire = NO;

    NSLog(@"********** %s", __PRETTY_FUNCTION__);

    KGResumableTimer *resumableTimer = [[KGResumableTimer alloc] initWithTarget:self delay:5000 updateDelayWhenPaused:NO];
    resumableTimer.didTimerFire = ^(id target) {
        NSLog(@"********* TIMER FIRED AT %@", [[NSDate date] description]);
        didFire = YES;
    };

    NSLog(@"********* TIMER STARTED at %@", [[NSDate date] description]);
    [resumableTimer start];
    
    // Wait for 10seconds to allow the timer to fire.
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 10.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    XCTAssertTrue(didFire, @"Timer did not fire");
}

- (void)testTimerPauseResume
{
    __block BOOL didFire = NO;

    NSLog(@"********** %s", __PRETTY_FUNCTION__);

    KGResumableTimer *resumableTimer = [[KGResumableTimer alloc] initWithTarget:self delay:5000 updateDelayWhenPaused:YES];
    resumableTimer.didTimerFire = ^(id target) {
        NSLog(@"********* TIMER FIRED AT %@", [[NSDate date] description]);
        didFire = YES;
    };

    NSLog(@"********* TIMER STARTED AT %@", [[NSDate date] description]);
    [resumableTimer start];
    
    // Let the runLoop run for 2seconds before pausing the timer.
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 2.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    NSLog(@"********* TIMER PAUSED AT %@", [[NSDate date] description]);
    [resumableTimer pause];
    XCTAssertTrue(([resumableTimer delay] < 5000), @"When paused, the current delay should be less than the initial delay");

    // Let the runLoop run for 4seconds before resuming the timer.
    runUntil = [NSDate dateWithTimeIntervalSinceNow: 4.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    NSLog(@"********* TIMER RESUMED AT %@", [[NSDate date] description]);
    [resumableTimer resume];

    // Let the runLoop run for 5seconds to allow the timer to fire.
    runUntil = [NSDate dateWithTimeIntervalSinceNow: 5.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    XCTAssertTrue(didFire, @"Timer did not fire after resume");
}

- (void)testTimerPauseResumeUsingThreads
{
    __block BOOL didFire = NO;
    
    NSLog(@"********** %s", __PRETTY_FUNCTION__);
    
    [[NSThread currentThread] setName:@"MainThread"];
    KGResumableTimer *resumableTimer = [[KGResumableTimer alloc] initWithTarget:self delay:5000 updateDelayWhenPaused:YES];
    resumableTimer.didTimerFire = ^(id target) {
        NSLog(@"********* Thread name = %@", [[NSThread currentThread] name]);
        NSLog(@"********* TIMER FIRED AT %@", [[NSDate date] description]);
        didFire = YES;
    };
    
    NSLog(@"********* TIMER STARTED AT %@", [[NSDate date] description]);
    [resumableTimer start];

    // Let the runLoop run for 2seconds before pausing the timer.
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 2.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];

    // Start a separate thread and pause the timer in new thread.
    NSThread *pauseThread = [[NSThread alloc] initWithTarget:self selector:@selector(pauseTimer:) object:resumableTimer];
    [pauseThread setName:@"PauseThread"];
    [pauseThread start];

    // Let the runLoop run for 4seconds before resuming the timer.
    runUntil = [NSDate dateWithTimeIntervalSinceNow: 4.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    XCTAssertTrue(([resumableTimer delay] < 5000), @"When paused, the current delay should be less than the initial delay");
    
    // Start a separate thread and resume the timer in new thread.
    NSThread *resumeThread = [[NSThread alloc] initWithTarget:self selector:@selector(resumeTimer:) object:resumableTimer];
    [resumeThread setName:@"ResumeThread"];
    [resumeThread start];

    // Let the runLoop run for 5seconds to allow the timer to fire.
    runUntil = [NSDate dateWithTimeIntervalSinceNow: 5.0];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    XCTAssertTrue(didFire, @"Timer did not fire after resume");
}

- (void) pauseTimer:(id)resumableTimer {
    NSLog(@"********* Thread name = %@", [[NSThread currentThread] name]);
    NSLog(@"********* TIMER PAUSED AT %@", [[NSDate date] description]);
    KGResumableTimer *timer = (KGResumableTimer *)resumableTimer;
    [timer pause];
}

- (void) resumeTimer:(id)resumableTimer {
    NSLog(@"********* Thread name = %@", [[NSThread currentThread] name]);
    NSLog(@"********* TIMER RESUMED AT %@", [[NSDate date] description]);
    KGResumableTimer *timer = (KGResumableTimer *)resumableTimer;
    [timer resume];
}

@end
