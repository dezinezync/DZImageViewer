//
//  DZProgressView.h
//  DZIIMG
//
//  Created by Nikhil Nigade on 7/4/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CAMediaTimingFunction.h>

@interface DZProgressView : UIView

/*
 * Value Range: 0.0-1.0
 */
@property (nonatomic, assign) CGFloat progress;

@end
