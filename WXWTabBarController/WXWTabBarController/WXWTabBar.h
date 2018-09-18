//
//  WXWTabBar.h
//  WXWTabBarController
//
//  Created by administrator on 2018/8/24.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXWTabBar : UITabBar

/*!
 * 让 `TabImageView` 垂直居中时，所需要的默认偏移量。
 * @attention 该值将在设置 top 和 bottom 时被同时使用，具体的操作等价于如下行为：
 * `viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(tabImageViewDefaultOffset, 0, -tabImageViewDefaultOffset, 0);`
 */
@property (nonatomic, assign, readonly) CGFloat tabImageViewDefaultOffset;

@property (nonatomic, copy) NSString *context;

@end
