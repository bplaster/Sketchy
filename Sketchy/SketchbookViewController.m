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
@property (nonatomic, strong) UIBarButtonItem *playButton;
@property (nonatomic, strong) UIBarButtonItem *stopButton;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) UIPageControl *pageControl;

// Pen properties
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat diameter;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) CGFloat frameRate;

@end

@implementation SketchbookViewController

@synthesize delegate;


-(id)init{
    self = [super init];
    if (self) {
        // Set up Navigation Bar
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        [self.navigationItem setLeftBarButtonItem:backButton];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"palette.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettingsPressed)];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveSketchPressed)];
        
        [self.navigationItem setRightBarButtonItems:@[saveButton, settingsButton]];
        
        // Set up Toolbar
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSketchView)];
        self.playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playStop)];
        self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(playStop)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [self setToolbarItems:@[self.playButton, flexibleSpace, addButton]];
    }
    return self;
}

- (void) backButtonPressed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:@"Care to save your work?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
    alert.tag = 1;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [self saveSketchPressed];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:NO];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.frameRate = 20;
    
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
    self.pageController.delegate = self;
    
    // Drawing Area
    CGFloat statusBarHeight = ([[UIApplication sharedApplication] statusBarFrame]).size.height;
    CGFloat vcWidth = self.view.bounds.size.width;
    CGFloat vcHeight = self.view.bounds.size.height - statusBarHeight - self.navigationController.navigationBar.bounds.size.height - self.navigationController.toolbar.bounds.size.height;
    CGFloat vcX = 0;
    CGFloat vcY = statusBarHeight + self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        
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

    // Set up page control
    CGFloat pcX = 0;
    CGFloat pcY = 0;
    CGFloat pcWidth = self.navigationController.toolbar.bounds.size.width;
    CGFloat pcHeight = self.navigationController.toolbar.bounds.size.height;
    [self.pageControl setFrame:CGRectMake(pcX, pcY, pcWidth, pcHeight)];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHue:0.6 saturation:1 brightness:1 alpha:1]];
    [self.pageControl setPageIndicatorTintColor:[UIColor colorWithHue:0.6 saturation:1 brightness:1 alpha:0.5]];
    [self.pageControl setUserInteractionEnabled:NO];
    [self.navigationController.toolbar addSubview:self.pageControl];
    
    // Attach pagecontroller gestures to toolbar
    for (UIGestureRecognizer *gest in self.pageController.gestureRecognizers) {
        [self.navigationController.toolbar addGestureRecognizer:gest];
    }
    
    // Other setup
    self.isPlaying = NO;
    [self viewControllerAtIndex:0];
}

// Plays the animation
- (void) playStop {
    NSMutableArray* itemsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.toolbar.items];
    if (self.isPlaying) {
        self.isPlaying = NO;
        [itemsArray setObject:self.playButton atIndexedSubscript:0];
        SketchViewController *currView = [self viewControllerAtIndex:self.pageControl.currentPage];
        [currView.tempSketchView stopAnimating];
        [currView.tempSketchView setImage:nil];
        [currView.mainSketchView setHidden:NO];
    } else {
        self.isPlaying = YES;
        [itemsArray setObject:self.stopButton atIndexedSubscript:0];
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for (SketchViewController *sketchView in self.viewControllers) {
            [imageArray addObject:sketchView.mainSketchView.image];
        }
        SketchViewController *currView = [self viewControllerAtIndex:self.pageControl.currentPage];
        [currView.mainSketchView setHidden:YES];
        [currView.tempSketchView setAnimationImages:imageArray];
        [currView.tempSketchView setAnimationDuration:imageArray.count/self.frameRate];
        //[currView.tempSketchView setAnimationRepeatCount:1];
        [currView.tempSketchView startAnimating];
    }
    [self.navigationController.toolbar setItems:itemsArray animated:YES];

}

- (void)openSettingsPressed {
    SettingsViewController *settingsView = [[SettingsViewController alloc] init];
    [settingsView setRed:self.red andGreen:self.green andBlue:self.blue andOpacity:self.opacity andDiameter:self.diameter andFrameRate:self.frameRate];
    [settingsView setDelegate:self];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (void)closeSettings:(id)sender {
    self.red = ((SettingsViewController*)sender).red;
    self.green = ((SettingsViewController*)sender).green;
    self.blue = ((SettingsViewController*)sender).blue;
    self.opacity = ((SettingsViewController*)sender).opacity;
    self.diameter = ((SettingsViewController*)sender).diameter;
    self.frameRate = ((SettingsViewController*)sender).frameRate;

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
                if (i == count - 1) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Pardon my mistake. Would you mind trying again?" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
                    [alert show];
                }
            } else {
                [self.sketchURLArray addObject: [assetURL absoluteString]];
                if (i == count - 1) {
                    [self.delegate storeSketchURL:self];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your masterpiece is in the archives." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
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


// Returns viewController at given index
- (SketchViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.sketchNameArray count] == 0) || (index >= [self.sketchNameArray count])) {
        return nil;
    }
    return [self.viewControllers objectAtIndex:index];
}

// Returns index of viewController
- (NSUInteger)indexOfViewController:(SketchViewController *)viewController{
    return [self.sketchNameArray indexOfObject:viewController.dataObject];
}

#pragma mark - UIPageViewControllerDataSource Methods

// Returns viewController before viewController
- (UIViewController *)pageViewController: (UIPageViewController *)pageViewController viewControllerBeforeViewController: (UIViewController *)viewController{
    NSUInteger index = [self indexOfViewController:(SketchViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
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
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate Methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        NSInteger index = [self indexOfViewController: [[pageViewController viewControllers] lastObject]];
        [self.pageControl setCurrentPage: index];
    }
}


@end
