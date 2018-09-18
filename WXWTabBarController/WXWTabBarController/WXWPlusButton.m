//
//  WXWPlusButton.m
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "WXWPlusButton.h"
#import "WXWTabBarController.h"
#import "UIViewController+WXWTabBarControllerExtention.h"

CGFloat WXWPlusButtonWidth = 0.0f;
UIButton<WXWPlusButtonSubclassing> *WXWExternPlusButton = nil;
UIViewController *WXWPlusChildViewController = nil;

@implementation WXWPlusButton

#pragma mark -
#pragma mark - public Methods

+ (void)registerPlusButton {
    if (![self conformsToProtocol:@protocol(WXWPlusButtonSubclassing)]) {
        return;
    }
    Class<WXWPlusButtonSubclassing> class = self;
    UIButton<WXWPlusButtonSubclassing> *plusButton = [class plusButton];
    WXWExternPlusButton = plusButton;
    WXWPlusButtonWidth = plusButton.frame.size.width;
    if ([[self class] respondsToSelector:@selector(plusChildViewController)]) {
        WXWPlusChildViewController = [class plusChildViewController];
        if ([[self class] respondsToSelector:@selector(tabBarContext)]) {
            NSString *tabBarContext = [class tabBarContext];
            if (tabBarContext && tabBarContext.length) {
                [WXWPlusChildViewController wxw_setContext:tabBarContext];
            }
        } else {
            [WXWPlusChildViewController wxw_setContext:NSStringFromClass([WXWTabBarController class])];
        }
        [[self class] addSelectViewControllerTarget:plusButton];
        if ([[self class] respondsToSelector:@selector(indexOfPlusButtonInTabBar)]) {
            WXWPlusButtonIndex = [[self class] indexOfPlusButtonInTabBar];
        } else {
            [NSException raise:NSStringFromClass([WXWTabBarController class]) format:@"If you want to add PlusChildViewController, you must realizse `+indexOfPlusButtonInTabBar` in your custom plusButton class.【Chinese】如果你想使用PlusChildViewController样式，你必须同时在你自定义的plusButton中实现 `+indexOfPlusButtonInTabBar`，来指定plusButton的位置"];
        }
    }
}

//+ (NSUInteger)indexOfPlusButtonInTabBar {
//    return 1;
//}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)registerSubclass {
    [self registerPlusButton];
}
#pragma clang diagnostic pop

- (void)plusChildViewControllerButtonClicked:(UIButton<WXWPlusButtonSubclassing> *)sender {
    BOOL notNeedConfigureSelectionStatus = [[self class] respondsToSelector:@selector(shouldSelectPlusChildViewController)] && ![[self class] shouldSelectPlusChildViewController];
    if (notNeedConfigureSelectionStatus) {
        return;
    }
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    WXWTabBarController *tabBarController = [sender wxw_tabBarController];
    NSInteger index = [tabBarController.viewControllers indexOfObject:WXWPlusChildViewController];
    @try {
        [tabBarController setSelectedIndex:index];
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception);
    }
}

#pragma mark -
#pragma mark - Private Methods

+ (void)addSelectViewControllerTarget:(UIButton<WXWPlusButtonSubclassing> *)plusButton {
    id target = self;
    NSArray<NSString *> *selectorNamesArray = [plusButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    if (selectorNamesArray.count == 0) {
        target = plusButton;
        selectorNamesArray = [plusButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    }
    [selectorNamesArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector =  NSSelectorFromString(obj);
        [plusButton removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }];
    [plusButton addTarget:plusButton action:@selector(plusChildViewControllerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  按钮选中状态下点击先显示normal状态的颜色，松开时再回到selected状态下颜色。
 *  重写此方法即不会出现上述情况，与 UITabBarButton 相似
 */
- (void)setHighlighted:(BOOL)highlighted {}


@end
