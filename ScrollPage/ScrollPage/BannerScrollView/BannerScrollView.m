//
//  BannerScrollView.m
//  ScrollPage
//
//  Created by Yuchi Chen on 2017/1/9.
//  Copyright © 2017年 Yuchi Chen. All rights reserved.
//

#import "BannerScrollView.h"

@interface BannerScrollView () <UIScrollViewDelegate>

@property (nonatomic, assign) ScrollingDirection scrollingDirection;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
/*
 lastPage - page0 - page1 - page2 - page3 - firstPage
 */
@property (nonatomic, strong) NSMutableArray *pages;
/*
 page0 - page1 - page2 - page3
 */
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) BOOL hasPageControl;

@end

@implementation BannerScrollView

- (instancetype)initWithFrame:(CGRect)frame views:(NSMutableArray *)views scrollingDirection:(ScrollingDirection)direction andPageControl:(BOOL)hasPageControl
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.numberOfPages = views.count;
        self.hasPageControl = hasPageControl;
        self.scrollingDirection = direction;
        [self setPagesWithViews:views];
        [self setScrollView];
        if (self.hasPageControl) {
            [self setPageControl];
        }
    }
    
    return self;
}

- (id)viewFromNibNamed:(NSString *)nibName owner:(id)owner
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    return [nibView firstObject];
}

- (void)setPagesWithViews:(NSMutableArray *)views
{
    // 一樣使用self.pages == nil來判斷會比較直覺
    if (self.pages == nil) {
        self.pages = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < views.count + 2; i ++) {
            if (i == 0) {
                [self.pages addObject:[self viewFromNibNamed:views.lastObject owner:nil]];
            }
            else if (i == views.count + 1) {
                [self.pages addObject:[self viewFromNibNamed:views.firstObject owner:nil]];
            }
            else {
                [self.pages addObject:[self viewFromNibNamed:[views objectAtIndex:i - 1] owner:nil]];
            }
        }
    }
}

- (void)setScrollView
{
    if (self.scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.pagingEnabled = true;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.showsVerticalScrollIndicator = false;
        [self addSubview:self.scrollView];
        
        switch (self.scrollingDirection) {
            case HorizontalScrolling:
                [self setHorizontalScrollView];
                break;
                
            case VeritcalScrolling:
                [self setVerticalScrollView];
                break;
                
            default:
                break;
        }
    }
}

- (void)setHorizontalScrollView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(width * self.pages.count, height);
    
    //循環添加view
    for (NSInteger i = 0; i < self.pages.count; i ++) {
        UIView *view = [self.pages objectAtIndex:i];
        view.userInteractionEnabled = false;
        //設置按鈕
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        
        // i = 0, tag = -1?
        button.tag = i - 1;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:view];
        //添加view到scrollView上
        [self.scrollView addSubview:button];
    }
    
    //設置初始滾動的位置為第二個view
    self.scrollView.contentOffset = CGPointMake(width, 0);
}

- (void)setVerticalScrollView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(width, height * self.pages.count);
    
    //循環添加view
    for (NSInteger i = 0; i < self.pages.count; i ++) {
        UIView *view = [self.pages objectAtIndex:i];
        view.userInteractionEnabled = false;
        //設置按鈕
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i * height, width, height)];
        button.tag = i - 1;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:view];
        //添加view到scrollView上
        [self.scrollView addSubview:button];
    }
    
    //設置初始滾動的位置為第二個view
    self.scrollView.contentOffset = CGPointMake(0, height);
}

- (void)setPageControl
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (self.pageControl == nil) {
        self.pageControl = [[UIPageControl alloc] init];
        
        switch (self.scrollingDirection) {
            case HorizontalScrolling:
                self.pageControl.frame = CGRectMake(0, height - 30, width, 20);
                break;
                
            case VeritcalScrolling:
                self.pageControl.frame = CGRectMake(30, 0, 20, height);
                self.pageControl.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
                
            default:
                break;
        }
        
        // page control 如果點擊不能切換頁面的話就將它可以點擊的功能關掉吧
        self.pageControl.enabled = false;
        
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = self.numberOfPages;
        [self addSubview:self.pageControl];
    }
}

#pragma mark - BannerScrollViewDelegate

- (void)buttonPressed:(UIButton *)sender
{
    if ([self.delgate respondsToSelector:@selector(bannerScrollViewDidSelectViewAtIndex:)]) {
        [self.delgate bannerScrollViewDidSelectViewAtIndex:sender.tag];
    }
}

#pragma mark - UIScrollViewDelegate

//當停止滾動時，重設scrollView的sontentOffset
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    
    switch (self.scrollingDirection) {
        case HorizontalScrolling:
            //當滾動到最後的時候
            if (point.x / width > self.numberOfPages) {
                [scrollView setContentOffset:CGPointMake(width, 0) animated:false];
            }
            //當滾動到最前的時候
            else if (point.x / width < 1) {
                [scrollView setContentOffset:CGPointMake(width * self.numberOfPages, 0) animated:false];
            }
            break;
            
        case VeritcalScrolling:
            //當滾動到最後的時候
            if (point.y / height > self.numberOfPages) {
                [scrollView setContentOffset:CGPointMake(0, height) animated:false];
            }
            //當滾動到最前的時候
            else if (point.y / height < 1) {
                [scrollView setContentOffset:CGPointMake(0, height * self.numberOfPages) animated:false];
            }
            break;
            
        default:
            break;
    }
}

//一邊滾動一邊設置pageControl的currentPage
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.hasPageControl) {
        CGPoint point = scrollView.contentOffset;
        CGFloat width = scrollView.frame.size.width;
        CGFloat height = scrollView.frame.size.height;
        NSInteger currentPage;
        
        switch (self.scrollingDirection) {
            case HorizontalScrolling:
                //當滾動到最後的時候
                if (point.x / width > self.numberOfPages) {
                    currentPage = self.pages.count - 1;
                }
                //當滾動到最前的時候
                else if (point.x / width < 1) {
                    currentPage = 0;
                }
                else {
                    currentPage = (point.x / width) - 1;
                }
                break;
                
            case VeritcalScrolling:
                //當滾動到最後的時候
                if (point.y / height > self.pages.count) {
                    currentPage = self.pages.count - 1;
                }
                //當滾動到最前的時候
                else if (point.y / height < 1) {
                    currentPage = 0;
                }
                else {
                    currentPage = (point.y / height) - 1;
                }
                break;
                
            default:
                break;
        }
        
        [self.pageControl setCurrentPage:currentPage];
    }
}

@end
