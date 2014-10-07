//
//  SketchbookViewController.h
//  Sketchy
//
//  Created by Brandon Plaster on 10/7/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SketchViewController.h"

@protocol SketchbookViewControllerDelegate <NSObject>
- (void)storeSketchURL:(id)sender;
@end

@interface SketchbookViewController : UIViewController <UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<SketchbookViewControllerDelegate> delegate;

@property (strong, nonatomic) UIPageViewController *pageController;
@property (nonatomic, strong) NSMutableArray *sketchURLArray;
@property (nonatomic, strong) NSMutableArray *sketchNameArray;
@property (nonatomic, strong) NSString *sketchbookName;

@end
