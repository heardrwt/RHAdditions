//
//  NSImage+RHResizableImageAdditions.m
//
//  Created by Richard Heard on 15/04/13.
//  Copyright (c) 2013 Richard Heard. All rights reserved.
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


#import "NSImage+RHResizableImageAdditions.h"
#import "RHARCSupport.h"

//if enabled, we use RHDrawNinePartImage() instead of NSDrawNinePartImage()
#define USE_RH_NINE_PART 0

//==========
#pragma mark - RHEdgeInsets

RHEdgeInsets RHEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right){
    RHEdgeInsets insets = {top, left, bottom, right};
    return insets;
}

CGRect RHEdgeInsetsInsetRect(CGRect rect, RHEdgeInsets insets, BOOL flipped){
    rect.origin.x    += insets.left;
    rect.origin.y    += flipped ? insets.top : insets.bottom;
    rect.size.width  -= (insets.left + insets.right);
    rect.size.height -= (insets.top  + insets.bottom);
    return rect;
}

extern BOOL RHEdgeInsetsEqualToEdgeInsets(RHEdgeInsets insets1, RHEdgeInsets insets2){
    return insets1.left == insets2.left && insets1.top == insets2.top && insets1.right == insets2.right && insets1.bottom == insets2.bottom;
}

const RHEdgeInsets RHEdgeInsetsZero = {0.0f, 0.0f, 0.0f, 0.0f};



//==========
#pragma mark - NSImage+RHResizableImageAdditions


@implementation NSImage (RHResizableImageAdditions)

