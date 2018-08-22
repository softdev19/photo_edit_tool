//
//  ComposeVC.m
//  Wardrobe
//
//  Created by GoldenSpear1 on 25/04/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "ComposeVC.h"
#import "ComposeDefine.h"
#import "CCMenuView.h"
#include <AssetsLibrary/AssetsLibrary.h>
#import "LayoutVC.h"
#import "LayoutCollectionViewCell.h"

#define NO_SELECTED  999
#define TAG_TEMPLATES 10000
#define TAG_FFIVIEW   30000
#define TAG_IMGVIEW   40000

#define state_normal            20000
#define state_draw              20001
#define state_text              20002
#define state_copy              20003
#define state_search            20004
#define state_eraser            20005
#define state_restore           20006
#define state_target            20007


@interface ComposeVC () <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, FloodFillImageViewTouchDelegate>{
    
    //TopView
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UIButton *undoButton;
    __weak IBOutlet UIButton *resetButton;
    __weak IBOutlet UIButton *redoButton;
    __weak IBOutlet UIButton *closeButton;
    
    //EditView
    __weak IBOutlet UIView *editView;
    IBOutlet UIView *sharingView;
    //Main BottomView
    __weak IBOutlet UIView *bottomView1;
    __weak IBOutlet UIScrollView *BSView1;
    __weak IBOutlet UIView *bottomView2;
    __weak IBOutlet UIScrollView *BSView2;
    __weak IBOutlet UIView *bottomView3;
    __weak IBOutlet UIScrollView *BSView3;
    
    //Search View
    IBOutlet UIView *searchView;
    IBOutlet UILabel *srhTitleLbl;
    IBOutlet UITextField *srhtxtFld;
    IBOutlet NSLayoutConstraint *srhTopConstraint;
    NSArray *srhAry;
    NSInteger  aryCount;
    
    //selected numbers for mainMenu, subMenu, thirdMenu items
    NSInteger selectedMenuItem, selectedSubMenuItem, selectedThirdMenuItem;
    
    //state
    int state;
    
    //layout template info
    NSArray *templateInfo;
    
    //check layout is non-square
    BOOL isSquare;
    
    //selected template cell number
    NSInteger selectedEditImageNumber;
    
    //thumbnails Array
    NSMutableArray *thumbAry;
    
    NSInteger currentffViewTag;
    
    //save info
    NSMutableArray *saveInfo;
    int stepNumber;
    UIImage *oldImg;
    
    NSMutableArray *undoData, *redoData;
    NSMutableArray *undoMask, *redoMask;
}

@property (strong, nonatomic) IBOutlet UICollectionView *srhCollectionView;
@property (strong, nonatomic)  FloodFillImageView *changedImage;

@end

@implementation ComposeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init Frames
    [self initFrames];
}

-(void)initFrames {
    
    /*
     ___________________________________________
     |                                           |
     |                                           |
     |                                           |
     |              Edit Area                    |
     |          (editView, SharingView)          |
     |                                           |
     |___________________________________________|
     |      ThirdMenu - bottomView3              |
     |___________________________________________|
     |      SubMenu - bottomView2                |
     |___________________________________________|
     |      MainMunu - bottomView1               |
     |___________________________________________|
     */
    
    selectedMenuItem = NO_SELECTED;
    selectedSubMenuItem = NO_SELECTED;
    selectedThirdMenuItem = NO_SELECTED;
    state = state_normal;
    
    aryCount = 0;
    
    saveInfo = [[NSMutableArray alloc] init];
    stepNumber = 0;
    
    //init thumbnail array
    thumbAry = [[NSMutableArray alloc] init];
    for (int i = 0; i < Thumnail_Temp_Number; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"t%i.png", i]];
        [thumbAry addObject:image];
    }
    
    //set Main MenuView
    [self setMainBottomView];
//    undoData = [[NSMutableArray alloc] init];
//    redoData = [[NSMutableArray alloc] init];
//    undoMask = [[NSMutableArray alloc] init];
//    redoMask = [[NSMutableArray alloc] init];
    
    
    
    //set SharingView, default layout template is 0
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(initLayoutTemp:) userInfo: nil repeats: NO];
}

#pragma mark - Set Layout Template

-(void)initLayoutTemp:(NSTimer*) t {
    [self setLayoutImage:0];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //add NSNotificationCenter for layout template event
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changedLayoutTemp:) name:LAYOUTNOTIFICATION object:nil];
}

- (void)changedLayoutTemp:(NSNotification *)notification{
    [self setLayoutImage:selectedLayoutNumber];
}

