//
//  RHMushParser.m
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

#import "RHMushParser.h"
#import "RHARCSupport.h"

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
    typedef UIColor _NSUIColor;
    typedef UIFont  _NSUIFont;
#else
    typedef NSColor _NSUIColor;
    typedef NSFont  _NSUIFont;
#endif

static NSString * const RHMushParserColorKey = @"color";

@interface RHMushParser ()
-(void)_applyParserRegex:(NSString *)parserRegex withReplacements:(NSArray*)parserReplacements andAttributes:(NSArray*)parserAttributes;
@end

@implementation RHMushParser
@synthesize markup=_markup;
@synthesize baseFont=_baseFont;
@synthesize baseColor=_baseColor;

- (void)dealloc{
    arc_release_nil(_markup);
    arc_release_nil(_baseFont);
    arc_release_nil(_baseColor);
    arc_release_nil(_boldFont);
    arc_release_nil(_italicFont);
    arc_release_nil(_monospaceFont);
    arc_release_nil(_mutableAttributedString);

    arc_super_dealloc();
}

+(NSAttributedString *)attributedStringFromMarkup:(NSString *)markup withFont:(_NSUIFont *)font andColor:(_NSUIColor *)color{
    RHMushParser *parser = arc_autorelease([[RHMushParser alloc] init]);
    parser.markup = markup;
    parser.baseColor = color;
    parser.baseFont = font;
    
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
    [UILabel instancesRespondToSelector:@selector(attributedText)] ? [parser parse] : [parser strip];
#else
    [parser parse];
#endif

    return [parser attributedString];
}

#pragma mark - parse
-(void)parse{
    if (!_baseColor) {
        NSLog(@"RHMushParser: Error: parse called with a nil baseColor. Bailing.");
        return;
    }

    if (!_baseFont) {
        NSLog(@"RHMushParser: Error: parse called with a nil baseFont. Bailing.");
        return;
    }

    //apply base colour and font
    id base = @{
                NSForegroundColorAttributeName:self.baseColor,
                NSFontAttributeName:self.baseFont,
                NSParagraphStyleAttributeName:NSParagraphStyle.defaultParagraphStyle
                };
    [_mutableAttributedString addAttributes:base range:NSMakeRange(0, _mutableAttributedString.length)];
    
    //perform parsing
    
    //bold
    [self _applyParserRegex:@"(\\*{2})(.+?)(\\*{2})"
           withReplacements:@[@"", @1, @""]
              andAttributes:@[@{}, @{ NSFontAttributeName:_boldFont }, @{}]];
    
    //italic
    [self _applyParserRegex:@"(/{2})(.+?)(/{2})"
           withReplacements:@[@"", @1, @""]
              andAttributes:@[@{}, @{ NSFontAttributeName:_italicFont }, @{}]];
    
    //underline
    [self _applyParserRegex:@"(_{2})(.+?)(_{2})"
           withReplacements:@[@"", @1, @""]
              andAttributes:@[@{}, @{ NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle) }, @{}]];
    
    //monospace
    if (!_monospaceFont) {
        [self _applyParserRegex:@"(`)(.+?)(`)"
               withReplacements:@[@"", @1, @""]
                  andAttributes:@[@{}, @{ NSFontAttributeName:_monospaceFont }, @{}]];
    } else {
        NSLog(@"RHMushParser: Error: parse called with a nil monospaceFont. Unable to render monospace text.");
    }

    //color
    [self _applyParserRegex:@"(\\{)(.+?)(\\|)(.+?)(\\})"
           withReplacements:@[@"", @"", @"", @3, @""]
              andAttributes:@[@{}, @{}, @{}, @[RHMushParserColorKey, @1], @{}]];
    
}

-(void)strip{
    //perform parsing
    
    //bold
    [self _applyParserRegex:@"(\\*{2})(.+?)(\\*{2})" withReplacements:@[@"", @1, @""] andAttributes:nil];
    
    //italic
    [self _applyParserRegex:@"(/{2})(.+?)(/{2})" withReplacements:@[@"", @1, @""] andAttributes:nil];
    
    //underline
    [self _applyParserRegex:@"(_{2})(.+?)(_{2})" withReplacements:@[@"", @1, @""] andAttributes:nil];
    
    //monospace
    [self _applyParserRegex:@"(`)(.+?)(`)" withReplacements:@[@"", @1, @""] andAttributes:nil];
    
    //color
    [self _applyParserRegex:@"(\\{)(.+?)(\\|)(.+?)(\\})" withReplacements:@[@"", @"", @"", @3, @""] andAttributes:nil];
    
}


/*
 GENERAL PARSER ARGS
 parserRegex = regex to use to match on, with various bracketed placeholders.
 parserReplacements = array of strings to replace an indexed match with, or if NSNumber the index of the match to use.
 parserAttributes = Attributes to apply to string for range of replaced text.
 parserReplacements.count && parserAttributes.count should both match the number of bracketed replacements in the regex.
 if parserAttributes is not included in the parser dictionary, no attributes will be added to the attributed string.
 if a parserAttributes item is an array, and the first value in said array is @"color", then the 2nd value should be
 an index to a matched string that is passed to RHColorFromHexString() and then applied as an attribute to the string.
 */

