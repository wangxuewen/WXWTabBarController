//
//  WXWTabBar.m
//  WXWTabBarController
//
//  Created by administrator on 2018/8/24.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import "WXWTabBar.h"
#import "WXWPlusButton.h"
#import "WXWTabBarController.h"
#import "WXWConstants.h"

static void *const WXWTabBarContext = (void*)&WXWTabBarContext;

@interface WXWTabBar ()

/** 发布按钮 */
@property (nonatomic, strong) UIButton<WXWPlusButtonSubclassing> *plusButton;
@property (nonatomic, assign) CGFloat tabBarItemWidth;
@property (nonatomic, copy) NSArray *tabBarButtonArray;
@property (nonatomic, assign, getter=hasAddPlusButton) BOOL addPlusButton;

@end

@implementation WXWTabBar

@synthesize plusButton = _plusButton;
#pragma mark -
#pragma mark - LifeCycle Method

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (void)setPlusButton:(UIButton<WXWPlusButtonSubclassing> *)plusButton {
    if (!plusButton) {
        return;
    }
    _plusButton = plusButton;
    if (!self.hasAddPlusButton) {
        
        NSString *tabBarContext = self.tabBarContext;
        BOOL isFirstAdded = (_plusButton.superview == nil);
        
        BOOL isSameContext = [tabBarContext isEqualToString:self.context] && (tabBarContext && self.context);
        if (_plusButton && isSameContext && isFirstAdded) {
            [self addSubview:(UIButton *)_plusButton];
            [_plusButton wxw_setTabBarController: [self wxw_tabBarController]];
        }
        self.addPlusButton = YES;
    }
}

- (void)setContext:(NSString *)context {
    _context = context;
    self.plusButton = WXWExternPlusButton;
}

- (instancetype)sharedInit {
    // KVO注册监听
    _tabBarItemWidth = WXWTabBarItemWidth;
    [self addObserver:self forKeyPath:@"tabBarItemWidth" options:NSKeyValueObservingOptionNew context:WXWTabBarContext];
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    CGFloat height = [self wxw_tabBarController].tabBarHeight;
    if (height > 0) {
        sizeThatFits.height = [self wxw_tabBarController].tabBarHeight;
    }
    return sizeThatFits;
}

/**
 *  lazy load tabBarButtonArray
 *
 *  @return NSArray
 */
- (NSArray *)tabBarButtonArray {
    if (_tabBarButtonArray == nil) {
        _tabBarButtonArray = @[];
    }
    return _tabBarButtonArray;
}

- (NSString *)tabBarContext {
    NSString *tabBarContext;
    if ([[_plusButton class] respondsToSelector:@selector(tabBarContext)]) {
        tabBarContext = [[_plusButton class] tabBarContext];
    }
    if (tabBarContext && tabBarContext.length > 0) {
        return tabBarContext;
    }
    tabBarContext = NSStringFromClass([WXWTabBarController class]);
    return tabBarContext;
}

