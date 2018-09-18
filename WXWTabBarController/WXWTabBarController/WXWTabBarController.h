//
//  WXWTabBarController.h
//  WXWTabBarController
//
//  Created by administrator on 2018/8/24.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWPlusButton.h"
#import "UIViewController+WXWTabBarControllerExtention.h"
#import "UIView+WXWTabBarControllerExtention.h"
#import "UITabBarItem+WXWTabBarControllerExtention.h"
#import "UIControl+WXWTabBarControllerExtention.h"

@class WXWTabBarController;
typedef void(^WXWViewDidLayoutSubViewsBlock)(WXWTabBarController *tabBarController);

FOUNDATION_EXTERN NSString *const WXWTabBarItemTitle;
FOUNDATION_EXTERN NSString *const WXWTabBarItemImage;
FOUNDATION_EXTERN NSString *const WXWTabBarItemSelectedImage;
FOUNDATION_EXTERN NSString *const WXWTabBarItemImageInsets;
FOUNDATION_EXTERN NSString *const WXWTabBarItemTitlePositionAdjustment;
FOUNDATION_EXTERN NSUInteger WXWTabbarItemsCount;
FOUNDATION_EXTERN NSUInteger WXWPlusButtonIndex;
FOUNDATION_EXTERN CGFloat WXWPlusButtonWidth;
FOUNDATION_EXTERN CGFloat WXWTabBarItemWidth;
FOUNDATION_EXTERN NSString *const WXWTabBarItemWidthDidChangeNotification;

@protocol WXWTabBarControllerDelegate <NSObject>
@optional
/*!
 * @param tabBarController The tab bar controller containing viewController.
 * @param control Selected UIControl in TabBar.
 */
- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control;

@end

@interface WXWTabBarController : UITabBarController <WXWTabBarControllerDelegate>

@property (nonatomic, copy) WXWViewDidLayoutSubViewsBlock viewDidLayoutSubviewsBlock;

- (void)setViewDidLayoutSubViewsBlock:(WXWViewDidLayoutSubViewsBlock)viewDidLayoutSubviewsBlock;

/*!
 * An array of the root view controllers displayed by the tab bar interface.
 */
@property (nonatomic, readwrite, copy) NSArray<UIViewController *> *viewControllers;

/*!
 * The Attributes of items which is displayed on the tab bar.
 */
@property (nonatomic, readwrite, copy) NSArray<NSDictionary *> *tabBarItemsAttributes;

/*!
 * Customize UITabBar height
 */
@property (nonatomic, assign) CGFloat tabBarHeight;

/*!
 * To set both UIBarItem image view attributes in the tabBar,
 * default is UIEdgeInsetsZero.
 */
@property (nonatomic, readonly, assign) UIEdgeInsets imageInsets;

/*!
 * To set both UIBarItem label text attributes in the tabBar,
 * use the following to tweak the relative position of the label within the tab button (for handling visual centering corrections if needed because of custom text attributes)
 */
@property (nonatomic, readonly, assign) UIOffset titlePositionAdjustment;

@property (nonatomic, readonly, copy) NSString *context;

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes;

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes;

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment;

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment;

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                context:(NSString *)context;

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                            context:(NSString *)context;


- (void)updateSelectionStatusIfNeededForTabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

- (void)hideTabBadgeBackgroundSeparator;

- (void)setTintColor:(UIColor *)tintColor;

/*!
 * Judge if there is plus button.
 */
+ (BOOL)havePlusButton;

/*!
 * @attention Include plusButton if exists.
 */
+ (NSUInteger)allItemsInTabBarCount;

- (id<UIApplicationDelegate>)appDelegate;

- (UIWindow *)rootWindow;


@end

@interface NSObject (WXWTabBarControllerReferenceExtension)

/*!
 * If `self` is kind of `UIViewController`, this method will return the nearest ancestor in the view controller hierarchy that is a tab bar controller. If `self` is not kind of `UIViewController`, it will return the `rootViewController` of the `rootWindow` as long as you have set the `WXWTabBarController` as the  `rootViewController`. Otherwise return nil. (read-only)
 */
@property (nonatomic, setter=wxw_setTabBarController:) WXWTabBarController *wxw_tabBarController;

@end

FOUNDATION_EXTERN NSString *const WXWTabBarItemWidthDidChangeNotification;

