//
//  LKAlert.m
//  linkeye
//
//  Created by haohao on 2018/4/19.
//  Copyright © 2018年 haohao. All rights reserved.
//

#import "LKAlert.h"

#define ADIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define singleTag 999

typedef void (^confirm)();
typedef void (^cancel)();

@interface LKAlert() <UIAlertViewDelegate>

@property (nonatomic, copy) confirm confirmParam;
@property (nonatomic, copy) cancel cancelParam;

@end

@implementation LKAlert

+ (instancetype)shareAlertTool{
    static LKAlert *shareAlertTool = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareAlertTool = [[self alloc] init];
    });
    return shareAlertTool;
}

// 重写该方法，保证该对象不会被释放，如果被释放，iOS8以下的UIAlertView的回调时候会崩溃
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    static LKAlert *_shareAlertView = nil;
    dispatch_once(&onceToken, ^{
        if (_shareAlertView == nil) {
            _shareAlertView = [super allocWithZone:zone];
        }
    });
    return _shareAlertView;
}

- (void)showAlertViewWithVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message confirmAction:(void (^)())confirm {
    [self showAlertViewWithVC:vc title:title message:message cancel:nil other:@"确认" cancleAction:^{} confirmAction:confirm];
}

- (void)showAlertViewWithVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message cancleAction:(void (^)())cancel confirmAction:(void (^)())confirm {
    [self showAlertViewWithVC:vc title:title message:message cancel:@"取消" other:@"确认" cancleAction:cancel confirmAction:confirm];
}

- (void)showAlertViewWithVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelTitle other:(NSString *)otherTitle cancleAction:(void (^)())cancel confirmAction:(void (^)())confirm {
    self.confirmParam = confirm;
    self.cancelParam = cancel;
    if (ADIOS8) { // iOS8以上(包括iOS8)
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the actions.
        if (cancelTitle && self.cancelParam) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.cancelParam();
            }];
            // Add the actions.
            [alertController addAction:cancelAction];
        }
        if (otherTitle && self.confirmParam) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.confirmParam();
            }];
            // Add the actions.
            [alertController addAction:otherAction];
        }
        if (vc) {
            [vc presentViewController:alertController animated:YES completion:nil];
        }
    } else { // iOS8以下
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
        [alertView show];
    }
}

-(void)showAlertViewWithVC:(UIViewController*)vc message:(NSString*)message confirmAction:(void(^)())confirm{
    [self showAlertViewWithVC:vc title:@"提示" message:message cancel:@"取消" other:@"确认" cancleAction:^{} confirmAction:confirm];
}


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelTitle other:(NSString *)otherTitle cancleAction:(void (^)())cancel confirmAction:(void (^)())confirm{
    self.confirmParam = confirm;
    self.cancelParam = cancel;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
    [alertView show];
    
}

//普通的1个按钮的 Alert 弹窗
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle confirmAction:(void (^)())confirm{
    self.confirmParam = confirm;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:btnTitle, nil];
    alertView.tag = singleTag;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
#pragma mark

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == singleTag) {
        if (buttonIndex == 0) {
            if (self.confirmParam) self.confirmParam();
        }
    }else{
        if (buttonIndex == 0) {
            if (self.cancelParam) self.cancelParam();
        } else {
            if (self.confirmParam)  self.confirmParam();
        }
    }
}
@end
