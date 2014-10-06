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

@property (strong, nonatomic) IBOutlet UIImageView *mainSketchView;
@property (strong, nonatomic) IBOutlet UIImageView *tempSketchView;
@property (assign, nonatomic) CGPoint lastPoint;
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat brush;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) BOOL isContinuousStroke;

@end

@implementation SketchViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.red = 0.0/255.0;
    self.green = 0.0/255.0;
    self.blue = 0.0/255.0;
    self.brush = 10.0;
    self.opacity = 1.0;
    
    self.sketchURL = [[NSURL alloc] init];

}


- (IBAction)addFramePressed:(id)sender {
}


- (IBAction)saveSketchPressed:(id)sender {
    UIGraphicsBeginImageContextWithOptions(self.mainSketchView.bounds.size, NO,0.0);
    [self.mainSketchView.image drawInRect:CGRectMake(0, 0, self.mainSketchView.frame.size.width, self.mainSketchView.frame.size.height)];
    UIImage *saveSketch = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[saveSketch CGImage] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
     if (error) {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved. Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
         [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
        self.sketchURL = assetURL;
        [self.delegate storeSketchURL:self];
    }
     }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Get location of initial touch
    self.isContinuousStroke = NO;
    UITouch *touch = [touches anyObject];
    self.lastPoint = [touch locationInView:self.mainSketchView];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Draw line between last and current point
    self.isContinuousStroke = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.mainSketchView];
    [self drawBetweenPoint:self.lastPoint andPoint:currentPoint];
    self.lastPoint = currentPoint;
}


// Draws line between two points

- (void) drawBetweenPoint: (CGPoint) startPoint andPoint: (CGPoint) endPoint {
    
    UIGraphicsBeginImageContext(self.tempSketchView.frame.size);
    [self.tempSketchView.image drawInRect:CGRectMake(0, 0, self.tempSketchView.frame.size.width, self.tempSketchView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, self.opacity);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), endPoint.x, endPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.tempSketchView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempSketchView setAlpha:self.opacity];
    UIGraphicsEndImageContext();
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Draw a point
    if(!self.isContinuousStroke) {
        [self drawBetweenPoint:self.lastPoint andPoint:self.lastPoint];
    }
    
    // Blend Temporary and Main Sketch
    UIGraphicsBeginImageContext(self.mainSketchView.frame.size);
    [self.mainSketchView.image drawInRect:CGRectMake(0, 0, self.mainSketchView.frame.size.width, self.mainSketchView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempSketchView.image drawInRect:CGRectMake(0, 0, self.tempSketchView.frame.size.width, self.tempSketchView.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.opacity];
    self.mainSketchView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempSketchView.image = nil;
    UIGraphicsEndImageContext();
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
