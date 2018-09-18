//
//  WXWTabBarController.m
//  WXWTabBarController
//
//  Created by administrator on 2018/8/24.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "WXWTabBarController.h"
#import "WXWTabBar.h"
#import <objc/runtime.h>
#import "UIViewController+WXWTabBarControllerExtention.h"

NSString *const WXWTabBarItemTitle = @"WXWTabBarItemTitle";
NSString *const WXWTabBarItemImage = @"WXWTabBarItemImage";
NSString *const WXWTabBarItemSelectedImage = @"WXWTabBarItemSelectedImage";
NSString *const WXWTabBarItemImageInsets = @"WXWTabBarItemImageInsets";
NSString *const WXWTabBarItemTitlePositionAdjustment = @"WXWTabBarItemTitlePositionAdjustment";

NSUInteger WXWTabbarItemsCount = 0;
NSUInteger WXWPlusButtonIndex = 0;
CGFloat WXWTabBarItemWidth = 0.0f;
NSString *const WXWTabBarItemWidthDidChangeNotification = @"WXWTabBarItemWidthDidChangeNotification";
static void * const WXWTabImageViewDefaultOffsetContext = (void*)&WXWTabImageViewDefaultOffsetContext;


@interface WXWTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, assign, getter=isObservingTabImageViewDefaultOffset) BOOL observingTabImageViewDefaultOffset;

@end

@implementation WXWTabBarController

@synthesize viewControllers = _viewControllers;

#pragma mark -
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (WXW_IS_IPHONE_X) {
        self.tabBarHeight = 83;
    }
    // 处理tabBar，使用自定义 tabBar 添加 发布按钮
    [self setUpTabBar];
    // KVO注册监听
    if (!self.isObservingTabImageViewDefaultOffset) {
        [self.tabBar addObserver:self forKeyPath:@"tabImageViewDefaultOffset" options:NSKeyValueObservingOptionNew context:WXWTabImageViewDefaultOffsetContext];
        self.observingTabImageViewDefaultOffset = YES;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self updateSelectionStatusIfNeededForTabBarController:nil shouldSelectViewController:nil];
}

- (void)setViewDidLayoutSubViewsBlock:(WXWViewDidLayoutSubViewsBlock)viewDidLayoutSubviewsBlock {
    _viewDidLayoutSubviewsBlock = viewDidLayoutSubviewsBlock;
}

- (void)viewDidLayoutSubviews {
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion >= 10 && deviceVersion < 10.2) {
        [self.tabBar layoutSubviews];//Fix issue #93
    }
    UITabBar *tabBar =  self.tabBar;
    for (UIControl *control in tabBar.subviews) {
        if ([control isKindOfClass:[UIControl class]]) {
            SEL actin = @selector(didSelectControl:);
            [control addTarget:self action:actin forControlEvents:UIControlEventTouchUpInside];
        }
    }
    !self.viewDidLayoutSubviewsBlock ?: self.viewDidLayoutSubviewsBlock(self);
}

- (void)viewWillLayoutSubviews {
    if (!(self.tabBarHeight > 0)) {
        return;
    }
    self.tabBar.frame = ({
        CGRect frame = self.tabBar.frame;
        CGFloat tabBarHeight = self.tabBarHeight;
        frame.size.height = tabBarHeight;
        frame.origin.y = self.view.frame.size.height - tabBarHeight;
        frame;
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *controller = self.selectedViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)controller;
        return navigationController.topViewController.supportedInterfaceOrientations;
    } else {
        return controller.supportedInterfaceOrientations;
    }
}

- (void)dealloc {
    UIButton<WXWPlusButtonSubclassing> *plusButton = WXWExternPlusButton;
    if (plusButton.superview && (plusButton.superview == self.tabBar)) {
        plusButton.selected = NO;
        [plusButton removeFromSuperview];
    }
    BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
    BOOL hasPlusChildViewController = [self hasPlusChildViewController] && isAdded;
    if (isAdded && hasPlusChildViewController && WXWPlusChildViewController.wxw_plusViewControllerEverAdded == YES) {
        [WXWPlusChildViewController wxw_setPlusViewControllerEverAdded:NO];
    }
    // KVO反注册
    if (self.isObservingTabImageViewDefaultOffset) {
        [self.tabBar removeObserver:self forKeyPath:@"tabImageViewDefaultOffset"];
    }
}

