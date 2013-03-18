//  JALExtendedActionSheetVC.m
//
//  Created by Jose Lobato on 3/18/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.

#import "JALExtendedActionSheetVC.h"
#import <QuartzCore/QuartzCore.h>

@interface JALExtendedActionSheetVC ()
@property (nonatomic, strong) UIViewController *rootController;

@property (nonatomic, strong) UIView *actionSheet;
@property (nonatomic, strong) NSLayoutConstraint *sheetVerticalConstraint;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIPageControl *pagerCotrol;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSLayoutConstraint *cancleButtonHeightConstraint;

@property (nonatomic, strong) NSMutableArray *scrollViewPages;
@end


@implementation JALExtendedActionSheetVC
static const CGFloat kApearanceAnimationDuration = 0.4;
static const CGFloat kBackgroundAlpha = 0.7;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.alpha = 0.4;

	self.scrollViewPages = [NSMutableArray array];

	[self addActionSheet];
	[self addMessageLabel];
	[self addPagerControl];
	[self addScrollView];
	[self addCancelButton];


	// Vertical arrangement
	NSString *constraintStr = [NSString stringWithFormat:@"V:|-(7)-[msg(22)]-(7)-[scroll][pager(22)]-7-[CancelBtn]-(7)-|"];
	NSDictionary *views = @{@"msg":self.messageLabel,@"scroll":self.scrollView,@"pager":self.pagerCotrol,@"CancelBtn":self.cancelButton};
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintStr
																   options:0
																   metrics:nil
																	 views:views];
	[self.actionSheet addConstraints:constraints];

	[self.actionSheet layoutIfNeeded];
	[self AddButtonsToTheScrollView];
	[self.actionSheet layoutIfNeeded];

	// TODO: Shall this go in the viewDidAppear?.
	[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
		[self.sheetVerticalConstraint setConstant:0];
		[self.actionSheet layoutIfNeeded];
		self.view.alpha = kBackgroundAlpha;

	} completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
	// TODO: Not being called??
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMessage:(NSString *)message
{
	if (self.messageLabel) {
		self.messageLabel.text = message;
	}
}

#pragma mark - Dimensions

static const CGFloat kJEACSheetHeightPortrait = 320.0;
static const CGFloat kJEACSheetHeightLandscape = 200.0;
- (CGFloat)sheetHeight
{
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
		return kJEACSheetHeightLandscape;
    }
    else //(UIDeviceOrientationIsPortrait(deviceOrientation))
    {
		return kJEACSheetHeightPortrait;
    }
}

static const CGFloat kJEACButtonHeightPortrait = 40.0;
static const CGFloat kJEACButtonHeightLandscape = 30.0;
- (CGFloat)buttonHeight
{
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
		return kJEACButtonHeightLandscape;
    }
    else //(UIDeviceOrientationIsPortrait(deviceOrientation))
    {
		return kJEACButtonHeightPortrait;
    }
}


#pragma mark - Manage Rotation.

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"RotationEvenv1");	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"RotationEvenv2");
	[self adjustSheetConstraints];
	[self adjustCancelButtonConstraints];
	[self.actionSheet layoutIfNeeded];
	[self AddButtonsToTheScrollView];
	[self.scrollView layoutIfNeeded];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"RotationEvenv3");
}


#pragma mark - Showing Up

- (void)showInView:(UIView*)hostview
{
	self.rootController = hostview.window.rootViewController;

	[self.rootController addChildViewController:self];
	[self.rootController.view addSubview:self.view];
	[self didMoveToParentViewController:self.rootController];

	UIView *selfview = self.view;
	NSDictionary *views = NSDictionaryOfVariableBindings(selfview);
	NSArray *constraints;
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[selfview]|"
														  options:0
														  metrics:nil
															views:views];
	[self.rootController.view addConstraints:constraints];

	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[selfview]|"
														  options:0
														  metrics:nil
															views:views];
	[self.rootController.view addConstraints:constraints];

	// TODO: Remove only debug.
//	self.view.layer.borderWidth = 1.0;
//	self.view.layer.borderColor = [UIColor greenColor].CGColor;
}


#pragma mark - Creation of subviews

- (UIView *)addActionSheet
{
	UIView *sheet = [[UIView alloc] init];
	[sheet setTranslatesAutoresizingMaskIntoConstraints:NO];
	sheet.backgroundColor = [UIColor blackColor];
	[self.view addSubview:sheet];
	self.actionSheet = sheet;
	[self adjustSheetConstraints];
	[self.sheetVerticalConstraint setConstant:[self sheetHeight]-10];

	// TODO: Remove only debug.
//	self.actionSheet.layer.borderWidth = 1.0;
//	self.actionSheet.layer.borderColor = [UIColor redColor].CGColor;
	return sheet;
}

