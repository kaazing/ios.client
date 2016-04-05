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
#import "KGTransportFactory.h"
#import "KGHttpRequestIoHandler.h"
#import "KGHttpRequestLoggingHandler.h"
#import "KGTracer.h"

@implementation KGTransportFactory {
    
}

+ (id<KGHttpRequestHandler>) createHttpRequestHandler {
    id<KGHttpRequestHandler> requestHandler;

    // set up the actual "bridge/io" handler
    requestHandler = [[KGHttpRequestIoHandler alloc] init];
    
    if ([self useLogging]) {
        KGHttpRequestLoggingHandler * loggingHandler = [[KGHttpRequestLoggingHandler alloc] init];
        [loggingHandler setNextHandler:requestHandler];
        requestHandler = loggingHandler;
    }
    return requestHandler;
}


// not yet:
+ (id<KGWebSocketHandler>) createWebSocketHandler {
    return nil;
}


//private:
+(BOOL) useLogging {
    return KGTracerDebug;
}

@end
