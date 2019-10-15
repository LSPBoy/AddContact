//
//  NSString+SecureCheck.m
//  HuiDemo
//
//  Created by 马士超 on 2017/8/9.
//  Copyright © 2017年 马士超. All rights reserved.
//

#import "NSString+SecureCheck.h"

@implementation NSString (SecureCheck)

/**
 判断手机号码格式是否正确
 
 @param mobile 用户的手机号（字符串）
 @return 结果
 */
+ (BOOL)validateMobile:(NSString *)mobile;{
    
    //去掉所有的空格
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11){ 
        return NO;
    }else{
        // 移动号段正则表达式
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(198)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        // 联通号段正则表达式
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(166)|(175)|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        // 电信号段正则表达式
        NSString *CT_NUM = @"^((133)|(153)|(173)|(177)|(199)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if(isMatch1 || isMatch2 || isMatch3){
            
            return YES;
        }else{
            
            return NO;
        }
    }
}

/**
 判断身份证号是否正确
 
 @param identityCard 身份证号
 @return 结果
 */
+ (BOOL)validateIdentityCard:(NSString *)identityCard{
    
    //去掉所有的空格
    identityCard = [identityCard stringByReplacingOccurrencesOfString:@" " withString:@""];
    //身份证的位数为18位
    if (identityCard.length == 18) {
        
        NSString *regex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
        NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        
        return [identityCardPredicate evaluateWithObject:identityCard];
    }else{
        
        return NO;
    }
}

/**
 判断是否是有效的中文名
 
 @param chinese 名字
 @return 如果是在如下规则下符合的中文名则返回`YES`，否则返回`NO`
 限制规则：
 1. 首先是名字要大于2个汉字，小于8个汉字
 2. 如果是中间带`{•|·}`的名字，则限制长度15位（新疆人的名字有15位左右的，之前公司实名认证就遇到过），如果有更长的，请自行修改长度限制
 3. 如果是不带小点的正常名字，限制长度为8位，若果觉得不适，请自行修改位数限制
 *PS: `•`或`·`具体是那个点具体处理需要注意*
 */
+ (BOOL)validateChineseName:(NSString *)chinese{
    
    NSRange range1 = [chinese rangeOfString:@"·"];
    NSRange range2 = [chinese rangeOfString:@"•"];
    if(range1.location != NSNotFound||range2.location != NSNotFound ){
        
        //一般中间带 `•`的名字长度不会超过15位，如果有那就设高一点
        if ([chinese length] < 2||[chinese length] > 15){
            return NO;
        }
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\u4e00-\u9fa5]+[·•][\u4e00-\u9fa5]+$" options:0 error:NULL];
        
        NSTextCheckingResult *match = [regex firstMatchInString:chinese options:0 range:NSMakeRange(0, [chinese length])];
        
        NSUInteger count = [match numberOfRanges];
        
        return count == 1;
    }else{
        
        //一般正常的名字长度不会少于2位并且不超过8位，如果有那就设高一点
        if ([chinese length] < 2||[chinese length] > 8) {
            return NO;
        }
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\u4e00-\u9fa5]+$" options:0 error:NULL];
        
        NSTextCheckingResult *match = [regex firstMatchInString:chinese options:0 range:NSMakeRange(0, [chinese length])];
        
        NSUInteger count = [match numberOfRanges];
        
        return count == 1;
    }
}

/**
 判断字符串是否同时包含字母和数字
 
 @param password 密码
 @return 结果
 */

+ (BOOL)validatePassword:(NSString *)password{
    
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,15}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    
    return isMatch;
}

/**
 判断字符串是否同时包含字母和数字
 
 @param numAndChar 字符串
 @return 结果
 */
+ (BOOL)validateWithNumberAndCharacter:(NSString *)numAndChar{
    
    // 去掉所有的空格
    numAndChar = [numAndChar stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 筛选数字条件
    NSRegularExpression *NumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger NumMatchCount = [NumRegularExpression numberOfMatchesInString:numAndChar options:NSMatchingReportProgress range:NSMakeRange(0, numAndChar.length)];
    
    if(NumMatchCount == numAndChar.length){
        
        // 纯数字
        return NO;
    }
    
    // 筛选字母条件
    NSRegularExpression *LetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger LetterMatchCount = [LetterRegularExpression numberOfMatchesInString:numAndChar options:NSMatchingReportProgress range:NSMakeRange(0, numAndChar.length)];
    
    if(LetterMatchCount == numAndChar.length){
        
        // 纯字母
        return NO;
    }
    
    if(NumMatchCount + LetterMatchCount == numAndChar.length){
        
        // 包含字母和数字
        return YES;
    }else{
        
        // 包含字母和数字之外的其他字符
        return NO;
    }
}

/**
 判断银行卡号输入是否正确
 
 @param bankAccount 银行卡号
 @return 结果
 */
+ (BOOL)validateBankAccountNumber:(NSString *)bankAccount{
    
    if (bankAccount.length>0) {
        // 奇数求和
        int oddsum = 0;
        // 偶数求和
        int evensum = 0;
        int allsum = 0;
        int cardNoLength = (int)[bankAccount length];
        int lastNum = [[bankAccount substringFromIndex:cardNoLength - 1] intValue];
        NSString *cardNo = [bankAccount substringToIndex:cardNoLength - 1];
        
        for(int i = cardNoLength - 1; i >= 1; i--){
            
            NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
            int tmpVal = [tmpString intValue];
            
            if (cardNoLength % 2 == 1) {
                
                if((i % 2) == 0){
                    
                    tmpVal *= 2;
                    if (tmpVal >= 10){
                        
                        tmpVal -= 9;
                    }
                    evensum += tmpVal;
                }else{
                    
                    oddsum += tmpVal;
                }
                
            }else{
                
                if((i%2) == 1){
                    
                    tmpVal *= 2;
                    if (tmpVal >= 10){
                        
                        tmpVal -= 9;
                    }
                    evensum += tmpVal;
                    
                }else{
                    
                    oddsum += tmpVal;
                }
            }
        }
        
        allsum = oddsum + evensum;
        allsum += lastNum;
        
        return ((allsum % 10) == 0)?YES:NO;
    }else{
        
        return NO;
    }
}

+ (BOOL)validateLoanAmount:(NSString *)number{
    
    int count = [number intValue];
    if (count>=500) {
        
        if (count%100==0) {
            
            return YES;
        }else{
            
            return NO;
        }
    }else{
        
        return NO;
    }
}
 
@end
