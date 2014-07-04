//
//  DZUIImageViewerCell.m
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/30/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import "DZUIImageViewerCell.h"
//#import "DZUIStatics.h"

NSString *const kUpdateStatusBarDisplay = @"com.dezinezync.updateStatusBarDisplay";
NSString *const kStatusBarHiddenKey = @"com.dezinezync.statusBarHiddenKey";

@interface DZUIImageViewerCell() <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isZoomed;
@property (nonatomic, assign) BOOL forceStatusBarHidden;
@property (nonatomic, strong) UIScrollView *view;

@property (nonatomic, assign) BOOL statusBarAlwaysHidden;

@end

@implementation DZUIImageViewerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		_isZoomed = NO;
		_forceStatusBarHidden = NO;
		_statusBarAlwaysHidden = NO;
		
		_view = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
		_view.delegate = self;
		_view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_view.showsHorizontalScrollIndicator = NO;
		_view.showsVerticalScrollIndicator = NO;
		_view.minimumZoomScale = 0.1;
		_view.maximumZoomScale = 1.0;
		_view.clipsToBounds = YES;
		_view.scrollEnabled = YES;
        _view.backgroundColor = [UIColor blackColor];
		
		[_view addSubview:self.imageView];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
		tapGesture.numberOfTapsRequired = 1;
		
		UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
		doubleTapGesture.numberOfTapsRequired = 2;
		
		[tapGesture requireGestureRecognizerToFail:doubleTapGesture];
		
		[_view addGestureRecognizer:tapGesture];
		[_view addGestureRecognizer:doubleTapGesture];
		
		[self.contentView addSubview:_view];
        
        _progressView = [[DZProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _progressView.center = self.contentView.center;
        
        [self.contentView addSubview:self.progressView];
		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self centerScrollViewContents];
	[self updateScrollViewScale];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	self.imageView.image = nil;
	self.view.zoomScale = 1.0;
	self.isZoomed = NO;
}

- (void)setImage:(UIImage *)image
{
	self.imageView.image = image;
}

- (void)dealloc
{
	self.view.delegate = nil;
	[self removeObserver:self.imageView forKeyPath:@"image" context:nil];

}

#pragma mark - Getters

- (UIImageView *)imageView
{
	if(!_imageView)
	{
		_imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
		_imageView.backgroundColor = self.view.backgroundColor;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		
		_imageView.center = self.view.center;
		
		[_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
		
	}
	return _imageView;
}

#pragma mark - UIGestures

- (void)didTap:(UITapGestureRecognizer *)gesture
{
	self.forceStatusBarHidden = !self.forceStatusBarHidden;
	[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateStatusBarDisplay object:@{kStatusBarHiddenKey: @([self prefersStatusBarHidden])}];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)gesture
{
	
	CGPoint pointInView = [gesture locationInView:self.imageView];
	
//	NSLog(@"%@", NSStringFromCGPoint(pointInView));
	
	if(self.isZoomed)
	{
//		Zoom out
		
		[self.view setZoomScale:self.view.minimumZoomScale animated:YES];
	}
	else
	{
//		Zoom in at tapPoint
		
		CGSize scrollViewSize = self.view.bounds.size;
		
		CGFloat w = scrollViewSize.width / 1;
		CGFloat h = scrollViewSize.height / 1;
		CGFloat x = pointInView.x - (w / 2.0f);
		CGFloat y = pointInView.y - (h / 2.0f);
		
		CGRect rectToZoomTo = CGRectMake(x, y, w, h);
		
		[self.view zoomToRect:rectToZoomTo animated:YES];
		
	}
	
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
	return self.forceStatusBarHidden || self.statusBarAlwaysHidden || UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

#pragma mark - UIScrollView Delegate

- (void)centerScrollViewContents {
	
	CGSize boundsSize = self.view.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
	
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
	
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
	
    self.imageView.frame = contentsFrame;
}

- (void)updateScrollViewScale
{
	CGRect scrollViewFrame = self.contentView.bounds;
	CGSize contentSize = self.imageView.image.size;
	
	CGFloat scaleWidth = scrollViewFrame.size.width / contentSize.width;
	CGFloat scaleHeight = scrollViewFrame.size.height / contentSize.height;
	CGFloat minScale = MIN(scaleWidth, scaleHeight);
	
	self.view.minimumZoomScale = minScale;
	
	if(!self.isZoomed)
	{
		self.view.zoomScale = minScale;
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	[self centerScrollViewContents];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	self.isZoomed = !(scale == scrollView.minimumZoomScale);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	if([object isKindOfClass:[UIImageView class]] && [keyPath isEqualToString:@"image"])
	{
		UIImage *newImage = [change objectForKey:@"new"];
		if([newImage isKindOfClass:[NSNull class]]) return;
		if(newImage)
		{
            [self.progressView setHidden:YES];
			self.imageView.frame = (CGRect){.origin=CGPointZero,.size=newImage.size};
			self.view.contentSize = newImage.size;
			
			[self updateScrollViewScale];
		
		}
        else
        {
            [self.progressView setHidden:NO];
        }
		
	}
	
}

@end
