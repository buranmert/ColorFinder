//
//  UIImage+ColorFinder.h
//  ColorFinder
//
//  Created by Mert Buran on 13/04/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorFinder)
- (void)getDominantColorWithCompletionHandler:(void (^)(UIColor*))completion;
@end