- (UIButton<WXWPlusButtonSubclassing> *)plusButton {
    if (!WXWExternPlusButton || !_plusButton) {
        return nil;
    }
    NSString *tabBarContext = self.tabBarContext;
    BOOL addedToTabBar = [_plusButton.superview isEqual:self];
    BOOL isSameContext = [tabBarContext isEqualToString:self.context] && (tabBarContext && self.context);;//|| (!tabBarContext  && !self.context);
    if (_plusButton  &&  addedToTabBar && isSameContext) {
        return _plusButton;
    }
    
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *sortedSubviews = [self sortedSubviews];
    self.tabBarButtonArray = [self tabBarButtonFromTabBarSubviews:sortedSubviews];
    if (self.tabBarButtonArray.count == 0) {
        return;
    }
    [self setupTabImageViewDefaultOffset:self.tabBarButtonArray[0]];
    CGFloat tabBarWidth = self.bounds.size.width;
    CGFloat tabBarHeight = self.bounds.size.height;
    
    if (!WXWExternPlusButton) {
        return;
    }
    BOOL addedToTabBar = [_plusButton.superview isEqual:self];
    if (!addedToTabBar) {
        WXWTabBarItemWidth = (tabBarWidth) / WXWTabbarItemsCount;
        [self.tabBarButtonArray enumerateObjectsUsingBlock:^(UIView * _Nonnull childView, NSUInteger buttonIndex, BOOL * _Nonnull stop) {
            //仅修改childView的x和宽度,yh值不变
            CGFloat childViewX = buttonIndex * WXWTabBarItemWidth;
            [self changeXForChildView:childView childViewX:childViewX tabBarItemWidth:WXWTabBarItemWidth];
        }];
        
    } else {
        WXWTabBarItemWidth = (tabBarWidth - WXWPlusButtonWidth) / WXWTabbarItemsCount;
        CGFloat multiplierOfTabBarHeight = [self multiplierOfTabBarHeight:tabBarHeight];
        CGFloat constantOfPlusButtonCenterYOffset = [self constantOfPlusButtonCenterYOffsetForTabBarHeight:tabBarHeight];
        _plusButton.center = CGPointMake(tabBarWidth * 0.5, tabBarHeight * multiplierOfTabBarHeight + constantOfPlusButtonCenterYOffset);
        NSUInteger plusButtonIndex = [self plusButtonIndex];
        [self.tabBarButtonArray enumerateObjectsUsingBlock:^(UIView * _Nonnull childView, NSUInteger buttonIndex, BOOL * _Nonnull stop) {
            //调整UITabBarItem的位置
            CGFloat childViewX;
            if ([self hasPlusChildViewController]) {
                if (buttonIndex <= plusButtonIndex) {
                    childViewX = buttonIndex * WXWTabBarItemWidth;
                } else {
                    childViewX = (buttonIndex - 1) * WXWTabBarItemWidth + WXWPlusButtonWidth;
                }
            } else {
                if (buttonIndex >= plusButtonIndex) {
                    childViewX = buttonIndex * WXWTabBarItemWidth + WXWPlusButtonWidth;
                } else {
                    childViewX = buttonIndex * WXWTabBarItemWidth;
                }
            }
            //仅修改childView的x和宽度,yh值不变
            [self changeXForChildView:childView childViewX:childViewX tabBarItemWidth:WXWTabBarItemWidth];
        }];
        //bring the plus button to top
        [self bringSubviewToFront:_plusButton];
    }
    
    self.tabBarItemWidth = WXWTabBarItemWidth;
}

- (void)changeXForChildView:(UIView *)childView childViewX:(CGFloat)childViewX tabBarItemWidth:(CGFloat)tabBarItemWidth {
    //仅修改childView的x和宽度,yh值不变
    childView.frame = CGRectMake(childViewX,
                                 CGRectGetMinY(childView.frame),
                                 tabBarItemWidth,
                                 CGRectGetHeight(childView.frame)
                                 );
}

#pragma mark -
#pragma mark - Private Methods

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return NO;
}

// KVO监听执行
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context != WXWTabBarContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if(context == WXWTabBarContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WXWTabBarItemWidthDidChangeNotification object:self];
        if (WXW_IS_IPHONE_X) {
            [self layoutIfNeeded];
        }
    }
}


- (void)dealloc {
    // KVO反注册
    [self removeObserver:self forKeyPath:@"tabBarItemWidth"];
}

- (void)setTabBarItemWidth:(CGFloat )tabBarItemWidth {
    if (_tabBarItemWidth != tabBarItemWidth) {
        [self willChangeValueForKey:@"tabBarItemWidth"];
        _tabBarItemWidth = tabBarItemWidth;
        [self didChangeValueForKey:@"tabBarItemWidth"];
    }
}

- (void)setTabImageViewDefaultOffset:(CGFloat)tabImageViewDefaultOffset {
    if (tabImageViewDefaultOffset != 0.f) {
        [self willChangeValueForKey:@"tabImageViewDefaultOffset"];
        _tabImageViewDefaultOffset = tabImageViewDefaultOffset;
        [self didChangeValueForKey:@"tabImageViewDefaultOffset"];
    }
}

