//
//  UIDevice+RHDeviceIdentifierAdditions.m
//
//  Created by Richard Heard on 29/03/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>
#import "UIDevice+RHDeviceIdentifierAdditions.h"

#import <CommonCrypto/CommonDigest.h>

#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>

NSString* NSStringGenerateSHA1FromString(NSString *string);

@implementation UIDevice (RHDeviceIdentifierAdditions)

-(NSString *)rh_macAddressForInterface:(NSString*)interface{
    
    //look up the interface number 
    int interfaceIndex =  if_nametoindex([interface UTF8String]);
    if (interfaceIndex == 0){
        NSLog(@"Error: if_nametoindex failure.");
        return nil;
    }
    
    //create our mib (Management Information Base)
    int mib[] = {
        CTL_NET,        /* request network subsystem */
        AF_ROUTE,       /* routing table info */
        0,              /*  */
        AF_LINK,        /* request link layer info */
        NET_RT_IFLIST,  /* request all configured interfaces */
        interfaceIndex  /* include the interface we are interested in */
    };
    
    
    //look up the length of our expected result
    size_t length = 0;
    if (sysctl(mib, 6, NULL, &length, NULL, 0) < 0) {
        NSLog(@"Error: looking up length for interfaceMessageBuffer.");
        return nil;
    }
    
    //allocate memory for resultant structure
    char *interfaceBuffer = malloc(length);
    if (!interfaceBuffer){
        NSLog(@"Error: looking allocating memory for interfaceMessageBuffer.");        
        return nil;
    }
    
    //get our result
    if (sysctl(mib, 6, interfaceBuffer, &length, NULL, 0) < 0) {
        NSLog(@"Error: sysctl failed to populate interfaceMessageBuffer.");
        free(interfaceBuffer);
        return nil;
    }
    

    //get the mac address from the resulting interfaceBuffer. It consists of 2 structs, a header followed by the llsocket struct
    struct if_msghdr *interfaceMessageHeaderStruct = (struct if_msghdr*)interfaceBuffer;
    struct sockaddr_dl *linkLevelSocketStruct = (struct sockaddr_dl *)(interfaceMessageHeaderStruct + 1); //comes after the message header
    unsigned char *macAddressPtr = (unsigned char *)LLADDR(linkLevelSocketStruct);
    NSString *macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *macAddressPtr, *(macAddressPtr+1), *(macAddressPtr+2), *(macAddressPtr+3), *(macAddressPtr+4), *(macAddressPtr+5)];
    free(interfaceBuffer);
    
    return macAddress;
}


-(NSString *)rh_uniqueApplicationDeviceIdentifier{
    return NSStringGenerateSHA1FromString([NSString stringWithFormat:@"RHDeviceIdentifier-%@-%@", [[NSBundle mainBundle] bundleIdentifier], [self rh_macAddressForInterface:@"en0"]]);
}

-(NSString *)rh_uniqueGlobalDeviceIdentifier{
    return NSStringGenerateSHA1FromString([NSString stringWithFormat:@"RHDeviceIdentifier-%@",[self rh_macAddressForInterface:@"en0"]]);
}



NSString* NSStringGenerateSHA1FromString(NSString *string){
    if (! string) return nil;
    //sha1 hash the string
    const char *str = [string UTF8String];
    unsigned char outBuffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(str, strlen(str), outBuffer);
    
    NSMutableString *hash = [NSMutableString string];
    for(int i = 0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", outBuffer[i]];
    }
    return [NSString stringWithString:hash];
}

    

@end

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassUIDRHDIA : NSObject @end @implementation RHFixCategoryBugClassUIDRHDIA @end


