//
//  FloodFillImageView.m
//  ImageFloodFilleDemo
//

#import "FloodFillImageView.h"
#import <AVFoundation/AVFoundation.h>

#define state_eraser            20005
#define state_restore           20006
#define state_target            20007
#define state_copy              20003


@implementation FloodFillImageView

@synthesize panRecognizer, tapRecognizer, pinchRecognizer;
@synthesize tolorance,newcolor,firstX,firstY,dirX,dirY, chImageView;
@synthesize radius, state, mainImage, maskImage, lastScale;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Get touch Point
    CGPoint tpoint = [[[event allTouches] anyObject] locationInView:self];
    UITouch* touch = [touches anyObject];
    tpoint = [touch locationInView:self];
    
    //Convert Touch Point to pixel of Image
    //This code will be according to your need
    
    firstY = tpoint.y;
    firstX = tpoint.x;
    dirY=0;
    dirX=0;
    
    lastPoint = tpoint;
}


-(void)setPanGes{

    self.userInteractionEnabled = true;
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self addGestureRecognizer:panRecognizer];
    
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [tapRecognizer setDelegate:self];
    [self addGestureRecognizer:tapRecognizer];
    
    [self setBackgroundColor:[UIColor clearColor]];
    maskImage = [self clearImageWithColor:self.bounds];

    [self.delegate getTag:self.tag];
}
-(void)setPinchGes;
{
    self.userInteractionEnabled = true;
    lastScale = 0;
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandle:)];
    [pinchRecognizer setDelegate:self];
    [self addGestureRecognizer:pinchRecognizer];
    [self setBackgroundColor:[UIColor clearColor]];
    maskImage = [self clearImageWithColor:self.bounds];
    
    [self.delegate getTag:self.tag];

}
-(void)tap:(UITapGestureRecognizer*)sender
{
    NSLog(@"tap %ld ",self.tag);
    [Utils CustomiseView:sender.view withColor:GSyellowColor withWidth:1.0 withCorner:0.0];
    [self.delegate getTag:self.tag];
    if (state == state_eraser || state == state_restore) {
        CGPoint touchPoint = [sender locationInView:self];
        [self drawLineFrom:lastPoint toPoint:touchPoint];
        [self.delegate ActionFinished:self.image Mask:maskImage Type:1 Tag:self.tag];// type:1-eraser/restore, 2:instant alpha
    }
    
}
-(void)pinchHandle:(UIPinchGestureRecognizer *)gestureRecognizer
{
    CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
    
    // Constants to adjust the max/min values of zoom
    const CGFloat kMaxScale = 5.0;
    const CGFloat kMinScale = 0.5;
    
    CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]);
    newScale = MIN(newScale, kMaxScale / currentScale);
    newScale = MAX(newScale, kMinScale / currentScale);
    CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
    [gestureRecognizer view].transform = transform;
    
    lastScale = [gestureRecognizer scale];
}
-(void)move:(UIPanGestureRecognizer*)sender {
    if (state == state_target)
    {
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
        
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            
        }
        
        int diffx,diffy;
        
        //Calculate how much figur moved from starting point
        
        diffx=fabs(firstX-fabs(firstX+translatedPoint.x));
        diffy=fabs(firstY-fabs(firstY+translatedPoint.y));
        
        if(diffx>diffy)
        {
            tolorance=0+(diffx);
        }
        else
        {
            tolorance=0 + (diffy);
        }
        
        //Redraw image the from starting point to show instant alpha effect
        translatedPoint = CGPointMake(firstX, firstY);
        
        //Call function to flood fill and get new image with filled color
        UIImage *image1 = [self.image floodFillFromPoint:translatedPoint withColor:[self.newcolor colorWithAlphaComponent:0.0] andTolerance:tolorance withFrame:self];
        image1 = [image1 changeWhiteColorTransparent:image1]; // RED Color Issue here

        // TEST for Merging Instant Alpha & Eraser tool
        
        //        maskImage = [maskImage floodFillFromPoint:translatedPoint withColor:[self.newcolor colorWithAlphaComponent:0.0] andTolerance:tolorance withFrame:self];
        //        maskImage = [maskImage changeWhiteColorTransparent:maskImage];

        if([sender state] == UIGestureRecognizerStateEnded) {
            [self.delegate ActionFinished:self.image Mask:maskImage Type:2 Tag:self.tag];
        }
        else {
//            [self drawLineFrom:lastPoint toPoint:translatedPoint];
//            lastPoint = translatedPoint;
        }
        //Update UIImageView with new Image Asyncronousely
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self setImage:image1];
                       });
    }
    else if(state == state_eraser || state == state_restore) {
        CGPoint touchPoint = [sender locationInView:self];
        
        if(sender.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"start");
        }
        else if(sender.state == UIGestureRecognizerStateEnded)
        {
            [self.delegate ActionFinished:self.image Mask:maskImage Type:1 Tag:self.tag];
        }
        else
        {
            [self drawLineFrom:lastPoint toPoint:touchPoint];
            lastPoint = touchPoint;
        }
    }
    else if (state == state_copy)
    {
        {
            CGPoint touchPoint = [sender locationInView:sender.view]; // get touched point
            
            
            [self setCenter:touchPoint]; // set touched thumb view's center to touchPoint
            
            
            if (sender.state ==UIGestureRecognizerStateEnded) {
                NSLog(@"end...");

                FloodFillImageView *img = (FloodFillImageView*)sender.view;
                FloodFillImageView *thumbView = [[FloodFillImageView alloc] initWithFrame:self.frame];
                thumbView.image = img.image;
                [thumbView setImage:[img.image changeWhiteColorTransparent:img.image]];
                [thumbView setChImageView:self];
                thumbView.tag = img.tag + 10;
                thumbView.clipsToBounds = YES;
                thumbView.contentMode = UIViewContentModeScaleAspectFill;
                [thumbView setOpaque:NO];
                
                thumbView.tolorance = 0;
                thumbView.delegate=self.delegate;
                [thumbView setPanGes];
                [thumbView setRadius:10];
                [thumbView setMainImage:thumbView.image];
               [self.superview addSubview:thumbView];
               
                state = 0;
                //save info
                [self.delegate ActionFinished:thumbView.image Mask:[self clearImageWithColor:thumbView.bounds]  Type:3 Tag:self.tag];
//                [self saveEditInfo:viewImage withNumber:selectedEditImageNumber];
                //            [self saveEditedImage:(UIImageView *)sender.view];
                
            }else if(sender.state ==UIGestureRecognizerStateBegan)
            {
                NSLog(@"starting...");
                NSLog(@"tag = %ld", sender.view.tag);
                
            }else{
                //TODO
            }
        }
     }
    else
    {
//        CGPoint translation = [sender translationInView:self.superview];
//        sender.view.center = CGPointMake(sender.view.center.x + translation.x,
//                                             sender.view.center.y + translation.y);
//        [sender setTranslation:CGPointMake(0, 0) inView:self.superview];
    }
    
}

