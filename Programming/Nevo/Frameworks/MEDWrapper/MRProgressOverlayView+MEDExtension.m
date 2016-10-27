//
//  MRProgressOverlayView+MEDExtension.m
//  Nevo
//
//  Created by Quentin on 27/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

#import "MRProgressOverlayView+MEDExtension.h"
#import "objc/runtime.h"
#import "Nevo-Swift.h"

@implementation MRProgressOverlayView (MEDExtension)

+ (void)load {
    Method new = class_getClassMethod(self, @selector(MEDShowOverlayAddedTo: title: mode: animated:));
    Method old = class_getClassMethod(self, @selector(showOverlayAddedTo: title: mode: animated:));
    method_exchangeImplementations(new, old);
}

+ (instancetype)MEDShowOverlayAddedTo:(UIView *)view title:(NSString *)title mode:(MRProgressOverlayViewMode)mode animated:(BOOL)animated {
    MRProgressOverlayView *newView = [MRProgressOverlayView MEDShowOverlayAddedTo:view title:title mode:mode animated:animated];
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    NSString *appName = infoDict[@"CFBundleName"];
    if ([appName isEqual: @"LunaR"]) {
        newView.titleLabel.textColor = [UIColor whiteColor];
        UIView *subview = [[UIView alloc] init];
        for (subview in newView.subviews) {
            subview.backgroundColor = [UIColor getGreyColor];
        }
    }
    return newView;
}

@end


