//
//  UIImage+ColorFinder.m
//  ColorFinder
//
//  Created by Mert Buran on 13/04/15.
//  Copyright (c) 2015 Mert Buran. All rights reserved.
//

#import "UIImage+ColorFinder.h"

static const CGFloat CFColorThreshold = 80.f;
static const CGFloat CFInversePrecisionFactor = 16;

@interface CFPoint: NSObject
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat alpha;
@end

@implementation CFPoint

- (CGFloat)getDistanceToPoint:(CFPoint *)otherPoint {
    CGFloat distance = 0.f;
    distance += fabs(self.red - otherPoint.red);
    distance += fabs(self.green - otherPoint.green);
    distance += fabs(self.blue - otherPoint.blue);
    distance += fabs(self.alpha - otherPoint.alpha);
    return distance;
}

- (UIColor *)getColor {
    return [UIColor colorWithRed:self.red/255.f green:self.green/255.f blue:self.blue/255.f alpha:self.alpha/255.f];
}

@end

@interface CFCluster : NSObject
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) CFPoint *center;
@end

@implementation CFCluster

- (instancetype)initWithPoint:(CFPoint *)point {
    self = [super init];
    if (self != nil) {
        _points = [NSMutableArray arrayWithObject:point];
        _center = point;
    }
    return self;
}

- (void)addPoint:(CFPoint *)point {
    [self updateCenterWithNewPoint:point];
    [self.points addObject:point];
}

- (NSUInteger)getWeight {
    return self.points.count;
}

- (void)updateCenterWithNewPoint:(CFPoint *)newPoint {
    CGFloat red = ((self.center.red * self.points.count) + newPoint.red) / (self.points.count + 1);
    CGFloat green = ((self.center.green * self.points.count) + newPoint.green) / (self.points.count + 1);
    CGFloat blue = ((self.center.blue * self.points.count) + newPoint.blue) / (self.points.count + 1);
    CGFloat alpha = ((self.center.alpha * self.points.count) + newPoint.alpha) / (self.points.count + 1);
    CFPoint *newCenter = [CFPoint new];
    newCenter.red = red;
    newCenter.green = green;
    newCenter.blue = blue;
    newCenter.alpha = alpha;
    self.center = newCenter;
}

@end

@implementation UIImage (ColorFinder)

- (void)getDominantColorInRect:(CGRect)rect WithCompletionHandler:(void (^)(UIColor* dominantColor))completion {
    // First get the image into your data buffer
    
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    unsigned char *rawData = (unsigned char*) calloc(height * width * bytesPerPixel, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger rawDataCount = height * width * bytesPerPixel;
    NSMutableArray *clusterArray = [NSMutableArray array];
    for (int byteIndex = 0 ; byteIndex + bytesPerPixel*CFInversePrecisionFactor < rawDataCount ; byteIndex += bytesPerPixel * CFInversePrecisionFactor) {
        CFPoint *point = [CFPoint new];
        point.red   = rawData[byteIndex] * 1.f;
        point.green = rawData[byteIndex+1] * 1.f;
        point.blue  = rawData[byteIndex+2] * 1.f;
        point.alpha = rawData[byteIndex+3] * 1.f;
        
//        if (point.red < 180.f && point.green < 120.f && point.blue < 120.f) {
//            continue;
//        }
        
        __block NSInteger clusterIndex = -1;
        __block CGFloat closestDistance = CGFLOAT_MAX;
        [clusterArray enumerateObjectsUsingBlock:^(CFCluster *cluster, NSUInteger idx, BOOL *stop) {
            CGFloat distance = [cluster.center getDistanceToPoint:point];
            if (distance < CFColorThreshold && distance < closestDistance) {
                closestDistance = distance;
                clusterIndex = idx;
            }
        }];
        
        if (clusterIndex >= 0) {
            [((CFCluster *)[clusterArray objectAtIndex:clusterIndex]) addPoint:point];
        }
        else {
            CFCluster *newCluster = [[CFCluster alloc] initWithPoint:point];
            [clusterArray addObject:newCluster];
        }
        byteIndex += bytesPerPixel;
    }
    free(rawData);
    
    CFCluster *tempCluster = nil;
    for (CFCluster *cluster in clusterArray) {
        if (tempCluster == nil || [cluster getWeight] > [tempCluster getWeight]) {
            tempCluster = cluster;
        }
    }
    UIColor *dominantColor = [tempCluster.center getColor];
#ifdef DEBUG
    NSLog(@"%f %f %f %f", tempCluster.center.red, tempCluster.center.green, tempCluster.center.blue, tempCluster.center.alpha);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(dominantColor);
    });
}

@end