- (void)adjustSheetConstraints
{
	[self.view removeConstraints:[self.view constraints]];	
	NSArray *constraints;
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[sheet]|"
														  options:0
														  metrics:nil
															views:@{@"sheet":self.actionSheet}];
	[self.view addConstraints:constraints];

	constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[sheet(%f)]", [self sheetHeight]]
														  options:0
														  metrics:nil
															views:@{@"sheet":self.actionSheet}];
	[self.view addConstraints:constraints];

	self.sheetVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.actionSheet
																attribute:NSLayoutAttributeBottom
																relatedBy:NSLayoutRelationEqual
																   toItem:self.view
																attribute:NSLayoutAttributeBottom
															   multiplier:1.0
																 constant:0];
	[self.view addConstraint:self.sheetVerticalConstraint];
}

- (UIButton *)addCancelButton
{
	UIButton *newCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newCancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.cancelButton = newCancelButton;
	newCancelButton.layer.backgroundColor = [UIColor redColor].CGColor;
	newCancelButton.layer.cornerRadius = 5.0;
	[newCancelButton setTitle:NSLocalizedString(@"Cancel",@"CancelButton on action sheet") forState:UIControlStateNormal];

	[newCancelButton addTarget:self
						action:@selector(onCancelButton:)
			  forControlEvents:UIControlEventTouchUpInside];

	[self.actionSheet addSubview:newCancelButton];
	NSArray *constraints = nil;
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[cancelButton]-20-|"
														  options:0
														  metrics:nil
															views:@{@"cancelButton":newCancelButton}];
	[self.actionSheet addConstraints:constraints];

	[self adjustCancelButtonConstraints];
	
	return newCancelButton;
}

- (void)adjustCancelButtonConstraints
{
	if (self.cancleButtonHeightConstraint) {
		[self.actionSheet removeConstraint:self.cancleButtonHeightConstraint];
		self.cancleButtonHeightConstraint = nil;
	}
	NSArray *constraints = nil;
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[cancelButton(%f)]",[self buttonHeight]]
														  options:0
														  metrics:nil
															views:@{@"cancelButton":self.cancelButton}];
	if([constraints count]>1)
		NSAssert(NO, @"More than one condition for height");
	self.cancleButtonHeightConstraint = [constraints lastObject];
	[self.actionSheet addConstraints:constraints];
}

- (UILabel *)addMessageLabel
{
	UILabel *newLabel = [[UILabel alloc] init];
	[newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.messageLabel = newLabel;
	newLabel.textColor = [UIColor whiteColor];
	newLabel.backgroundColor = [UIColor clearColor];
	newLabel.textAlignment = NSTextAlignmentCenter;
	[self.actionSheet addSubview:newLabel];
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[msg]-20-|"
														  options:0
														  metrics:nil
															views:@{@"msg":newLabel}];
	[self.actionSheet addConstraints:constraints];

	// TODO: Remove only debug.
//	newLabel.textColor = [UIColor whiteColor];

	return newLabel;
}

- (UIPageControl*)addPagerControl
{
	UIPageControl *newPageControl = [[UIPageControl alloc] init];
	[newPageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.pagerCotrol = newPageControl;
	[self.actionSheet addSubview:newPageControl];
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[pager]|"
																   options:0
																   metrics:nil
																	 views:@{@"pager":newPageControl}];
	[self.actionSheet addConstraints:constraints];
	
	[newPageControl addTarget:self
					   action:@selector(pageControlDidChangeValue:)
			 forControlEvents:UIControlEventValueChanged];

	// TODO: Remove. Only Debug
//	newPageControl.layer.borderColor = [UIColor whiteColor].CGColor;
//	newPageControl.layer.borderWidth = 1.0;

	return newPageControl;
}

- (UIScrollView *)addScrollView
{
	UIScrollView *newScrollView = [[UIScrollView alloc] init];
	[newScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.scrollView = newScrollView;
	[self.actionSheet addSubview:newScrollView];
	newScrollView.pagingEnabled = YES;
	newScrollView.showsHorizontalScrollIndicator = NO;
	newScrollView.showsVerticalScrollIndicator = NO;
	newScrollView.scrollsToTop = NO;
	newScrollView.bounces = NO;
	newScrollView.delegate = self;

	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollV]|"
																   options:0
																   metrics:nil
																	 views:@{@"scrollV":newScrollView}];
	[self.actionSheet addConstraints:constraints];

	// TODO: Remove. Only Debug
//	newScrollView.layer.borderColor = [UIColor whiteColor].CGColor;
//	newScrollView.layer.borderWidth = 1.0;

	return newScrollView;	
}

- (UIButton *)newRegularButtonWithTitle:(NSString *)title;
{
	UIButton *newRegularButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newRegularButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	newRegularButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
	newRegularButton.layer.cornerRadius = 5.0;
	[newRegularButton setTitle:title forState:UIControlStateNormal];

	[newRegularButton addTarget:self
						 action:@selector(onRegularButton:)
			   forControlEvents:UIControlEventTouchUpInside];

	return newRegularButton;
}

#pragma mark - Content of the scroll view
static const CGFloat kJEACInterButtonsSpace = 10.0;


