//
//  UILabel+RHLayoutAdditions.m
//
//  Created by Richard Heard on 6/12/12.
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

#import "UILabel+RHSizeAdditions.h"
#import "RHARCSupport.h"

@implementation UILabel (RHLayoutAdditions)

-(CGSize)sizeWithMaxWidth:(CGFloat)maxWidth{
    if ([self respondsToSelector: @selector(boundingRectWithSize:options:attributes:context:)]) {
        
        NSMutableParagraphStyle *paragraphStyle = arc_autorelease([[NSMutableParagraphStyle alloc] init]);
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:self.font, NSParagraphStyleAttributeName:paragraphStyle};
        CGSize size = [self.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        return CGSizeMake(MIN(maxWidth, ceilf(size.width)), ceilf(size.height));
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
        return CGSizeMake(MIN(maxWidth, ceilf(size.width)), ceilf(size.height));
#pragma clang diagnostic pop
        
    }
}

-(CGSize)sizeWithMaxHeight:(CGFloat)maxHeight{
    if ([self respondsToSelector: @selector(boundingRectWithSize:options:attributes:context:)]) {
        
        NSMutableParagraphStyle *paragraphStyle = arc_autorelease([[NSMutableParagraphStyle alloc] init]);
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:self.font, NSParagraphStyleAttributeName:paragraphStyle};
        CGSize size = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        return CGSizeMake(ceilf(size.width), MIN(maxHeight, ceilf(size.height)));
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, maxHeight) lineBreakMode:self.lineBreakMode];
        return CGSizeMake(size.width, MIN(maxHeight, size.height));
#pragma clang diagnostic pop
        
    }}

-(CGFloat)heightForWidth:(CGFloat)width{
    return [self sizeWithMaxWidth:width].height;
}

-(CGFloat)widthForHeight:(CGFloat)height{
    return [self sizeWithMaxHeight:height].width;
}

@end

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassUILRHSA : NSObject @end @implementation RHFixCategoryBugClassUILRHSA @end

