//
//  UIAlertController+CYWindow.h
//  CYAlertController
//
//  Created by chenyn on 17/1/23.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 for iOS 8.0 or later  .
 */
@protocol CYAlertControllerDelegate <NSObject>

@optional

- (void)willPresentAlertController:(UIAlertController *)alertController;  // before animation and showing view
- (void)didPresentAlertController:(UIAlertController *)alertController;  // after animation

- (void)willDismissAlertController:(UIAlertController *)alertController;
- (void)didDismissAlertController:(UIAlertController *)alertController;  // after animation

@end

@interface UIAlertController (CYWindow)

- (NSUInteger)cy_addButtonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (NSUInteger)cy_addCancelButtonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (NSUInteger)cy_addDestructiveButtonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler;

@end

/* 用UIAlertController实现类AlertView的API使用 */
@interface UIAlertController (CYAlertView)

@property(nullable, nonatomic, weak) id <CYAlertControllerDelegate> delegate;

// adds a button with the title. returns the index (0 based) of where it was added. buttons are displayed in the order added except for the
// cancel button which will be positioned based on HI requirements. buttons cannot be customized.
- (NSInteger)addButtonWithTitle:(nullable NSString *)title;    // returns index of button. 0 based.
- (nullable NSString *)buttonTitleAtIndex:(NSUInteger)buttonIndex;
@property(nonatomic,readonly) NSInteger numberOfButtons;
@property(nonatomic) NSInteger cancelButtonIndex;      // if the delegate does not implement -alertViewCancel:, we pretend this button was clicked on. default is -1

@property(nonatomic,readonly,getter=isVisible) BOOL visible;

// shows popup alert animated.
- (void)show;

// hides alert sheet or popup. use this method when you need to explicitly dismiss the alert.
// it does not need to be called if the user presses on a button
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

// Retrieve a text field at an index
// The field at index 0 will be the first text field (the single field or the login field), the field at index 1 will be the password field. */
- (nullable UITextField *)textFieldAtIndex:(NSUInteger)textFieldIndex;

NS_ASSUME_NONNULL_END
@end
