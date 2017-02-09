//
//  ViewController.m
//  CYAlertController
//
//  Created by chenyn on 17/1/23.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import "ViewController.h"
#import "UIAlertController+CYWindow.h"

@interface ViewController () <CYAlertControllerDelegate, UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Test" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
//    
//    [alertView show];
//    
//    
//    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
//    
//    view1.backgroundColor = [UIColor grayColor];
//    
//    [self.view addSubview:view1];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Test" preferredStyle:UIAlertControllerStyleAlert];
    alertC.delegate = self;
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"-------> 成功调用了取消block ");
    }]];
    
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"-------> 成功调用了确定block");
    }];
    
    [alertC addAction:submitAction];
    
    NSInteger btnIndex = [alertC addButtonWithTitle:@"随便加一个"];
    
    alertC.preferredAction = submitAction;
    
    [alertC show];
    
    NSLog(@"第二个按钮的标题：%@", [alertC buttonTitleAtIndex:1]);
    NSLog(@"取消按钮的位置：%ld", alertC.cancelButtonIndex);
    NSLog(@"随便加一个的位置：%ld", btnIndex);
    NSLog(@"按钮数量：%ld", alertC.numberOfButtons);
    
    NSLog(@"第二个输入框：%@", [alertC textFieldAtIndex:1]);
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [alertC dismissWithClickedButtonIndex:0 animated:YES];
//    });
}

#pragma mark - CYAlertControllerDelegate
- (void)willPresentAlertController:(nonnull UIAlertController *)alertController  // before animation and showing view
{
    NSLog(@"AlertController将要显示 是否显示：%d", alertController.visible);
}
- (void)didPresentAlertController:(nonnull UIAlertController *)alertController  // after animation
{
    NSLog(@"AlertController已经显示 是否显示：%d", alertController.visible);
}

- (void)willDismissAlertController:(nonnull UIAlertController *)alertController
{
    NSLog(@"AlertController将要消失 是否显示：%d", alertController.visible);
}
- (void)didDismissAlertController:(nonnull UIAlertController *)alertController  // after animation
{
    NSLog(@"AlertController已经消失 是否显示：%d", alertController.visible);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
