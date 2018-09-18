//
//  UIView+WXWTabBarControllerExtention.h
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WXWTabBarControllerExtention)

- (BOOL)wxw_isPlusButton;
- (BOOL)wxw_isTabButton;
- (BOOL)wxw_isTabImageView;
- (BOOL)wxw_isTabLabel;
- (BOOL)wxw_isTabBadgeView;
- (BOOL)wxw_isTabBackgroundView;
- (UIView *)wxw_tabBadgeBackgroundView;
- (UIView *)wxw_tabBadgeBackgroundSeparator;

+ (UIView *)wxw_tabBadgePointViewWithClolor:(UIColor *)color radius:(CGFloat)radius;

@end
