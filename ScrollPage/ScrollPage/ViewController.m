//
//  ViewController.m
//  ScrollPage
//
//  Created by yuchi on 2017/1/6.
//  Copyright © 2017年 Yuchi Chen. All rights reserved.
//

#import "ViewController.h"
#import "BannerScrollView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController () <BannerScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //store class name of view in pages
    NSMutableArray *pages = [NSMutableArray arrayWithArray:@[@"Page0", @"Page1", @"Page2", @"Page3"]];
    
    CGFloat width = 200;
    CGFloat height = 200;
    CGRect rect = CGRectMake((SCREEN_WIDTH / 2) - (width / 2), (SCREEN_HEIGHT / 2) - (height / 2), width, height);

    BannerScrollView *bannerScrollView = [[BannerScrollView alloc] initWithFrame:rect
                                                                classNamesOfView:pages
                                                              scrollingDirection:HorizontalScrolling
                                                                  andPageControl:true];
    bannerScrollView.delegate = self;
    [self.view addSubview:bannerScrollView];
}

#pragma mark - BannerScrollViewDelegate

- (void)bannerScrollViewDidSelectViewAtIndex:(NSInteger)index
{
    NSLog(@"%ld", (long)index);
}

@end
