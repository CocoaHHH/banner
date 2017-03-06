//
//  BannerView.m
//  图片轮播
//
//  Created by hankeke on 16/12/20.
//  Copyright © 2016年 hkk. All rights reserved.
//

#import "BannerView.h"
@interface BannerView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

static const NSInteger imageCount = 3;

@implementation BannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        for (int i = 0; i < imageCount; i ++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [scrollView addSubview:imageView];
        }
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [self addSubview:pageControl];
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        self.pageControl = pageControl;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //设置图片位置
    for (int i = 0; i < self.scrollView.subviews.count; i ++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        if (self.isScrollDorectionPortrait) {
            imageView.frame = CGRectMake(0, i * height, width, height);
        } else {
            imageView.frame = CGRectMake(i * width, 0, width, height);
        }
    }
    //设置contentSize
    //设置contentOffset，显示最中间的图片
    if (self.isScrollDorectionPortrait) {
        self.scrollView.contentSize = CGSizeMake(width, height * imageCount);
        self.scrollView.contentOffset = CGPointMake(0, height);
    } else {
        self.scrollView.contentSize = CGSizeMake(width * imageCount, height);
        self.scrollView.contentOffset = CGPointMake(width, 0);
    }
    
    //pagecontrol
    CGFloat pageWidth = 100;
    CGFloat pageHeight = 20;
    CGFloat pageX = width - pageWidth;
    CGFloat pageY = height = pageHeight;
    self.pageControl.frame = CGRectMake(pageX, pageY, pageWidth, pageHeight);
}

#pragma mark - Getter and Setter
- (void)setImages:(NSArray *)images {
    _images = images;
    //pageControl 的页数个数
    self.pageControl.numberOfPages = images.count;  // 5
    self.pageControl.currentPage = 0;
    //设置图片显示内容
    [self configImages];
    //开启定时
    [self startTimer];
}

- (void)configImages {
    //设置三个imageButton 的显示图片
    for (int i = 0; i < self.scrollView.subviews.count; i ++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        //图片索引
        NSInteger index = self.pageControl.currentPage;//1
        if (0 == i) { //第一个按钮，它的背景图片应该是需要显示图片的前一个图片，隐藏在正在显示图片的左侧
            index --; //当前展示的index 减1 就是需要显示的前一张图片 -1
        } else if (2 == i) { //最后一个按钮，它的图片是当前显示图片的后一张图片，隐藏在正在显示图片的右侧
            index ++; //index +1 即使后一张图片  1
        }
        if (index < 0) {
            index = self.pageControl.numberOfPages - 1;  //4
        } else if (self.pageControl.numberOfPages == index) {
            index = 0;
        }
        imageView.tag = index;
        //主要依靠index 来展示图片
        [imageView setImage:self.images[index]];
    }
}

- (void)updateImages {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    [self configImages];
    //重新设置offset， 保证时钟显示最中间的那个按钮，按钮对应的图片即是pageControl currentPage 所对应的数组中的index
    if (self.isScrollDorectionPortrait) {
        self.scrollView.contentOffset = CGPointMake(0, height);
    } else {
        self.scrollView.contentOffset = CGPointMake(width, 0);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //拖动的时候，哪张图片最靠中间，也就是偏移量(相对于scrollView)最小，就滑到哪页
    NSInteger page = 0;
    //最小偏移量
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0; i < self.scrollView.subviews.count; i ++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        CGFloat distance = 0;
        if (self.isScrollDorectionPortrait) {
            distance = ABS(imageView.frame.origin.y - scrollView.contentOffset.y);
        } else {
            distance = ABS(imageView.frame.origin.x - scrollView.contentOffset.x);
        }
        if (distance < minDistance) {
            minDistance = distance;
            page = imageView.tag;//如果是向右滑，那么第三个按钮的位置相对于offset的偏移量最小，此时重新设置pagecontrol的currentpag 就等于正在展示图片的tag + 1 ，那么当执行setContent 时，1==i 时，中间按钮的tag 就变成了 滑动之前的tag + 1；
        }
    }
    //currentPage 来控制显示数组中的第几张图片
    self.pageControl.currentPage = page;
}

//开始拖拽时，停止计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

//结束拖拽，时开始计时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

//结束拖拽的时候更新image
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateImages];
}

//滚动动画结束的时候更新
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateImages];
}

- (void)startTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextImage {

    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    if (self.isScrollDorectionPortrait) {
        [self.scrollView setContentOffset:CGPointMake(0, 2 * height) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(2 * width, 0) animated:YES];
    }
    
}

@end