-(void)setLayoutImage:(NSInteger)num {
    [self removeAllSubviews:sharingView];
    
    templateInfo = nil;
    NSString * path = [[NSBundle mainBundle] pathForResource:LAYOUT_LIST_FILE ofType:nil];
    NSArray *templateAry = [NSArray arrayWithContentsOfFile:path];
    templateInfo = templateAry[num];
    
    
    if (num < Non_Square_Number) {
        isSquare = YES;
        
        for (int i = 0; i < templateInfo.count; i++)
        {
            NSDictionary *frameInfo = templateInfo[i];
            CGRect frame = [Utils getFrameByInfo:frameInfo withView:sharingView];
            FloodFillImageView *imgView = [[FloodFillImageView alloc] initWithFrame:frame];
            imgView.backgroundColor = GSlightGrayAlphaColor;
            imgView.contentMode = UIViewContentModeScaleAspectFit; // UIViewContentModeScaleAspectFill
            imgView.tag = TAG_FFIVIEW + i;
            imgView.userInteractionEnabled = YES;
            imgView.clipsToBounds = YES;
            [sharingView addSubview:imgView];
            
//            UIView *view = [[UIView alloc] initWithFrame:frame];
//            [view setBackgroundColor:GSclearColor];
//            [view addSubview:imgView];
//            [sharingView addSubview:view];
            
            //======================remove=============
            //add tap action
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLayout:)];
            [imgView addGestureRecognizer:gesture];
            
            //move gesture
//            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveEditImage:)];
//            [panRecognizer setMinimumNumberOfTouches:1];
//            [panRecognizer setDelegate:self];
//            [imgView addGestureRecognizer:panRecognizer];
            //======================remove=============//
        }
    }else {
        isSquare = NO;
        for (int i = 0; i < templateInfo.count; i++) {
            FloodFillImageView *imgView = [[FloodFillImageView alloc] initWithFrame:sharingView.frame];
            imgView.backgroundColor = GSlightGrayAlphaColor;
            imgView.tag = TAG_FFIVIEW + i;
            imgView.userInteractionEnabled = YES;
            imgView.clipsToBounds = YES;
            [sharingView addSubview:imgView];
            
            NSArray *pointAry = templateInfo[i];
            CAShapeLayer *shapeView = [[CAShapeLayer alloc] init]; //(CAShapeLayer *)imgView.layer.mask;//
            [shapeView setPath:[Utils createPath:pointAry withView:sharingView].CGPath];
            [shapeView setLineWidth:2.0f];
            [shapeView setStrokeColor:GSwhiteColor.CGColor];
            [shapeView setFillColor:GSlightGrayAlphaColor.CGColor];
            [[imgView layer] addSublayer:shapeView];
            imgView.layer.mask = shapeView;
            
            //======================remove=============
            //add tap action
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLayout:)];
            [imgView addGestureRecognizer:gesture];
            
            //move gesture
            //            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveEditImage:)];
            //            [panRecognizer setMinimumNumberOfTouches:1];
            //            [panRecognizer setDelegate:self];
            //            [imgView addGestureRecognizer:panRecognizer];
            //======================remove=============//
        }
    }
}

///======================remove=============///
- (void)tappedLayout:(UITapGestureRecognizer*)sender {
    NSLog(@"tapped template");
    for (int i = 0; i < templateInfo.count; i++) {
        FloodFillImageView *imgView = (FloodFillImageView*)[self.view viewWithTag:TAG_FFIVIEW + i];
        [Utils CustomiseView:imgView withColor:GSclearColor withWidth:1.0 withCorner:0.0];
    }
    
    if (selectedLayoutNumber < Non_Square_Number) {
        [Utils CustomiseView:sender.view withColor:GSyellowColor withWidth:1.0 withCorner:0.0];
        selectedEditImageNumber = sender.view.tag - TAG_FFIVIEW;
        currentffViewTag = sender.view.tag - TAG_FFIVIEW;
    } else {
        
    }
}

#pragma mark - Set BottomView

-(void)setMainBottomView {
    NSArray *items;
    NSInteger num;
    items = @[@"Layout", @"Text", @"Background", @"Images"];
    num = 4;
    
    CGFloat x = 0;
    CGFloat H = 64;
    CGFloat ih = 46;
    CGFloat width = self.view.bounds.size.width;
    CGFloat W = width/num;
    
    for(int i = 0; i < items.count; i++) {
        CCMenuView *view = [[CCMenuView alloc] initWithFrame:CGRectMake(x, 0, W, H)];
        view.tag = i + 10;
        view.title = items[i];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((W - ih)/2, 1, ih, ih)];
        iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"menu_%@.png", items[i]]];
        iconView.tag = i + 20;
        [view addSubview:iconView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ih + 2, W, 12)];
        label.backgroundColor = GSclearColor;
        label.text = items[i];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        //add tap action
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMenuView:)];
        [view addGestureRecognizer:gesture];
        
        [BSView1 addSubview:view];
        x += W;
    }
    
    BSView1.contentSize = CGSizeMake(MAX(width, W * items.count), 0);
    
}

- (void)tappedMenuView:(UITapGestureRecognizer*)sender
{
    
    [self resetStateToNormal];
    
    if (selectedMenuItem != NO_SELECTED ) {
        CCMenuView *view = (CCMenuView*)[self.view viewWithTag:selectedMenuItem + 10];
        UIImageView *previousImgView = (UIImageView*)[self.view viewWithTag:selectedMenuItem + 20];
        previousImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"menu_%@.png", view.title]];
    }
    
    CCMenuView *view = (CCMenuView*)sender.view;
    UIImageView *selectedImgView = (UIImageView*)[view viewWithTag:view.tag + 10];
    selectedImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"menu_%@_1.png", view.title]];
    
    selectedMenuItem = sender.view.tag - 10;
    
    [self menuViewEvents:selectedMenuItem];
}

