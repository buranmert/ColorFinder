# ColorFinder
##### Dominant color finder on UIImage on iOS
It does clustering on the image. It varies but usually takes between 0.05 sec and 0.1 sec

(This repo is already an example for this category but, again:)
#### Example Usage:
```
#import "UIImage+ColorFinder.h"
...
@property (...) UIImageView *sourceImageView;
...
- (void)getDominantColor {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //inRect is to be implemented, it is useless currently
        [self.sourceImageView.image getDominantColorInRect:CGRectZero WithCompletionHandler:^(UIColor *dominantColor) {
            [self.resultView setBackgroundColor:dominantColor];
            ...do something...
        }];
    });
}
```
