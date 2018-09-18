//
//  WXWConstants.h
//  WXWTabBarController
//
//  Created by administrator on 2018/8/27.
//  Copyright © 2018年 xuewen.wang. All rights reserved.
//

#ifndef WXWConstants_h
#define WXWConstants_h

#define WXW_DEPRECATED(explain) __attribute__((deprecated(explain)))
#define WXW_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define WXW_IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define WXW_IS_IPHONE_X (WXW_IS_IOS_11 && WXW_IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) == 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) == 812))

#endif /* WXWConstants_h */
