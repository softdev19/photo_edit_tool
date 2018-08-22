//
//  Utils.m
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+ (void)setObjectToUserDefaults:(id)object inUserDefaultsForKey:(NSString*)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getObjectFromUserDefaultsForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    //Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    //Draw your image
    [image drawInRect:rect];
    
    //Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(void)CustomiseView:(UIView *)view withColor:(UIColor*)color withWidth:(float)width withCorner:(float)corner{
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
    view.layer.cornerRadius = corner;
    view.layer.masksToBounds = YES;
}

-(CGFloat)getDistance:(CGPoint)p1 withP2:(CGPoint)p2 {
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

+ (UIBezierPath*)createPath:(NSArray*)ary withView:(UIView*)view
{
    CGFloat base = 600;
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    
    UIBezierPath* path = [[UIBezierPath alloc]init];
    
    CGFloat cx = 0.0, cy = 0.0;
    for (int i = 0; i < ary.count; i++) {
        NSDictionary *pointInfo = ary[i];
        CGFloat x = [[pointInfo objectForKey:@"x"] floatValue] * width / base + 1;
        CGFloat y = [[pointInfo objectForKey:@"y"] floatValue] * height / base + 1;
        CGPoint pt = CGPointMake(x, y);
        
        cx += x;
        cy += y;
        
        if (i == 0) {
            [path moveToPoint:pt];
        } else if(i > 0 && i < ary.count) {
            [path addLineToPoint:pt];
        } else {
            [path closePath];
        }
    }
    
    return path;
}

+ (CGRect)getFrameByInfo:(NSDictionary*)info withView:(UIView*)view
{
    CGRect rect;
    CGFloat base = 600;
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    CGFloat x = [[info objectForKey:@"x"] floatValue] * width / base + 1;
    CGFloat y = [[info objectForKey:@"y"] floatValue] * height / base + 1;
    CGFloat w = [[info objectForKey:@"w"] floatValue] * width / base - 2;
    CGFloat h = [[info objectForKey:@"h"] floatValue] * height / base - 2;
    
    rect = CGRectMake(x, y, w, h);
    return rect;
}

+ (UIImage *)changeBlackColorTransparent: (UIImage *)image
{
    
    
    const CGFloat colorMasking[6]={0.0,0.0,0.0,0.0,0.0,0.0};
    
    CGImageRef oldImage = image.CGImage;
    
    CGBitmapInfo oldInfo = CGImageGetBitmapInfo(oldImage);
    
    CGBitmapInfo newInfo = (oldInfo & (UINT32_MAX ^ kCGBitmapAlphaInfoMask)) | kCGImageAlphaNoneSkipLast;
    
    CGDataProviderRef provider = CGImageGetDataProvider(oldImage);
    
    CGImageRef newImage = CGImageCreate(image.size.width, image.size.height, CGImageGetBitsPerComponent(oldImage), CGImageGetBitsPerPixel(oldImage), CGImageGetBytesPerRow(oldImage), CGImageGetColorSpace(oldImage), newInfo, provider, NULL, false, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(provider); provider = NULL;
    CGImageRef im = CGImageCreateWithMaskingColors(newImage, colorMasking);
    UIImage *ret = [UIImage imageWithCGImage:im];
    CGImageRelease(im);
    
    return ret;
    
}

@end

@implementation NSString (containsCategory)
- (BOOL) containsString:(NSString *)substring{
    NSRange range = [self rangeOfString:substring];
    BOOL found = (range.location != NSNotFound);
    return found;
}

@end