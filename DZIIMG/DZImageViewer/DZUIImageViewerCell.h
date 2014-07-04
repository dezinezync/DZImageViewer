//
//  DZUIImageViewerCell.h
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/30/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZProgressView.h"

extern NSString *const kUpdateStatusBarDisplay;
extern NSString *const kStatusBarHiddenKey;

@interface DZUIImageViewerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DZProgressView *progressView;

- (void)setImage:(UIImage *)image;
- (void)centerScrollViewContents;

@end
