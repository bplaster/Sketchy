//
//  ViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/4/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *savedSketchbookNamesArrayKey;
@property (nonatomic, strong) NSString *savedSketchbooksDictionaryKey;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.savedSketchbookNamesArrayKey = @"sketchbookNames";
    self.savedSketchbooksDictionaryKey = @"sketchbooksDictionary";
}

// Create new sketch book
- (IBAction)newSketchbookPressed:(id)sender {
    SketchbookViewController *newSketchbookView = [[SketchbookViewController alloc] init];
    [newSketchbookView setDelegate:self];
    UINavigationController *sketchNav = [[UINavigationController alloc] initWithRootViewController:newSketchbookView];
    [self presentViewController:sketchNav animated:YES completion:nil];
}

// View Sketch book gallery
- (IBAction)viewSketchbooksPressed:(id)sender {
    NSArray *savedSketchbookNamesArray = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.savedSketchbookNamesArrayKey]];
    NSDictionary *savedSketchbooksDictionary = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:self.savedSketchbooksDictionaryKey]];
    
    GalleryTableViewController *galleryTableView = [[GalleryTableViewController alloc] initWithArray:savedSketchbookNamesArray andDictionary:savedSketchbooksDictionary];
    UINavigationController *galleryNav = [[UINavigationController alloc] initWithRootViewController:galleryTableView];
    [self presentViewController:galleryNav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SketchViewControllerDelegate methods

- (void)storeSketchURL:(id)sender {
    NSMutableArray *savedSketchbookNamesArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.savedSketchbookNamesArrayKey]];
    NSMutableDictionary *savedSketchbooksDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:self.savedSketchbooksDictionaryKey]];
    
    NSString *newSketchbookName = ((SketchbookViewController*)sender).sketchbookName;
    NSArray *newSketchURLArray = [[NSArray alloc] initWithArray:((SketchbookViewController*)sender).sketchURLArray];
    if (![savedSketchbookNamesArray containsObject:newSketchbookName]) {
        [savedSketchbookNamesArray addObject:newSketchbookName];
    }
    [savedSketchbooksDictionary setObject:newSketchURLArray forKey:newSketchbookName];
    
    [[NSUserDefaults standardUserDefaults] setObject:savedSketchbookNamesArray forKey:self.savedSketchbookNamesArrayKey];
    [[NSUserDefaults standardUserDefaults] setObject:savedSketchbooksDictionary forKey:self.savedSketchbooksDictionaryKey];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
