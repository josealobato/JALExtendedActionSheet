//
//  JALExtendedActionSheetVC.h
//  JALExtendedActionSheetDemo
//
//  Created by Jose Lobato on 3/18/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALExtendedActionSheetVC : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *actions;
- (void)showInView:(UIView*)hostview;

@end
