//
//  MSPromptBox.h
//  HuiDemo
//
//  Created by 马士超 on 2017/7/19.
//  Copyright © 2017年 马士超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSPromptBoxDelegate <NSObject>
@optional
- (void)ClosePromptBox:(NSString *)operateString;

@end

@interface MSPromptBox : UIView
@property (nonatomic,strong) NSString *prompt;
@property (nonatomic,strong) NSString *operateString;
@property (nonatomic,weak) id<MSPromptBoxDelegate> delegate;

// 封装展示
+ (void)showProcessing;
+ (void)showMessage:(NSString *)message;
+ (void)showError:(NSError *)error;
+ (void)showSuccess:(NSString *)successString;
+ (void)dissmissBox;

// 自定义展示1
+ (instancetype)defaultPromptUI;
+ (void)showPromptUI;
+ (void)dissmissPromptUI;


@end
