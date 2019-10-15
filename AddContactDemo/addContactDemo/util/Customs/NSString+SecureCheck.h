//
//  NSString+SecureCheck.h
//  HuiDemo
//
//  Created by 马士超 on 2017/8/9.
//  Copyright © 2017年 马士超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SecureCheck)
// 校验手机号
+ (BOOL)validateMobile:(NSString *)mobile;
// 校验身份证号
+ (BOOL)validateIdentityCard:(NSString *)identityCard;
// 校验中文名称
+ (BOOL)validateChineseName:(NSString *)chinese;
// 校验数字与字母组合
+ (BOOL)validateWithNumberAndCharacter:(NSString *)numAndChar;
// 校验银行卡号
+ (BOOL)validateBankAccountNumber:(NSString *)bankAccount;
// 校验密码8-16位字母数字组合
+ (BOOL)validatePassword:(NSString *)password;

// 判断是否大于等于500且金额为100的倍数
+ (BOOL)validateLoanAmount:(NSString *)number;
 
@end
