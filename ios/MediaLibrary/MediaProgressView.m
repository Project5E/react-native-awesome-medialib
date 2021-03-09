//
//  MediaProgressView.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaProgressView.h"

@interface MediaProgressView()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation MediaProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
      self.backgroundColor = [UIColor clearColor];
      
      _progressLayer = [CAShapeLayer layer];
      _progressLayer.fillColor = [[UIColor clearColor] CGColor];
      _progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
      _progressLayer.opacity = 1;
      _progressLayer.lineCap = kCALineCapRound;
      _progressLayer.lineWidth = 5;
      
      [_progressLayer setShadowColor:[UIColor blackColor].CGColor];
      [_progressLayer setShadowOffset:CGSizeMake(1, 1)];
      [_progressLayer setShadowOpacity:0.5];
      [_progressLayer setShadowRadius:2];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = rect.size.width / 2;
    CGFloat startA = - M_PI_2;
    CGFloat endA = - M_PI_2 + M_PI * 2 * _progress;
    _progressLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    _progressLayer.path =[path CGPath];
    
    [_progressLayer removeFromSuperlayer];
    [self.layer addSublayer:_progressLayer];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay];
}
@end
