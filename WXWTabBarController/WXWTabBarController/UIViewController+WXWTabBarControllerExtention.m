//
//  UIViewController+WXWTabBarControllerExtention.m
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "UIViewController+WXWTabBarControllerExtention.h"
#import "WXWTabBarController.h"
#import <objc/runtime.h>

@implementation UIViewController (WXWTabBarControllerExtention)

#pragma mark -
#pragma mark - public Methods

- (UIViewController *)wxw_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index {
    return [self wxw_popSelectTabBarChildViewControllerAtIndex:index animated:NO];
}

- (UIViewController *)wxw_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated {
    UIViewController *viewController = [self wxw_getViewControllerInsteadOfNavigationController];
    [viewController checkTabBarChildControllerValidityAtIndex:index];
    WXWTabBarController *tabBarController = [viewController wxw_tabBarController];
    tabBarController.selectedIndex = index;
    [viewController.navigationController popToRootViewControllerAnimated:animated];
    UIViewController *selectedTabBarChildViewController = tabBarController.selectedViewController;
    return [selectedTabBarChildViewController wxw_getViewControllerInsteadOfNavigationController];
}

- (void)wxw_popSelectTabBarChildViewControllerAtIndex:(NSUInteger)index
                                           completion:(WXWPopSelectTabBarChildViewControllerCompletion)completion {
    UIViewController *selectedTabBarChildViewController = [self wxw_popSelectTabBarChildViewControllerAtIndex:index];
    dispatch_async(dispatch_get_main_queue(), ^{
        !completion ?: completion(selectedTabBarChildViewController);
    });
}

- (UIViewController *)wxw_popSelectTabBarChildViewControllerForClassType:(Class)classType {
    WXWTabBarController *tabBarController = [[self wxw_getViewControllerInsteadOfNavigationController] wxw_tabBarController];
    NSArray *viewControllers = tabBarController.viewControllers;
    NSInteger atIndex = [self wxw_indexForClassType:classType inViewControllers:viewControllers];
    return [self wxw_popSelectTabBarChildViewControllerAtIndex:atIndex];
}

- (void)wxw_popSelectTabBarChildViewControllerForClassType:(Class)classType
                                                completion:(WXWPopSelectTabBarChildViewControllerCompletion)completion {
    UIViewController *selectedTabBarChildViewController = [self wxw_popSelectTabBarChildViewControllerForClassType:classType];
    dispatch_async(dispatch_get_main_queue(), ^{
        !completion ?: completion(selectedTabBarChildViewController);
    });
}

- (void)wxw_pushOrPopToViewController:(UIViewController *)viewController
                             animated:(BOOL)animated
                             callback:(WXWPushOrPopCallback)callback {
    if (!callback) {
        [self.navigationController pushViewController:viewController animated:animated];
        return;
    }
    
    void (^popSelectTabBarChildViewControllerCallback)(BOOL shouldPopSelectTabBarChildViewController, NSUInteger index) = ^(BOOL shouldPopSelectTabBarChildViewController, NSUInteger index) {
        if (shouldPopSelectTabBarChildViewController) {
            [self wxw_popSelectTabBarChildViewControllerAtIndex:index completion:^(__kindof UIViewController *selectedTabBarChildViewController) {
                [selectedTabBarChildViewController.navigationController pushViewController:viewController animated:animated];
            }];
        } else {
            [self.navigationController pushViewController:viewController animated:animated];
        }
    };
    NSArray<__kindof UIViewController *> *otherSameClassTypeViewControllersInCurrentNavigationControllerStack = [self wxw_getOtherSameClassTypeViewControllersInCurrentNavigationControllerStack:viewController];
    
    WXWPushOrPopCompletionHandler completionHandler = ^(BOOL shouldPop,
                                                        __kindof UIViewController *viewControllerPopTo,
                                                        BOOL shouldPopSelectTabBarChildViewController,
                                                        NSUInteger index
                                                        ) {
        if (!otherSameClassTypeViewControllersInCurrentNavigationControllerStack || otherSameClassTypeViewControllersInCurrentNavigationControllerStack.count == 0) {
            shouldPop = NO;
        }
        dispatch_async(dispatch_get_main_queue(),^{
            if (shouldPop) {
                [self.navigationController popToViewController:viewControllerPopTo animated:animated];
                return;
            }
            popSelectTabBarChildViewControllerCallback(shouldPopSelectTabBarChildViewController, index);
        });
    };
    callback(otherSameClassTypeViewControllersInCurrentNavigationControllerStack, completionHandler);
}

