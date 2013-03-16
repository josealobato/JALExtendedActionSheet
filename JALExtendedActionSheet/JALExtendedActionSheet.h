//
//  JALExtendedActionSheet.h
//
//  Created by Jose Lobato on 3/15/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALExtendedActionSheet : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *actions;
- (void)showInView:(UIView*)hostview;

@end