-(void)menuViewEvents:(NSInteger)num {
    
    //remove all subMenus
    [self removeAllSubviews:BSView2];
    [self removeAllSubviews:BSView3];
    
    if (num == 0) {
        [self setThumbnails];
        [self performSegueWithIdentifier:SEGUE_EDIT_LAYOUT sender:self];
    } else {
        //set second bottomView
        [self setSubMenuView:num];
        //set third bottomView
        [self setThirdBottomView:num withFlag:NO];
    }
}

#pragma mark - Set 2nd BottomView

-(void)setSubMenuView:(NSInteger)num {
    
    BSView2.backgroundColor = GSwhiteColor;
    
    NSArray *items;
    if (num == 1) {
        items = @[@"Font", @"Colors", @"Size", @"Shadow", @"Transparent", @"Alignment", @"Paragraph", @"Rotate"];
    } else if(num == 2) {
        items = @[@"Upload", @"Clear", @"Search", @"Solid Color", @"Fade Color", @"Camera"];
    } else if(num == 3) {
        items = @[@"Add", @"Delete", @"Format", @"Copy", @"Flip", @"Rotate"];
    } else {
        items = nil;
    }
    
    CGFloat x = 0;
    CGFloat H = 64;
    CGFloat ih = 46;
    CGFloat width = self.view.bounds.size.width;
    CGFloat W = 80;
    if (items.count ==2) {
        x = (width - W *2) / items.count;
    } else {
        W = width/MIN(5, items.count);
    }
    
    for(int i = 0; i < items.count; i++) {
        CCMenuView *view = [[CCMenuView alloc] initWithFrame:CGRectMake(x, 0, W, H)];
        view.tag = i + 100;
        view.title = items[i];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((W - ih)/2, 1, ih, ih)];
        iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sm_%@.png", items[i]]];
        iconView.tag = i + 150;
        [view addSubview:iconView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ih + 2, W, 12)];
        label.backgroundColor = GSclearColor;
        label.text = items[i];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSubMenuView:)];
        [view addGestureRecognizer:gesture];
        
        [BSView2 addSubview:view];
        x += W;
    }
    
    BSView2.contentSize = CGSizeMake(MAX(x, bottomView2.frame.size.width), 0);
    
}

- (void)tappedSubMenuView:(UITapGestureRecognizer*)sender
{
    [self resetStateToNormal];
    
    if (selectedSubMenuItem != NO_SELECTED ) {
        CCMenuView *view = (CCMenuView*)[self.view viewWithTag:selectedSubMenuItem + 100];
        UIImageView *previousImgView = (UIImageView*)[self.view viewWithTag:selectedSubMenuItem + 150];
        previousImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sm_%@.png", view.title]];
    }
    
    selectedSubMenuItem = sender.view.tag - 100;
    
    CCMenuView *view = (CCMenuView*)sender.view;
    UIImageView *selectedImgView = (UIImageView*)[view viewWithTag:view.tag + 50];
    selectedImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sm_%@_1.png", view.title]];
    
    [self setThirdBottomView:selectedMenuItem withFlag:YES];
}

#pragma mark - Set 3rd BottomView

