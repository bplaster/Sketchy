//
//  GalleryViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/5/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "GalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GalleryViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *galleryView;
@property (strong, nonatomic) NSURL *sketchURL;

@end

@implementation GalleryViewController

-(id)initWithSketchURL: (NSURL *) url {
    self = [super init];
    if (self) {
        self.sketchURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:self.sketchURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation *rep = [asset defaultRepresentation];
         CGImageRef imageRef = [rep fullResolutionImage];
         if (imageRef) {
             [self.galleryView setImage: [UIImage imageWithCGImage:imageRef]];
         }
     } failureBlock:^(NSError *error)
     {
         NSLog(@"%@",[error localizedDescription]);
     }];
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
