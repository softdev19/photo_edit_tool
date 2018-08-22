//
//  ERImageView.m
//  backgroundEraser
//
//

#import "ERImageView.h"

#define state_eraser    100
#define state_restore   200

@implementation ERImageView
@synthesize radius, state, panRecognizer, origialImage, mainImage, maskImage, tapRecognizer;

-(void)setPanGes{
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self addGestureRecognizer:panRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [tapRecognizer setDelegate:self];
    [self addGestureRecognizer:tapRecognizer];
}

-(void)initOriginalImage {
    [self setBackgroundColor:[UIColor clearColor]];
    maskImage = [UIImage new];
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 1.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    origialImage = viewImage;
}

-(void)tap:(UITapGestureRecognizer*)sender {
    CGPoint touchPoint = [sender locationInView:self];
    [self drawLineFrom:lastPoint toPoint:touchPoint];
    [self.delegate ActionFinished:self.image Mask:maskImage];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[[event allTouches] anyObject] locationInView:self];
    lastPoint = touchPoint;
}

-(void)move:(UIPanGestureRecognizer*)sender {
    CGPoint touchPoint = [sender locationInView:self];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"start");
    } else if(sender.state == UIGestureRecognizerStateEnded) {
        [self.delegate ActionFinished:self.image Mask:maskImage];
    } else {
        [self drawLineFrom:lastPoint toPoint:touchPoint];
        lastPoint = touchPoint;
    }
    
}

-(void)drawLineFrom:(CGPoint)point1 toPoint:(CGPoint)point2
{
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [maskImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, radius);// set width here radius when require
 
    if(state == state_eraser)
    {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
    else
    {
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextStrokePath(context);
    
    maskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    [self mask];
}

-(void)mask
{
    CGRect rect=CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [mainImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1];
    [maskImage drawInRect:rect blendMode:kCGBlendModeDestinationOut alpha:1];
    UIImage *result =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = result;
}

@end
