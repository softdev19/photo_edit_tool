//
//  ERImageView.h
//  backgroundEraser
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ERImageView;

@protocol ERImageViewTouchDelegate

@optional

-(void)ActionFinished:(UIImage*)image Mask:(UIImage *)mask;
@end

@interface ERImageView : UIImageView<UIGestureRecognizerDelegate>{
    CGPoint lastPoint;
}

-(void)setPanGes;
-(void)initOriginalImage;

@property (retain, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (retain, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (assign, nonatomic)  int radius;
@property (assign, nonatomic)  int state;
@property (strong, nonatomic)  UIImage *origialImage;
@property (strong, nonatomic)  UIImage *mainImage;
@property (strong, nonatomic)  UIImage *maskImage;
@property (nonatomic, retain) id<ERImageViewTouchDelegate> delegate;

@end
