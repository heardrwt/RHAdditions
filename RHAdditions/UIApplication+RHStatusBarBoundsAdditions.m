//
//  UIApplication+RHStatusBarBoundsAdditions.m
//
//  Created by Richard Heard on 5/11/12.
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

#import "UIApplication+RHStatusBarBoundsAdditions.h"

@implementation UIApplication (RHStatusBarBoundsAdditions)

-(CGFloat)rh_statusBarHeight{
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait: return frame.size.height;
        case UIInterfaceOrientationPortraitUpsideDown: return frame.size.height;
        case UIInterfaceOrientationLandscapeLeft: return frame.size.width;
        case UIInterfaceOrientationLandscapeRight: return frame.size.width;
    }
}

-(CGFloat)rh_statusBarWidth{
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait: return frame.size.width;
        case UIInterfaceOrientationPortraitUpsideDown: return frame.size.width;
        case UIInterfaceOrientationLandscapeLeft: return frame.size.height;
        case UIInterfaceOrientationLandscapeRight: return frame.size.height;
    }
}

-(CGRect)rh_statusBarBounds{
    return CGRectMake(0.0f, 0.0f, [self rh_statusBarWidth], [self rh_statusBarHeight]);
}

@end

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassUIARHSBBA : NSObject @end @implementation RHFixCategoryBugClassUIARHSBBA @end