- (CGFloat)multiplierOfTabBarHeight:(CGFloat)tabBarHeight {
    CGFloat multiplierOfTabBarHeight;
    if ([[self.plusButton class] respondsToSelector:@selector(multiplierOfTabBarHeight:)]) {
        multiplierOfTabBarHeight = [[self.plusButton class] multiplierOfTabBarHeight:tabBarHeight];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if ([[self.plusButton class] respondsToSelector:@selector(multiplerInCenterY)]) {
        multiplierOfTabBarHeight = [[self.plusButton class] multiplerInCenterY];
    }
#pragma clang diagnostic pop
    
    else {
        CGSize sizeOfPlusButton = self.plusButton.frame.size;
        CGFloat heightDifference = sizeOfPlusButton.height - self.bounds.size.height;
        if (heightDifference < 0) {
            multiplierOfTabBarHeight = 0.5;
        } else {
            CGPoint center = CGPointMake(self.bounds.size.height * 0.5, self.bounds.size.height * 0.5);
            center.y = center.y - heightDifference * 0.5;
            multiplierOfTabBarHeight = center.y / self.bounds.size.height;
        }
    }
    return multiplierOfTabBarHeight;
}

- (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    CGFloat constantOfPlusButtonCenterYOffset = 0.f;
    if ([[self.plusButton class] respondsToSelector:@selector(constantOfPlusButtonCenterYOffsetForTabBarHeight:)]) {
        constantOfPlusButtonCenterYOffset = [[self.plusButton class] constantOfPlusButtonCenterYOffsetForTabBarHeight:tabBarHeight];
    }
    return constantOfPlusButtonCenterYOffset;
}

- (NSUInteger)plusButtonIndex {
    NSUInteger plusButtonIndex;
    if ([[self.plusButton class] respondsToSelector:@selector(indexOfPlusButtonInTabBar)]) {
        plusButtonIndex = [[self.plusButton class] indexOfPlusButtonInTabBar];
        CGFloat childViewX = plusButtonIndex * WXWTabBarItemWidth;
        CGFloat tabBarItemWidth = CGRectGetWidth(self.plusButton.frame);
        [self changeXForChildView:self.plusButton childViewX:childViewX tabBarItemWidth:tabBarItemWidth];
    } else {
        if (WXWTabbarItemsCount % 2 != 0) {
            [NSException raise:NSStringFromClass([WXWTabBarController class]) format:@"If the count of WXWTabbarControllers is odd,you must realizse `+indexOfPlusButtonInTabBar` in your custom plusButton class.【Chinese】如果WXWTabbarControllers的个数是奇数，你必须在你自定义的plusButton中实现`+indexOfPlusButtonInTabBar`，来指定plusButton的位置"];
        }
        plusButtonIndex = WXWTabbarItemsCount * 0.5;
    }
    WXWPlusButtonIndex = plusButtonIndex;
    return plusButtonIndex;
}

/*!
 *  Deal with some trickiness by Apple, You do not need to understand this method, somehow, it works.
 *  NOTE: If the `self.title of ViewController` and `the correct title of tabBarItemsAttributes` are different, Apple will delete the correct tabBarItem from subViews, and then trigger `-layoutSubviews`, therefore subViews will be in disorder. So we need to rearrange them.
 */
- (NSArray *)sortedSubviews {
    if (self.subviews.count == 0) {
        return self.subviews;
    }
    NSMutableArray *tabBarButtonArray = [NSMutableArray arrayWithCapacity:self.subviews.count];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj wxw_isTabButton]) {
            [tabBarButtonArray addObject:obj];
        }
    }];
    
    NSArray *sortedSubviews = [[tabBarButtonArray copy] sortedArrayUsingComparator:^NSComparisonResult(UIView * formerView, UIView * latterView) {
        CGFloat formerViewX = formerView.frame.origin.x;
        CGFloat latterViewX = latterView.frame.origin.x;
        return  (formerViewX > latterViewX) ? NSOrderedDescending : NSOrderedAscending;
    }];
    return sortedSubviews;
}

