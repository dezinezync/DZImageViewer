//
//  DZUIImageViewerController.h
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/30/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZUIStatics.h"

@interface DZUIImageViewerController : UICollectionViewController

@property (nonatomic, strong) NSArray *photos;

- (void)setSelectedIndex:(NSInteger)index;

@end
