//
//  DZAppDelegate.m
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/29/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import "DZAppDelegate.h"
#import "DZUIImageViewerController.h"

@implementation DZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    DZUIImageViewerController *imageViewer = [[DZUIImageViewerController alloc] init];
    
//    Can be UIImage, NSString or NSURL objects
	imageViewer.photos = @[@"https://farm4.staticflickr.com/3895/14537514401_731d6b15c2.jpg",
						   @"https://farm4.staticflickr.com/3866/14537514541_f0a427ac65.jpg",
						   @"https://farm3.staticflickr.com/2912/14560785463_c30cee7190.jpg",
						   @"https://farm6.staticflickr.com/5528/14538801834_39fcfa8b23.jpg",
						   @"https://farm3.staticflickr.com/2920/14353807148_a6168c0333.jpg"];
	
	self.window.rootViewController = imageViewer;
	
	[self.window makeKeyAndVisible];
    return YES;
}

@end
