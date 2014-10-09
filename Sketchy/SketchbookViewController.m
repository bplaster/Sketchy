//
//  SketchbookViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/7/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "SketchbookViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SketchbookViewController ()

@property (nonatomic, strong) UIView *framesView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSString *saveResult;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) UIPageControl *pageControl;

// Pen properties
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat diameter;
@property (assign, nonatomic) CGFloat opacity;

@end

@implementation SketchbookViewController

@synthesize delegate;


-(id)init{
    self = [super init];
    if (self) {
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem:self.backButton];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"palette.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettingsPressed)];
        
        self.saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveSketchPressed)];
        
        [self.navigationItem setRightBarButtonItems:@[self.saveButton, settingsButton]];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Name the project
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    self.sketchbookName = [formatter stringFromDate:[NSDate date]];
    self.sketchNameArray = [[NSMutableArray alloc] init];
    self.sketchURLArray = [[NSMutableArray alloc] init];
    
    // Setup drawing defaults
    self.red = 0.0/255.0;
    self.green = 0.0/255.0;
    self.blue = 0.0/255.0;
    self.diameter = 10.0;
    self.opacity = 1.0;
    
    // Add pagecontrol display
    self.pageControl = [[UIPageControl alloc] init];
    
    // Add initial Sketch
    self.viewControllers = [[NSMutableArray alloc] init];
    
    //Setup pagecontroller
    NSDictionary *options = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                        forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle: UIPageViewControllerTransitionStylePageCurl
                                                          navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal
                                                                        options: options];
    self.pageController.dataSource = self;
    
    
    // Gesture Area
    CGFloat fvWidth = self.view.bounds.size.width;
    CGFloat fvHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat fvX = self.view.bounds.origin.x;
    CGFloat fvY = self.view.bounds.size.height - fvHeight;
    
    // Drawing Area
    CGFloat statusBarHeight = ([[UIApplication sharedApplication] statusBarFrame]).size.height;
    CGFloat vcWidth = fvWidth;
    CGFloat vcHeight = self.view.bounds.size.height - statusBarHeight - self.navigationController.navigationBar.bounds.size.height - fvHeight;
    CGFloat vcX = fvX;
    CGFloat vcY = fvY - vcHeight;
        
    // Set up drawing area
    [self addSketchView];
    [self.pageController.view setFrame:CGRectMake(vcX, vcY, vcWidth, vcHeight)];
    [self.pageController setViewControllers:self.viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview: self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    // Set up area for gestures
    self.framesView = [[UIView alloc] initWithFrame:CGRectMake(fvX, fvY, fvWidth, fvHeight)];
    [self.framesView setBackgroundColor: [UIColor colorWithHue:0 saturation:0 brightness:0.9 alpha:1]];
    [self.view addSubview:self.framesView];
    
    // Add buttons
    UIButton *addButton = [[UIButton alloc] initWithFrame:((UIView*)[self.saveButton valueForKey:@"view"]).frame];
    UIImage *addImage = [[UIImage imageNamed:@"add.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addSketchView) forControlEvents:UIControlEventTouchUpInside];
    [self.framesView addSubview:addButton];
    
    self.playButton = [[UIButton alloc] initWithFrame:((UIView*)[self.backButton valueForKey:@"view"]).frame];
    UIImage *playImage = [[UIImage imageNamed:@"play.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.playButton setImage:playImage forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAnimationPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.framesView addSubview:self.playButton];
    
    //Page control area
    CGFloat pcX = self.playButton.frame.origin.x + self.playButton.frame.size.width;
    CGFloat pcY = self.playButton.frame.origin.y;
    CGFloat pcWidth = addButton.frame.origin.x - pcX;
    CGFloat pcHeight = self.playButton.frame.size.height;
    [self.pageControl setFrame:CGRectMake(pcX, pcY, pcWidth, pcHeight)];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHue:0.6 saturation:1 brightness:1 alpha:1]];
    [self.pageControl setPageIndicatorTintColor:[UIColor colorWithHue:0.6 saturation:1 brightness:1 alpha:0.5]];
    [self.pageControl setUserInteractionEnabled:NO];
    [self.framesView addSubview:self.pageControl];
    
    // Attach pagecontroller gestures to framesView
    for (UIGestureRecognizer *gest in self.pageController.gestureRecognizers) {
        [self.framesView addGestureRecognizer:gest];
    }
    
    // Other setup
    self.isPlaying = NO;
    [self viewControllerAtIndex:0];
}

// Plays the animation
- (void) playAnimationPressed {
    if (self.isPlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        self.isPlaying = NO;
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        self.isPlaying = YES;
    }
}

// Returns viewController at given index
- (SketchViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.sketchNameArray count] == 0) || (index >= [self.sketchNameArray count])) {
        return nil;
    }
    [self.pageControl setCurrentPage: index];
    return [self.viewControllers objectAtIndex:index];
}

