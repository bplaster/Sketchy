//
//  SettingsViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/8/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *diameterLabel;
@property (strong, nonatomic) IBOutlet UILabel *redLabel;
@property (strong, nonatomic) IBOutlet UILabel *greenLabel;
@property (strong, nonatomic) IBOutlet UILabel *blueLabel;
@property (strong, nonatomic) IBOutlet UILabel *opacityLabel;
@property (strong, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *brushView;
@property (strong, nonatomic) IBOutlet UISlider *diameterSlider;
@property (strong, nonatomic) IBOutlet UISlider *redSlider;
@property (strong, nonatomic) IBOutlet UISlider *greenSlider;
@property (strong, nonatomic) IBOutlet UISlider *blueSlider;
@property (strong, nonatomic) IBOutlet UISlider *opacitySlider;
@property (strong, nonatomic) IBOutlet UISlider *frameRateSlider;

@end

@implementation SettingsViewController

@synthesize delegate;
-(id) init {
    self = [super init];
    if (self) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeSettings)];
        [self.navigationItem setLeftBarButtonItem:backButton];
        [self setTitle:@"Settings"];
        
        self.red = 0.0/255.0;
        self.green = 0.0/255.0;
        self.blue = 0.0/255.0;
        self.diameter = 10.0;
        self.opacity = 1.0;
        self.frameRate = 20.0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateBrushView];
    [self updateUIElements];
}

- (void)setRed:(CGFloat)r andGreen:(CGFloat)g andBlue:(CGFloat)b andOpacity:(CGFloat)o andDiameter:(CGFloat)d andFrameRate:(CGFloat)f{
    self.red = r;
    self.green = g;
    self.blue = b;
    self.opacity = o;
    self.diameter = d;
    self.frameRate = f;
}

- (IBAction)sliderChanged:(id)sender {
    UISlider *changedSlider = (UISlider*)sender;
    if (changedSlider == self.diameterSlider) {
        self.diameter = changedSlider.value;
        self.diameterLabel.text = [NSString stringWithFormat:@"%.1f", self.diameter];
    } else if (changedSlider == self.redSlider) {
        self.red = changedSlider.value;
        self.redLabel.text = [NSString stringWithFormat:@"%.1f", self.red];
    } else if (changedSlider == self.greenSlider) {
        self.green = changedSlider.value;
        self.greenLabel.text = [NSString stringWithFormat:@"%.1f", self.green];
    } else if (changedSlider == self.blueSlider) {
        self.blue = changedSlider.value;
        self.blueLabel.text = [NSString stringWithFormat:@"%.1f", self.blue];
    } else if (changedSlider == self.opacitySlider) {
        self.opacity = changedSlider.value;
        self.opacityLabel.text = [NSString stringWithFormat:@"%.1f", self.opacity];
    } else if (changedSlider == self.frameRateSlider) {
        self.frameRate = changedSlider.value;
        self.frameRateLabel.text = [NSString stringWithFormat:@"%.1f", self.frameRate];
    }
    [self updateBrushView];
}

-(void) updateBrushView {
    UIGraphicsBeginImageContext(self.brushView.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(),self.diameter);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, self.opacity);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.brushView.bounds.size.width/2, self.brushView.bounds.size.height/2);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.brushView.bounds.size.width/2, self.brushView.bounds.size.height/2);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.brushView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void) updateUIElements {
    
    self.diameterSlider.value = self.diameter;
    self.redSlider.value = self.red;
    self.greenSlider.value = self.green;
    self.blueSlider.value = self.blue;
    self.opacitySlider.value = self.opacity;
    self.frameRateSlider.value = self.frameRate;
    
    self.diameterLabel.text = [NSString stringWithFormat:@"%.1f", self.diameter];
    self.redLabel.text = [NSString stringWithFormat:@"%.1f", self.red];
    self.greenLabel.text = [NSString stringWithFormat:@"%.1f", self.green];
    self.blueLabel.text = [NSString stringWithFormat:@"%.1f", self.blue];
    self.opacityLabel.text = [NSString stringWithFormat:@"%.1f", self.opacity];
    self.frameRateLabel.text = [NSString stringWithFormat:@"%.1f", self.frameRate];
}

- (void)closeSettings {
    [self.delegate closeSettings:self];
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
