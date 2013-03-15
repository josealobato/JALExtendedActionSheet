//
//  DetailViewController.h
//  JALExtendedActionSheetDemo
//
//  Created by Jose Lobato on 3/15/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