- (void)wxw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *fromViewController = [self wxw_getViewControllerInsteadOfNavigationController];
    NSArray *childViewControllers = fromViewController.navigationController.childViewControllers;
    if (childViewControllers.count > 0) {
        if ([[childViewControllers lastObject] isKindOfClass:[viewController class]]) {
            return;
        }
    }
    [fromViewController.navigationController pushViewController:viewController animated:animated];
}

- (UIViewController *)wxw_getViewControllerInsteadOfNavigationController {
    BOOL isNavigationController = [[self class] isSubclassOfClass:[UINavigationController class]];
    if (isNavigationController && ((UINavigationController *)self).viewControllers.count > 0) {
        return ((UINavigationController *)self).viewControllers[0];
    }
    return self;
}

#pragma mark - public method

- (BOOL)wxw_isPlusChildViewController {
    if (!WXWPlusChildViewController) {
        return NO;
    }
    return (self == WXWPlusChildViewController);
}

- (void)wxw_showTabBadgePoint {
    if (self.wxw_isPlusChildViewController) {
        return;
    }
    [self.wxw_tabButton wxw_showTabBadgePoint];
    [[[self wxw_getViewControllerInsteadOfNavigationController] wxw_tabBarController].tabBar layoutIfNeeded];
}

- (void)wxw_removeTabBadgePoint {
    if (self.wxw_isPlusChildViewController) {
        return;
    }
    [self.wxw_tabButton wxw_removeTabBadgePoint];
    [[[self wxw_getViewControllerInsteadOfNavigationController] wxw_tabBarController].tabBar layoutIfNeeded];
}

- (BOOL)wxw_isShowTabBadgePoint {
    if (self.wxw_isPlusChildViewController) {
        return NO;
    }
    return [self.wxw_tabButton wxw_isShowTabBadgePoint];
}

- (void)wxw_setTabBadgePointView:(UIView *)tabBadgePointView {
    if (self.wxw_isPlusChildViewController) {
        return;
    }
    [self.wxw_tabButton wxw_setTabBadgePointView:tabBadgePointView];
}

- (UIView *)wxw_tabBadgePointView {
    if (self.wxw_isPlusChildViewController) {
        return nil;
    }
    return [self.wxw_tabButton wxw_tabBadgePointView];;
}

- (void)wxw_setTabBadgePointViewOffset:(UIOffset)tabBadgePointViewOffset {
    if (self.wxw_isPlusChildViewController) {
        return;
    }
    return [self.wxw_tabButton wxw_setTabBadgePointViewOffset:tabBadgePointViewOffset];
}

//offset如果都是整数，则往右下偏移
- (UIOffset)wxw_tabBadgePointViewOffset {
    if (self.wxw_isPlusChildViewController) {
        return UIOffsetZero;
    }
    return [self.wxw_tabButton wxw_tabBadgePointViewOffset];
}

- (BOOL)wxw_isEmbedInTabBarController {
    if (self.wxw_tabBarController == nil) {
        return NO;
    }
    if (self.wxw_isPlusChildViewController) {
        return NO;
    }
    BOOL isEmbedInTabBarController = NO;
    UIViewController *viewControllerInsteadIOfNavigationController = [self wxw_getViewControllerInsteadOfNavigationController];
    for (NSInteger i = 0; i < self.wxw_tabBarController.viewControllers.count; i++) {
        UIViewController * vc = self.wxw_tabBarController.viewControllers[i];
        if ([vc wxw_getViewControllerInsteadOfNavigationController] == viewControllerInsteadIOfNavigationController) {
            isEmbedInTabBarController = YES;
            [self wxw_setTabIndex:i];
            break;
        }
    }
    return isEmbedInTabBarController;
}

