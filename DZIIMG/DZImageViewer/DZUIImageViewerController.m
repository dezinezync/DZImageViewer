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
#import "DZFlowLayout.h"

static NSString *cellIdentifier = @"com.dezinezync.imageviewercell";

@interface DZUIImageViewerController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) BOOL hideStatusBar, forcedStatusBarHidden;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation DZUIImageViewerController

- (instancetype)init
{
	
	DZFlowLayout *layout = [[DZFlowLayout alloc] init];
    
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
    [self addObserver:self forKeyPath:@"photos" options:kNilOptions context:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[self.collectionView setDataSource:nil];
    [self removeObserver:self forKeyPath:@"photos"];
}

- (void)setSelectedIndex:(NSInteger)index
{
    self.currentIndex = index;
    
    CGSize currentSize = self.collectionView.bounds.size;
    CGFloat offset = self.currentIndex * currentSize.width;
    
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
}

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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"photos"])
    {
        [self.collectionView reloadData];
    }
}

@end
