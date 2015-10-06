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
#import "KGHandler.h"
#import "KGByteBuffer.h"
#import "KGUpstreamChannel.h"
#import "KGUpstreamHandlerListener.h"
#import "KGHttpRequestHandlerFactory.h"

@interface KGUpstreamHandler : NSObject <KGHandler>

//+ (id <KGHttpRequestHandlerFactory>) UPSTREAM_HANDLER_FACTORY;


-(void) processBinaryMessage:(KGUpstreamChannel *)channel message: (KGByteBuffer *)message;
-(void) processTextMessage:(KGUpstreamChannel *)channel message: (NSString*)message;
-(void) processClose:(KGUpstreamChannel *)channel code:(NSInteger)code reason:(NSString *)reason;
-(void) processOpen:(KGUpstreamChannel *)channel;
- (void) processPong:(KGUpstreamChannel *)channel;


//-(void) processConnect:(KGUpstreamChannel*) channel uri: (NSString*)uri protocol:(NSString*) protocol;
-(void) setListener:(id <KGUpstreamHandlerListener>)listener;
-(void) setNextHandler:(id<KGHttpRequestHandler>)nextHandler;

//awful:
-(id <KGHttpRequestHandler>) nextHandler;
-(id<KGUpstreamHandlerListener>) listener;


@end
