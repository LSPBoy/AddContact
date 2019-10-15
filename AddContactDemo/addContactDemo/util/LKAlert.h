//
//  LKAlert.h
//  linkeye
//
//  Created by haohao on 2018/4/19.
//  Copyright © 2018年 haohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LKAlert : NSObject

+ (instancetype)shareAlertTool;
/**
 *  AlertView封装(只带确认按钮)
 *
 *  @param viewController    当前控制器
 *  @param title             标题
 *  @param message           提示信息
 *  @param confirm           点击确定事件
 */
- (void)showAlertViewWithVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message confirmAction:(void (^)())confirm;

/**
 *  AlertView封装(带取消和确认按钮)
 *
 *  @param viewController    当前控制器
 *  @param title             标题
 *  @param message           提示信息
 *  @param cancle            点击取消事件
 *  @param confirm           点击确定事件
 */
- (void)showAlertViewWithVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message cancleAction:(void (^)())cancel confirmAction:(void (^)())confirm;

/**
 *  AlertView封装(带两个按钮)
 *
 *  @param viewController    当前控制器
 *  @param title             标题
 *  @param message           提示信息
 *  @param cancelTitle       取消按钮
 *  @param otherTitle        其他按钮
 *  @param cancle            点击取消事件
 *  @param confirm           点击确定事件
 */
- (void)showAlertViewWithVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelTitle other:(NSString *)otherTitle cancleAction:(void (^)())cancel confirmAction:(void (^)())confirm;

/**
 *  AlertView封装(带两个按钮)
 *
 *  @param vc      当前控制器
 *  @param message 提示信息
 *  @param confirm 点击确定事件
 */
-(void)showAlertViewWithVC:(UIViewController*)vc message:(NSString*)message confirmAction:(void(^)())confirm;

//普通的2个按钮的 Alert 弹窗
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelTitle other:(NSString *)otherTitle cancleAction:(void (^)())cancel confirmAction:(void (^)())confirm;

//普通的1个按钮的 Alert 弹窗
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle confirmAction:(void (^)())confirm;

@end