-(void) setThirdBottomView:(NSInteger)num withFlag:(BOOL)flag {
    
    //remove all subMenus
    [self resetStateToNormal];
    [self removeAllSubviews:BSView3];
    BSView3.backgroundColor = GSwhiteColor;
    
    FloodFillImageView *imageview =[self getSelectedLayoutImageViewByTag];
    [imageview setTransform:CGAffineTransformIdentity];
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
  
    
    if (flag) {
        NSArray *items;
        if (num == 1) {
            if (selectedSubMenuItem == 0) { //Font
                //                    [ProgressHUD showError:@"Pending" Interaction:NO];
            } else if(selectedSubMenuItem == 1) { //Colors
                //                    [ProgressHUD showError:@"Pending" Interaction:NO];
            } else if(selectedSubMenuItem == 2) { //Size
                //                    [ProgressHUD showError:@"Pending" Interaction:NO];
            } else if(selectedSubMenuItem == 3) { //Shadow
                items = @[@"Direction", @"Color", @"Blur", @"Transparency"];
                [self setThirdItems:items withCenterFlag:NO];
            } else if(selectedSubMenuItem == 4) { //Transparent
                //                    [ProgressHUD showError:@"Pending" Interaction:NO];
            } else if(selectedSubMenuItem == 5) { //Alignment
                items = @[@"Left", @"Center", @"Right", @"Column"];
                [self setThirdItems:items withCenterFlag:NO];
            } else if(selectedSubMenuItem == 6) { //Paragraph
                items = @[@"Spacing", @"Line"];
                [self setThirdItems:items withCenterFlag:YES];
            } else if(selectedSubMenuItem == 7) { //Rotate
                items = @[@"90  Degrees", @"180  Degrees"];
                [self setThirdItems:items withCenterFlag:YES];
            } else {
                items = nil;
            }
        } else if(num == 2) {
            //                [ProgressHUD showError:@"Pending" Interaction:NO];
        } else if(num == 3) {
            if (selectedSubMenuItem == 0) { //Add
                items = @[@"Upload", @"Camera", @"Search", @"Products", @"Brands"];
                [self setThirdItems:items withCenterFlag:NO];
            } else if(selectedSubMenuItem == 1) { //Delete
                [self imageEvents:IMAGE_DELETE];
            } else if(selectedSubMenuItem == 2) { //Format
                items = @[@"Target", @"Erase", @"Restore"]; // @"Solid", @"Alpha"
                [self setThirdItems:items withCenterFlag:YES];
            } else if(selectedSubMenuItem == 3) { //Copy
                [self imageEvents:IMAGE_COPY];
            } else if(selectedSubMenuItem == 4) { //Flip
                items = @[@"Horizontal", @"Vertical"];
                [self setThirdItems:items withCenterFlag:YES];
            } else if(selectedSubMenuItem == 5) { //Rotate
                [imageview setContentMode:UIViewContentModeScaleAspectFill];
               items = @[@"90 Degrees", @"180 Degrees"];
                [self setThirdItems:items withCenterFlag:YES];
            } else {
                items = nil;
            }
        } else {
            
        }
        
        
    } else {
        if (num == 1) {
            BSView3.backgroundColor = GSwhiteColor;
        } else if(num == 2) {
            //TODO
            BSView3.backgroundColor = GSblackColor;
        } else if(num == 3) {
            [self setThumbnails];
        } else {
            
        }
    }
}

-(void) setThirdItems:(NSArray*)items withCenterFlag:(BOOL)flag {
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat x = 0;
    CGFloat H = 64;
    CGFloat ih = 46;
    CGFloat W = 80;
    
    if (flag){
        x = (width - W *2) / items.count;
    }else {
        W = width/MIN(5, items.count);
    }
    
    
    
    for(int i = 0; i < items.count; i++) {
        CCMenuView *view = [[CCMenuView alloc] initWithFrame:CGRectMake(x, 0, W, H)];
        view.title = items[i];
        view.tag = i + selectedMenuItem *100 + selectedSubMenuItem *10;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((W - ih)/2, 1, ih, ih)];
        iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",items[i]]];
        iconView.tag = i + selectedMenuItem *100 + selectedSubMenuItem *10 + 1000;
        [view addSubview:iconView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ih + 2, W, 12)];
        label.backgroundColor = GSclearColor;
        label.text = items[i];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedThirdMenuView:)];
        [view addGestureRecognizer:gesture];
        
        [BSView3 addSubview:view];
        x += W;
    }
    
    BSView3.contentSize = CGSizeMake(MAX(x, bottomView3.frame.size.width), 0);
}

- (void)tappedThirdMenuView:(UITapGestureRecognizer*)sender {
    
    
    [self resetStateToNormal];
    
    NSInteger newTag = sender.view.tag;
    
    if (selectedThirdMenuItem != NO_SELECTED ) {
        CCMenuView *view = (CCMenuView*)[self.view viewWithTag:selectedThirdMenuItem + selectedMenuItem *100 + selectedSubMenuItem *10 ];
        NSString *title = view.title;
        UIImageView *previousImgView = (UIImageView*)[self.view viewWithTag:selectedThirdMenuItem + selectedMenuItem *100 + selectedSubMenuItem *10 + 1000];
        previousImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",title]];
    }
    
    selectedThirdMenuItem = newTag - selectedMenuItem *100 - selectedSubMenuItem *10;
    
    CCMenuView *view = (CCMenuView*)sender.view;
    NSString *title = view.title;
    UIImageView *selectedImgView = (UIImageView*)[view viewWithTag:newTag + 1000];
    selectedImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_1.png",title]];
    
    //add events
    if (newTag >= 300) {
        [self imageEvents:newTag];
    }
}

#pragma mark - Set Thumbnails

-(void) setThumbnails {
    //remove all subMenus
    [self removeAllSubviews:BSView3];
    
    //This is temp code. The code should be updated when wardrobe is integrated to GoldenSpearApp
    BSView3.backgroundColor = GSblackColor;
    
    CGFloat x = 5;
    CGFloat ih = 54;
    
    for(int i = 0; i < thumbAry.count; i++) {
        
        UIImageView *thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 5, ih, ih)];
        thumbView.image = thumbAry[i];
        thumbView.tag = i + 2000;
        thumbView.clipsToBounds = YES;
        thumbView.contentMode = UIViewContentModeScaleAspectFill;
        thumbView.userInteractionEnabled = YES;
        [BSView3 addSubview:thumbView];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveThumbnail:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        [thumbView addGestureRecognizer:panRecognizer];
        
        x += ih + 10;
    }
    
    BSView3.contentSize = CGSizeMake(MAX(x, bottomView3.frame.size.width), 0);
    
    if (selectedMenuItem == 0) {
        //TODO: Add Summer Fits TextField
        //        BSView2.scrollEnabled = NO;
        BSView2.backgroundColor = GSblackColor;
        CGRect frame = CGRectMake(5, 8.0, bottomView2.frame.size.width - 10, bottomView2.frame.size.height - 20);
        UITextField* searchFld = [[UITextField alloc] initWithFrame:frame];
        searchFld.placeholder = @"Summer Fits";
        searchFld.backgroundColor = GSwhiteColor;
        searchFld.delegate = self;
        searchFld.returnKeyType = UIReturnKeyDone;
        [BSView2 addSubview:searchFld];
        [Utils CustomiseView:searchFld withColor:GSclearColor withWidth:1.0f withCorner:6.0f];
        BSView2.contentSize = CGSizeZero;
    }
}

