//
//  ViewController.m
//  ColorFinder
//
//  Created by Mert Buran on 13/04/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ColorFinder.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self.sourceImageView setImage:[UIImage imageNamed:@"balloons"]];
//    [self.sourceImageView setImage:[UIImage imageNamed:@"messi"]];
    [self.sourceImageView setImage:[UIImage imageNamed:@"orchard"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getDominantColor];
}

- (void)getDominantColor {
    NSDate *start = [NSDate date];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.sourceImageView.image getDominantColorInRect:CGRectZero WithCompletionHandler:^(UIColor *dominantColor) {
            [self.resultView setBackgroundColor:dominantColor];
            NSDate *end = [NSDate date];
            NSTimeInterval duration = [end timeIntervalSinceDate:start];
            NSLog(@"%f", duration);
        }];
    });
}

@end
