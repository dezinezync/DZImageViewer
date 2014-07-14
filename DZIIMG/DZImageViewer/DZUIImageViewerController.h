//
//  DZUIImageViewerController.h
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/30/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DZUIImageViewerDelegate <NSObject>

@optional
- (void)didChangeSelectedIndex:(NSNumber *)idx;
- (void)updateState:(NSNumber *)idx;

@end

@interface DZUIImageViewerController : UICollectionViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) UIButton *closeButton;
//  Dark style toolbar, add items to this if needed.
@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, weak) id<DZUIImageViewerDelegate> delegate;

- (void)setSelectedIndex:(NSInteger)index;
- (NSInteger)getSelectedIndex;

@end
