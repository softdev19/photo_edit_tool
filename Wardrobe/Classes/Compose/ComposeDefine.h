//
//  ComposeDefine.h
//  Wardrobe
//
//  Created by GoldenSpear1 on 25/04/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#ifndef ComposeDefine_h
#define ComposeDefine_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import "Utils.h"
#import "FloodFillImageView.h"
#import "ProgressHUD.h"

#define LAYOUTNOTIFICATION @"layoutNotification"

#define IMAGE_ADD_UPLOAD        300
#define IMAGE_ADD_CAMERA        301
#define IMAGE_ADD_SEARCH        302
#define IMAGE_ADD_PRODUCTS      303
#define IMAGE_ADD_BRANDS        304
#define IMAGE_DELETE            310
#define IMAGE_FORMAT_TARGET     320
#define IMAGE_FORMAT_ERASE      321
#define IMAGE_FORMAT_RESTORE    322
#define IMAGE_COPY              330
#define IMAGE_FLIP_HORIZONTAL   340
#define IMAGE_FLIP_VERTICAL     341
#define IMAGE_ROTATE_90         350
#define IMAGE_ROTATE_180        351

#define LAYOUT_LIST_FILE         @"LayoutTemplates.plist"

//segue
#define SEGUE_EDIT_LAYOUT  @"editToLayoutSegue"

//color
#define GSyellowColor           [UIColor yellowColor]
#define GSlightGrayColor        [UIColor lightGrayColor]
#define GSlightGrayAlphaColor   [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5]
#define GSwhiteColor            [UIColor whiteColor]
#define GSclearColor            [UIColor clearColor]
#define GSblackColor            [UIColor blackColor]
#define GSredColor              [UIColor redColor]

NSInteger selectedLayoutNumber;

//temp - layout templates
#define tempNumber 52
#define Non_Square_Number    35
#define Thumnail_Temp_Number 7

#endif /* ComposeDefine_h */
