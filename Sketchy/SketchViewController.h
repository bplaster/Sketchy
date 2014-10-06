//
//  SketchViewController.h
//  Sketchy
//
//  Created by Brandon Plaster on 10/4/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SketchViewControllerDelegate <NSObject>
- (void)storeSketchURL:(id)sender;
@end

@interface SketchViewController : UIViewController

@property (nonatomic, weak) id<SketchViewControllerDelegate> delegate;
@property (strong, nonatomic) NSURL *sketchURL;


@end
