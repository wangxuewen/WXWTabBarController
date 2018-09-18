//
//  UIControl+WXWTabBarControllerExtention.h
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (WXWTabBarControllerExtention)

- (UIView *)wxw_tabBadgeView;
- (UIImageView *)wxw_tabImageView;
- (UILabel *)wxw_tabLabel;

/*!
 * 调用该方法前已经添加了系统的角标，调用该方法后，系统的角标并未被移除，只是被隐藏，调用 `-wxw_removeTabBadgePoint` 后会重新展示。
 */
- (void)wxw_showTabBadgePoint;
- (void)wxw_removeTabBadgePoint;
- (BOOL)wxw_isShowTabBadgePoint;

@property (nonatomic, strong, setter=wxw_setTabBadgePointView:, getter=wxw_tabBadgePointView) UIView *wxw_tabBadgePointView;
@property (nonatomic, assign, setter=wxw_setTabBadgePointViewOffset:, getter=wxw_tabBadgePointViewOffset) UIOffset wxw_tabBadgePointViewOffset;

@end