-(void)moveThumbnail:(UIPanGestureRecognizer*)sender
{
    CGPoint startPoint;
    CGPoint touchPoint = [sender locationInView:editView]; // get touched point
    
    UIImageView *imgView = (UIImageView*)[self.view viewWithTag:sender.view.tag + 1000];
    [imgView setCenter:touchPoint]; // set touched thumb view's center to touchPoint
    
    
    
    if (sender.state ==UIGestureRecognizerStateEnded) {
        NSLog(@"end...");
        sender.view.alpha = 1.0;
        
        FloodFillImageView *imgView = (FloodFillImageView*)[self.view viewWithTag:sender.view.tag + 1000];
        
        
        if (touchPoint.y < bottomView3.frame.origin.y) {
            if (selectedLayoutNumber < Non_Square_Number) {
                for (int i = 0; i < templateInfo.count; i++)
                {
                    FloodFillImageView *tmpView = (FloodFillImageView*)[self.view viewWithTag:i + TAG_FFIVIEW];
                    
                    if (CGRectContainsPoint(tmpView.frame, touchPoint)) {
                        
                        tmpView.backgroundColor = GSwhiteColor;
                        tmpView.alpha = 1.0;
                        tmpView.image = imgView.image;
                        currentffViewTag = i;
                        
                        self.changedImage = [[FloodFillImageView alloc]initWithImage:imgView.image];
                        tmpView.newcolor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0];
                        tmpView.chImageView = self.changedImage;
                        [tmpView setOpaque:NO];
                        
                        tmpView.tolorance = 0;
                        tmpView.delegate=self;
                        [tmpView setPanGes];
                        [tmpView setPinchGes];
                        [tmpView setRadius:10];
                        [tmpView setMainImage:tmpView.image];
                        //save info
                        oldImg = [self clearImageWithColor:tmpView.bounds];
                        [self saveEditInfo:tmpView.image MaskImage:[self clearImageWithColor:tmpView.bounds] withNumber:currentffViewTag];
                        
//                        UIImage *image = [self clearImage];
//                        [image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//                        [undoData addObject:image];
//                        [undoMask addObject:[UIImage new]];
//                        [tmpView.image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//                        
//                        [undoData addObject:tmpView.image];
//                        [undoMask addObject:[UIImage new]];
                        break;
                    }
                }
            } else {
                NSInteger num = [self getNearestNumber:touchPoint];
                NSLog(@"estimate number = %ld", num);
                FloodFillImageView *tmpView = (FloodFillImageView*)[self.view viewWithTag:num + TAG_FFIVIEW];
                tmpView.image = imgView.image;
                tmpView.alpha = 1.0;
                selectedEditImageNumber = num;
                currentffViewTag = num;
                //save info
//                [tmpView.image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//                [undoData addObject:tmpView.image];
//                [undoMask addObject:[UIImage new]];
                [self saveEditInfo:tmpView.image MaskImage:[self clearImageWithColor:tmpView.bounds] withNumber:currentffViewTag];
            }
            
        }
        
        [imgView removeFromSuperview];
        
    }else if(sender.state ==UIGestureRecognizerStateBegan){
        NSLog(@"starting...");
        sender.view.alpha = 0.5;
        
        startPoint = [sender locationInView:editView];
        CGRect frame = [bottomView3 convertRect:sender.view.frame toView:editView];
        UIImageView *thumbView = [[UIImageView alloc] initWithFrame:frame];
        UIImageView *imgView = (UIImageView*)[self.view viewWithTag:sender.view.tag];
        thumbView.image = imgView.image;
        thumbView.tag = sender.view.tag + 1000;
        thumbView.clipsToBounds = YES;
        thumbView.contentMode = UIViewContentModeScaleAspectFill;
        thumbView.userInteractionEnabled = YES;
        [sharingView addSubview:thumbView];
    }else{
        //TODO
    }
}

-(void)getTag:(NSInteger)value
{
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    [Utils CustomiseView:imgView withColor:GSclearColor withWidth:1.0 withCorner:0.0];
    currentffViewTag = value;
}

