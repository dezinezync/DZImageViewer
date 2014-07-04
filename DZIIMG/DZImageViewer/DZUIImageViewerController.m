//
//  DZUIImageViewerController.m
//  DZIIMG
//
//  Created by Nikhil Nigade on 6/30/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import "DZUIImageViewerController.h"
#import "DZUIImageViewerCell.h"
#import "UIImageView+WebCache.h"

static NSString *cellIdentifier = @"com.dezinezync.imageviewercell";

@interface DZUIImageViewerController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) BOOL hideStatusBar, forcedStatusBarHidden;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation DZUIImageViewerController

- (instancetype)init
{
	
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	layout.minimumInteritemSpacing = 0;
	layout.minimumLineSpacing = 0;
	
    if (self = [super initWithCollectionViewLayout:layout])
	{
        // Custom initialization
		_photos = @[];
		
		self.view.backgroundColor = [UIColor blackColor];
		
		self.collectionView.pagingEnabled = YES;
		self.collectionView.backgroundColor = [UIColor blackColor];
		self.collectionView.showsHorizontalScrollIndicator = NO;
		self.collectionView.layer.rasterizationScale = [UIScreen mainScreen].scale;
		
		[self.collectionView registerClass:[DZUIImageViewerCell class] forCellWithReuseIdentifier:cellIdentifier];
		
		_hideStatusBar = NO;
		_forcedStatusBarHidden = NO;
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self.collectionView setDataSource:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarDisplay:) name:kUpdateStatusBarDisplay object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[self.collectionView setDataSource:nil];
}

#pragma mark - Rotation

// iOS 7
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[self.collectionView.collectionViewLayout invalidateLayout];
	
	CGPoint currentOffset = [self.collectionView contentOffset];
	self.currentIndex = currentOffset.x / self.collectionView.frame.size.width;
    self.collectionView.alpha = 0;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.forcedStatusBarHidden = YES;
    }
    else
    {
        self.forcedStatusBarHidden = NO;
    }
	
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	// Force realignment of cell being displayed
    CGSize currentSize = self.collectionView.bounds.size;
    CGFloat offset = self.currentIndex * currentSize.width;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        
        typeof(weakSelf) sself = weakSelf;
        sself.collectionView.alpha = 1.0f;
        
    }];
	
}

// iOS 8
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//	NSLog(@"HERE?");
//	self.forcedStatusBarHidden = size.height == 320.0f;
//	[self setNeedsStatusBarAppearanceUpdate];
//	
//	if(coordinator)
//	{
//		[self.collectionView.collectionViewLayout invalidateLayout];
//		
//		CGPoint currentOffset = [self.collectionView contentOffset];
//		self.currentIndex = currentOffset.x / self.collectionView.frame.size.width;
//		self.collectionView.alpha = 0;
//		
//		__weak typeof(self) weakSelf = self;
//		[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//		
//		} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//			
//			typeof(weakSelf) sself = weakSelf;
//			
//			CGSize currentSize = size;
//			CGFloat offset = self.currentIndex * currentSize.width;
//            
//            NSLog(@"%.2f", offset);
//            
//			[sself.collectionView setContentOffset:CGPointMake(offset, 0)];
//			
//			[UIView animateWithDuration:0.15 animations:^{
//				
//				sself.collectionView.alpha = 1.0f;
//				
//			}];
//			
//		}];
//		
//	}
//	
//}

#pragma mark - Notifications

- (void)updateStatusBarDisplay:(NSNotification *)notification
{
	NSNumber *hide = [notification.object objectForKey:kStatusBarHiddenKey];
	if(hide)
	{
		_hideStatusBar = [hide boolValue];
		[self setNeedsStatusBarAppearanceUpdate];
	}
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	DZUIImageViewerCell *cell = (DZUIImageViewerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	
	id obj = [self.photos objectAtIndex:indexPath.item];
	
    if([obj isKindOfClass:[UIImage class]])
    {
        [cell setImage:obj];
    }
    else
    {
        NSURL *url;
        
        if([obj isKindOfClass:[NSString class]])
        {
            url = [NSURL URLWithString:obj];
        }
        else if([obj isKindOfClass:[NSURL class]])
        {
            url = obj;
        }
        
        __weak typeof(cell) weakCell = cell;
        
        [cell.imageView sd_setImageWithURL:url placeholderImage:nil options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            if(!weakCell) return;
            
            CGFloat progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
            
            [(DZUIImageViewerCell *)weakCell progressView].progress = progress;
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if(!weakCell) return;
            
            if(error)
            {
                NSLog(@"%@", error);
                [(DZUIImageViewerCell *)cell progressView].progress = 1.0f;
                return;
            }
            
            [weakCell centerScrollViewContents];
            
        }];
        
    }
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [(DZUIImageViewerCell *)cell centerScrollViewContents];
}

#pragma mark - Collection View Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.collectionView.bounds.size;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
	return self.forcedStatusBarHidden || self.hideStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationSlide;
}

@end
