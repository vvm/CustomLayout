//
//  CenterShowLayout.m
//  CustomLayout
//
//  Created by vee on 2016/12/13.
//  Copyright © 2016年 xman. All rights reserved.
//

#import "CenterShowLayout.h"


static const float centerItemWith = 65.0;
static const float normalItemWith = 50.0;
static const float itemMargin = 10.0;

@interface CenterShowLayout ()

@property (nonatomic, assign) float emptyBlockLength;
@property (nonatomic, assign) float distancePerScroller;
@property (nonatomic, assign) float centerY;
@property (nonatomic, assign) float detalScale;
@property (nonatomic, assign) NSInteger totalCount;

@end

@implementation CenterShowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = CGSizeMake(normalItemWith, normalItemWith);
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareLayout
{
    [super prepareLayout];
    _emptyBlockLength = (self.collectionView.bounds.size.width - centerItemWith) / 2.0;
    NSInteger scetionCount = self.collectionView.numberOfSections;
    NSAssert(scetionCount == 1, @"Only support one section now");
    _totalCount = [self.collectionView numberOfItemsInSection:0];
    _centerY = self.collectionView.bounds.size.height / 2.0;
    _detalScale = (centerItemWith - normalItemWith) / normalItemWith;
    
    _distancePerScroller = normalItemWith + itemMargin;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = self.collectionView.bounds.size;
    if (_totalCount > 2) {
        size.width += (_totalCount - 1) * (normalItemWith + itemMargin);
    }
    return size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGPoint offset = self.collectionView.contentOffset;
    int areaBeginIndex = floor(offset.x / _distancePerScroller);
    float areaBeginScale = 1.0 - (offset.x - areaBeginIndex * _distancePerScroller) / _distancePerScroller;
    
    int beginIndex = floor((offset.x - _emptyBlockLength) / normalItemWith);
    int showCount = ceil((self.collectionView.bounds.size.width - centerItemWith) / normalItemWith) + 1;
    beginIndex = MAX(0, beginIndex - 1);
    
    CGFloat usedLength = _emptyBlockLength;
    if (beginIndex > 0) {
        usedLength += (beginIndex/* - 1*/) * (normalItemWith + itemMargin);
    }
    
    NSMutableArray* layouts = [NSMutableArray array];
    for (int i = 0; i <= showCount; i++) {
        int index = beginIndex + i;
        if (index >= _totalCount) {
            break;
        }
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes* layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        layoutAttributes.size = CGSizeMake(normalItemWith, normalItemWith);
        float sem = normalItemWith / 2.0;
        if (index == areaBeginIndex) {
            CGFloat scale = 1 + areaBeginScale * _detalScale;
            sem = normalItemWith / 2.0 * scale;
            layoutAttributes.center = CGPointMake(usedLength + sem, _centerY);
            layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
        } else if (index == areaBeginIndex + 1) {
            CGFloat scale = 1.0 + (1.0 - areaBeginScale) * _detalScale;
            sem = normalItemWith / 2.0 * scale;
            layoutAttributes.center = CGPointMake(usedLength + sem, _centerY);
            layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
        } else {
            layoutAttributes.center = CGPointMake(usedLength + sem, _centerY);
        }
        usedLength += sem * 2.0 + itemMargin;
        
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