-(void)ActionFinished:(UIImage*)image Mask:(UIImage *)mask Type:(int)type Tag:(NSInteger)tag{
    NSLog(@"action finished");
//    [image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)tag]];
//    [undoData addObject:image];
//    [undoMask addObject:mask];

    
    FloodFillImageView *ffView = (FloodFillImageView*)[self.view viewWithTag:tag];
    currentffViewTag = tag;
    
    [ffView.chImageView setImage:image];
    [ffView setContentMode:UIViewContentModeScaleAspectFit];
    if (state == state_target)
    {
        [ffView setMainImage:image];
    
    [self.changedImage setImage:image];
    }
    oldImg = self.changedImage.image;
    [self saveEditInfo:image MaskImage:mask withNumber:tag];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Images Event

-(void)imageEvents:(NSInteger)num {
    
    if (num == IMAGE_DELETE) {
        [self deleteImage];
    } else if (num == IMAGE_COPY) {
        [self copyEditImage];
    } else if (num == IMAGE_ADD_UPLOAD) {
        [self uploadImageFromCamera:0];
    } else if (num == IMAGE_ADD_CAMERA) {
        [self uploadImageFromCamera:1];
    } else if (num == IMAGE_ADD_SEARCH) {
        [self searchImage:0];
    } else if (num == IMAGE_ADD_PRODUCTS) {
        [self searchImage:1];
    } else if (num == IMAGE_ADD_BRANDS) {
        [self searchImage:2];
    } else if (num == IMAGE_FORMAT_TARGET) {
        [self formatEditImage:0];
    } else if (num == IMAGE_FORMAT_ERASE) {
        [self formatEditImage:1];
    } else if (num == IMAGE_FORMAT_RESTORE) {
        [self formatEditImage:2];
    } else if (num == IMAGE_FLIP_HORIZONTAL) {
        [self flipEditImage:0];
    } else if (num == IMAGE_FLIP_VERTICAL) {
        [self flipEditImage:1];
    } else if (num == IMAGE_ROTATE_90) {
        [self rotateEditImageByButtonTap:0];
    } else if (num == IMAGE_ROTATE_180) {
        [self rotateEditImageByButtonTap:1];
    } else {
        NSLog(@"image events");
    }
}


-(void)deleteImage {
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    if (imgView.image != [self clearImage]) {
        oldImg = imgView.image;
        [self saveEditInfo:[self clearImage] MaskImage:[self clearImageWithColor:imgView.bounds] withNumber:currentffViewTag];
        
//        [imgView.image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//        [undoData addObject:imgView.image];
//        UIImage *img = [self clearImage];
//        [img setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//        [undoData addObject:img];
//        [undoMask addObject:[UIImage new]];
//        [undoMask addObject:[UIImage new]];
        imgView.image = [self clearImage];
    }
    
}

-(void)saveEditedImage:(FloodFillImageView*)view {
    
    UIImageView *newImgView = [[UIImageView alloc] initWithImage:view.image];
    [newImgView setBackgroundColor:GSwhiteColor];
    
    UIGraphicsBeginImageContextWithOptions(newImgView.frame.size, YES, 1.0);
    [newImgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    view.image = viewImage;
    
    //save info
    [self saveEditInfo:viewImage MaskImage:[self clearImageWithColor:newImgView.bounds] withNumber:currentffViewTag];
//    [viewImage setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//    [undoData addObject:viewImage];
//    [undoMask addObject:[UIImage new]];
}

-(void)copyEditImage {
    state = state_copy;
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    [imgView setState:state_copy];
}

-(void)formatEditImage:(int)type {
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    
    oldImg = imgView.image;
//    [imgView.image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//    [undoData addObject:imgView.image];
//    [undoMask addObject:[UIImage new]];
    [self saveEditInfo:imgView.image MaskImage:[self clearImageWithColor:imgView.bounds] withNumber:currentffViewTag];

    [Utils CustomiseView:imgView withColor:GSyellowColor withWidth:1.0 withCorner:0.0];
    
    
    if(type == 0) {
        state = state_target;
        [imgView setState:state_target];
    } else if (type == 1) {
        state = state_eraser;
        [imgView setState:state_eraser];
    } else if(type == 2){
        state = state_restore;
        [imgView setState:state_restore];
    }
    /*
     if (type == 1) { //Alpha:cut the image
     UIGraphicsBeginImageContextWithOptions(imgView.frame.size, YES, 1.0);
     [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
     UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     [imgView setImage:viewImage];
     
     [self saveEditedImage:imgView];
     } */
}

-(void)flipEditImage:(int)type {
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    oldImg = imgView.image;
//    [imgView.image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//    [undoData addObject:imgView.image];
//    [undoMask addObject:[UIImage new]];
    
    UIImage *flippedImage;
    if (type == 0) {
        flippedImage = [UIImage imageWithCGImage:imgView.image.CGImage
                                           scale:imgView.image.scale
                                     orientation:UIImageOrientationUpMirrored];
    }else {
        flippedImage = [UIImage imageWithCGImage:imgView.image.CGImage
                                           scale:imgView.image.scale
                                     orientation:UIImageOrientationDownMirrored];
    }
    
    [imgView setImage:flippedImage];
    [self saveEditedImage:imgView];
    
}

-(void)rotateEditImageByButtonTap:(int)type {
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    
    oldImg = imgView.image;
//    [imgView.image setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//    [undoData addObject:imgView.image];
//    [undoMask addObject:[UIImage new]];
    
    UIImage *rotatedImage;
    
    if (type == 0) { //Rotate 90
        rotatedImage = [UIImage imageWithCGImage:imgView.image.CGImage
                                           scale:1.0
                                     orientation:UIImageOrientationRight];
    }else {
        rotatedImage = [UIImage imageWithCGImage:imgView.image.CGImage
                                           scale:imgView.image.scale
                                     orientation:UIImageOrientationDown];
    }
    
    [imgView setImage:rotatedImage];
    
    [self saveEditedImage:imgView];
    
    
}

-(void)moveEditImage:(UIPanGestureRecognizer*)sender
{
    if (state == state_copy)
    {
        CGPoint touchPoint = [sender locationInView:sender.view]; // get touched point
        
        UIImageView *imgView = (UIImageView*)[self.view viewWithTag:sender.view.tag + 10];
        [imgView setCenter:touchPoint]; // set touched thumb view's center to touchPoint
        
        
        if (sender.state ==UIGestureRecognizerStateEnded) {
            NSLog(@"end Moving...");
            
            UIImageView *newImgView = (UIImageView*)sender.view;
            
            UIGraphicsBeginImageContextWithOptions(newImgView.frame.size, YES, 1.0);
            [newImgView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            newImgView.image = viewImage;
            
            //save info
//            [viewImage setAccessibilityValue:[NSString stringWithFormat:@"%ld",(long)currentffViewTag]];
//            [undoData addObject:viewImage];
//            [undoMask addObject:[UIImage new]];
            [self saveEditInfo:viewImage MaskImage:[self clearImageWithColor:newImgView.bounds] withNumber:currentffViewTag];
            //            [self saveEditedImage:(FloodFillImageView *)sender.view];
            [imgView removeFromSuperview];
            
        }else if(sender.state ==UIGestureRecognizerStateBegan){
            NSLog(@"start Moving...");
            NSLog(@"tag = %ld", sender.view.tag);
            UIImageView *img = (UIImageView*)sender.view;
            UIImageView *thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sharingView.frame.size.width, sharingView.frame.size.height)];
            thumbView.image = img.image;
            thumbView.tag = img.tag + 10;
            thumbView.clipsToBounds = YES;
            thumbView.contentMode = UIViewContentModeScaleAspectFill;
            [img addSubview:thumbView];
        }else{
            //TODO
        }
    }if (state == state_draw) {
        
    } else {
        
    }
    
    
}

-(void)uploadImageFromCamera:(int)type {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (type == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
#if TARGET_IPHONE_SIMULATOR
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Place image picker on the screen
            [self presentViewController:picker animated:YES completion:NULL];
        }];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark - Image Picker Controller delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImg = info[UIImagePickerControllerEditedImage];
    
    CGSize newSize = CGSizeMake(320, 320);
    UIImage *image1 = [self imageWithImage:chosenImg scaledToSize:newSize];
    
    //add image to thumbnail
    [thumbAry addObject:image1];
    
    
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage1;
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    //save edited wardrobe name
    
    if (textField == srhtxtFld) {
        srhTitleLbl.text = textField.text;
        aryCount = thumbAry.count;
        [_srhCollectionView reloadData];
        [srhtxtFld setHidden:YES];
        
    }
    return NO;
}


