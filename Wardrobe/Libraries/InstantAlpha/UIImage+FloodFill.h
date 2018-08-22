//
//  UIImage+FloodFill.h
//  ImageFloodFilleDemo
//


#import <UIKit/UIKit.h>
#import "LinkedListStack.h"

@interface UIImage (FloodFill)

-(UIImage *)changeWhiteColorTransparent: (UIImage *)image;
- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance;
- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance withFrame:(UIImageView*)frame;
- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance useAntiAlias:(BOOL)antiAlias withFrame:(UIImageView*)imframe;


@end