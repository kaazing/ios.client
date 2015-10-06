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
#import "KGWebSocketHandler.h"
#import "KGByteBuffer.h"
#import "KGWebSocketChannel.h"
#import "KGWebSocketHandlerListener.h"
#import "KGWebSocketSelectedHandler.h"
#import "KGWebSocketCompositeChannel.h"

extern NSArray* Kaazing_Enterprise_Extensions;

@protocol KGWebSocketSelectedHandlerFactory <NSObject>
-(KGWebSocketSelectedHandler *)createSelectedHandler;
@end

@interface KGWebSocketCompositeHandler : NSObject <KGWebSocketHandler>{
    @private
    KGWebSocketSelectedHandler * emulatedHandler;
    KGWebSocketSelectedHandler * nativeHandler;
}

+ (KGWebSocketCompositeHandler *) compositeHandler;

//// private section ////
-(KGWebSocketSelectedHandler *) createEmulatedHandler;
-(id<KGWebSocketHandlerListener>)createListener;
-(void) doOpen:(KGWebSocketCompositeChannel *) channel;
-(void) doClose:(KGWebSocketCompositeChannel *) channel wasClean:(BOOL)wasClean code:(short)code reason:(NSString*)reason;
-(void) doClose:(KGWebSocketCompositeChannel *) channel exception:(NSException *)exception;
-(void) fallbackNext:(KGWebSocketCompositeChannel *) channel exception:(NSException *)exception;

//hrm..
+(void) setSelectHandlerFactory:(id<KGWebSocketSelectedHandlerFactory>) factory;
@end