#pragma mark -
#pragma mark - public Methods

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {
    return [self initWithViewControllers:viewControllers
                   tabBarItemsAttributes:tabBarItemsAttributes
                             imageInsets:UIEdgeInsetsZero
                 titlePositionAdjustment:UIOffsetZero
                                 context:nil];
}

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    
    return [self initWithViewControllers:viewControllers
                   tabBarItemsAttributes:tabBarItemsAttributes
                             imageInsets:imageInsets
                 titlePositionAdjustment:titlePositionAdjustment
                                 context:nil];
}

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                  tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                            imageInsets:(UIEdgeInsets)imageInsets
                titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                context:(NSString *)context {
    if (self = [super init]) {
        _imageInsets = imageInsets;
        _titlePositionAdjustment = titlePositionAdjustment;
        _tabBarItemsAttributes = tabBarItemsAttributes;
        self.context = context;
        self.viewControllers = viewControllers;
        if ([self hasPlusChildViewController]) {
            self.delegate = self;
        }
    }
    return self;
}

- (void)setContext:(NSString *)context {
    if (context && context.length > 0) {
        _context = [context copy];
    } else {
        _context = NSStringFromClass([WXWTabBarController class]);
    }
    [self.tabBar setValue:_context forKey:@"context"];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                                            context:(NSString *)context {
    return [[self alloc] initWithViewControllers:viewControllers
                           tabBarItemsAttributes:tabBarItemsAttributes
                                     imageInsets:imageInsets
                         titlePositionAdjustment:titlePositionAdjustment
                                         context:context];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                              tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes
                                        imageInsets:(UIEdgeInsets)imageInsets
                            titlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    return [[self alloc] initWithViewControllers:viewControllers
                           tabBarItemsAttributes:tabBarItemsAttributes
                                     imageInsets:imageInsets
                         titlePositionAdjustment:titlePositionAdjustment
                                         context:nil];
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes {
    return [self tabBarControllerWithViewControllers:viewControllers
                               tabBarItemsAttributes:tabBarItemsAttributes
                                         imageInsets:UIEdgeInsetsZero
                             titlePositionAdjustment:UIOffsetZero];
}

- (void)hideTabBadgeBackgroundSeparator {
    [self.tabBar layoutIfNeeded];
    self.tabBar.wxw_tabBadgeBackgroundSeparator.alpha = 0;
    self.tabBar.barStyle = UIBarStyleBlack;
}

+ (BOOL)havePlusButton {
    if (WXWExternPlusButton) {
        return YES;
    }
    return NO;
}

+ (NSUInteger)allItemsInTabBarCount {
    NSUInteger allItemsInTabBar = WXWTabbarItemsCount;
    if ([WXWTabBarController havePlusButton]) {
        allItemsInTabBar += 1;
    }
    return allItemsInTabBar;
}

- (id<UIApplicationDelegate>)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (UIWindow *)rootWindow {
    UIWindow *result = nil;
    
    do {
        if ([self.appDelegate respondsToSelector:@selector(window)]) {
            result = [self.appDelegate window];
        }
        
        if (result) {
            break;
        }
    } while (NO);
    
    return result;
}

#pragma mark -
#pragma mark - Private Methods

/**
 *  利用 KVC 把系统的 tabBar 类型改为自定义类型。
 */
- (void)setUpTabBar {
    WXWTabBar *tabBar = [[WXWTabBar alloc] init];
    [self setValue:tabBar forKey:@"tabBar"];
    [tabBar wxw_setTabBarController:self];
}

- (BOOL)hasPlusChildViewController {
    NSString *context = WXWPlusChildViewController.wxw_context;
    BOOL isSameContext = [context isEqualToString:self.context] && (context && self.context); // || (!context && !self.context);
    BOOL hasPlusChildViewController = WXWPlusChildViewController && isSameContext;//&& !isAdded;
    return hasPlusChildViewController;
}

- (BOOL)isPlusViewControllerAdded:(NSArray *)viewControllers {
    if ([_viewControllers containsObject:WXWPlusChildViewController]) {
        return YES;
    }
    __block BOOL isAdded = NO;
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isEqualViewController:obj compairedViewController:WXWPlusChildViewController]) {
            isAdded = YES;
            *stop = YES;
            return;
        }
    }];
    return isAdded;;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers && _viewControllers.count) {
        for (UIViewController *viewController in _viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
        BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
        BOOL hasPlusChildViewController = [self hasPlusChildViewController] && !isAdded;
        if (hasPlusChildViewController) {
            [WXWPlusChildViewController willMoveToParentViewController:nil];
            [WXWPlusChildViewController.view removeFromSuperview];
            [WXWPlusChildViewController removeFromParentViewController];
        }
    }
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        if ((!_tabBarItemsAttributes) || (_tabBarItemsAttributes.count != viewControllers.count)) {
            [NSException raise:NSStringFromClass([WXWTabBarController class]) format:@"The count of WXWTabBarControllers is not equal to the count of tabBarItemsAttributes.【Chinese】设置_tabBarItemsAttributes属性时，请确保元素个数与控制器的个数相同，并在方法`-setViewControllers:`之前设置"];
        }
        //TODO:
        BOOL isAdded = [self isPlusViewControllerAdded:_viewControllers];
        BOOL addedFlag = [WXWPlusChildViewController wxw_plusViewControllerEverAdded];
        BOOL hasPlusChildViewController = [self hasPlusChildViewController] && !isAdded && !addedFlag;
        if (hasPlusChildViewController) {
            NSMutableArray *viewControllersWithPlusButton = [NSMutableArray arrayWithArray:viewControllers];
            [viewControllersWithPlusButton insertObject:WXWPlusChildViewController atIndex:WXWPlusButtonIndex];
            _viewControllers = [viewControllersWithPlusButton copy];
            [WXWPlusChildViewController wxw_setPlusViewControllerEverAdded:YES];
        } else {
            _viewControllers = [viewControllers copy];
        }
        WXWTabbarItemsCount = [viewControllers count];
        WXWTabBarItemWidth = ([UIScreen mainScreen].bounds.size.width - WXWPlusButtonWidth) / (WXWTabbarItemsCount);
        NSUInteger idx = 0;
        for (UIViewController *viewController in _viewControllers) {
            NSString *title = nil;
            id normalImageInfo = nil;
            id selectedImageInfo = nil;
            UIOffset titlePositionAdjustment = UIOffsetZero;
            UIEdgeInsets imageInsets = UIEdgeInsetsZero;
            if (viewController != WXWPlusChildViewController) {
                title = _tabBarItemsAttributes[idx][WXWTabBarItemTitle];
                normalImageInfo = _tabBarItemsAttributes[idx][WXWTabBarItemImage];
                selectedImageInfo = _tabBarItemsAttributes[idx][WXWTabBarItemSelectedImage];
                
                NSValue *offsetValue = _tabBarItemsAttributes[idx][WXWTabBarItemTitlePositionAdjustment];
                UIOffset offset = [offsetValue UIOffsetValue];
                titlePositionAdjustment = offset;
                
                NSValue *insetsValue = _tabBarItemsAttributes[idx][WXWTabBarItemImageInsets];
                UIEdgeInsets insets = [insetsValue UIEdgeInsetsValue];
                imageInsets = insets;
            } else {
                idx--;
            }
            
            [self addOneChildViewController:viewController
                                  WithTitle:title
                            normalImageInfo:normalImageInfo
                          selectedImageInfo:selectedImageInfo
                    titlePositionAdjustment:titlePositionAdjustment
                                imageInsets:imageInsets
             
             ];
            [[viewController wxw_getViewControllerInsteadOfNavigationController] wxw_setTabBarController:self];
            idx++;
        }
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [[viewController wxw_getViewControllerInsteadOfNavigationController] wxw_setTabBarController:nil];
        }
        _viewControllers = nil;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.f) {
//        [self.tabBar setSelectedImageTintColor:tintColor];
//    }
    self.tabBar.tintColor = tintColor;
}

