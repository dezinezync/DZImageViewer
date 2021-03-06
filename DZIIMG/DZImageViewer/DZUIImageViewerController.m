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

@interface DZUIImageViewerController () <UICollectionViewDelegateFlowLayout> {
    BOOL hidesInitial;
}

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
    
    if(self.currentIndex && self.currentIndex > 0)
    {
        hidesInitial = YES;
    }
    
    [self.collectionView setDataSource:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarDisplay:) name:kUpdateStatusBarDisplay object:nil];
    [self addObserver:self forKeyPath:@"photos" options:kNilOptions context:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if([self isModal])
    {
        
        if(!_closeButton)
        {
            _closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
            [_closeButton setTitle:@"Close" forState:UIControlStateHighlighted];
            [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_closeButton setTitleColor:[self.view tintColor] forState:UIControlStateHighlighted];
            
            _closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
            _closeButton.layer.borderWidth = 1/[UIScreen mainScreen].scale;
            
            _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
            
            [_closeButton addTarget:self action:@selector(shouldCloseImageViewer:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view insertSubview:self.closeButton aboveSubview:self.collectionView];
        }
        
        if(!_toolbar)
        {
            CGRect frame = self.collectionView.bounds;
            
            _toolbar = [[UIToolbar alloc] initWithFrame:(CGRect){.origin=CGPointMake(0, CGRectGetHeight(frame)-44),.size=CGSizeMake(frame.size.width, 44)}];
            _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            _toolbar.barStyle = UIBarStyleBlackTranslucent;
            
            [self.view insertSubview:_toolbar aboveSubview:self.collectionView];
        }
        
        self.closeButton.hidden = NO;
        
        [self.closeButton sizeToFit];
        
        self.closeButton.layer.cornerRadius = self.closeButton.frame.size.height/2;
        
//        Top right corner
        CGRect frame = self.closeButton.frame;
        frame.size.width += 20;
        frame.origin = CGPointMake(self.view.bounds.size.width - self.closeButton.bounds.size.width - 35, 35);
        
        self.closeButton.frame = frame;
    }
    
    [super viewDidAppear:animated];
    
    if(self.currentIndex)
    {
//        LogID(@"Scrolling to selected");
        __weak typeof(self) weakSelf = self;
        
        asyncMain(^{
            
            [weakSelf setSelectedIndex:weakSelf.currentIndex];
            
        });
        
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    if(self.closeButton)
    {
        self.closeButton.hidden = YES;
    }
    
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
//    Should not be set since we don't have that photo.
    if(index > ([self.photos count]-1)) return;
    
    self.currentIndex = index;
    
    CGSize currentSize = self.collectionView.bounds.size;
    CGFloat offset = self.currentIndex * currentSize.width;
    CGPoint pointOffset = CGPointMake(offset, 0);
    
    [self.collectionView setContentOffset:pointOffset animated:NO];
}

- (NSInteger)getSelectedIndex
{
    return self.currentIndex;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

#pragma mark - UI Actions

- (void)shouldCloseImageViewer:(UIButton *)close
{
    [self dismissViewControllerAnimated:YES completion:^{
//        LogID(@"Dismissed");
    }];
}


#pragma mark - Notifications

- (void)updateStatusBarDisplay:(NSNotification *)notification
{
    
    NSNumber *hide = [notification.object objectForKey:kStatusBarHiddenKey];
	__weak typeof(self) weakSelf = self;

    CGRect frame = self.toolbar.frame;
//    ToolbarHeight + 1 for the toolbar top stroke;
    CGFloat adjustBy = CGRectGetHeight(self.toolbar.frame)+1;
    
    if([hide boolValue])
    {
        frame.origin.y += adjustBy;
    }
    else
    {
        frame.origin.y -= adjustBy;
    }
    
    if([hide boolValue])
	{
		_hideStatusBar = [hide boolValue];
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        if(self.closeButton && !self.closeButton.hidden)
        {
            [UIView animateWithDuration:duration animations:^{
                
                typeof(weakSelf) sself = self;
                
                sself.closeButton.alpha = 0;
                sself.toolbar.frame = frame;
                
            }];
        }
        
	}
    else
    {
        _hideStatusBar = [hide boolValue];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		
        if(self.closeButton && !self.closeButton.hidden)
        {
            [UIView animateWithDuration:duration animations:^{
                
                typeof(weakSelf) sself = self;
                
                sself.closeButton.alpha = 1;
                sself.toolbar.frame = frame;
                
            }];
        }
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
    
    if(indexPath.item == 0 && hidesInitial)
    {
//        Do nothing since the user wishes to see another image to start with?
        hidesInitial = NO;
        return cell;
    }
    
    hidesInitial = NO;
    
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[(DZUIImageViewerCell *)cell imageView] sd_cancelCurrentImageLoad];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger idx = self.collectionView.contentOffset.x / pageWidth;
    
    if(self.currentIndex == idx) return;
    
    self.currentIndex = idx;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didChangeSelectedIndex:)])
    {
        [self.delegate performSelector:@selector(didChangeSelectedIndex:) withObject:@(idx)];
    }
    
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
