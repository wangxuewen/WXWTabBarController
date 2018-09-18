//
//  UITabBarItem+WXWTabBarControllerExtention.m
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "UITabBarItem+WXWTabBarControllerExtention.h"
#import "UIControl+WXWTabBarControllerExtention.h"
#import <objc/runtime.h>

@implementation UITabBarItem (WXWTabBarControllerExtention)

+ (void)load {
    [self wxw_swizzleSetBadgeValue];
}

+ (void)wxw_swizzleSetBadgeValue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wxw_ClassMethodSwizzle([self class], @selector(setBadgeValue:), @selector(wxw_setBadgeValue:));
    });
}

- (void)wxw_setBadgeValue:(NSString *)badgeValue {
    [self.wxw_tabButton wxw_removeTabBadgePoint];
    [self wxw_setBadgeValue:badgeValue];
}

- (UIControl *)wxw_tabButton {
    UIControl *control = [self valueForKey:@"view"];
    return control;
}

#pragma mark - private method

BOOL wxw_ClassMethodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector) {
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
    BOOL didAddMethod =
    class_addMethod(aClass,
                    originalSelector,
                    method_getImplementation(swizzleMethod),
                    method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    return YES;
}


@end
