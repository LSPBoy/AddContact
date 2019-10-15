//
//  KHNetworkManager.h
//  HuiDemo
//
//  Created by 马士超 on 2017/7/18.
//  Copyright © 2017年 马士超. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger, RequestType) {
    GET,
    POST,
};

@interface KHNetworkManager : AFHTTPSessionManager

+ (instancetype)shareNetworkManager;
 

- (void)requestWithType:(RequestType)type URL:(NSString *)urlString Parameters:(NSDictionary *)parameter SuccessBlock:(void(^)(id responseObject))success FailureBlock:(void(^)(NSError *error))failure;



@end
