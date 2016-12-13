//
//  CenterShowLayout.m
//  CustomLayout
//
//  Created by vee on 2016/12/13.
//  Copyright © 2016年 xman. All rights reserved.
//

#import "CenterShowLayout.h"

@interface CenterShowLayout ()

@property (nonatomic, assign) float emptyBlockLength;
@property (nonatomic, assign) float distancePerScroller;

@property (nonatomic, assign) CGPoint viewCenter;

@property (nonatomic, assign) NSInteger totalCount;

@end

@implementation CenterShowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    _emptyBlockLength = (self.collectionView.bounds.size.width - self.itemSize.width * (1.0 + _detalScale)) / 2.0;
    _viewCenter = CGPointMake(self.collectionView.bounds.size.width / 2.0, self.collectionView.bounds.size.height / 2.0);
    
    NSInteger scetionCount = self.collectionView.numberOfSections;
    NSAssert(scetionCount == 1, @"Only support one section now");
    _totalCount = [self.collectionView numberOfItemsInSection:0];
    
    _distancePerScroller = self.itemSize.width + self.minimumInteritemSpacing;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = self.collectionView.bounds.size;
    if (_totalCount > 2) {
        size.width += (_totalCount - 1) * (self.itemSize.width + self.minimumInteritemSpacing);
    }
    return size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGPoint offset = self.collectionView.contentOffset;
    int areaBeginIndex = floor(offset.x / _distancePerScroller);
    float areaBeginScale = 1.0 - (offset.x - areaBeginIndex * _distancePerScroller) / _distancePerScroller;
    
    int beginIndex = floor((offset.x - _emptyBlockLength) / _distancePerScroller);
    int showCount = ceil((self.collectionView.bounds.size.width - self.itemSize.width * (1 + _detalScale)) / self.itemSize.width) + 1;
    beginIndex = MAX(0, beginIndex - 1);
    
    CGFloat usedLength = _emptyBlockLength;
    if (beginIndex > 0) {
        usedLength += beginIndex * _distancePerScroller;
    }
    
    NSMutableArray* layouts = [NSMutableArray array];
    for (int i = 0; i <= showCount; i++) {
        int index = beginIndex + i;
        if (index >= _totalCount) {
            break;
        }
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes* layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        layoutAttributes.size = self.itemSize;
        float sem = self.itemSize.width / 2.0;
        if (index == areaBeginIndex) {
            CGFloat scale = 1.0 + areaBeginScale * _detalScale;
            sem = self.itemSize.width / 2.0 * scale;
            layoutAttributes.center = CGPointMake(usedLength + sem, _viewCenter.y);
            layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
        } else if (index == areaBeginIndex + 1) {
            CGFloat scale = 1.0 + (1.0 - areaBeginScale) * _detalScale;
            sem = self.itemSize.width / 2.0 * scale;
            layoutAttributes.center = CGPointMake(usedLength + sem, _viewCenter.y);
            layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
        } else {
            layoutAttributes.center = CGPointMake(usedLength + sem, _viewCenter.y);
        }
        usedLength += sem * 2.0 + self.minimumInteritemSpacing;
        
        [layouts addObject:layoutAttributes];
    }
    return layouts;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

// change offset after scroll
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    int areaBeginIndex = floor(proposedContentOffset.x / _distancePerScroller);
    float scrollCress = proposedContentOffset.x - areaBeginIndex * _distancePerScroller;
    if (scrollCress * 2.0 > _distancePerScroller) {
        proposedContentOffset.x = MIN(areaBeginIndex + 1, _totalCount - 1) * _distancePerScroller;
    } else {
        proposedContentOffset.x = MAX(areaBeginIndex, 0) * _distancePerScroller;
    }
    
    return proposedContentOffset;
}

@end