// Returns index of viewController
- (NSUInteger)indexOfViewController:(SketchViewController *)viewController{
    return [self.sketchNameArray indexOfObject:viewController.dataObject];
}

// Returns viewController before viewController
- (UIViewController *)pageViewController: (UIPageViewController *)pageViewController viewControllerBeforeViewController: (UIViewController *)viewController{
    NSUInteger index = [self indexOfViewController:(SketchViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    [self.pageControl setCurrentPage: index];
    return [self viewControllerAtIndex:index];
}

// Returns viewController after viewController
- (UIViewController *)pageViewController: (UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController: (SketchViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.sketchNameArray count]) {
        return nil;
    }
    
    [self.pageControl setCurrentPage: index];
    return [self viewControllerAtIndex:index];
}

- (void)openSettingsPressed {
    SettingsViewController *settingsView = [[SettingsViewController alloc] init];
    [settingsView setRed:self.red andGreen:self.green andBlue:self.blue andOpacity:self.opacity andDiameter:self.diameter];
    [settingsView setDelegate:self];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (void)closeSettings:(id)sender {
    self.red = ((SettingsViewController*)sender).red;
    self.green = ((SettingsViewController*)sender).green;
    self.blue = ((SettingsViewController*)sender).blue;
    self.opacity = ((SettingsViewController*)sender).opacity;
    self.diameter = ((SettingsViewController*)sender).diameter;
    [self.navigationController popViewControllerAnimated:YES];
    
    for (SketchViewController *sketchView in self.viewControllers) {
        [sketchView setRed:self.red andGreen:self.green andBlue:self.blue andOpacity:self.opacity andDiameter:self.diameter];
    }
}

// Adds a new sketch view
- (void) addSketchView {
    NSString *sketchName = [NSString stringWithFormat:@"Frame: %i",(int)[self.sketchNameArray count]];
    [self.sketchNameArray addObject: sketchName];
    
    SketchViewController *sketchView = [[SketchViewController alloc] init];
    sketchView.dataObject = sketchName;
    [sketchView setRed:self.red andGreen:self.green andBlue:self.blue andOpacity:self.opacity andDiameter:self.diameter];
    [self.viewControllers addObject:sketchView];

    [self.pageControl setNumberOfPages:[self.sketchNameArray count]];
}

// Saves all sketches
- (void)saveSketchPressed {
    NSUInteger count = [self.viewControllers count];
    for (int i = 0; i < count; i++) {
    
        SketchViewController *vc = [self.viewControllers objectAtIndex:i];
        UIGraphicsBeginImageContextWithOptions(vc.mainSketchView.bounds.size, NO,0.0);
        [vc.mainSketchView.image drawInRect:CGRectMake(0, 0, vc.mainSketchView.frame.size.width, vc.mainSketchView.frame.size.height)];
        UIImage *saveSketch = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[saveSketch CGImage] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please try again" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
                [alert show];
            } else {
                [self.sketchURLArray addObject: [assetURL absoluteString]];
                if (i == count - 1) {
                    [self.delegate storeSketchURL:self];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Project saved" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
                    [alert show];
                }
            }
        }];
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
