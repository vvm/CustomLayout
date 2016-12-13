//
//  ViewController.m
//  CustomLayout
//
//  Created by vee on 2016/12/13.
//  Copyright © 2016年 xman. All rights reserved.
//

#import "ViewController.h"

static NSString* const cellIdentifier = @"cell";

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    UILabel* label = [cell viewWithTag:10];
    label.text = [NSString stringWithFormat:@"%d",indexPath.item];
    return cell;
}


@end
