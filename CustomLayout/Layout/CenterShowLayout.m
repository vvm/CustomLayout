//
//  CenterShowLayout.m
//  CustomLayout
//
//  Created by vee on 2016/12/13.
//  Copyright © 2016年 xman. All rights reserved.
//

#import "CenterShowLayout.h"

@interface CenterShowLayout ()

// length of empty area in header and footer
@property (nonatomic, assign) CGFloat emptyBlockLength;
// distance that change a select item should scroll
@property (nonatomic, assign) CGFloat distancePerScroller;
// count that one frame can show
@property (nonatomic, assign) NSInteger showCountOnce;

// width / 2 for UICollectionViewScrollDirectionHorizontal &&
@property (nonatomic, assign) CGFloat semidiameter;
// select item should show in this center
@property (nonatomic, assign) CGPoint viewCenter;
// total item count
@property (nonatomic, assign) NSInteger totalCount;

@end

@implementation CenterShowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        _emptyBlockLength = (self.collectionView.bounds.size.width - self.itemSize.width * (1.0 + _detalScale)) / 2.0;
        _distancePerScroller = self.itemSize.width + self.minimumInteritemSpacing;
        
        _showCountOnce = ceil((self.collectionView.bounds.size.width - self.itemSize.width * (1 + _detalScale)) / self.itemSize.width) + 1;
        _semidiameter = self.itemSize.width / 2.0;
    } else {
        _emptyBlockLength = (self.collectionView.bounds.size.height - self.itemSize.height * (1.0 + _detalScale)) / 2.0;
        _distancePerScroller = self.itemSize.height + self.minimumInteritemSpacing;
        
        _showCountOnce = ceil((self.collectionView.bounds.size.height - self.itemSize.height * (1 + _detalScale)) / self.itemSize.height) + 1;
        _semidiameter = self.itemSize.height / 2.0;
    }

    
    _viewCenter = CGPointMake(self.collectionView.bounds.size.width / 2.0, self.collectionView.bounds.size.height / 2.0);
    
    NSInteger scetionCount = self.collectionView.numberOfSections;
    NSAssert(scetionCount == 1, @"Only support one section now");
    _totalCount = [self.collectionView numberOfItemsInSection:0];
    
}

- (CGSize)collectionViewContentSize
{
    CGSize size = self.collectionView.bounds.size;
    if (_totalCount > 2) {
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            size.width += (_totalCount - 1) * (self.itemSize.width + self.minimumInteritemSpacing);
        } else {
            size.height += (_totalCount - 1) * (self.itemSize.height + self.minimumInteritemSpacing);
        }
    }
    return size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGPoint offset = self.collectionView.contentOffset;
    // use max instead of direction charge
    CGFloat offsetValue = MAX(offset.x, offset.y);
    
    // index for scale area begin at
    int areaBeginIndex = floor(offsetValue / _distancePerScroller);
    float areaBeginScale = 1.0 - (offsetValue - areaBeginIndex * _distancePerScroller) / _distancePerScroller;
    
    int beginIndex = floor((offsetValue - _emptyBlockLength) / _distancePerScroller);
    
    beginIndex = MAX(0, beginIndex - 1);
    
    CGFloat usedLength = _emptyBlockLength;
    if (beginIndex > 0) {
        usedLength += beginIndex * _distancePerScroller;
    }
    
    NSMutableArray* layouts = [NSMutableArray array];
    for (int i = 0; i <= _showCountOnce; i++) {
        int index = beginIndex + i;
        if (index >= _totalCount) {
            break;
        }
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes* layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        layoutAttributes.size = self.itemSize;
        float sem = _semidiameter;
        if (index == areaBeginIndex) {
            CGFloat scale = 1.0 + areaBeginScale * _detalScale;
            sem *= scale;
            layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
        } else if (index == areaBeginIndex + 1) {
            CGFloat scale = 1.0 + (1.0 - areaBeginScale) * _detalScale;
            sem *= scale;
            layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
        } else {
        }
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            layoutAttributes.center = CGPointMake(usedLength + sem, _viewCenter.y);
        } else {
            layoutAttributes.center = CGPointMake(_viewCenter.x, usedLength + sem);
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
    CGFloat offsetValue = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? proposedContentOffset.x : proposedContentOffset.y;
    
    int areaBeginIndex = floor(offsetValue / _distancePerScroller);
    float scrollCress = offsetValue - areaBeginIndex * _distancePerScroller;
    NSInteger showIndex = 0;
    if (scrollCress * 2.0 > _distancePerScroller) {
        showIndex = MIN(areaBeginIndex + 1, _totalCount - 1) ;
    } else {
        showIndex = MAX(areaBeginIndex, 0);
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        proposedContentOffset.x = showIndex * _distancePerScroller;
    } else {
        proposedContentOffset.y = showIndex * _distancePerScroller;
    }
    
    return proposedContentOffset;
}

#pragma mark - 
- (CGSize)size:(CGSize)size multipliedBy:(CGFloat)multiplier
{
    return CGSizeMake(size.width * multiplier, size.height * multiplier);
}

@end
