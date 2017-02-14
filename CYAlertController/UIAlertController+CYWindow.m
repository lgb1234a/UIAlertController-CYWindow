//
//  UIAlertController+CYWindow.m
//  CYAlertController
//
//  Created by chenyn on 17/1/23.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import "UIAlertController+CYWindow.h"
#import <objc/runtime.h>

@interface UIAlertController (CYPrivate)

/**
 alertC依附的window
 */
@property (nonatomic, strong) UIWindow *CYAlertWindow;

@end

@implementation UIAlertController (CYPrivate)
@dynamic CYAlertWindow;
/**

 @return UIWindow
 */
- (UIWindow *)CYAlertWindow
{
    return objc_getAssociatedObject(self, @selector(CYAlertWindow));
}

- (void)setCYAlertWindow:(UIWindow *)CYAlertWindow
{
    objc_setAssociatedObject(self, @selector(CYAlertWindow), CYAlertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIAlertController (CYWindow)

- (void)setVisible:(BOOL)visible
{
    objc_setAssociatedObject(self, @selector(isVisible), [NSNumber numberWithBool:visible], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isVisible
{
    NSNumber *isVisible = objc_getAssociatedObject(self, @selector(isVisible));
    
    return isVisible.boolValue;
}

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.visible = NO;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.visible = NO;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertController:)])
    {
        [self.delegate willPresentAlertController:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.visible = YES;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didPresentAlertController:)])
    {
        [self.delegate didPresentAlertController:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(willDismissAlertController:)])
    {
        [self.delegate willDismissAlertController:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.visible = NO;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didDismissAlertController:)])
    {
        [self.delegate didDismissAlertController:self];
    }
    
    self.CYAlertWindow.hidden = YES;
    self.CYAlertWindow = nil;
}

- (NSUInteger)cy_addButtonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
    
    [self addAction:action];
    
    return self.actions.count - 1;
}

- (NSUInteger)cy_addCancelButtonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
    
    [self addAction:action];
    
    return self.actions.count - 1;
}

- (NSUInteger)cy_addDestructiveButtonWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];
    
    [self addAction:action];
    
    return self.actions.count - 1;
}

@end

@implementation UIAlertController (CYAlertView)

@dynamic delegate, numberOfButtons, cancelButtonIndex, visible;

- (id<CYAlertControllerDelegate>)delegate
{
    return objc_getAssociatedObject(self, @selector(delegate));
}

- (void)setDelegate:(id<CYAlertControllerDelegate>)delegate
{
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)show {
    [self show:YES];
}

- (void)show:(BOOL)animated {
    self.CYAlertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.CYAlertWindow.rootViewController = [[UIViewController alloc] init];
    self.CYAlertWindow.windowLevel = UIWindowLevelAlert + 1;
    [self.CYAlertWindow makeKeyAndVisible];
    [self.CYAlertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (NSInteger)addButtonWithTitle:(nullable NSString *)title
{
    [self addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:nil]];
    
    return self.actions.count - 1;
}

- (nullable NSString *)buttonTitleAtIndex:(NSUInteger)buttonIndex
{
    if(buttonIndex >= self.actions.count)
    {
        return nil;
    }
    UIAlertAction *action = [self.actions objectAtIndex:buttonIndex];
    
    return action.title;
}

- (NSInteger)numberOfButtons
{
    return self.actions.count;
}

- (NSInteger)cancelButtonIndex
{
    for (UIAlertAction *action in self.actions) {
        if(action.style == UIAlertActionStyleCancel)
        {
            return [self.actions indexOfObject:action];
        }
    }
    
    return -1;  // default is -1
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if(buttonIndex >= self.actions.count)
    {
        return;
    }
    
    if(self.CYAlertWindow)
    {
        UIAlertAction *action = [self.actions objectAtIndex:buttonIndex];
        
        void (^someBlock)(id obj) = [action valueForKey:@"handler"];
        
        if(someBlock)
        {
            someBlock(action);
        }
        
        [self dismiss];
    }
}

- (nullable UITextField *)textFieldAtIndex:(NSUInteger)textFieldIndex
{
    if(textFieldIndex >= self.textFields.count)
    {
        return nil;
    }
    return [self.textFields objectAtIndex:textFieldIndex];
}

- (void)dismiss
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated
{
    // dismiss
    [self dismissViewControllerAnimated:animated completion:nil];
}

@end
