#pragma mark - Save Edit Actions

-(void)saveEditInfo:(UIImage*)currentImage MaskImage:(UIImage *)maskImage withNumber:(NSInteger)num {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:currentImage forKey:@"image"];
    [dic setObject:maskImage forKey:@"mask"];
    [dic setObject:oldImg forKey:@"old"];
    [dic setObject:[NSNumber numberWithInteger:num] forKey:@"num"];
    [saveInfo addObject:dic];
    
    stepNumber = 0;
    
}

#pragma mark - Top Bar Button Actions

// Save cover page
- (IBAction)saveBtnClicked:(UIButton *)sender {
    UIGraphicsBeginImageContextWithOptions(sharingView.frame.size, YES, [UIScreen mainScreen].scale);
    [sharingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
}

// Undo last action
- (IBAction)undoBtnClicked:(UIButton *)sender {
    if (stepNumber < saveInfo.count - 1) {
        stepNumber += 1;
    }
    
    NSLog(@"stepCountU = %d", stepNumber);
    [self restoreEditImgae:0];
//    if (undoData.count > 1)
//    {
//        [redoMask addObject:[undoMask lastObject]];
//        [undoMask removeLastObject];
//        
//        UIImage *lastImage = [undoData objectAtIndex:undoData.count - 2];
//        NSInteger lastnum = [lastImage.accessibilityValue integerValue];
//        FloodFillImageView *imgView = (FloodFillImageView*)[self.view viewWithTag:lastnum];
//        [imgView setMaskImage:[undoMask lastObject]];
//        
//        [redoData addObject:[undoData lastObject]];
//        [undoData removeLastObject];
//        [imgView setImage:[undoData lastObject]];
//    }
    
}

// Redo last action
- (IBAction)redoBtnClicked:(UIButton *)sender {
    if (stepNumber > 0) {
        stepNumber -= 1;
    }
    
    NSLog(@"stepCountR = %d", stepNumber);
    [self restoreEditImgae:1];
    
//    if (redoData.count > 0)
//    {
//        UIImage *lastImage = [redoData lastObject];
//        NSInteger lastnum = [lastImage.accessibilityValue integerValue];
//        FloodFillImageView *imgView = (FloodFillImageView*)[self.view viewWithTag:lastnum];
//        [imgView setMaskImage:[redoMask lastObject]];
//        
//        [undoMask addObject:[redoMask lastObject]];
//        [redoMask removeLastObject];
//        
//        [imgView setImage:[redoData lastObject]];
//        [undoData addObject:[redoData lastObject]];
//        [redoData removeLastObject];
//    }
}

// Reset entire cover page
- (IBAction)resetBtnClicked:(UIButton *)sender {
    
    [self removeAllSubviews:sharingView];
    [saveInfo removeAllObjects];
//    [undoData removeAllObjects];
//    [redoData removeAllObjects];
//    [undoMask removeAllObjects];
//    [redoMask removeAllObjects];
    
    [self initFrames];
}

// Cancel/Close button
- (IBAction)closeBtnClicked:(UIButton *)sender {
    //TODO Event
    //    [ProgressHUD showError:@"Pending" Interaction:NO];
}

-(void)restoreEditImgae:(int)type
{
    int num = (int)saveInfo.count - stepNumber - 1;
    NSLog(@"num = %d %ld", num, saveInfo.count);
    if (stepNumber >= 0 && num < saveInfo.count) {
        NSDictionary *dic = [saveInfo objectAtIndex:num];
        NSInteger num = [[dic objectForKey:@"num"] integerValue];
        FloodFillImageView *imgView = (FloodFillImageView*)[self.view viewWithTag:num];
        if (type == 0) {
            imgView.image = [dic objectForKey:@"old"];
        }else {
            imgView.image = [dic objectForKey:@"image"];
        }
        [self.changedImage setImage:imgView.image];
        [imgView setChImageView:self.changedImage];
        [imgView setMaskImage:[dic objectForKey:@"mask"]];
    }
}

#pragma mark -Touch event

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    if (!isSquare) {
        CGPoint currentPoint = [touch locationInView:sharingView];
        NSInteger num = [self getNearestNumber:currentPoint];
        selectedEditImageNumber = num;
        currentffViewTag = num;
    }
}

