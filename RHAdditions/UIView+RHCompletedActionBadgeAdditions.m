//
//  UIView+RHCompletedActionBadgeAdditions.m
//
//  Created by Richard Heard on 10/3/11.
//  Copyright (c) 2011 Richard Heard. All rights reserved.
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

#import "UIView+RHCompletedActionBadgeAdditions.h"

@implementation UIView (RHCompletedActionBadgeAdditions)

-(void)showCompletedActionBadgeImage:(UIImage*)image forSeconds:(NSTimeInterval)seconds{
    //turn off clips to bounds, but turn it on again once we are done.
    BOOL _oldClipsToBounds = self.clipsToBounds;
    self.clipsToBounds = NO;
    
    __block UIImageView *_badge = [[UIImageView alloc] initWithImage:image];
    _badge.center = CGPointMake(self.frame.size.width , 0.0f); //checkmark top right, but inset slightly
    _badge.alpha = 0.0f;
    [_badge setTransform:CGAffineTransformMakeScale(0.01, 0.01)]; //make it small so we can scale it in
    
    [self addSubview:_badge];
    
    //delay by 0.8s to give the visual impression of some activity occurring that has succeeded.
    [UIView animateWithDuration:0.2f delay:0.8f options:0 animations:^{
        _badge.alpha = 1.0f;
        [_badge setTransform:CGAffineTransformMakeScale(1.0, 1.0)]; //scale to full size
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.8f delay:seconds options:0 animations:^{
            //fade out 
            _badge.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [_badge removeFromSuperview];
            [_badge release];
            _badge = nil;
            self.clipsToBounds = _oldClipsToBounds;
        }];
    }];
    
}

@end

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassUIVRHCABA : NSObject @end @implementation RHFixCategoryBugClassUIVRHCABA @end


