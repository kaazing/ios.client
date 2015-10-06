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
#import "KGHttpRequest.h"
#import "KGHttpResponse.h"
#import "KGByteBuffer.h"

@protocol KGHttpRequestListener <NSObject>

// package private
- (void) requestReady:(KGHttpRequest *)request;

// package private
- (void) requestOpened:(KGHttpRequest *)request;

// package private
- (void) requestProgressed:(KGHttpRequest *)request payload:(KGByteBuffer *)payload;

// package private
- (void) requestLoaded:(KGHttpRequest *)request response:(KGHttpResponse *)response;

// package private
- (void) requestAborted:(KGHttpRequest *)request;

// package private
- (void) requestClosed:(KGHttpRequest *)request;

// package private
- (void) errorOccurred:(KGHttpRequest *)request exception:(NSException *)exception;

@end
