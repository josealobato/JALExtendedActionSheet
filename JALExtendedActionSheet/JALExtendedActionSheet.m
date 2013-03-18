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
@property (nonatomic, strong) UIViewController *rootController;
@property (nonatomic, strong) UIView *hostV;
@property (nonatomic, weak) UIView* sheetV;
@property (nonatomic, strong) NSLayoutConstraint *sheetVerticalConstraint;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *scrollViewPages;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *buttons;
@end

@implementation JALExtendedActionSheet

static const CGFloat kApearanceAnimationDuration = 0.4;
static const CGFloat kBackgroundAlpha = 0.7;

static const CGFloat kJEACGeneralMargin = 5.0;
static const CGFloat kJEACInterButtonsSpace = 14.0;
static const CGFloat kJEACButtonsHeight = 38.0;

static const CGFloat kJEACMessageHeight = 20.0;
static const CGFloat kJEACPagerHeight = 20.0;
static const CGFloat kJEACWidth = 320.0;
static const CGFloat kJEACHeight = 320.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.alpha = 0.0;

	self.scrollViewPages = [NSMutableArray array];

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

	constraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[sheet(%f)]", kJEACHeight]
														  options:0
														  metrics:nil
															views:views];
	[self.view addConstraints:constraints];

	self.sheetVerticalConstraint = [NSLayoutConstraint constraintWithItem:sheet
																attribute:NSLayoutAttributeTop
																relatedBy:NSLayoutRelationEqual
																   toItem:self.view
																attribute:NSLayoutAttributeBottom
															   multiplier:1.0
																 constant:0];

	[self.view addConstraint:self.sheetVerticalConstraint];


	// Message Label

	UILabel *msgLabel = [self newMessageLabel];
	[sheet addSubview:msgLabel];
	views = NSDictionaryOfVariableBindings(msgLabel);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[msgLabel]-20-|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];
	self.label = msgLabel;

	// Buttons container (Scroll)

	UIScrollView *buttonsContainer = [self newButtonsContainer];
	[sheet addSubview:buttonsContainer];
	views = NSDictionaryOfVariableBindings(buttonsContainer);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[buttonsContainer]|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];
	self.scrollView = buttonsContainer;


	// Pager under the Scroll

	UIPageControl *pager = [self newPageControl];
	[sheet addSubview:pager];
	views = NSDictionaryOfVariableBindings(pager);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[pager]|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];
	self.pageControl = pager;


	// Cancel Button

	UIButton *cancelButton = [self newCancelButton];
	[sheet addSubview:cancelButton];
	views = NSDictionaryOfVariableBindings(cancelButton);
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[cancelButton]-20-|"
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	// Vertical arrangement

	views = NSDictionaryOfVariableBindings(msgLabel, buttonsContainer, pager, cancelButton);
	NSString *constraintStr = [NSString stringWithFormat:@"V:|-5-[msgLabel(%f)][buttonsContainer][pager(%f)]-7-[cancelButton(%f)]-7-|",kJEACMessageHeight, kJEACPagerHeight, kJEACButtonsHeight];
	constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintStr
														  options:0
														  metrics:nil
															views:views];
	[sheet addConstraints:constraints];


	// NOTE: note that before build the buttons view we need the size of the scroll so layout first.
	[sheet layoutIfNeeded];
	[self buildButtonViews];
	[sheet layoutIfNeeded];
	self.sheetV = sheet;

	// TODO: Shall this go in the viewDidAppear?.
	[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
		[self.sheetVerticalConstraint setConstant:-kJEACHeight];
		[self.view layoutIfNeeded];
		self.view.alpha = kBackgroundAlpha;
	} completion:NULL];

}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

	constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selfview]|"
														  options:0
														  metrics:nil
															views:views];
	[self.rootController.view addConstraints:constraints];
}

#pragma mark - Button Views

