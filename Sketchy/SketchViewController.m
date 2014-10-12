//
//  SketchViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/4/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "SketchViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SketchViewController ()

@property (assign, nonatomic) CGPoint lastPoint;
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat diameter;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) BOOL isContinuousStroke;
@property (strong, nonatomic) UIImageView *backgroundLayer;

@end

@implementation SketchViewController

-(id) init {
    self = [super init];
    if (self) {
        self.red = 0.0/255.0;
        self.green = 0.0/255.0;
        self.blue = 0.0/255.0;
        self.diameter = 10.0;
        self.opacity = 1.0;
        self.isErasing = NO;
        self.savedSinceLastEdit = NO;
        
        self.backgroundLayer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundWhite.JPG"]];
        [self.backgroundLayer setFrame:self.view.bounds];
        [self.view addSubview:self.backgroundLayer];
        
        self.drawLayer = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.drawLayer setFrame:self.view.bounds];
        [self.view addSubview:self.drawLayer];
        
        self.tempLayer = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.tempLayer];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setRed:(CGFloat)r andGreen:(CGFloat)g andBlue:(CGFloat)b andOpacity:(CGFloat)o andDiameter:(CGFloat)d {
    self.red = r;
    self.green = g;
    self.blue = b;
    self.opacity = o;
    self.diameter = d;
}

- (UIImage*) getImage {
    // Return Blended Background and Draw Sketch
    UIGraphicsBeginImageContext(self.tempLayer.frame.size);
    [self.backgroundLayer.image drawInRect:CGRectMake(0, 0, self.backgroundLayer.frame.size.width, self.backgroundLayer.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.drawLayer.image drawInRect:CGRectMake(0, 0, self.drawLayer.frame.size.width, self.drawLayer.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempLayer.image = nil;
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Get location of initial touch
    self.isContinuousStroke = NO;
    self.savedSinceLastEdit = NO;
    UITouch *touch = [touches anyObject];
    self.lastPoint = [touch locationInView:self.drawLayer];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Draw line between last and current point
    self.isContinuousStroke = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.drawLayer];
    if (!CGPointEqualToPoint(self.lastPoint, currentPoint)) {
        [self drawBetweenPoint:self.lastPoint andPoint:currentPoint];
    }
    self.lastPoint = currentPoint;
}


// Draws line between two points

- (void) drawBetweenPoint: (CGPoint) startPoint andPoint: (CGPoint) endPoint {
    
    if (self.isErasing) {
        UIGraphicsBeginImageContext(self.drawLayer.frame.size);
        [self.drawLayer.image drawInRect:CGRectMake(0, 0, self.drawLayer.frame.size.width, self.drawLayer.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.diameter);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), endPoint.x, endPoint.y);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 0);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.drawLayer.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        
        UIGraphicsBeginImageContext(self.tempLayer.frame.size);
        [self.tempLayer.image drawInRect:CGRectMake(0, 0, self.tempLayer.frame.size.width, self.tempLayer.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.diameter);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), endPoint.x, endPoint.y);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, self.opacity);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempLayer.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.tempLayer setAlpha:self.opacity];
        UIGraphicsEndImageContext();
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Draw a point
    if(!self.isContinuousStroke) {
        [self drawBetweenPoint:self.lastPoint andPoint:self.lastPoint];
    }
    
    // Blend Temporary and Main Sketch
    if (!self.isErasing) {
        UIGraphicsBeginImageContext(self.drawLayer.frame.size);
        [self.drawLayer.image drawInRect:CGRectMake(0, 0, self.drawLayer.frame.size.width, self.drawLayer.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
        [self.tempLayer.image drawInRect:CGRectMake(0, 0, self.tempLayer.frame.size.width, self.tempLayer.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.opacity];
        self.drawLayer.image = UIGraphicsGetImageFromCurrentImageContext();
        self.tempLayer.image = nil;
        UIGraphicsEndImageContext();
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