/**
 *  添加一个子控制器
 *
 *  @param viewController    控制器
 *  @param title             标题
 *  @param normalImageInfo   图片
 *  @param selectedImageInfo 选中图片
 */
- (void)addOneChildViewController:(UIViewController *)viewController
                        WithTitle:(NSString *)title
                  normalImageInfo:(id)normalImageInfo
                selectedImageInfo:(id)selectedImageInfo
          titlePositionAdjustment:(UIOffset)titlePositionAdjustment
                      imageInsets:(UIEdgeInsets)imageInsets {
    viewController.tabBarItem.title = title;
    if (normalImageInfo) {
        UIImage *normalImage = [self getImageFromImageInfo:normalImageInfo];
        viewController.tabBarItem.image = normalImage;
    }
    if (selectedImageInfo) {
        UIImage *selectedImage = [self getImageFromImageInfo:selectedImageInfo];
        viewController.tabBarItem.selectedImage = selectedImage;
    }
    if (self.shouldCustomizeImageInsets || ([self isNOTEmptyForImageInsets:imageInsets])) {
        UIEdgeInsets insets = (([self isNOTEmptyForImageInsets:imageInsets]) ? imageInsets : self.imageInsets);
        viewController.tabBarItem.imageInsets = insets;
    }
    if (self.shouldCustomizeTitlePositionAdjustment || [self isNOTEmptyForTitlePositionAdjustment:titlePositionAdjustment]) {
        UIOffset offset = (([self isNOTEmptyForTitlePositionAdjustment:titlePositionAdjustment]) ? titlePositionAdjustment : self.titlePositionAdjustment);
        viewController.tabBarItem.titlePositionAdjustment = offset;
    }
    [self addChildViewController:viewController];
}

