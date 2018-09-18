//
//  UIControl+WXWTabBarControllerExtention.m
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "UIControl+WXWTabBarControllerExtention.h"
#import "UIView+WXWTabBarControllerExtention.h"
#import <objc/runtime.h>
#import "WXWConstants.h"

@implementation UIControl (WXWTabBarControllerExtention)

- (void)wxw_showTabBadgePoint {
    [self wxw_setShowTabBadgePointIfNeeded:YES];
}

- (void)wxw_removeTabBadgePoint {
    [self wxw_setShowTabBadgePointIfNeeded:NO];
}

- (BOOL)wxw_isShowTabBadgePoint {
    return !self.wxw_tabBadgePointView.hidden;
}

- (void)wxw_setShowTabBadgePointIfNeeded:(BOOL)showTabBadgePoint {
    @try {
        [self wxw_setShowTabBadgePoint:showTabBadgePoint];
    } @catch (NSException *exception) {
        NSLog(@"WXWPlusChildViewController do not support set TabBarItem red point");
    }
}

- (void)wxw_setShowTabBadgePoint:(BOOL)showTabBadgePoint {
    if (showTabBadgePoint && self.wxw_tabBadgePointView.superview == nil) {
        [self addSubview:self.wxw_tabBadgePointView];
        [self bringSubviewToFront:self.wxw_tabBadgePointView];
        self.wxw_tabBadgePointView.layer.zPosition = MAXFLOAT;
        // X constraint
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self.wxw_tabBadgePointView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:0
                                         toItem:self.wxw_tabImageView
                                      attribute:NSLayoutAttributeRight
                                     multiplier:1
                                       constant:self.wxw_tabBadgePointViewOffset.horizontal]];
        //Y constraint
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self.wxw_tabBadgePointView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:0
                                         toItem:self.wxw_tabImageView
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1
                                       constant:self.wxw_tabBadgePointViewOffset.vertical]];
    }
    self.wxw_tabBadgePointView.hidden = showTabBadgePoint == NO;
    self.wxw_tabBadgeView.hidden = showTabBadgePoint == YES;
}

- (void)wxw_setTabBadgePointView:(UIView *)tabBadgePointView {
    UIView *tempView = objc_getAssociatedObject(self, @selector(wxw_tabBadgePointView));
    if (tempView) {
        [tempView removeFromSuperview];
    }
    if (tabBadgePointView.superview) {
        [tabBadgePointView removeFromSuperview];
    }
    
    tabBadgePointView.hidden = YES;
    objc_setAssociatedObject(self, @selector(wxw_tabBadgePointView), tabBadgePointView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)wxw_tabBadgePointView {
    UIView *tabBadgePointView = objc_getAssociatedObject(self, @selector(wxw_tabBadgePointView));
    
    if (tabBadgePointView == nil) {
        tabBadgePointView = self.wxw_defaultTabBadgePointView;
        objc_setAssociatedObject(self, @selector(wxw_tabBadgePointView), tabBadgePointView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tabBadgePointView;
}

- (void)wxw_setTabBadgePointViewOffset:(UIOffset)tabBadgePointViewOffset {
    objc_setAssociatedObject(self, @selector(wxw_tabBadgePointViewOffset), [NSValue valueWithUIOffset:tabBadgePointViewOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//offset如果都是正数，则往右下偏移
- (UIOffset)wxw_tabBadgePointViewOffset {
    id tabBadgePointViewOffsetObject = objc_getAssociatedObject(self, @selector(wxw_tabBadgePointViewOffset));
    UIOffset tabBadgePointViewOffset = [tabBadgePointViewOffsetObject UIOffsetValue];
    return tabBadgePointViewOffset;
}

- (UIView *)wxw_tabBadgeView {
    for (UIView *subview in self.subviews) {
        if ([subview wxw_isTabBadgeView]) {
            return (UIView *)subview;
        }
    }
    return nil;
}

- (UIImageView *)wxw_tabImageView {
    for (UIImageView *subview in self.subviews) {
        if ([subview wxw_isTabImageView]) {
            return (UIImageView *)subview;
        }
    }
    return nil;
}

- (UILabel *)wxw_tabLabel {
    for (UILabel *subview in self.subviews) {
        if ([subview wxw_isTabLabel]) {
            return (UILabel *)subview;
        }
    }
    return nil;
}

#pragma mark - private method

- (UIView *)wxw_defaultTabBadgePointView {
    UIView *defaultRedTabBadgePointView = [UIView wxw_tabBadgePointViewWithClolor:[UIColor redColor] radius:4.5];
    return defaultRedTabBadgePointView;
}

@end
