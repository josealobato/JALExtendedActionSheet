//
//  JALExtendedActionSheet.m
//  JALExtendedActionSheetDemo
//
//  Created by Jose Lobato on 3/15/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.
//

#import "JALExtendedActionSheet.h"
#import <QuartzCore/QuartzCore.h>



@interface JALExtendedActionSheet ()
@property (nonatomic,strong) UIView *hostV;
//@property (nonatomic, weak) UIView* sheetV;
@end

@implementation JALExtendedActionSheet

static const CGFloat kApearanceAnimationDuration = 0.3;
static const CGFloat kActionSheetHeight = 250.0;
static const CGFloat kBackgroundAlpha = 0.7;


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
	UIView *sheet = [[UIView alloc] init];
	[sheet setTranslatesAutoresizingMaskIntoConstraints:NO];
	sheet.backgroundColor = [UIColor blackColor];
	[self.view addSubview:sheet];
	NSDictionary *views = NSDictionaryOfVariableBindings(sheet);
	NSArray *constraints;
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[sheet]|"
														  options:0
														  metrics:nil
															views:views];
	[self.view addConstraints:constraints];

	constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[sheet(%f)]", kActionSheetHeight]
														  options:0
														  metrics:nil
															views:views];
	[self.view addConstraints:constraints];

	NSLayoutConstraint *vPositionConstraint = [NSLayoutConstraint constraintWithItem:sheet attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];

	[self.view addConstraint:vPositionConstraint];
	
	[self.view layoutIfNeeded];

	[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
		[vPositionConstraint setConstant:-kActionSheetHeight];
		[self.view layoutIfNeeded];
		self.view.alpha = kBackgroundAlpha;
	} completion:NULL];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInView:(UIView*)hostview
{
	self.hostV = hostview;
	[hostview.window addSubview:self.view];

	UIView *selfview = self.view;
	NSDictionary *views = NSDictionaryOfVariableBindings(selfview);
	NSArray *constraints;
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[selfview]|"
														  options:0
														  metrics:nil
															views:views];
	[hostview.window addConstraints:constraints];

	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selfview]|"
														  options:0
														  metrics:nil
															views:views];
	[hostview.window addConstraints:constraints];

}

@end