- (NSArray *)tabBarButtonFromTabBarSubviews:(NSArray *)tabBarSubviews {
    if (tabBarSubviews.count == 0) {
        return tabBarSubviews;
    }
    NSMutableArray *tabBarButtonMutableArray = [NSMutableArray arrayWithCapacity:tabBarSubviews.count];
    [tabBarSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj wxw_isTabButton]) {
            [tabBarButtonMutableArray addObject:obj];
        }
    }];
    if ([self hasPlusChildViewController]) {
        @try {
            UIControl *control = tabBarButtonMutableArray[WXWPlusButtonIndex];
            control.userInteractionEnabled = NO;
            control.hidden = YES;
        } @catch (NSException *exception) {}
    }
    return [tabBarButtonMutableArray copy];
}

- (BOOL)hasPlusChildViewController {
    NSString *context = WXWPlusChildViewController.wxw_context;
    BOOL isSameContext = [context isEqualToString:self.context] && (context && self.context);
    BOOL isAdded = [[self wxw_tabBarController].viewControllers containsObject:WXWPlusChildViewController];
    if (WXWPlusChildViewController && isSameContext && isAdded) {
        return YES;
    }
    return NO;
}

- (void)setupTabImageViewDefaultOffset:(UIView *)tabBarButton {
    __block BOOL shouldCustomizeImageView = YES;
    __block CGFloat tabImageViewHeight = 0.f;
    __block CGFloat tabImageViewDefaultOffset = 0.f;
    CGFloat tabBarHeight = self.frame.size.height;
    [tabBarButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj wxw_isTabLabel]) {
            shouldCustomizeImageView = NO;
        }
        tabImageViewHeight = obj.frame.size.height;
        BOOL isTabImageView = [obj wxw_isTabImageView];
        if (isTabImageView) {
            tabImageViewDefaultOffset = (tabBarHeight - tabImageViewHeight) * 0.5 * 0.5;
        }
        if (isTabImageView && tabImageViewDefaultOffset == 0.f) {
            shouldCustomizeImageView = NO;
        }
    }];
    if (shouldCustomizeImageView) {
        self.tabImageViewDefaultOffset = tabImageViewDefaultOffset;
    }
}

/*!
 *  Capturing touches on a subview outside the frame of its superview.
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //1. 边界情况：不能响应点击事件
    
    BOOL canNotResponseEvent = self.hidden || (self.alpha <= 0.01f) || (self.userInteractionEnabled == NO) || (!self.superview) || self.frame.size.width == 0 || self.frame.size.height == 0;
    if (canNotResponseEvent) {
        return nil;
    }
    
    //2. 优先处理 PlusButton （包括其突出的部分）、TabBarItems 未凸出的部分
    //这一步主要是在处理只有两个 TabBarItems 的场景。
    // 2.1先考虑clipsToBounds情况：子view超出部分没有显示出来
    if (self.clipsToBounds && ![self pointInside:point withEvent:event]) {
        return nil;
    }
    
    if (self.plusButton) {
        CGRect plusButtonFrame = self.plusButton.frame;
        BOOL isInPlusButtonFrame = CGRectContainsPoint(plusButtonFrame, point);
        if (isInPlusButtonFrame) {
            return self.plusButton;
        }
    }
    NSArray *tabBarButtons = self.tabBarButtonArray;
    if (self.tabBarButtonArray.count == 0) {
        tabBarButtons = [self tabBarButtonFromTabBarSubviews:self.subviews];
    }
    for (NSUInteger index = 0; index < tabBarButtons.count; index++) {
        UIView *selectedTabBarButton = tabBarButtons[index];
        CGRect selectedTabBarButtonFrame = selectedTabBarButton.frame;
        BOOL isTabBarButtonFrame = CGRectContainsPoint(selectedTabBarButtonFrame, point);
        if (isTabBarButtonFrame) {
            return selectedTabBarButton;
        }
    }
    
    //3. 最后处理 TabBarItems 凸出的部分、添加到 TabBar 上的自定义视图、点击到 TabBar 上的空白区域
    UIView *result = [super hitTest:point withEvent:event];
    if (result) {
        return result;
    }
    
    for (UIView *subview in self.subviews.reverseObjectEnumerator) {
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        result = [subview hitTest:subPoint withEvent:event];
        if (result) {
            return result;
        }
    }
    return nil;
}

@end
