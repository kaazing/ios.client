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
#import "KGChallengeHandler.h"
#import "KGNegotiableChallengeHandler.h"

/**
A Negotiate Challenge Handler handles initial empty "Negotiate" challenges from the
server.  It uses other "candidate" challenger handlers to assemble an initial context token
to send to the server, and is responsible for creating a challenge response that can delegate
to the winning candidate.
<p/>
This KGNegotiateChallengeHandler can be loaded and instantiated using KGChallengeHandlers load,
and registered at a location using KGDispatchChallengeHandler register.
<p/>
In addition, one can register more specific KGNegotiableChallengeHandler objects with
this initial KGNegotiateChallengeHandler to handle initial Negotiate challenges and subsequent challenges associated
with specific Negotiation <a href="http://tools.ietf.org/html/rfc4178#section-4.1">mechanism types / object identifiers</a>.
<p/>
The following example establishes a Negotiation strategy at a specific URL location.
We show the use of a KGDispatchChallengeHandler to register a KGNegotiateChallengeHandler at
a specific location.  The KGNegotiateChallengeHandler has a KGNegotiableChallengeHandler
instance registered as one of the potential negotiable alternative challenge handlers.

      KGLoginHandler* someServerLoginHandler = ...
 
      KGNegotiableChallengeHandler* handler = [KGChallengeHandlers load:@"KGNegotiableChallengeHandler"];
      [handler setLoginHandler:someServerLoginHandler];
      KGNegotiateChallengeHandler* negotiatehandler = [KGChallengeHandlers load:@"KGNegotiateChallengeHandler"];
      [negotiatehandler register:handler];
      KGDispatchChallengeHandler* dispatch = [KGChallengeHandlers load:@"KGDispatchChallengeHandler"];
      [dispatch registerChallengeHandler:@"ws://my.server.com" challengeHandler:negotiatehandler];
      [KGChallengeHandlers setDefault:dispatch];
 

see [RFC 4559 - Microsoft SPNEGO](http://tools.ietf.org/html/rfc4559)
see [RFC 4178 - GSS-API SPNEGO](http://tools.ietf.org/html/rfc4178)
see [RFC 2743 - GSS-API](http://tools.ietf.org/html/rfc2743)
see [RFC 4121 - Kerberos v5 GSS-API (version 2)](http://tools.ietf.org/html/rfc4121)
see [RFC 2616 - HTTP 1.1](http://tools.ietf.org/html/rfc2616)
see [RFC 2617 - HTTP Authentication](http://tools.ietf.org/html/rfc2617)
 */
@interface KGNegotiateChallengeHandler : KGChallengeHandler

/**
 * Register a candidate negotiable challenge handler that will be used to respond
 * to an initial "Negotiate" server challenge and can then potentially be
 * a winning candidate in the race to handle the subsequent server challenge.
 *
 * @param handler the mechanism-type-specific challenge handler.
 *
 * @return a reference to this handler, to support chained calls
 */
- (KGNegotiateChallengeHandler *) register:(KGNegotiableChallengeHandler *)handler;

@end
