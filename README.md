# BannerScrollView
`BannerScrollView` is a clean and easy-to-use banner on iOS.

## How To Use
Just import the header file and create an instance of `BannerScrollView`.
```objective-c
#import "BannerScrollView.h"

...

BannerScrollView *bannerScrollView = [[BannerScrollView alloc] initWithFrame:frame
                                                            classNamesOfView:mutableArray
                                                          scrollingDirection:HorizontalScrolling
                                                              andPageControl:true];
bannerScrollView.delgate = self;
[self.view addSubview:bannerScrollView];
```

### Gesture Interaction

```objective-c
- (void)bannerScrollViewDidSelectViewAtIndex:(NSInteger)index;
```
