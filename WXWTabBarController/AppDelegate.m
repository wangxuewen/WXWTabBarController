//
//  AppDelegate.m
//  WXWTabBarController
//
//  Created by administrator on 2018/9/5.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "AppDelegate.h"
#import "WXWTabBarControllerConfig.h"
#import "WXWMidddleSubClass.h"

@interface AppDelegate ()<UITabBarControllerDelegate ,WXWTabBarControllerDelegate>

@end

@implementation AppDelegate
#define RANDOM_COLOR [UIColor colorWithHue: (arc4random() % 256 / 256.0) saturation:((arc4random()% 128 / 256.0 ) + 0.5) brightness:(( arc4random() % 128 / 256.0 ) + 0.5) alpha:1]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 设置主窗口,并设置根控制器
    self.window = [[UIWindow alloc]init];
    self.window.frame = [UIScreen mainScreen].bounds;
    [WXWMidddleSubClass registerPlusButton];
    WXWTabBarControllerConfig *tabBarControllerConfig = [[WXWTabBarControllerConfig alloc] init];
    WXWTabBarController *tabBarController = tabBarControllerConfig.tabBarController;
    [self.window setRootViewController:tabBarController];
    
    tabBarController.delegate = self;
    [self.window makeKeyAndVisible];
    [self customizeInterfaceWithTabBarController:tabBarController];
    return YES;
}

- (void)customizeInterfaceWithTabBarController:(WXWTabBarController *)tabBarController {
    //设置导航栏
    [self setUpNavigationBarAppearance];
    
    [tabBarController hideTabBadgeBackgroundSeparator];
//    //添加小红点
//    UIViewController *viewController = tabBarController.viewControllers[0];
//    UIView *tabBadgePointView0 = [UIView wxw_tabBadgePointViewWithClolor:RANDOM_COLOR radius:4.5];
//    [viewController.tabBarItem.wxw_tabButton wxw_setTabBadgePointView:tabBadgePointView0];
//    [viewController wxw_showTabBadgePoint];
//
//    UIView *tabBadgePointView1 = [UIView wxw_tabBadgePointViewWithClolor:RANDOM_COLOR radius:4.5];
//    @try {
//        [tabBarController.viewControllers[1] wxw_setTabBadgePointView:tabBadgePointView1];
//        [tabBarController.viewControllers[1] wxw_showTabBadgePoint];
//
//        UIView *tabBadgePointView2 = [UIView wxw_tabBadgePointViewWithClolor:RANDOM_COLOR radius:4.5];
//        [tabBarController.viewControllers[2] wxw_setTabBadgePointView:tabBadgePointView2];
//        [tabBarController.viewControllers[2] wxw_showTabBadgePoint];
//
//        [tabBarController.viewControllers[3] wxw_showTabBadgePoint];
//
//        //添加提示动画，引导用户点击
//        [self addScaleAnimationOnView:tabBarController.viewControllers[3].wxw_tabButton.wxw_tabImageView repeatCount:20];
//    } @catch (NSException *exception) {}
}

/**
 *  设置navigationBar样式
 */
- (void)setUpNavigationBarAppearance {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName : [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName : [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        textAttributes = @{
                           UITextAttributeFont : [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor : [UIColor blackColor],
                           UITextAttributeTextShadowColor : [UIColor clearColor],
                           UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}


#pragma mark - delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [[self wxw_tabBarController] updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control {
    UIView *animationView;
    
    if ([control wxw_isTabButton]) {
        //更改红标状态
//        if ([[self wxw_tabBarController].selectedViewController wxw_isShowTabBadgePoint]) {
//            [[self wxw_tabBarController].selectedViewController wxw_removeTabBadgePoint];
//        } else {
//            [[self wxw_tabBarController].selectedViewController wxw_showTabBadgePoint];
//        }

        animationView = [control wxw_tabImageView];
    }
    
    // 即使 PlusButton 也添加了点击事件，点击 PlusButton 后也会触发该代理方法。
    if ([control wxw_isPlusButton]) {
        UIButton *button = WXWExternPlusButton;
        animationView = button.imageView;
    }
    
    if ([self wxw_tabBarController].selectedIndex % 2 == 0) {
        [self addScaleAnimationOnView:animationView repeatCount:1];
    } else {
        [self addRotateAnimationOnView:animationView];
    }
}

//缩放动画
- (void)addScaleAnimationOnView:(UIView *)animationView repeatCount:(float)repeatCount {
    //需要实现的帧动画，这里根据需求自定义
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration = 1;
    animation.repeatCount = repeatCount;
    animation.calculationMode = kCAAnimationCubic;
    [animationView.layer addAnimation:animation forKey:nil];
}

//旋转动画
- (void)addRotateAnimationOnView:(UIView *)animationView {
    // 针对旋转动画，需要将旋转轴向屏幕外侧平移，最大图片宽度的一半
    // 否则背景与按钮图片处于同一层次，当按钮图片旋转时，转轴就在背景图上，动画时会有一部分在背景图之下。
    // 动画结束后复位
    animationView.layer.zPosition = 65.f / 2;
    [UIView animateWithDuration:0.32 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        animationView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.70 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            animationView.layer.transform = CATransform3DMakeRotation(2 * M_PI, 0, 1, 0);
        } completion:nil];
    });
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
