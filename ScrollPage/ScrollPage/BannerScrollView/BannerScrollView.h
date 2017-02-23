//
//  BannerScrollView.h
//  ScrollPage
//
//  Created by Yuchi Chen on 2017/1/9.
//  Copyright © 2017年 Yuchi Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ScrollingDirection)
{
    HorizontalScrolling = 0,
    VeritcalScrolling,
};

@protocol BannerScrollViewDelegate <NSObject>

@optional
- (void)bannerScrollViewDidSelectViewAtIndex:(NSInteger)index;

@end

@interface BannerScrollView : UIView

@property (nonatomic, weak) id<BannerScrollViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame classNamesOfView:(NSMutableArray *)classNamesOfView scrollingDirection:(ScrollingDirection)direction andPageControl:(BOOL)hasPageControl;

@end
