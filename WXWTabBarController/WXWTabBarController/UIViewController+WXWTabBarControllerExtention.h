//
//  UIViewController+WXWTabBarControllerExtention.h
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WXWPopSelectTabBarChildViewControllerCompletion)(__kindof UIViewController *selectedTabBarChildViewController);

typedef void (^WXWPushOrPopCompletionHandler)(BOOL shouldPop,
                                              __kindof UIViewController *viewControllerPopTo,
                                              BOOL shouldPopSelectTabBarChildViewController,
                                              NSUInteger index
                                              );

typedef void (^WXWPushOrPopCallback)(NSArray<__kindof UIViewController *> *viewControllers, WXWPushOrPopCompletionHandler completionHandler);

@interface UIViewController (WXWTabBarControllerExtention)

@property (nonatomic, strong, setter=wxw_setTabBadgePointView:, getter=wxw_tabBadgePointView) UIView *wxw_tabBadgePointView;

@property (nonatomic, assign, setter=wxw_setTabBadgePointViewOffset:, getter=wxw_tabBadgePointViewOffset) UIOffset wxw_tabBadgePointViewOffset;

@property (nonatomic, readonly, getter=wxw_isEmbedInTabBarController) BOOL wxw_embedInTabBarController;

@property (nonatomic, readonly, getter=wxw_tabIndex) NSInteger wxw_tabIndex;

@property (nonatomic, readonly) UIControl *wxw_tabButton;

@property (nonatomic, copy, setter=wxw_setContext:, getter=wxw_context) NSString *wxw_context;

@property (nonatomic, assign, setter=wxw_setPlusViewControllerEverAdded:, getter=wxw_plusViewControllerEverAdded) BOOL wxw_plusViewControllerEverAdded;

/*!
 * @attention
 - 调用该方法前已经添加了系统的角标，调用该方法后，系统的角标并未被移除，只是被隐藏，调用 `-wxw_removeTabBadgePoint` 后会重新展示。
 - 不支持 WXWPlusChildViewController 对应的 TabBarItem 角标设置，调用会被忽略。
 */
- (void)wxw_showTabBadgePoint;

- (void)wxw_removeTabBadgePoint;

- (BOOL)wxw_isShowTabBadgePoint;

/*!
 * Pop 到当前 `NavigationController` 的栈底，并改变 `TabBarController` 的 `selectedViewController` 属性，并将被选择的控制器作为返回值返回。
 @param index 需要选择的控制器在 `TabBar` 中的 index。
 @return 最终被选择的控制器。
 @attention 注意：方法中的参数和返回值都是 `UIViewController` 的子类，但并非 `UINavigationController` 的子类，该方法无 pop 动画。
 */
- (UIViewController *)wxw_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index;

/*!
 * Pop 到当前 `NavigationController` 的栈底，并改变 `TabBarController` 的 `selectedViewController` 属性，并将被选择的控制器作为返回值返回。
 @param index 需要选择的控制器在 `TabBar` 中的 index。
 @param animated 动画
 @return 最终被选择的控制器。
 @attention 注意：方法中的参数和返回值都是 `UIViewController` 的子类，但并非 `UINavigationController` 的子类。
 */
- (UIViewController *)wxw_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

/*!
 * Pop 到当前 `NavigationController` 的栈底，并改变 `TabBarController` 的 `selectedViewController` 属性，并将被选择的控制器在 `Block` 回调中返回。
 @param index 需要选择的控制器在 `TabBar` 中的 index。
 @attention 注意：方法中的参数和返回值都是 `UIViewController` 的子类，但并非 `UINavigationController` 的子类。
 */
- (void)wxw_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index
                                           completion:(WXWPopSelectTabBarChildViewControllerCompletion)completion;

/*!
 * Pop 到当前 `NavigationController` 的栈底，并改变 `TabBarController` 的 `selectedViewController` 属性，并将被选择的控制器作为返回值返回。
 @param classType 需要选择的控制器所属的类。
 @return 最终被选择的控制器。
 @attention 注意：
 - 方法中的参数和返回值都是 `UIViewController` 的子类，但并非 `UINavigationController` 的子类。
 - 如果 TabBarViewController 的 viewControllers 中包含多个相同的 `classType` 类型，会返回最左端的一个。
 
 */
- (UIViewController *)wxw_popSelectTabBarChildViewControllerForClassType:(Class)classType;

/*!
 * Pop 到当前 `NavigationController` 的栈底，并改变 `TabBarController` 的 `selectedViewController` 属性，并将被选择的控制器在 `Block` 回调中返回。
 @param classType 需要选择的控制器所属的类。
 @attention 注意：
 - 方法中的参数和返回值都是 `UIViewController` 的子类，但并非 `UINavigationController` 的子类。
 - 如果 TabBarViewController 的 viewControllers 中包含多个相同的 `classType` 类型，会返回最左端的一个。
 */
- (void)wxw_popSelectTabBarChildViewControllerForClassType:(Class)classType
                                                completion:(WXWPopSelectTabBarChildViewControllerCompletion)completion;

/*!
 *@brief 如果当前的 `NavigationViewController` 栈中包含有准备 Push 到的目标控制器，可以选择 Pop 而非 Push。
 *@param viewController Pop 或 Push 到的“目标控制器”，由 completionHandler 的参数控制 Pop 和 Push 的细节。
 *@param animated Pop 或 Push 时是否带动画
 *@param callback 回调，如果传 nil，将进行 Push。callback 包含以下几个参数：
 * param : viewControllers 表示与“目标控制器”相同类型的控制器；
 * param : completionHandler 包含以下几个参数：
 * param : shouldPop 是否 Pop
 * param : viewControllerPopTo Pop 回的控制器
 * param : shouldPopSelectTabBarChildViewController 在进行 Push 行为之前，是否 Pop 到当前 `NavigationController` 的栈底。
 可能的值如下：
 NO 如果上一个参数为 NO，下一个参数 index 将被忽略。
 YES 会根据 index 参数改变 `TabBarController` 的 `selectedViewController` 属性。
 注意：该属性在 Pop 行为时不起作用。
 * param : index Pop 改变 `TabBarController` 的 `selectedViewController` 属性。
 注意：该属性在 Pop 行为时不起作用。
 */
- (void)wxw_pushOrPopToViewController:(UIViewController *)viewController
                             animated:(BOOL)animated
                             callback:(WXWPushOrPopCallback)callback;

/*!
 * 如果正要 Push 的页面与当前栈顶的页面类型相同则取消 Push
 * 这样做防止主界面卡顿时，导致一个 ViewController 被 Push 多次
 */
- (void)wxw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)wxw_getViewControllerInsteadOfNavigationController;

@end
