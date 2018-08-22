//
//  FloodFillImageView.h
//  ImageFloodFilleDemo
//


#import <UIKit/UIKit.h>
#import "UIImage+FloodFill.h"

@class FloodFillImageView;

@protocol FloodFillImageViewTouchDelegate

@optional

-(void)ActionFinished:(UIImage*)image Mask:(UIImage *)mask Type:(int)type Tag:(NSInteger)tag;
-(void)getTag:(NSInteger)value;

@end



@interface FloodFillImageView : UIImageView<UIGestureRecognizerDelegate> {
    CGPoint lastPoint;
}

@property (assign, nonatomic)  int radius;
@property (assign, nonatomic)  int state;
@property (assign, nonatomic)  CGFloat lastScale;
@property (strong, nonatomic)  UIImage *mainImage;
@property (strong, nonatomic)  UIImage *maskImage;

@property int tolorance;
@property (strong, nonatomic)  UIColor *newcolor;

@property (strong, nonatomic)  UIImageView *chImageView;
@property (assign, nonatomic)  int firstX;
@property (assign, nonatomic)  int firstY;

@property (assign, nonatomic)  int dirX;
@property (assign, nonatomic)  int dirY;

@property (retain, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (retain, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (retain, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;

@property (nonatomic, retain) id<FloodFillImageViewTouchDelegate> delegate;
-(void)setPanGes;
-(void)setPinchGes;
@end
