//
//  SketchViewController.h
//  Sketchy
//
//  Created by Brandon Plaster on 10/4/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SketchViewController : UIViewController
@property (strong, nonatomic) id dataObject;
@property (nonatomic, strong) NSMutableArray *sketchURLArray;
@property (nonatomic, strong) NSString *sketchbookName;
@property (strong, nonatomic) IBOutlet UIImageView *mainSketchView;


@end
