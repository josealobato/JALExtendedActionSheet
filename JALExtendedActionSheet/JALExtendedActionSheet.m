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
@property (nonatomic, strong) UIView *hostV;
@property (nonatomic, weak) UIView* sheetV;
@property (nonatomic, strong) NSLayoutConstraint *sheetVerticalConstraint;
@end

@implementation JALExtendedActionSheet

static const CGFloat kApearanceAnimationDuration = 0.4;
static const CGFloat kActionSheetHeight = 250.0;
static const CGFloat kBackgroundAlpha = 0.7;
static const CGFloat kButtonsHeight = 27.0;


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.alpha = 0.0;

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

	self.sheetVerticalConstraint = [NSLayoutConstraint constraintWithItem:sheet attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];

	[self.view addConstraint:self.sheetVerticalConstraint];


	// Message Label

	UILabel *msgLabel = [self messageLabel];
	[sheet addSubview:msgLabel];
	views = NSDictionaryOfVariableBindings(msgLabel);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[msgLabel]-20-|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	// Buttons container (Scroll)

	UIScrollView *buttonsContainer = [[UIScrollView alloc] init];
	buttonsContainer.layer.borderColor = [UIColor whiteColor].CGColor;
	buttonsContainer.layer.borderWidth = 1.0;
	[sheet addSubview:buttonsContainer];
	[buttonsContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
	views = NSDictionaryOfVariableBindings(buttonsContainer);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonsContainer]|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	// Pager under the Scroll

	UIPageControl *pageControl = [[UIPageControl alloc] init];
	pageControl.layer.borderColor = [UIColor whiteColor].CGColor;
	pageControl.layer.borderWidth = 1.0;
	[sheet addSubview:pageControl];
	[pageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
	views = NSDictionaryOfVariableBindings(pageControl);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[pageControl]|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	// Cancel Button

	UIButton *cancelButton = [self cancelButton];
	[sheet addSubview:cancelButton];
	views = NSDictionaryOfVariableBindings(cancelButton);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[cancelButton]-20-|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	// Vertical arrangement

	views = NSDictionaryOfVariableBindings(msgLabel, buttonsContainer, pageControl, cancelButton);
	NSString *constraintStr = [NSString stringWithFormat:@"V:|-5-[msgLabel(16)][buttonsContainer][pageControl(10)]-7-[cancelButton(%f)]-7-|", kButtonsHeight];
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintStr
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	[sheet layoutIfNeeded];
	self.sheetV = sheet;

}


- (void)viewDidAppear:(BOOL)animated
{
	[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
		[self.sheetVerticalConstraint setConstant:-kActionSheetHeight];
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


#pragma mark - basic Views customization

- (UIButton *)cancelButton
{
	UIButton *newCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newCancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	//	[newCancelButton setBackgroundColor:[UIColor redColor]];
	newCancelButton.layer.backgroundColor = [UIColor redColor].CGColor;
	newCancelButton.layer.cornerRadius = 5.0;
	[newCancelButton setTitle:NSLocalizedString(@"Cancel",@"CancelButton on action sheet") forState:UIControlStateNormal];

	return newCancelButton;
}

- (UILabel *)messageLabel
{
	UILabel *newLabel = [[UILabel alloc] init];
	[newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	newLabel.textColor = [UIColor whiteColor];
	//	newLabel.textAlignment = UITextAlignmentCenter;
	return newLabel;
}


@end
