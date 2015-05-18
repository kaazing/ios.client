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

#import "KGResumableTimer.h"
#import "KGTracer.h"

@implementation KGResumableTimer {
    NSThread        *_thread;
    NSTimer         *_timer;
    NSRunLoop       *_runLoop;
    id               _target;
    long             _delay;
    long             _startTime;
    BOOL             _updateDelayWhenPaused;
    volatile bool    _fired;
}

- (id) init {
    NSString *msg = @"init is not a valid initializer for KGResumableTimer. \
                      Please use initWithTarget:selector:timeout to create KGResumableTimer.";
    NSException *exception = [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                                     reason:msg
                                                   userInfo:nil];
    @throw exception;
}

- (id) initWithTarget:(id)target
                delay:(int)delay
                updateDelayWhenPaused:(BOOL)update {
    self = [super init];
    if (self) {
        if (delay < 0) {
            NSString *msg = @"Timer delay cannot be negative";
            NSException *exception = [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                                             reason:msg
                                                           userInfo:nil];
            @throw exception;
        }

        _thread = [NSThread currentThread];
        _runLoop = [NSRunLoop currentRunLoop];
        _target = target;
        _delay = delay;
        _fired = false;
        _updateDelayWhenPaused = update;
    }
    
    return self;
}

- (void) dealloc {
    if (_timer != nil) {
        [_timer invalidate];
    }

    _thread = nil;
    _runLoop = nil;
    _timer = nil;
    _target = nil;
}

- (void) cancel {
    if ((_thread == nil) || (_runLoop == nil) || (_timer == nil)) {
        return;
    }

    @synchronized (self) {
        [self performSelector:@selector(cancelInternal) onThread:_thread withObject:NULL waitUntilDone:YES];

        _delay = -1;
        _timer = nil;
        _target = nil;
        _thread = nil;
        _runLoop = nil;
    }
}

- (int) delay {
    return (int) _delay;
}

- (void) pause {
    if (_fired || (_thread == nil) || (_timer == nil)) {
        // NSString *msg = @"Timer cannot be paused";
        return;
    }

    @synchronized (self) {
        [self performSelector:@selector(pauseInternal) onThread:_thread withObject:NULL waitUntilDone:YES];
    }
}

- (void) resume {
    if (_fired || (_thread == nil) || (_timer != nil)) {
        // NSString *msg = @"Timer cannot be resumed";
        return;
    }

    @synchronized (self) {
        [self performSelector:@selector(resumeInternal) onThread:_thread withObject:NULL waitUntilDone:YES];
    }
}

- (void) start {
    if (_fired || (_thread == nil) || (_runLoop == nil)) {
        NSString *msg = @"Timer cannot be started";
        NSException *exception = [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                                         reason:msg
                                                       userInfo:nil];
        @throw exception;
    }

    @synchronized (self) {
        [self performSelector:@selector(startInternal) onThread:_thread withObject:NULL waitUntilDone:NO];
    }
}

#pragma mark <Private Methods>

- (long) currentTimeMillis {
    NSTimeInterval time = ([[NSDate date] timeIntervalSince1970]); // returned as a double
    long digits = (long)time; // this is the first 10 digits
    int decimalDigits = (int)(fmod(time, 1) * 1000); // this will get the 3 missing digits
    long timestamp = (digits * 1000) + decimalDigits;

    return timestamp;
}

- (void) cancelInternal {
    if (_timer != nil) {
        [_timer invalidate];
    }
    
    _timer = nil;
}

- (void) pauseInternal {
    if (_timer == nil) {
        // throw new IllegalStateException("Timer is not running");
        return;
    }
    
    long elapsedTime = [self currentTimeMillis] - _startTime;

    [_timer invalidate];
    _timer = nil;
    
    if (_updateDelayWhenPaused) {
        assert(elapsedTime < _delay);
        _delay = _delay - elapsedTime;
    }
}

- (void) resumeInternal {
    if (_timer != nil) {
        return;
    }

    [self startInternal];
}

- (void) startInternal {
    _startTime = [self currentTimeMillis];

    if (_delay < 0) {
        NSString *msg = @"Timer delay cannot be negative";
        NSException *exception = [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                                         reason:msg
                                                       userInfo:nil];
        @throw exception;
    }

    double delay = (double) _delay;
    double delayInSeconds = (double) delay / 1000.0;
    
    _timer = [NSTimer timerWithTimeInterval:delayInSeconds
                                     target:self
                                   selector:@selector(onTimerFire:)
                                   userInfo:nil
                                    repeats:NO];
    [_runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void) onTimerFire:(NSTimer *)timer {
    _fired = YES;

    if (self.didTimerFire) {
        @try {
            self.didTimerFire(_target);
        }
        @catch (NSException *ex) {
            [KGTracer trace:[NSString stringWithFormat:@"EXCEPTION: %@", [ex reason]]];
        }
    }
}

@end
