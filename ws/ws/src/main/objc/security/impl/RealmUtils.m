/*
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
#import "RealmUtils.h"
NSString *const REALM = @"realm";

@implementation RealmUtils


+ (NSString*) realm:(KGChallengeRequest *) challengeRequest {
    
    NSString* authenticationParameters = [challengeRequest authenticationParameters];
    if (authenticationParameters == nil) {
        return nil;
    }
    
    return [RealmUtils quotedSubHeaderFieldValue:REALM fromHeaderFieldValue:authenticationParameters];
}

+ (NSString *)quotedSubHeaderFieldValue:(NSString *)param fromHeaderFieldValue:(NSString *)header
{
    
    // Finds and returns the range of the first occurrence of the parameter withing the header
	NSRange startRange = [header rangeOfString:[NSString stringWithFormat:@"%@=\"", param]];
    
    // If the parameter was not found anywhere within the header
	if(startRange.location == NSNotFound)
	{
        
		return nil;
	}
    
    // Gets the location after the parameter
	NSUInteger postStartRangeLocation = startRange.location + startRange.length;
    
    // The header length minus the length of the location found in the header.  This is provides the for everything in the header after the last parameter
	NSUInteger postStartRangeLength = [header length] - postStartRangeLocation;
    
    // Creates a new range with a start location after the parameter to the end of the header
	NSRange postStartRange = NSMakeRange(postStartRangeLocation, postStartRangeLength);
    
    // Finds the the location of the next quotation mark
	NSRange endRange = [header rangeOfString:@"\"" options:0 range:postStartRange];
    
    // If the ending quotation mark is not found
	if(endRange.location == NSNotFound)
	{
		// The ending quote was not found anywhere in the header
		return nil;
	}
    
    
    // Made it to this point in the method, this means an end quote was found
    
    // Creates a range from the start location to the end location
	NSRange subHeaderRange = NSMakeRange(postStartRangeLocation, endRange.location - postStartRangeLocation);
    
    // Returns the string of the subheader
	return [header substringWithRange:subHeaderRange];
}


@end
