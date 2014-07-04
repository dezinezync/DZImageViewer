//
//  DZFlowLayout.m
//  DZIIMG
//
//  Created by Nikhil Nigade on 7/4/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import "DZFlowLayout.h"
#import "DZUIStatics.h"

@interface DZFlowLayout()

@property (nonatomic, strong) NSMutableDictionary *attributes;

@end

@implementation DZFlowLayout

- (NSMutableDictionary *)attributes
{
    if(!_attributes)
    {
        _attributes = [NSMutableDictionary dictionaryWithCapacity:[self.collectionView numberOfItemsInSection:0]];
    }
    return _attributes;
}

- (CGSize)itemSize
{
    CGSize viewSize = getBounds().size;
    UIEdgeInsets viewInset = self.collectionView.contentInset;
    CGSize size = CGSizeMake(viewSize.width - viewInset.left - viewInset.right, viewSize.height - viewInset.top - viewInset.bottom);
    //    NSLog(@"%@",NSStringFromCGSize(size));
    return size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    BOOL invalidate = !CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size);
    return invalidate;
}

//- (void)prepareLayout
//{
//    [super prepareLayout];
//}

- (CGSize)collectionViewContentSize
{
    //    NSLog(@"Size >> %@", NSStringFromCGSize(getBounds().size));
    CGFloat width = [self.collectionView numberOfItemsInSection:0] * getBounds().size.width;
    return CGSizeMake(width, getBounds().size.height);
}

- (void)invalidateLayout
{
    self.attributes = [NSMutableDictionary dictionaryWithCapacity:[self.collectionView numberOfItemsInSection:0]];
    [super invalidateLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //    NSLog(@"Rect >> %@", NSStringFromCGRect(rect));
    
    NSArray *indexPaths = [self indexPathsFromRect:rect forItemSize:[self itemSize]];
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:[indexPaths count]];
    
    __weak typeof(self) weakSelf = self;
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        
        [attributes addObject:[weakSelf layoutAttributesForItemAtIndexPath:obj]];
        
    }];
    
    return attributes;
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs;
    
    attrs = [self.attributes objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.item]];
    if(attrs)
    {
        return attrs;
    }
    
    CGSize size = [self itemSize];
    attrs =  [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = (CGRect){.origin=CGPointMake(indexPath.item * size.width, 0),.size=size};
    
    [self.attributes setObject:attrs forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.item]];
    
    //    NSLog(@"Layout Single >> %@", NSStringFromCGRect(attrs.frame));
    
    return attrs;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSArray *)indexPathsFromRect:(CGRect)rect forItemSize:(CGSize)size
{
    NSMutableArray *arr = @[].mutableCopy;
    
    NSInteger startingIDX = rect.origin.x == 0 ? 0 : rect.origin.x/size.width;
    NSInteger finalIDX; //Not included in the indexPaths
    
    if(startingIDX == 0 && rect.size.width == size.width)
    {
        finalIDX = 1;
    }
    else
    {
        finalIDX = (rect.origin.x + rect.size.width)/size.width;
    }
    
    //    NSLog(@"Index Range : %ld : %ld", (long)startingIDX, (long)finalIDX);
    
    for (NSInteger idx=startingIDX; idx<finalIDX; idx++) {
        [arr addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }
    
    return [NSArray arrayWithArray:arr];
}

@end