- (void)buildButtonViews
{
	NSInteger numberOfPages = ceil(((kJEACButtonsHeight + kJEACInterButtonsSpace)*[self.actions count])/self.scrollView.bounds.size.height);
	NSInteger buttonsPerPage = floor(self.scrollView.bounds.size.height/(kJEACButtonsHeight + kJEACInterButtonsSpace));

	self.pageControl.numberOfPages = numberOfPages;
	self.pageControl.currentPage = 0;

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
			[constraintVisualFormat appendFormat:@"[%@(%f)]-(>=%f)-",buttonID,kJEACButtonsHeight,kJEACInterButtonsSpace];
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

#pragma mark - basic Views customization

- (UIButton *)newCancelButton
{
	UIButton *newCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newCancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	//	[newCancelButton setBackgroundColor:[UIColor redColor]];
	newCancelButton.layer.backgroundColor = [UIColor redColor].CGColor;
	newCancelButton.layer.cornerRadius = 5.0;
	[newCancelButton setTitle:NSLocalizedString(@"Cancel",@"CancelButton on action sheet") forState:UIControlStateNormal];

	[newCancelButton addTarget:self
						action:@selector(onCancelButton:)
			  forControlEvents:UIControlEventTouchUpInside];

	return newCancelButton;
}

- (UIButton *)newRegularButtonWithTitle:(NSString *)title;
{
	UIButton *newRegularButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[newRegularButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	newRegularButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
	newRegularButton.layer.cornerRadius = 5.0;
	[newRegularButton setTitle:title forState:UIControlStateNormal];

	return newRegularButton;
}

- (UILabel *)newMessageLabel
{
	UILabel *newLabel = [[UILabel alloc] init];
	[newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
	newLabel.textColor = [UIColor whiteColor];
	// TODO: Set alignement fo the text to center.
	return newLabel;
}

- (UIScrollView *)newButtonsContainer
{
	UIScrollView *newButtonsContainer = [[UIScrollView alloc] init];
	[newButtonsContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
	newButtonsContainer.pagingEnabled = YES;
	newButtonsContainer.showsHorizontalScrollIndicator = NO;
	newButtonsContainer.showsVerticalScrollIndicator = NO;
	newButtonsContainer.scrollsToTop = NO;
	newButtonsContainer.bounces = NO;
	newButtonsContainer.delegate = self;

	// TODO: Remove. Only Debug
	newButtonsContainer.layer.borderColor = [UIColor whiteColor].CGColor;
	newButtonsContainer.layer.borderWidth = 1.0;

	return newButtonsContainer;
}

- (UIPageControl *)newPageControl
{
	UIPageControl *newPageControl = [[UIPageControl alloc] init];
	[newPageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
	[newPageControl addTarget:self
					   action:@selector(pageControlDidChangeValue:)
			 forControlEvents:UIControlEventValueChanged];

	// TODO: Remove. Only Debug
	newPageControl.layer.borderColor = [UIColor whiteColor].CGColor;
	newPageControl.layer.borderWidth = 1.0;

	return newPageControl;
}

#pragma mark - PageControl delegate

-(void)pageControlDidChangeValue:(UIPageControl *)pageControl
{
	if([pageControl currentPage]>=[self.scrollViewPages count])
		return;
	UIView *viewToShow = [self.scrollViewPages objectAtIndex:[pageControl currentPage]];
	[self.scrollView scrollRectToVisible:viewToShow.frame animated:YES];
}
#pragma mark - ScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//
//}
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//
//}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//
//}
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//
//}
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//
//}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger page = floor((self.scrollView.contentOffset.x - kJEACWidth / 2) / kJEACWidth) + 1;
    self.pageControl.currentPage = page;
}
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//
//}
////- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
////{
////
////}
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//{
//
//}
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//
//}
//- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
//{
//	return YES;
//}
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
//{
//
//}

#pragma mark - Buttons events

- (void)onCancelButton:(UIButton*)button
{
	// TODO: Investigate why this animation does not work.
	[[self.view.subviews lastObject] layoutIfNeeded];
	[UIView animateWithDuration:kApearanceAnimationDuration animations:^{
		[self.sheetVerticalConstraint setConstant:0.0];
		[self.view layoutIfNeeded];
		self.view.alpha = 0.0;
	} completion:^(BOOL finished){
		if (finished) {
			[self willMoveToParentViewController:nil];
			[self.view removeFromSuperview];
			[self removeFromParentViewController];
		}
	}];
	[self.view layoutIfNeeded];
}

@end
