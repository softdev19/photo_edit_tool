//
//  LayoutVC.m
//  Wardrobe
//
//  Created by GoldenSpear1 on 27/04/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "LayoutVC.h"
#import "LayoutCollectionViewCell.h"


@interface LayoutVC () <UICollectionViewDelegate> {
    
    __weak IBOutlet UILabel *subTitleLbl;
    NSInteger  selectedLayout;
    LayoutCollectionViewCell *previousCell;
    
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionview;

@end

@implementation LayoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)closebtnClicked:(id)sender {
    [self goComposeVC];
}

- (IBAction)selectBtnClicked:(id)sender {
    
    //Save Layout Template Number
    selectedLayoutNumber = selectedLayout;
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:LAYOUTNOTIFICATION object:nil];
    
    [self goComposeVC];
}

-(void)goComposeVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Stuff

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((collectionView.frame.size.width - 30)/3, (collectionView.frame.size.width - 30)/3);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return tempNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LayoutCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"layoutCollectionCellId" forIndexPath:indexPath];
    
    cell.imageview.image = [UIImage imageNamed:[NSString stringWithFormat:@"layout_%ld", indexPath.item]];
    
    //if currently used template will be stroke with black color
    if (indexPath.item == selectedLayoutNumber) {
        [Utils CustomiseView:cell.imageview withColor:GSblackColor withWidth:1.0 withCorner:0];
    }else {
        [Utils CustomiseView:cell.imageview withColor:GSclearColor withWidth:1.0 withCorner:0];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedLayout = indexPath.item;
    
    //remove redColor stroker
    if (previousCell != nil) {
        [Utils CustomiseView:previousCell.imageview withColor:GSclearColor withWidth:1.0 withCorner:0];
    }
    
    //get selected Cell
    LayoutCollectionViewCell *cell = (LayoutCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    previousCell = cell;
    //add redColor stroker
    [Utils CustomiseView:cell.imageview withColor:GSredColor withWidth:1.0 withCorner:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