- (void)wxw_setTabIndex:(NSInteger)tabIndex {
    objc_setAssociatedObject(self, @selector(wxw_tabIndex), @(tabIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)wxw_tabIndex {
    if (!self.wxw_isEmbedInTabBarController) {
        return NSNotFound;
    }
    
    id tabIndexObject = objc_getAssociatedObject(self, @selector(wxw_tabIndex));
    NSInteger tabIndex = [tabIndexObject integerValue];
    return tabIndex;
}

- (UIControl *)wxw_tabButton {
    if (!self.wxw_isEmbedInTabBarController) {
        return nil;
    }
    UITabBarItem *tabBarItem;
    UIControl *control;
    @try {
        tabBarItem = self.wxw_tabBarController.tabBar.items[self.wxw_tabIndex];
        control = [tabBarItem wxw_tabButton];
    } @catch (NSException *exception) {}
    return control;
}

- (NSString *)wxw_context {
    return objc_getAssociatedObject(self, @selector(wxw_context));
}

- (void)wxw_setContext:(NSString *)wxw_context {
    objc_setAssociatedObject(self, @selector(wxw_context), wxw_context, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)wxw_plusViewControllerEverAdded {
    NSNumber *wxw_plusViewControllerEverAddedObject = objc_getAssociatedObject(self, @selector(wxw_plusViewControllerEverAdded));
    return [wxw_plusViewControllerEverAddedObject boolValue];
}

- (void)wxw_setPlusViewControllerEverAdded:(BOOL)wxw_plusViewControllerEverAdded {
    NSNumber *wxw_plusViewControllerEverAddedObject = [NSNumber numberWithBool:wxw_plusViewControllerEverAdded];
    objc_setAssociatedObject(self, @selector(wxw_plusViewControllerEverAdded), wxw_plusViewControllerEverAddedObject, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark -
#pragma mark - Private Methods

- (NSArray<__kindof UIViewController *> *)wxw_getOtherSameClassTypeViewControllersInCurrentNavigationControllerStack:(UIViewController *)viewController {
    NSArray *currentNavigationControllerStack = [self.navigationController childViewControllers];
    if (currentNavigationControllerStack.count < 2) {
        return nil;
    }
    NSMutableArray *mutableArray = [currentNavigationControllerStack mutableCopy];
    [mutableArray removeObject:self];
    currentNavigationControllerStack = [mutableArray copy];
    
    __block NSMutableArray *mutableOtherViewControllersInNavigationControllerStack = [NSMutableArray arrayWithCapacity:currentNavigationControllerStack.count];
    
    [currentNavigationControllerStack enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *otherViewController = obj;
        if ([otherViewController isKindOfClass:[viewController class]]) {
            [mutableOtherViewControllersInNavigationControllerStack addObject:otherViewController];
        }
    }];
    return [mutableOtherViewControllersInNavigationControllerStack copy];
}

- (void)checkTabBarChildControllerValidityAtIndex:(NSUInteger)index {
    WXWTabBarController *tabBarController = [[self wxw_getViewControllerInsteadOfNavigationController] wxw_tabBarController];
    @try {
        UIViewController *viewController;
        viewController = tabBarController.viewControllers[index];
        UIButton *plusButton = WXWExternPlusButton;
        BOOL shouldConfigureSelectionStatus = (WXWPlusChildViewController) && ((index != WXWPlusButtonIndex) && (viewController != WXWPlusChildViewController));
        if (shouldConfigureSelectionStatus) {
            plusButton.selected = NO;
        }
    } @catch (NSException *exception) {
        NSString *formatString = @"\n\n\
        ------ BEGIN NSException Log ---------------------------------------------------------------------\n \
        class name: %@                                                                                    \n \
        ------line: %@                                                                                    \n \
        ----reason: The Class Type or the index or its NavigationController you pass in method `-wxw_popSelectTabBarChildViewControllerAtIndex` or `-wxw_popSelectTabBarChildViewControllerForClassType` is not the item of WXWTabBarViewController \n \
        ------ END ---------------------------------------------------------------------------------------\n\n";
        NSString *reason = [NSString stringWithFormat:formatString,
                            @(__PRETTY_FUNCTION__),
                            @(__LINE__)];
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), reason);
    }
}

- (NSInteger)wxw_indexForClassType:(Class)classType inViewControllers:(NSArray *)viewControllers {
    __block NSInteger atIndex = NSNotFound;
    [viewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *obj_ = [obj wxw_getViewControllerInsteadOfNavigationController];
        if ([obj_ isKindOfClass:classType]) {
            atIndex = idx;
            *stop = YES;
            return;
        }
    }];
    return atIndex;
}

@end
