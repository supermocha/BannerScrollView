//
//  BannerScrollView.m
//  ScrollPage
//
//  Created by Yuchi Chen on 2017/1/9.
//  Copyright © 2017年 Yuchi Chen. All rights reserved.
//

#import "BannerScrollView.h"

@interface BannerScrollView () <UIScrollViewDelegate>
{
    NSInteger numberOfPages;    //page0 - page1 - page2 - page3
    NSMutableArray *pages;      //lastPage - page0 - page1 - page2 - page3 - firstPage
    UIPageControl *pageControl;
    BOOL hasPageControl;
    ScrollingDirection scrollingDirection;
}
@end

@implementation BannerScrollView

- (instancetype)initWithFrame:(CGRect)frame classNamesOfView:(NSMutableArray *)classNamesOfView scrollingDirection:(ScrollingDirection)direction andPageControl:(BOOL)bl
{
    self = [super initWithFrame:frame];
    if (self) {
        hasPageControl = bl;
        scrollingDirection = direction;
        numberOfPages = classNamesOfView.count;
        [self setPages:classNamesOfView];
        [self setScrollView];
        if (hasPageControl) {
            [self setPageControl];
        }
    }
    return self;
}

#pragma mark - Private

- (void)setScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.pagingEnabled = true;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.showsVerticalScrollIndicator = false;
    [self addSubview:scrollView];
    
    switch (scrollingDirection) {
        case HorizontalScrolling:
            [self setHorizontalScrollView:scrollView];
            break;
            
        case VeritcalScrolling:
            [self setVerticalScrollView:scrollView];
            break;
            
        default:
            break;
    }
}

- (void)setPages:(NSMutableArray *)views
{
    pages = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < views.count + 2; i ++) {
        if (i == 0) {
            [pages addObject:[self loadNibWithName:views.lastObject]];
        }
        else if (i == views.count + 1) {
            [pages addObject:[self loadNibWithName:views.firstObject]];
        }
        else {
            [pages addObject:[self loadNibWithName:[views objectAtIndex:i - 1]]];
        }
    }
}

- (void)setPageControl
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    pageControl = [[UIPageControl alloc] init];
    
    switch (scrollingDirection) {
        case HorizontalScrolling:
            pageControl.frame = CGRectMake(0, height - 30, width, 20);
            break;
            
        case VeritcalScrolling:
            pageControl.frame = CGRectMake(30, 0, 20, height);
            pageControl.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default:
            break;
    }
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numberOfPages;
    //關閉pageControl的點擊功能
    pageControl.enabled = false;
    [self addSubview:pageControl];
}

- (void)setHorizontalScrollView:(UIScrollView *)scrollView
{
    CGFloat width = CGRectGetWidth(scrollView.frame);
    CGFloat height = CGRectGetHeight(scrollView.frame);
    
    scrollView.contentSize = CGSizeMake(width * pages.count, height);
    
    //循環添加view
    for (NSInteger i = 0; i < pages.count; i ++) {
        UIView *view = [pages objectAtIndex:i];
        view.userInteractionEnabled = false;
        //設置按鈕
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        
        button.tag = i - 1;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:view];
        //添加view到scrollView上
        [scrollView addSubview:button];
    }
    
    //設置初始滾動的位置為第二個view
    scrollView.contentOffset = CGPointMake(width, 0);
}

- (void)setVerticalScrollView:(UIScrollView *)scrollView
{
    CGFloat width = CGRectGetWidth(scrollView.frame);
    CGFloat height = CGRectGetHeight(scrollView.frame);
    
    scrollView.contentSize = CGSizeMake(width, height * pages.count);
    
    //循環添加view
    for (NSInteger i = 0; i < pages.count; i ++) {
        UIView *view = [pages objectAtIndex:i];
        view.userInteractionEnabled = false;
        //設置按鈕
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i * height, width, height)];
        button.tag = i - 1;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:view];
        //添加view到scrollView上
        [scrollView addSubview:button];
    }
    
    //設置初始滾動的位置為第二個view
    scrollView.contentOffset = CGPointMake(0, height);
}

- (id)loadNibWithName:(NSString *)nibName
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    [[nibView firstObject] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    return [nibView firstObject];
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
    CGFloat width = CGRectGetWidth(scrollView.frame);
    CGFloat height = CGRectGetHeight(scrollView.frame);
    
    switch (scrollingDirection) {
        case HorizontalScrolling:
            //當滾動到最後的時候
            if (point.x / width > numberOfPages) {
                [scrollView setContentOffset:CGPointMake(width, 0) animated:false];
            }
            //當滾動到最前的時候
            else if (point.x / width < 1) {
                [scrollView setContentOffset:CGPointMake(width * numberOfPages, 0) animated:false];
            }
            break;
            
        case VeritcalScrolling:
            //當滾動到最後的時候
            if (point.y / height > numberOfPages) {
                [scrollView setContentOffset:CGPointMake(0, height) animated:false];
            }
            //當滾動到最前的時候
            else if (point.y / height < 1) {
                [scrollView setContentOffset:CGPointMake(0, height * numberOfPages) animated:false];
            }
            break;
            
        default:
            break;
    }
}

//一邊滾動一邊設置pageControl的currentPage
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (hasPageControl) {
        CGPoint point = scrollView.contentOffset;
        CGFloat width = CGRectGetWidth(scrollView.frame);
        CGFloat height = CGRectGetHeight(scrollView.frame);
        NSInteger currentPage;
        
        switch (scrollingDirection) {
            case HorizontalScrolling:
                //當滾動到最後的時候
                if (point.x / width > numberOfPages) {
                    currentPage = pages.count - 1;
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
                if (point.y / height > pages.count) {
                    currentPage = pages.count - 1;
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
        
        [pageControl setCurrentPage:currentPage];
    }
}

@end
