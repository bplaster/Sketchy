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
@property (nonatomic, strong) NSMutableArray *sketchURL;
@property (strong, nonatomic) UIImageView *tempLayer;
@property (assign, nonatomic) BOOL isErasing;
@property (assign, nonatomic) BOOL savedSinceLastEdit;
@property (strong, nonatomic) UIImageView *drawLayer;


- (UIImage *) getImage;
- (void)setRed:(CGFloat)r andGreen:(CGFloat)g andBlue:(CGFloat)b andOpacity:(CGFloat)o andDiameter:(CGFloat)d;

@end
