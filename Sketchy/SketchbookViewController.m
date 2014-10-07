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

@end

@implementation SketchbookViewController

@synthesize delegate;


-(id)init{
    self = [super init];
    if (self) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Exit" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem:backButton];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(openSettingsPressed)];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSketchPressed)];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addSketchPressed)];
        [self setToolbarItems:@[addButton]];
        
        [self.navigationItem setRightBarButtonItems:@[saveButton, settingsButton, addButton]];
        
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
    
    // Add initial Sketch
    [self.sketchNameArray addObjectsFromArray:@[@"Frame: 0"]];
    self.viewControllers = [[NSMutableArray alloc] init];
    SketchViewController *initialViewController = [self viewControllerAtIndex:0];
    
    //Setup pagecontroller
    NSDictionary *options = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                        forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle: UIPageViewControllerTransitionStylePageCurl
                                                          navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal
                                                                        options: options];
    self.pageController.dataSource = self;
    
    
    // Gesture Area
    CGFloat fvWidth = initialViewController.view.bounds.size.width;
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
    self.framesView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.framesView];
    
    for (UIGestureRecognizer *gest in self.pageController.gestureRecognizers) {
        [self.framesView addGestureRecognizer:gest];
    }
}

// Returns viewController at given index
- (SketchViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.sketchNameArray count] == 0) || (index >= [self.sketchNameArray count])) {
        return nil;
    }
    if ([self.viewControllers count] <= index) {
        SketchViewController *sketchView = [[SketchViewController alloc] init];
        sketchView.dataObject = [self.sketchNameArray objectAtIndex:index];
        [self.viewControllers addObject:sketchView];
    }
    
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

- (void)openSettingsPressed {
    
}

- (void) addSketchPressed {
    [self.sketchNameArray addObject:[NSString stringWithFormat:@"Frame: %i",(int)self.sketchNameArray.count]];
}

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