- (UIImage *)getImageFromImageInfo:(id)imageInfo {
    UIImage *image = nil;
    if ([imageInfo isKindOfClass:[NSString class]]) {
        image = [UIImage imageNamed:imageInfo];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([imageInfo isKindOfClass:[UIImage class]]) {
        image = (UIImage *)imageInfo;
    }
    return image;
}

- (BOOL)shouldCustomizeImageInsets {
    BOOL shouldCustomizeImageInsets = [self isNOTEmptyForImageInsets:self.imageInsets];
    return shouldCustomizeImageInsets;
}

- (BOOL)shouldCustomizeTitlePositionAdjustment {
    BOOL shouldCustomizeTitlePositionAdjustment = [self isNOTEmptyForTitlePositionAdjustment:self.titlePositionAdjustment];
    return shouldCustomizeTitlePositionAdjustment;
}

- (BOOL)isNOTEmptyForImageInsets:(UIEdgeInsets)imageInsets {
    if (imageInsets.top != 0 || imageInsets.left != 0 || imageInsets.bottom != 0 || imageInsets.right != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isNOTEmptyForTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    if (titlePositionAdjustment.horizontal != 0 || titlePositionAdjustment.vertical != 0) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - KVO Method

// KVO监听执行
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context != WXWTabImageViewDefaultOffsetContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if(context == WXWTabImageViewDefaultOffsetContext) {
        CGFloat tabImageViewDefaultOffset = [change[NSKeyValueChangeNewKey] floatValue];
        [self offsetTabBarTabImageViewToFit:tabImageViewDefaultOffset];
    }
}

- (void)offsetTabBarTabImageViewToFit:(CGFloat)tabImageViewDefaultOffset {
    if (self.shouldCustomizeImageInsets) {
        return;
    }
    NSArray<UITabBarItem *> *tabBarItems = self.tabBar.items;
    [tabBarItems enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIEdgeInsets imageInset = UIEdgeInsetsMake(tabImageViewDefaultOffset, 0, -tabImageViewDefaultOffset, 0);
        obj.imageInsets = imageInset;
        if (!self.shouldCustomizeTitlePositionAdjustment) {
            obj.titlePositionAdjustment = UIOffsetMake(0, MAXFLOAT);
        }
    }];
}

#pragma mark - delegate

- (void)updateSelectionStatusIfNeededForTabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UIButton *plusButton = WXWExternPlusButton;
    WXWTabBarController *tabBarViewController = [[WXWPlusChildViewController wxw_getViewControllerInsteadOfNavigationController] wxw_tabBarController];
//    NSArray *viewControllers = tabBarViewController.viewControllers;
//    BOOL hasPlusChildViewController = [self isPlusViewControllerAdded:viewControllers];
    if (!viewController) {
        viewController = tabBarViewController.selectedViewController;
    }
    BOOL isCurrentViewController = [self isEqualViewController:viewController compairedViewController:WXWPlusChildViewController];
    BOOL shouldConfigureSelectionStatus = (!isCurrentViewController);
    if (shouldConfigureSelectionStatus) {
        plusButton.selected = NO;
        [self didSelectControl:nil];
    } else {
        plusButton.selected = YES;
        [self didSelectControl:plusButton];
    }
}