- (void)AddButtonsToTheScrollView
{
	for (UIView *sview in self.scrollView.subviews) {
		[sview removeFromSuperview];
	}
	[self.scrollViewPages removeAllObjects];
	[self.scrollView layoutIfNeeded];


	NSInteger numberOfPages = ceil((([self buttonHeight] + kJEACInterButtonsSpace)*[self.actions count])/self.scrollView.bounds.size.height);
	NSInteger buttonsPerPage = floor(self.scrollView.bounds.size.height/([self buttonHeight] + kJEACInterButtonsSpace));

	self.pagerCotrol.numberOfPages = numberOfPages;
	self.pagerCotrol.currentPage = 0;

	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * numberOfPages,
											 self.scrollView.bounds.size.height);

	UIView *currentSubView = nil;
	UIButton *currentButton = nil;
	NSInteger titleIDX = 0;
	for (NSInteger idx=0; idx<numberOfPages; idx++) {

		currentSubView = [[UIView alloc] init];
		[currentSubView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.scrollViewPages addObject:currentSubView];
		[self.scrollView addSubview:currentSubView];

		NSDictionary *views = NSDictionaryOfVariableBindings(currentSubView);
		NSArray *constraints;
		constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[currentSubView]|"
															  options:0
															  metrics:nil
																views:views];
		[self.scrollView addConstraints:constraints];

		NSMutableArray *buttonsInACurrentPage = [NSMutableArray array];
		for (NSInteger jdx = 0; jdx<buttonsPerPage; jdx++) {
			if (titleIDX>=[self.actions count])
				break;
			currentButton = [self newRegularButtonWithTitle:[self.actions objectAtIndex:titleIDX]];
			currentButton.tag = titleIDX;
			titleIDX++;
			[buttonsInACurrentPage addObject:currentButton];
			[currentSubView addSubview:currentButton];

			views = NSDictionaryOfVariableBindings(currentButton);
			constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[currentButton]-20-|"
																  options:0
																  metrics:nil
																	views:views];
			[currentSubView addConstraints:constraints];
		}

		NSMutableString *constraintVisualFormat = [NSMutableString stringWithFormat:@"V:|-(>=%f)-",kJEACInterButtonsSpace];
		NSMutableDictionary *viewsDictionary = [NSMutableDictionary dictionary];
		for (UIButton *button in buttonsInACurrentPage) {
			NSString *buttonID = [NSString stringWithFormat:@"button%d",[buttonsInACurrentPage indexOfObject:button]];
			[constraintVisualFormat appendFormat:@"[%@(%f)]-(>=%f)-",buttonID,[self buttonHeight],kJEACInterButtonsSpace];
			[viewsDictionary setObject:button forKey:buttonID];
		}
		[constraintVisualFormat appendFormat:@"|"];
		constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintVisualFormat
															  options:0
															  metrics:nil
																views:viewsDictionary];
		[currentSubView addConstraints:constraints];

		[currentSubView layoutIfNeeded];
	}

	NSMutableString *constraintVisualFormat = [NSMutableString stringWithFormat:@"H:|"];
	NSMutableDictionary *viewsDictionary = [NSMutableDictionary dictionary];
	NSString *viewID;
	for (UIView *subView in self.scrollViewPages) {
		viewID = [NSString stringWithFormat:@"ScrollerPage%d",[self.scrollViewPages indexOfObject:subView]];
		[constraintVisualFormat appendFormat:@"[%@(%f)]",viewID,self.scrollView.bounds.size.width];
		[viewsDictionary setObject:subView forKey:viewID];
	}
	[constraintVisualFormat appendFormat:@"|"];
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintVisualFormat
																   options:0
																   metrics:nil
																	 views:viewsDictionary];
	[self.scrollView addConstraints:constraints];

	[self.scrollView layoutIfNeeded];
}


#pragma mark - Buttons events

- (void)onCancelButton:(UIButton*)button
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheetDidCancel:)]) {
		[self.delegate actionSheetDidCancel:self];
	}
	
	// TODO: Investigate why this animation does not work.
	[self.view layoutIfNeeded];
	[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
		[self.sheetVerticalConstraint setConstant:[self sheetHeight]-10];
		[self.actionSheet layoutIfNeeded];
		self.view.alpha = 0.0;
	} completion:^(BOOL finished){
		if (finished) {
			[self willMoveToParentViewController:nil];
			[self.view removeFromSuperview];
			[self removeFromParentViewController];
		}
	}];
}

- (void)onRegularButton:(UIButton*)button
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:didSelectAction:)]) {
		[self.delegate actionSheet:self didSelectAction:button.tag];
	}
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat scrollWidth = self.scrollView.bounds.size.width;
    NSUInteger page = floor((self.scrollView.contentOffset.x - scrollWidth / 2) / scrollWidth) + 1;
    self.pagerCotrol.currentPage = page;
}

#pragma mark - PageControl delegate

-(void)pageControlDidChangeValue:(UIPageControl *)pageControl
{
	if([pageControl currentPage]>=[self.scrollViewPages count])
		return;
	UIView *viewToShow = [self.scrollViewPages objectAtIndex:[pageControl currentPage]];
	[self.scrollView scrollRectToVisible:viewToShow.frame animated:YES];
}

@end
