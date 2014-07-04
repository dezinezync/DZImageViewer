//
//  DZUIStatics.h
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/30/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

__unused static CGRect getBounds()
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
	{
		CGFloat w = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = w;
	}
	return bounds;
}