//
//  NSAlert+RHBlockAdditions.h
//  Screenie
//
//  Created by Richard Heard on 18/10/2013.
//  Copyright (c) 2013 Richard Heard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NSInteger RHModalResponse;

@interface NSAlert (RHBlockAdditions)

-(void)rh_beginSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(RHModalResponse returnCode))handler;

+(instancetype)rh_defaultAlertWithTitle:(NSString*)title; //NSAlertFirstButtonReturn == OK NSAlertSecondButtonReturn == Cancel

@end