-(void)_applyParserRegex:(NSString *)parserRegex withReplacements:(NSArray*)parserReplacements andAttributes:(NSArray*)parserAttributes{
    //sanity check
    if (!parserRegex) return;
    if (!parserReplacements) return;
    if (parserAttributes && [parserAttributes count] != [parserReplacements count]) return;
    
    //regex
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:parserRegex options:0 error:nil];
    NSString *markup = [NSString stringWithString:_mutableAttributedString.string];
    
    
    //enumerate matches
    __block int nudge = 0;
    [regex enumerateMatchesInString:markup options:0 range:NSMakeRange(0, markup.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
        //fetch match substrings
        NSMutableArray *matchedAttributedStrings = [NSMutableArray array];
        for (NSUInteger i = 0; i < match.numberOfRanges - 1; i++) {
            NSRange nudged = [match rangeAtIndex:i + 1];
            nudged.location -= nudge;
            [matchedAttributedStrings addObject:arc_autorelease([[_mutableAttributedString attributedSubstringFromRange:nudged] mutableCopy])];
        }
        
        //make replacement substrings
        NSMutableArray *replacementAttributedStrings = [NSMutableArray array];
        for (NSUInteger i = 0; i < match.numberOfRanges - 1; i++) {
            
            //replacement is either an index, or a string
            id replacement = [parserReplacements objectAtIndex:i];
            if ([replacement isKindOfClass:NSNumber.class]){
                [replacementAttributedStrings addObject:[matchedAttributedStrings objectAtIndex:[replacement intValue]]];
            } else {
                [replacementAttributedStrings addObject:arc_autorelease([[NSMutableAttributedString alloc] initWithString:replacement])];
            }
        }
        
        //apply attributes
        for (NSUInteger i = 0; i < match.numberOfRanges - 1; i++) {
            id attributes = [parserAttributes objectAtIndex:i];
            
            //hard coded color parser
            if ([attributes isKindOfClass:[NSArray class]] && [attributes count] > 1 && [[attributes objectAtIndex:0] isEqualToString:RHMushParserColorKey] && [[attributes objectAtIndex:1] isKindOfClass:[NSNumber class]]) {
                NSMutableAttributedString *replacementString = [replacementAttributedStrings objectAtIndex:i];
                NSInteger index = [[attributes objectAtIndex:1] intValue];
                NSString *hexString = [[matchedAttributedStrings objectAtIndex:index] string];
                _NSUIColor *color = RHColorFromHexString(hexString);
                if (color){
                    attributes = @{NSForegroundColorAttributeName:color};
                    [replacementString addAttributes:attributes range:NSMakeRange(0, replacementString.length)];
                } else {
                    NSLog(@"RHMushParser: Error parsing color from hexString: '%@' with attributes: %@", hexString, attributes);
                }
                
            } else if ([attributes isKindOfClass:[NSDictionary class]]) {
                NSMutableAttributedString *replacementString = [replacementAttributedStrings objectAtIndex:i];
                [replacementString addAttributes:attributes range:NSMakeRange(0, replacementString.length)];
                
            } else {
                //nothing to do, key not included, or unknown type
            }
        }
        
        //replace
        for (NSUInteger i = 0; i < match.numberOfRanges - 1; i++) {
            NSRange nudged = [match rangeAtIndex:i + 1];
            nudged.location -= nudge;
            nudge += [[matchedAttributedStrings objectAtIndex:i] length] - [[replacementAttributedStrings objectAtIndex:i] length];
            [_mutableAttributedString replaceCharactersInRange:nudged withAttributedString:[replacementAttributedStrings objectAtIndex:i]];
        }
    }];
}


#pragma mark - setters
-(void)setMarkup:(NSString *)markup{
    if (_markup != markup){
        arc_release(_markup);
        arc_release(_mutableAttributedString);
        
        _markup = [markup copy];
        _mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:_markup];
    }
}

-(void)setBaseFont:(_NSUIFont *)font{
    if (_baseFont == font) return;
    
    arc_release(_baseFont);
    _baseFont = arc_retain(font);
    
    if (!_baseFont) return;
    
    //base font
    CGFloat size = [font pointSize];
    CTFontRef baseFontRef = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), size, NULL);
    
    //bold font
    CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(baseFontRef, 0, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    CFStringRef boldNameRef = CTFontCopyName(boldFontRef, kCTFontPostScriptNameKey);
    
    arc_release(_boldFont);
    _boldFont = arc_retain([_NSUIFont fontWithName:(__bridge NSString *)(boldNameRef) size:size] ?: font);
    
    //italic font
    CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(baseFontRef, 0, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    CFStringRef italicNameRef = CTFontCopyName(italicFontRef, kCTFontPostScriptNameKey);
    
    arc_release(_italicFont);
    _italicFont = arc_retain([_NSUIFont fontWithName:(__bridge NSString *)italicNameRef size:size] ?: font);
    
    arc_release(_monospaceFont);
    _monospaceFont = arc_retain([_NSUIFont fontWithName:@"Courier New" size:size]);
    
    if (baseFontRef) CFRelease(baseFontRef);
    if (boldFontRef) CFRelease(boldFontRef);
    if (italicFontRef) CFRelease(italicFontRef);
    if (boldNameRef) CFRelease(boldNameRef);
    if (italicNameRef) CFRelease(italicNameRef);
}

#pragma mark - getters
- (NSAttributedString *)attributedString {
    return arc_autorelease([_mutableAttributedString copy]);
}

@end


//create a color from a string, skipping any leading whitespace and and ignoring any trailing characters
_NSUIColor* RHColorFromHexString(NSString *string){
    NSString *clean = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:clean];
    unsigned hex = 0;
    if (![scanner scanHexInt:&hex]) return nil;
    
    //parse
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    //create
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
#else
    return [NSColor colorWithCalibratedRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
#endif
    
}


