//
//  DZProgressView.m
//  DZIIMG
//
//  Created by Nikhil Nigade on 7/4/14.
//  Copyright (c) 2014 Nikhil Nigade. All rights reserved.
//

#import "DZProgressView.h"

CGFloat deg2rad(NSInteger degress)
{
    return degress * M_PI/180;
}

CGFloat interpolate(CGFloat a, CGFloat b, CGFloat progress)
{
    return a + (b - a) * progress;
}

@interface DZProgressView()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGFloat oldProgress;
//@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation DZProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _progress = 0.0f;
        _oldProgress = 0.0f;
        
        CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        
        UIBezierPath *path = [UIBezierPath
                              bezierPathWithArcCenter:CGPointZero
                              radius:MAX(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))/2
                              startAngle:deg2rad(-90)
                              endAngle:deg2rad(270)
                              clockwise:YES];
        
        path.lineCapStyle = kCGLineCapButt;
        
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.strokeColor = [self tintColor].CGColor;
        _shapeLayer.lineWidth = [UIScreen mainScreen].scale;
        _shapeLayer.position = center;
        _shapeLayer.lineCap = kCGLineCapButt;
        _shapeLayer.path = path.CGPath;
        _shapeLayer.strokeStart = 0.0f;
        _shapeLayer.strokeEnd = 0.0f;
        
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
        
        [self.layer addSublayer:_shapeLayer];
        
    }
    return self;
}

- (void)updateProgress
{
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.15;
    pathAnimation.fromValue = @(MIN(_oldProgress,self.shapeLayer.strokeStart));
    pathAnimation.toValue = @(_progress);
    pathAnimation.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.103:0.389:0.307:0.966];
    
    self.shapeLayer.strokeEnd = _progress;
    
    [self.shapeLayer removeAllAnimations];
    [self.shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

- (void)setProgress:(CGFloat)progress
{
    _oldProgress = _progress;
    _progress = progress;
    
    if(progress > 0.0f && progress < 1.0f)
    {
        [self setHidden:NO];
    }
    else
    {
        [self setHidden:YES];
    }
    
    if(_oldProgress != _progress) [self updateProgress];
}

@end