- (BOOL)isEqualViewController:(UIViewController *)viewController compairedViewController:(UIViewController *)compairedViewController {
    if ([viewController isEqual:compairedViewController]) {
        return YES;
    }
    if ([[viewController wxw_getViewControllerInsteadOfNavigationController] isEqual:[compairedViewController wxw_getViewControllerInsteadOfNavigationController]]) {
        return YES;
    }
    return NO;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [self updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control {
}

- (void)didSelectControl:(UIControl *)control {
    SEL actin = @selector(tabBarController:didSelectControl:);
    if ([self.delegate respondsToSelector:actin]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:actin withObject:self withObject:control ?: self.selectedViewController.tabBarItem.wxw_tabButton];
#pragma clang diagnostic pop
    }
}

- (id)rootViewController {
    WXWTabBarController *tabBarController = nil;
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    UIViewController *rootViewController = [window.rootViewController wxw_getViewControllerInsteadOfNavigationController];;
    if ([rootViewController isKindOfClass:[WXWTabBarController class]]) {
        tabBarController = (WXWTabBarController *)rootViewController;
    }
    return tabBarController;
}

@end

@implementation NSObject (WXWTabBarControllerReferenceExtension)

- (void)wxw_setTabBarController:(WXWTabBarController *)tabBarController {
    //OBJC_ASSOCIATION_ASSIGN instead of OBJC_ASSOCIATION_RETAIN_NONATOMIC to avoid retain circle
    id __weak weakObject = tabBarController;
    id (^block)(void) = ^{ return weakObject; };
    objc_setAssociatedObject(self, @selector(wxw_tabBarController),
                             block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WXWTabBarController *)wxw_tabBarController {
    WXWTabBarController *tabBarController;
    id (^block)(void) = objc_getAssociatedObject(self, @selector(wxw_tabBarController));
    tabBarController = (block ? block() : nil);
    if (tabBarController && [tabBarController isKindOfClass:[WXWTabBarController class]]) {
        return tabBarController;
    }
    if ([self isKindOfClass:[UIViewController class]] && [(UIViewController *)self parentViewController]) {
        tabBarController = [[(UIViewController *)self parentViewController] wxw_tabBarController];
        if ([tabBarController isKindOfClass:[WXWTabBarController class]]) {
            return tabBarController;
        }
    }
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    UIViewController *rootViewController = [window.rootViewController wxw_getViewControllerInsteadOfNavigationController];;
    if ([rootViewController isKindOfClass:[WXWTabBarController class]]) {
        tabBarController = (WXWTabBarController *)rootViewController;
    }
    return tabBarController;
}

@end