#pragma mark - Search Functions

-(void)searchImage:(int)type {
    state = state_search;
    
    if (type != 0) {
        [srhtxtFld setHidden:YES];
        aryCount = thumbAry.count;
    }else aryCount = 0;
    
    [_srhCollectionView reloadData];
    
    [self.view bringSubviewToFront:searchView];
}

- (IBAction)srhSaveBtnClicked:(id)sender {
    
}

- (IBAction)srhCloseBtnClicked:(id)sender {
    [self hiddenSearchView];
}

-(void)hiddenSearchView {
    [srhtxtFld setHidden:NO];
    srhTitleLbl.text = @"";
    srhtxtFld.text = @"";
    state = state_normal;
    [self.view sendSubviewToBack:searchView];
}


-(void)resetStateToNormal
{
    if (state == state_search) [self hiddenSearchView];
    state = state_normal;
    FloodFillImageView *imgView = [self getSelectedLayoutImageViewByTag];
    if ([imgView isKindOfClass:[FloodFillImageView class]])
        [imgView setState:state];
    
}

#pragma mark - UICollectionView Stuff

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((collectionView.frame.size.width - 30)/2, (collectionView.frame.size.width - 30)/2);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return aryCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LayoutCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchCellId" forIndexPath:indexPath];
    
    cell.imageview.image = thumbAry[indexPath.item];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //get selected Cell
    LayoutCollectionViewCell *cell = (LayoutCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    [thumbAry addObject:cell.imageview.image];
    
    [self hiddenSearchView];
}

#pragma mark - Utility Functions

-(void)removeAllSubviews:(UIView *)view {
    for(UIView *subview in [view subviews]) {
        [subview removeFromSuperview];
    }
}

-(FloodFillImageView *) getSelectedLayoutImageViewByTag {
    return (FloodFillImageView*)[self.view viewWithTag:currentffViewTag];
}


-(NSInteger)getNearestNumber:(CGPoint)pt {
    int n = 0;
    
    for (int i = 0; i < templateInfo.count; i++) {
        NSArray *pointAry = templateInfo[i];
        if (CGPathContainsPoint([Utils createPath:pointAry withView:sharingView].CGPath, NULL, pt, NO)) {
            return i;
        }
    }
    
    return n;
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
-(UIImage*)clearImage {
    UIImage *img = [UIImage imageNamed:@"bg_clear.png"];
    
    return img;
}

@end
