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

/**
 * A DispatchChallengeHandler is responsible for dispatching challenge requests
 * to appropriate challenge handlers when challenges
 * arrive from specific URI locations in challenge responses.
 * <p/>
 * This allows clients to use specific challenge handlers to handle specific
 * types of challenges at different URI locations.
 * <p/>
 */
@interface KGDispatchChallengeHandler : KGChallengeHandler

-(BOOL) canHandle:(KGChallengeRequest *)challengeRequest;

-(KGChallengeResponse *) handle:(KGChallengeRequest *)challengeRequest;

/**
 * Register a challenge handler to respond to challenges at one or more locations.
 * <p/>
 * When a challenge response is received for a protected URI, the `locationDescription`
 * matches against elements of the protected URI; if a match is found, one
 * consults the challenge handler(s) registered at that `locationDescription` to find
 * a challenge handler suitable to respond to the challenge.
 * <p/>
 * A `locationDescription` comprises a username, password, host, port and paths,
 * any of which can be wild-carded with the "*" character to match any number of request URIs.
 * If no port is explicitly mentioned in a `locationDescription`, a default port will be inferred
 * based on the scheme mentioned in the location description, according to the following table:
 * <table border=1>
 *     <tr><th>scheme</th><th>default port</th><th>Sample locationDescription</th></tr>
 *     <tr><td>http</td><td>80</td><td>foo.example.com or `http://foo.example.com`</td></tr>
 *     <tr><td>ws</td><td>80</td><td>foo.example.com or ws://foo.example.com</td></tr>
 *     <tr><td>https</td><td>443</td><td>`https://foo.example.com`</td></tr>
 *     <tr><td>wss</td><td>443</td><td>wss://foo.example.com</td></tr>
 * </table>
 * <p/>
 * The protocol scheme (e.g. http or ws) if present in `locationDescription` will not be used to
 * match `locationDescription` with the protected URI, because authentication challenges are
 * implemented on top of one of the HTTP/s protocols always, whether one is initiating web socket
 * connections or regular HTTP connections.  That is to say for example, the locationDescription `"foo.example.com"`
 * matches both URIs `http://foo.example.com` and `ws://foo.example.com`.
 * <p/>
 * Some examples of `locationDescription` values with wildcards are:
 * <ol>
 *     <li>`*`&#047; -- matches all requests to any host on port 80 (default port), with no user info or path specified.  </li>
 *     <li>`*.hostname.com:8000`  -- matches all requests to port 8000 on any sub-domain of `hostname.com`,
 *         but not `hostname.com` itself.</li>
 *     <li>`server.hostname.com:*`&#047;`*` -- matches all requests to a particular server on any port on any path but not the empty path. </li>
 * </ol>
 * @param locationDescription the (possibly wild-carded) location(s) at which to register a handler.
 * @param challengeHandler the challenge handler to register at the location(s).
 *
 * @return a reference to this challenge handler for chained calls
 */
-(KGDispatchChallengeHandler *) registerChallengeHandler:(NSString*)locationDescription challengeHandler:(KGChallengeHandler *)challengeHandler;

/**
 * If the provided challengeHandler is registered at the provided location, clear that
 * association such that any future challenge requests matching the location will never
 * be handled by the provided challenge handler.
 * <p/>
 * If no such location or challengeHandler registration exists, this method silently succeeds.
 * @param locationDescription the exact location description at which the challenge handler was originally registered
 * @param challengeHandler the challenge handler to de-register.
 *
 * @return a reference to this object for chained call support
 */
-(KGChallengeHandler *) unregisterChallengeHandler:(NSString*)locationDescription challengeHandler:(KGChallengeHandler *)challengeHandler;

@end
