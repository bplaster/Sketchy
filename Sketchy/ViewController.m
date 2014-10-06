//
//  ViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/4/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSString *savedSketchesKey;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navController = [[UINavigationController alloc] init];
    self.savedSketchesKey = @"sketches";
}

// Create new sketch book
- (IBAction)newSketchbookPressed:(id)sender {
    SketchViewController *newSketchView = [[SketchViewController alloc] init];
    [newSketchView setDelegate:self];
    [self.navController setViewControllers:@[newSketchView]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    [newSketchView.navigationItem setLeftBarButtonItem:backButton];
    [self presentViewController:self.navController animated:YES completion:nil];
}

// View Sketch book gallery
- (IBAction)viewSketchbooksPressed:(id)sender {
    NSArray *savedSketchesArray = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.savedSketchesKey]];
    GalleryTableViewController *galleryTableView = [[GalleryTableViewController alloc] initWithSketchArray:savedSketchesArray];
    [self.navController setViewControllers:@[galleryTableView]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    [galleryTableView.navigationItem setLeftBarButtonItem:backButton];
    [self presentViewController:self.navController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SketchViewControllerDelegate methods

- (void)storeSketchURL:(id)sender {
    NSURL *newSketchURL = ((SketchViewController*)sender).sketchURL;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *newSketchName = [formatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setURL:newSketchURL forKey:newSketchName];
    NSMutableArray *savedSketchesArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.savedSketchesKey]];
    [savedSketchesArray addObject:newSketchName];
    [[NSUserDefaults standardUserDefaults] setObject:savedSketchesArray forKey:self.savedSketchesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
