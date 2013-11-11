//
//  RHMushParser.h
//
//  Created by Richard Heard on 6/11/2013.
//  Copyright (c) 2013 Richard Heard. All rights reserved.
//
//  MGMushParser Copyright (c) 2012 Matt Greenfield. All rights reserved.
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
//  A Cocoa port of the awesome MGMushParser from MGBoxKit.
//  https://github.com/sobri909/MGBoxKit
//
//  Parse an NSString containing text and markup into a formatted NSAttributedString.
//
//  "Mush" Markup Format:
//   - **Bold** is achieved with **double asterisks**
//   - _Italics_ are achieved with //double slashes//
//   - <u>Underlining</u> is achieved with __double underscores__
//   - `Monospacing` is achieved with `single back-ticks`
//   - Coloured text is achieved with {#6699CC|the coloured text}
//
//  eg: NSString *format = @"**bold**, //italic//, __underline__, `monospaced`, and {#0000FF|coloured text}";
//
//  Requirements: OS X 10.7+ / iOS 4.0+
//

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
    #import <UIKit/UIKit.h>
    #import <CoreText/CoreText.h>
#else
    #import <Cocoa/Cocoa.h>
    #import <CoreText/CoreText.h>
#endif

@interface RHMushParser : NSObject {
    NSString *_markup;
    id _baseFont;
    id _baseColor;

    //internal
    id _boldFont;
    id _italicFont;
    id _monospaceFont;
    NSMutableAttributedString *_mutableAttributedString;
}

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)

@property (nonatomic, copy) NSString *markup;
@property (nonatomic, retain) UIFont *baseFont;
@property (nonatomic, retain) UIColor *baseColor;
+(NSAttributedString *)attributedStringFromMarkup:(NSString *)markup withFont:(UIFont *)font andColor:(UIColor *)color;

#else

@property (nonatomic, copy) NSString *markup;
@property (nonatomic, retain) NSFont *baseFont;
@property (nonatomic, retain) NSColor *baseColor;
+(NSAttributedString *)attributedStringFromMarkup:(NSString *)markup withFont:(NSFont *)font andColor:(NSColor *)color;

#endif

-(void)parse;
-(void)strip;
-(NSAttributedString *)attributedString;

@end

extern id RHColorFromHexString(NSString *string);

