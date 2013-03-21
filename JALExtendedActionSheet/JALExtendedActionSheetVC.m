//  JALExtendedActionSheetVC.m
//
//  Created by Jose Lobato on 3/18/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.

#import "JALExtendedActionSheetVC.h"
#import <QuartzCore/QuartzCore.h>

@interface JALExtendedActionSheetVC ()
@property (nonatomic, strong) UIViewController *rootController;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) UIView *actionSheet;
@property (nonatomic, strong) NSLayoutConstraint *sheetVerticalConstraint;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIPageControl *pagerCotrol;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSLayoutConstraint *cancleButtonHeightConstraint;

@property (nonatomic, strong) NSMutableArray *scrollViewPages;
@property (nonatomic, strong) NSString *sheetTitle;
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


	// if the device is an iPad we do not use the backgground view but the sheet itself as view.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.view = self.actionSheet;
	}

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

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		// TODO: Shall this go in the viewDidAppear?.
		[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
			[self.sheetVerticalConstraint setConstant:0];
			[self.actionSheet layoutIfNeeded];
			self.view.alpha = kBackgroundAlpha;

		} completion:NULL];
	}
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

}

- (void)setMainTitle:(NSString*)title
{
	if (self.messageLabel) {
		self.messageLabel.text = title;
		self.sheetTitle = title;
	}
}

- (void)setEventualMessage:(NSString *)message
{
	[UIView animateWithDuration:0.2
					 animations:^{self.messageLabel.alpha = 0.0;}
					 completion:^(BOOL finished){
						 if(finished){
							 [UIView animateWithDuration:0.4 animations:^{
								 self.messageLabel.text = message;
								 self.messageLabel.alpha = 1.0;
							 } completion:^(BOOL finished){
								 [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
							 }];
						 }
					 }];
}

- (void)onTimer:(id)sender
{
	[UIView animateWithDuration:0.2
					 animations:^{self.messageLabel.alpha = 0.0;}
					 completion:^(BOOL finished){
						 if(finished){
							 [UIView animateWithDuration:0.4 animations:^{
								 self.messageLabel.text = self.sheetTitle;
								 self.messageLabel.alpha = 1.0;
							 } completion:NULL];
						 }
					 }];
}

#pragma mark - Dimensions

static const CGFloat kJEACSheetHeightPortrait = 320.0;
static const CGFloat kJEACSheetHeightLandscape = 200.0;
- (CGFloat)sheetHeight
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
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
	else 
    {
		return kJEACSheetHeightPortrait;
    }
}

static const CGFloat kJEACButtonHeightPortrait = 40.0;
static const CGFloat kJEACButtonHeightLandscape = 30.0;
- (CGFloat)buttonHeight
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
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
	else
    {
		return kJEACButtonHeightPortrait;
    }
}


#pragma mark - Manage Rotation.

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
 	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[self dismissExtendedActionSheet];
	}
	else {
		[self adjustSheetConstraints];
		[self adjustCancelButtonConstraints];
		[self.actionSheet layoutIfNeeded];
		[self AddButtonsToTheScrollView];
		[self.scrollView layoutIfNeeded];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}


#pragma mark - Showing Up

- (void)showInView:(UIView*)hostview
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
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
	}
	else {
		self.popOverController =  [[UIPopoverController alloc] initWithContentViewController:self];
		self.rootController = hostview.window.rootViewController;
		[self.popOverController presentPopoverFromRect:hostview.frame
												inView:[hostview superview]
							  permittedArrowDirections:UIPopoverArrowDirectionAny
											  animated:YES];
		self.popOverController.delegate = self;
	}
}


#pragma mark - Creation of subviews

- (UIView *)addActionSheet
{
	UIView *sheet = [[UIView alloc] init];
	[sheet setTranslatesAutoresizingMaskIntoConstraints:NO];
	sheet.backgroundColor = [UIColor blackColor];
	// If ipad the acctionsheet it the view.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[self.view addSubview:sheet];
	}
	self.actionSheet = sheet;
	[self adjustSheetConstraints];
	[self.sheetVerticalConstraint setConstant:[self sheetHeight]-10];
	return sheet;
}

- (void)adjustSheetConstraints
{
	[self.view removeConstraints:[self.view constraints]];

	NSArray *constraints;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

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
	else{

		constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[sheet(320)]"
															  options:0
															  metrics:nil
																views:@{@"sheet":self.actionSheet}];
		[self.actionSheet addConstraints:constraints];
		
		constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[sheet(320)]"]
															  options:0
															  metrics:nil
																views:@{@"sheet":self.actionSheet}];
		[self.actionSheet addConstraints:constraints];
		self.contentSizeForViewInPopover = CGSizeMake(320, 340);

	}
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
	return newScrollView;	
}

- (UIButton *)newRegularButtonWithTitle:(NSString *)title;
{
	UIButton *newRegularButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newRegularButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	newRegularButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
	newRegularButton.layer.cornerRadius = 5.0;
	[newRegularButton setTitle:title forState:UIControlStateNormal];
	[newRegularButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

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

	if(numberOfPages == 0 || buttonsPerPage == 0) {

		self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,
												 self.scrollView.bounds.size.height);

		UILabel *label = [[UILabel alloc] init];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		[label setTranslatesAutoresizingMaskIntoConstraints:NO];
		label.text = NSLocalizedString(@"No Actions available.", @"No actions available on display message");
		[self.scrollView addSubview:label];

		NSArray *constraints;
		constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[label(%f)]|",self.scrollView.bounds.size.width]
																	   options:0
																	   metrics:nil
																		 views:@{@"label":label}];
		[self.scrollView addConstraints:constraints];
		constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[label]"
																	   options:0
																	   metrics:nil
																		 views:@{@"label":label}];
		[self.scrollView addConstraints:constraints];
		[self.scrollView layoutIfNeeded];
		return;
	}


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
	[self dismissExtendedActionSheet];
}

- (void)dismissExtendedActionSheet
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheetDidCancel:)]) {
		[self.delegate actionSheetDidCancel:self];
	}

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
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
	else {
		[self.popOverController dismissPopoverAnimated:YES];
	}

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

#pragma mark - UIPopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self dismissExtendedActionSheet];
}

@end
