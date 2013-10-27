//
//  NSAlert+RHBlockAdditions.m
//  Screenie
//
//  Created by Richard Heard on 18/10/2013.
//  Copyright (c) 2013 Richard Heard. All rights reserved.
//

#import "NSAlert+RHBlockAdditions.h"

@implementation NSAlert (RHBlockAdditions)

-(void)rh_beginSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(RHModalResponse returnCode))handler{
    //use the provided block method if available
#if defined(MAC_OS_X_VERSION_10_9) && (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
    if ([self respondsToSelector:@selector(beginSheetModalForWindow:completionHandler:)]){
        [self beginSheetModalForWindow:sheetWindow completionHandler:handler];
        return;
    }
#endif
    
    [self beginSheetModalForWindow:sheetWindow modalDelegate:self didEndSelector:@selector(rh_alertDidEnd:returnCode:contextInfo:) contextInfo:(void *)CFBridgingRetain(handler)];
}

-(void)rh_alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (contextInfo){
        void (^completionBlock)(RHModalResponse returnCode) = CFBridgingRelease(contextInfo);
        completionBlock(returnCode);
    }
}

+(instancetype)rh_defaultAlertWithTitle:(NSString*)title{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [alert setMessageText:title];
    return arc_autorelease(alert);
}


@end
