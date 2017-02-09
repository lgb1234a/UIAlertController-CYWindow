# UIAlertController-CYWindow

>Create UIAlertController do not need base on any UIViewController.

###业务需求
在iOS8.0之后，``UIAlertView``被官方弃用，取而代之的是以视图控制器的方式来显示和控制弹出框——``UIAlertController``。在某些程度上相比``UIAlertView``具有很多便利的地方，比如用``block``回调的形式取代``UIAlertView``的代理方法来监听事件响应。

**但是，它也有不方便的地方，下述代码新建一个alertView,之后再添加一个View。**

```
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Test" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
    
    [alertView show];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    
    view1.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:view1];
```

![Simulator Screen Shot 2017年2月8日 下午4.57.18.png](http://upload-images.jianshu.io/upload_images/1445324-1c967c9270a84516.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![QQ20170208-172931.png](http://upload-images.jianshu.io/upload_images/1445324-21190a3ddc931b02.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

从上面的**debug hierarchy**图，我们会发现，并没有看到``alertView``，这也就是为什么我们在``alertView``显示之后新建``view1``，但是``alertView``却覆盖在``view1``的上面。
**由此可见``alertView``并不在用户可操作的视图层级上面（对此，不做深入探究，有兴趣的可以自行探索）。**

而，``UIAlertController ``却是要依赖视图控制器来显示的，大多数情况我们只需要通过调用系统的``presentViewController:animated:completion:``去显示。

对于一般的应用场景，比如单个window下页面交互不复杂时，可以放心使用。如果遇到了多个window，而通过最底层window的响应事件来弹出全屏幕可见的``UIAlertController ``却有点麻烦。抑或是不同框架直接交互，例如``RN``与``Native``进行交互的场景，当在RN层拉起``UIAlertController ``时，会被``Native``的window所覆盖。（此处也不做过多讨论，只为引出此番重点）

###解决思路

**所以，我们需要实现的就是一个类似于``UIAlertView``的``alertController``。由于它需要依附于一个``UIViewController``对象。那我们大可以新建一个``windowLevel``最大的``window``，通过它去拉起我们要显示的``AlertController``。这样就能保证我们显示出来的``UIViewController``肯定是位于层级最高的位置。**

###解决方案

基于``UIAlertController``新建一个类目``UIAlertController+CYWindow``，实现了部分``alertView``的API以及新增了部分代理方法。


```
#import <UIKit/UIKit.h>

/**
 for iOS 8.0 or later  .
 */
@protocol CYAlertControllerDelegate <NSObject>

@optional

- (void)willPresentAlertController:(nonnull UIAlertController *)alertController;  // before animation and showing view
- (void)didPresentAlertController:(nonnull UIAlertController *)alertController;  // after animation

- (void)willDismissAlertController:(nonnull UIAlertController *)alertController;
- (void)didDismissAlertController:(nonnull UIAlertController *)alertController;  // after animation

@end

@interface UIAlertController (CYWindow)


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

@end
```

``UIAlertController+CYWindow.m``

```
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
```

###参考资料
<a href="https://github.com/agilityvision/FFGlobalAlertController"> FFGlobalAlertController gitHub</a>

<a href="http://stackoverflow.com/questions/36926827/how-can-you-test-the-contents-of-a-uialertaction-handler-with-ocmock"> How can you test the contents of a UIAlertAction handler?</a>