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
    ScrollingDirection scrollingDirection;
    NSInteger numberOfPages; //page0 - page1 - page2 - page3
    BOOL hasPageControl;
}
@property (nonatomic, strong) NSMutableArray *pages; //lastPage - page0 - page1 - page2 - page3 - firstPage
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation BannerScrollView

- (instancetype)initWithFrame:(CGRect)frame classNamesOfView:(NSMutableArray *)classNamesOfView scrollingDirection:(ScrollingDirection)direction andPageControl:(BOOL)bl
{
    self = [super initWithFrame:frame];
    if (self) {
        numberOfPages = classNamesOfView.count;
        hasPageControl = bl;
        scrollingDirection = direction;
        [self setPages:classNamesOfView];
        [self addSubview:self.scrollView];
        if (hasPageControl) {
            [self addSubview:self.pageControl];
        }
    }
    return self;
}

#pragma mark - Setter

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = true;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        
        switch (scrollingDirection) {
            case HorizontalScrolling:
                _scrollView = [self setHorizontalScrollView];
                break;
                
            case VeritcalScrolling:
                _scrollView = [self setVerticalScrollView];
                break;
                
            default:
                break;
        }
    }
    return _scrollView;
}

- (void)setPages:(NSMutableArray *)views
{
    if (_pages == nil) {
        _pages = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < views.count + 2; i ++) {
            if (i == 0) {
                [_pages addObject:[self loadNibWithName:views.lastObject]];
            }
            else if (i == views.count + 1) {
                [_pages addObject:[self loadNibWithName:views.firstObject]];
            }
            else {
                [_pages addObject:[self loadNibWithName:[views objectAtIndex:i - 1]]];
            }
        }
    }
}

- (UIPageControl *)pageControl
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        
        switch (scrollingDirection) {
            case HorizontalScrolling:
                _pageControl.frame = CGRectMake(0, height - 30, width, 20);
                break;
                
            case VeritcalScrolling:
                _pageControl.frame = CGRectMake(30, 0, 20, height);
                _pageControl.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
                
            default:
                break;
        }
        
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = numberOfPages;
        //關閉pageControl的點擊功能
        _pageControl.enabled = false;
    }
    return _pageControl;
}

#pragma mark - Private

- (id)loadNibWithName:(NSString *)nibName
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    [[nibView firstObject] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    return [nibView firstObject];
}

- (UIScrollView *)setHorizontalScrollView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _scrollView.contentSize = CGSizeMake(width * _pages.count, height);
    
    //循環添加view
    for (NSInteger i = 0; i < _pages.count; i ++) {
        UIView *view = [_pages objectAtIndex:i];
        view.userInteractionEnabled = false;
        //設置按鈕
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        
        button.tag = i - 1;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:view];
        //添加view到scrollView上
        [_scrollView addSubview:button];
    }
    
    //設置初始滾動的位置為第二個view
    _scrollView.contentOffset = CGPointMake(width, 0);
    return _scrollView;
}

- (UIScrollView *)setVerticalScrollView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _scrollView.contentSize = CGSizeMake(width, height * _pages.count);
    
    //循環添加view
    for (NSInteger i = 0; i < _pages.count; i ++) {
        UIView *view = [_pages objectAtIndex:i];
        view.userInteractionEnabled = false;
        //設置按鈕
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i * height, width, height)];
        button.tag = i - 1;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:view];
        //添加view到scrollView上
        [_scrollView addSubview:button];
    }
    
    //設置初始滾動的位置為第二個view
    _scrollView.contentOffset = CGPointMake(0, height);
    return _scrollView;
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
        CGFloat width = scrollView.frame.size.width;
        CGFloat height = scrollView.frame.size.height;
        NSInteger currentPage;
        
        switch (scrollingDirection) {
            case HorizontalScrolling:
                //當滾動到最後的時候
                if (point.x / width > numberOfPages) {
                    currentPage = _pages.count - 1;
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
                if (point.y / height > _pages.count) {
                    currentPage = _pages.count - 1;
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
        
        [_pageControl setCurrentPage:currentPage];
    }
}

@end