-(void)drawLineFrom:(CGPoint)point1 toPoint:(CGPoint)point2
{
    [self setTransform:CGAffineTransformIdentity];
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [maskImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
//    CGFloat imageViewRatio = CGRectGetWidth(self.frame)/CGRectGetHeight(self.frame);
//    CGFloat imageRatio = self.image.size.width/self.image.size.height;
//
//    CGFloat startValX = (imageRatio * point1.x) / imageViewRatio;
//    CGFloat startValY = (imageRatio * point1.y) / imageViewRatio;
//
//    CGFloat endValX = (imageRatio * point2.x) / imageViewRatio;
//    CGFloat endValY = (imageRatio * point2.y) / imageViewRatio;
    
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, radius);// set width here radius when require
    
//    if(state == state_eraser)
    if(state == state_eraser || state == state_target)
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
    [self maskFrom:point1 toPoint:point2];
}

-(void)maskFrom:(CGPoint)point1 toPoint:(CGPoint)point2
{
//    CGFloat imageViewRatio = CGRectGetWidth(self.frame)/CGRectGetHeight(self.frame);
//    CGFloat imageRatio = self.image.size.width/self.image.size.height;
//
//    CGFloat startValX = (imageRatio * point1.x) / imageViewRatio;
//    CGFloat startValY = (imageRatio * point1.y) / imageViewRatio;
//
//    CGFloat endValX = (imageRatio * point2.x) / imageViewRatio;
//    CGFloat endValY = (imageRatio * point2.y) / imageViewRatio;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImage:mainImage];
    UIImage *image = [self imageWithView:imageView];
 
    CGRect maskRect=CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0f);
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) blendMode:kCGBlendModeNormal alpha:1];
    
    [maskImage drawInRect:maskRect blendMode:kCGBlendModeDestinationOut alpha:1];
    UIImage *result =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = result;
}
- (UIImage *)clearImageWithColor:(CGRect )frame
{
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, frame);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end