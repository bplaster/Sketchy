//
//  SettingsViewController.h
//  Sketchy
//
//  Created by Brandon Plaster on 10/8/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate <NSObject>
- (void)closeSettings:(id)sender;
@end

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

- (void)setRed:(CGFloat)r andGreen:(CGFloat)g andBlue:(CGFloat)b andOpacity:(CGFloat)o andDiameter:(CGFloat)d andFrameRate:(CGFloat)f;


// Pen properties
@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat diameter;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) CGFloat frameRate;


@end
