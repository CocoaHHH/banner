//
//  BannerView.h
//  图片轮播
//
//  Created by hankeke on 16/12/20.
//  Copyright © 2016年 hkk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BannerViewTapActionBlock)(NSInteger);

@interface BannerView : UIView
//传入的图片数组
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, assign) BOOL isScrollDorectionPortrait;
//关闭Timer，default is NO
@property (nonatomic, assign) BOOL isTimerNeedClose;

@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

@property (nonatomic, copy) BannerViewTapActionBlock bannerBlock;

@end
