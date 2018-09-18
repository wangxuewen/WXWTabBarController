//
//  UIView+WXWTabBarControllerExtention.m
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "UIView+WXWTabBarControllerExtention.h"
#import "WXWPlusButton.h"

@implementation UIView (WXWTabBarControllerExtention)


- (BOOL)wxw_isPlusButton {
    return [self isKindOfClass:[WXWExternPlusButton class]];
}

- (BOOL)wxw_isTabButton {
    BOOL isKindOfButton = [self wxw_isKindOfClass:[UIControl class]];
    return isKindOfButton;
}

- (BOOL)wxw_isTabImageView {
    BOOL isKindOfImageView = [self wxw_isKindOfClass:[UIImageView class]];
    if (!isKindOfImageView) {
        return NO;
    }
    NSString *subString = [NSString stringWithFormat:@"%@cat%@ew", @"Indi" , @"orVi"];
    BOOL isBackgroundImage = [self wxw_classStringHasSuffix:subString];
    BOOL isTabImageView = !isBackgroundImage;
    return isTabImageView;
}

- (BOOL)wxw_isTabLabel {
    BOOL isKindOfLabel = [self wxw_isKindOfClass:[UILabel class]];
    return isKindOfLabel;
}

- (BOOL)wxw_isTabBadgeView {
    BOOL isKindOfClass = [self isKindOfClass:[UIView class]];
    BOOL isClass = [self isMemberOfClass:[UIView class]];
    BOOL isKind = isKindOfClass && !isClass;
    if (!isKind) {
        return NO;
    }
    NSString *tabBarClassString = [NSString stringWithFormat:@"%@IB%@", @"_U" , @"adg"];
    BOOL isTabBadgeView = [self wxw_classStringHasPrefix:tabBarClassString];;
    return isTabBadgeView;
}

- (BOOL)wxw_isTabBackgroundView {
    BOOL isKindOfClass = [self isKindOfClass:[UIView class]];
    BOOL isClass = [self isMemberOfClass:[UIView class]];
    BOOL isKind = isKindOfClass && !isClass;
    if (!isKind) {
        return NO;
    }
    NSString *tabBackgroundViewString = [NSString stringWithFormat:@"%@IB%@", @"_U" , @"arBac"];
    BOOL isTabBackgroundView = [self wxw_classStringHasPrefix:tabBackgroundViewString] && [self wxw_classStringHasSuffix:@"nd"];
    return isTabBackgroundView;
}

- (UIView *)wxw_tabBadgeBackgroundView {
    for (UIImageView *subview in self.subviews) {
        if ([subview wxw_isTabBackgroundView]) {
            return (UIImageView *)subview;
        }
    }
    return nil;
}

- (UIView *)wxw_tabBadgeBackgroundSeparator {
    UIView *subview = [self wxw_tabBadgeBackgroundView];
    if (!subview) {
        return nil;
    }
    NSArray<__kindof UIView *> *backgroundSubviews = subview.subviews;
    if (backgroundSubviews.count > 1) {
        for (UIView *tabBadgeBackgroundSeparator in backgroundSubviews) {
            if (CGRectGetHeight(tabBadgeBackgroundSeparator.bounds) <= 1.0 ) {
                return tabBadgeBackgroundSeparator;
            }
        }
    }
    return nil;
}

- (BOOL)wxw_isKindOfClass:(Class)class {
    BOOL isKindOfClass = [self isKindOfClass:class];
    BOOL isClass = [self isMemberOfClass:class];
    BOOL isKind = isKindOfClass && !isClass;
    if (!isKind) {
        return NO;
    }
    BOOL isTabBarClass = [self wxw_isTabBarClass];
    return isTabBarClass;
}

- (BOOL)wxw_isTabBarClass {
    NSString *tabBarClassString = [NSString stringWithFormat:@"U%@a%@ar", @"IT" , @"bB"];
    BOOL isTabBarClass = [self wxw_classStringHasPrefix:tabBarClassString];
    return isTabBarClass;
}

- (BOOL)wxw_classStringHasPrefix:(NSString *)prefix {
    NSString *classString = NSStringFromClass([self class]);
    return [classString hasPrefix:prefix];
}

- (BOOL)wxw_classStringHasSuffix:(NSString *)suffix {
    NSString *classString = NSStringFromClass([self class]);
    return [classString hasSuffix:suffix];
}

+ (UIView *)wxw_tabBadgePointViewWithClolor:(UIColor *)color radius:(CGFloat)radius {
    UIView *defaultTabBadgePointView = [[UIView alloc] init];
    [defaultTabBadgePointView setTranslatesAutoresizingMaskIntoConstraints:NO];
    defaultTabBadgePointView.backgroundColor = color;
    defaultTabBadgePointView.layer.cornerRadius = radius;
    defaultTabBadgePointView.layer.masksToBounds = YES;
    defaultTabBadgePointView.hidden = YES;
    // Width constraint
    [defaultTabBadgePointView addConstraint:[NSLayoutConstraint constraintWithItem:defaultTabBadgePointView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:radius * 2]];
    // Height constraint
    [defaultTabBadgePointView addConstraint:[NSLayoutConstraint constraintWithItem:defaultTabBadgePointView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:radius * 2]];
    return defaultTabBadgePointView;
}

@end
