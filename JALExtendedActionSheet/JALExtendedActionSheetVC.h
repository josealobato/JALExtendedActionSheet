//
//  JALExtendedActionSheetVC.h
//  JALExtendedActionSheetDemo
//
//  Created by Jose Lobato on 3/18/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JALExtendedActionSheetVCDelegate;

@interface JALExtendedActionSheetVC : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, assign) id<JALExtendedActionSheetVCDelegate> delegate;
- (void)showInView:(UIView*)hostview;
- (void)setMainTitle:(NSString*)title;
- (void)setEventualMessage:(NSString *)message;
@end

@protocol JALExtendedActionSheetVCDelegate <NSObject>
- (void)actionSheet:(JALExtendedActionSheetVC*)actionSheet didSelectAction:(NSInteger)index;
- (void)actionSheetDidCancel:(JALExtendedActionSheetVC*)actionSheet;
@end