-(RHResizableImage*)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(CGFloat)topCapHeight{
    RHResizableImage *new = [[RHResizableImage alloc] initWithImage:self leftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    return arc_autorelease(new);
}

-(RHResizableImage*)resizableImageWithCapInsets:(RHEdgeInsets)capInsets{
    RHResizableImage *new = [[RHResizableImage alloc] initWithImage:self capInsets:capInsets];
    return arc_autorelease(new);
}

-(RHResizableImage*)resizableImageWithCapInsets:(RHEdgeInsets)capInsets resizingMode:(RHResizableImageResizingMode)resizingMode{
    RHResizableImage *new = [[RHResizableImage alloc] initWithImage:self capInsets:capInsets resizingMode:resizingMode];
    return arc_autorelease(new);
}

@end



//==========
#pragma mark - RHResizableImage


@implementation RHResizableImage

@synthesize capInsets=_capInsets;
@synthesize resizingMode=_resizingMode;

-(id)initWithImage:(NSImage*)image leftCapWidth:(CGFloat)leftCapWidth topCapHeight:(CGFloat)topCapHeight{
    CGFloat rightCapWidth = image.size.width - leftCapWidth - 1.0f;
    CGFloat bottomCapHeight = image.size.height - topCapHeight - 1.0f;
    return [self initWithImage:image capInsets:RHEdgeInsetsMake(topCapHeight, leftCapWidth, bottomCapHeight, rightCapWidth)];
}

-(id)initWithImage:(NSImage*)image capInsets:(RHEdgeInsets)capInsets{
    return [self initWithImage:image capInsets:capInsets resizingMode:RHResizableImageResizingModeTile];
}
-(id)initWithImage:(NSImage*)image capInsets:(RHEdgeInsets)capInsets resizingMode:(RHResizableImageResizingMode)resizingMode{
    self = [super initWithData:[image TIFFRepresentation]];
    
    if (self){
        _capInsets = capInsets;
        _resizingMode = resizingMode;
        
        _imagePieces = arc_retain(RHNinePartPiecesFromImageWithInsets(self, _capInsets));
    }
    return self;
}

-(void)dealloc{
    arc_release_nil(_imagePieces);
    arc_release_nil(_cachedImage);

    arc_super_dealloc();
}

#pragma mark - drawing
-(void)drawInRect:(NSRect)rect{
    [self drawInRect:rect operation:NSCompositeSourceOver fraction:1.0f];
}

-(void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha{
    [self drawInRect:rect operation:op fraction:requestedAlpha respectFlipped:YES hints:nil];
}
-(void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints{
    [self drawInRect:rect fromRect:NSZeroRect operation:op fraction:requestedAlpha respectFlipped:YES hints:nil];
}

-(void)drawInRect:(NSRect)rect fromRect:(NSRect)fromRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints{
    //fromRect and hints are both ignored
    
    //if our current cached image size does not match, throw away the cached image
    if (!NSEqualSizes(rect.size, _cachedImageSize)){
        arc_release_nil(_cachedImage);
        _cachedImageSize = NSZeroSize;
    }
    
    
    //if we dont have a cached image, create one now
    if (!_cachedImage){
        _cachedImageSize = rect.size;
        _cachedImage = [[NSImage alloc] initWithSize:_cachedImageSize];
        [_cachedImage lockFocus];
        
        NSRect drawRect = NSMakeRect(0.0f, 0.0f, _cachedImageSize.width, _cachedImageSize.height);

        [[NSColor clearColor] setFill];
        NSRectFill(drawRect);

        
        
#if USE_RH_NINE_PART
        BOOL shouldTile = (_resizingMode == RHResizableImageResizingModeTile);
        RHDrawNinePartImage(drawRect,
                            [_imagePieces objectAtIndex:0], [_imagePieces objectAtIndex:1], [_imagePieces objectAtIndex:2],
                            [_imagePieces objectAtIndex:3], [_imagePieces objectAtIndex:4], [_imagePieces objectAtIndex:5],
                            [_imagePieces objectAtIndex:6], [_imagePieces objectAtIndex:7], [_imagePieces objectAtIndex:8],
                            NSCompositeSourceOver, 1.0f, shouldTile);
#else
        NSDrawNinePartImage(drawRect,
                            [_imagePieces objectAtIndex:0], [_imagePieces objectAtIndex:1], [_imagePieces objectAtIndex:2],
                            [_imagePieces objectAtIndex:3], [_imagePieces objectAtIndex:4], [_imagePieces objectAtIndex:5],
                            [_imagePieces objectAtIndex:6], [_imagePieces objectAtIndex:7], [_imagePieces objectAtIndex:8],
                            NSCompositeSourceOver, 1.0f, NO);
        
        //if we want a center stretch, we need to draw this separately, clearing center first
        //also note that this only stretches the center, if you also want all sides stretched,
        // you should use RHDrawNinePartImage() via USE_RH_NINE_PART = 1
        BOOL shouldStretch = (_resizingMode == RHResizableImageResizingModeStretch);
        if (shouldStretch){
            NSImage *centerImage = [_imagePieces objectAtIndex:4];
            NSRect centerRect = RHEdgeInsetsInsetRect(drawRect, _capInsets, NO);
            CGContextClearRect([[NSGraphicsContext currentContext] graphicsPort], NSRectToCGRect(centerRect));
            [centerImage drawInRect:centerRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:NO hints:nil];
        }

#endif
        
        [_cachedImage unlockFocus];
    }
    
    //finally draw the cached image
    fromRect = NSMakeRect(0.0f, 0.0f, _cachedImageSize.width, _cachedImageSize.height);
    [_cachedImage drawInRect:rect fromRect:fromRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
    
}

-(void)nonStretchedDrawInRect:(NSRect)rect fromRect:(NSRect)fromRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints{
    return [super drawInRect:rect fromRect:fromRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
}

@end



//==========
#pragma mark - utilites



NSImage* RHCapturePieceOfImageFromRect(NSImage *image, CGRect rect){
    NSRect fromRect = NSRectFromCGRect(rect);
    NSImage *newImage = [[NSImage alloc] initWithSize:fromRect.size];
    if (newImage.isValid && fromRect.size.width > 0.0f && fromRect.size.height > 0.0f) {
        NSRect toRect = fromRect;
        toRect.origin = NSZeroPoint;
        [newImage lockFocus];
        //because we override drawInRect method in RHResizableImage, we need to call the super; non stretch implementation
        if ([image isKindOfClass:[RHResizableImage class]]){
            [(RHResizableImage*)image nonStretchedDrawInRect:toRect fromRect:fromRect operation:NSCompositeCopy fraction:1.0f respectFlipped:YES hints:nil];
        } else {
            [image drawInRect:toRect fromRect:fromRect operation:NSCompositeCopy fraction:1.0f respectFlipped:YES hints:nil];
        }
        [newImage unlockFocus];
    }
    
    return arc_autorelease(newImage);
}

NSArray* RHNinePartPiecesFromImageWithInsets(NSImage *image, RHEdgeInsets capInsets){
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGFloat leftCapWidth = capInsets.left;
    CGFloat topCapHeight = capInsets.top;
    CGFloat rightCapWidth = capInsets.right;
    CGFloat bottomCapHeight = capInsets.bottom;
    
    CGSize centerSize = CGSizeMake(imageWidth - leftCapWidth - rightCapWidth, imageHeight - topCapHeight - bottomCapHeight);
    
    
    NSImage *topLeftCorner = RHCapturePieceOfImageFromRect(image, CGRectMake(0.0f, imageHeight - topCapHeight, leftCapWidth, topCapHeight));
    NSImage *topEdgeFill = RHCapturePieceOfImageFromRect(image, CGRectMake(leftCapWidth, imageHeight - topCapHeight, centerSize.width, topCapHeight));
    NSImage *topRightCorner = RHCapturePieceOfImageFromRect(image, CGRectMake(imageWidth - rightCapWidth, imageHeight - topCapHeight, rightCapWidth, topCapHeight));
    
    NSImage *leftEdgeFill = RHCapturePieceOfImageFromRect(image, CGRectMake(0.0f, bottomCapHeight, leftCapWidth, centerSize.height));
    NSImage *centerFill = RHCapturePieceOfImageFromRect(image, CGRectMake(leftCapWidth, bottomCapHeight, centerSize.width, centerSize.height));
    NSImage *rightEdgeFill = RHCapturePieceOfImageFromRect(image, CGRectMake(imageWidth - rightCapWidth, bottomCapHeight, rightCapWidth, centerSize.height));
    
    NSImage *bottomLeftCorner = RHCapturePieceOfImageFromRect(image, CGRectMake(0.0f, 0.0f, leftCapWidth, bottomCapHeight));
    NSImage *bottomEdgeFill = RHCapturePieceOfImageFromRect(image, CGRectMake(leftCapWidth, 0.0f, centerSize.width, bottomCapHeight));
    NSImage *bottomRightCorner = RHCapturePieceOfImageFromRect(image, CGRectMake(imageWidth - rightCapWidth, 0.0f, rightCapWidth, bottomCapHeight));
    
    return [NSArray arrayWithObjects:topLeftCorner, topEdgeFill, topRightCorner, leftEdgeFill, centerFill, rightEdgeFill, bottomLeftCorner, bottomEdgeFill, bottomRightCorner, nil];
}



//==========
#pragma mark - nine part



void RHDrawNinePartImage(NSRect frame, NSImage *topLeftCorner, NSImage *topEdgeFill, NSImage *topRightCorner, NSImage *leftEdgeFill, NSImage *centerFill, NSImage *rightEdgeFill, NSImage *bottomLeftCorner, NSImage *bottomEdgeFill, NSImage *bottomRightCorner, NSCompositingOperation op, CGFloat alphaFraction, BOOL shouldTile){
    
    CGFloat imageWidth = frame.size.width;
    CGFloat imageHeight = frame.size.height;
    
    CGFloat leftCapWidth = topLeftCorner.size.width;
    CGFloat topCapHeight = topLeftCorner.size.height;
    CGFloat rightCapWidth = bottomRightCorner.size.width;
    CGFloat bottomCapHeight = bottomRightCorner.size.height;
    
    CGSize centerSize = CGSizeMake(imageWidth - leftCapWidth - rightCapWidth, imageHeight - topCapHeight - bottomCapHeight);

    
    CGRect topLeftCornerRect = CGRectMake(0.0f, imageHeight - topCapHeight, leftCapWidth, topCapHeight);
    CGRect topEdgeFillRect = CGRectMake(leftCapWidth, imageHeight - topCapHeight, centerSize.width, topCapHeight);
    CGRect topRightCornerRect = CGRectMake(imageWidth - rightCapWidth, imageHeight - topCapHeight, rightCapWidth, topCapHeight);
    
    CGRect leftEdgeFillRect = CGRectMake(0.0f, bottomCapHeight, leftCapWidth, centerSize.height);
    CGRect centerFillRect = CGRectMake(leftCapWidth, bottomCapHeight, centerSize.width, centerSize.height);
    CGRect rightEdgeFillRect = CGRectMake(imageWidth - rightCapWidth, bottomCapHeight, rightCapWidth, centerSize.height);
    
    CGRect bottomLeftCornerRect = CGRectMake(0.0f, 0.0f, leftCapWidth, bottomCapHeight);
    CGRect bottomEdgeFillRect = CGRectMake(leftCapWidth, 0.0f, centerSize.width, bottomCapHeight);
    CGRect bottomRightCornerRect = CGRectMake(imageWidth - rightCapWidth, 0.0f, rightCapWidth, bottomCapHeight);
    
    
    RHDrawImageInRect(topLeftCorner, topLeftCornerRect, op, fraction, NO);
    RHDrawImageInRect(topEdgeFill, topEdgeFillRect, op, fraction, shouldTile);
    RHDrawImageInRect(topRightCorner, topRightCornerRect, op, fraction, NO);
    
    RHDrawImageInRect(leftEdgeFill, leftEdgeFillRect, op, fraction, shouldTile);
    RHDrawImageInRect(centerFill, centerFillRect, op, fraction, shouldTile);
    RHDrawImageInRect(rightEdgeFill, rightEdgeFillRect, op, fraction, shouldTile);
    
    RHDrawImageInRect(bottomLeftCorner, bottomLeftCornerRect, op, fraction, NO);
    RHDrawImageInRect(bottomEdgeFill, bottomEdgeFillRect, op, fraction, shouldTile);
    RHDrawImageInRect(bottomRightCorner, bottomRightCornerRect, op, fraction, NO);

}

void RHDrawImageInRect(NSImage* image, NSRect rect, NSCompositingOperation op, CGFloat fraction, BOOL tile){
    if (tile){
        RHDrawTiledImageInRect(image, rect, op, fraction);
    } else {
        [image drawInRect:rect fromRect:NSZeroRect operation:op fraction:fraction];
    }
}

void RHDrawTiledImageInRect(NSImage* image, NSRect rect, NSCompositingOperation op, CGFloat fraction){
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    
    [[NSGraphicsContext currentContext] setCompositingOperation:op];
    CGContextSetAlpha(context, fraction);
    
    NSRect outRect = rect;
    CGImageRef imageRef = [image CGImageForProposedRect:&outRect context:NULL hints:NULL];
    
    CGContextClipToRect(context, NSRectToCGRect(outRect));
    CGContextDrawTiledImage(context, CGRectMake(rect.origin.x, rect.origin.y, image.size.width, image.size.height), imageRef);
    
    CGContextRestoreGState(context);
}




