//
//  KHNetworkManager.m
//  HuiDemo
//
//  Created by 马士超 on 2017/7/18.
//  Copyright © 2017年 马士超. All rights reserved.
//

#import "KHNetworkManager.h"

@implementation KHNetworkManager

+ (instancetype)shareNetworkManager{
    
    static KHNetworkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 1.基地址
        NSURL *baseURL = [NSURL URLWithString:BASE_REQ_URL];
        
        // 2.配置请求时间，服务器
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 25.0;
        config.timeoutIntervalForResource = 25.0;
        
        // 3.实例化
        instance = [[KHNetworkManager alloc]initWithBaseURL:baseURL sessionConfiguration:config];
        
        // 4.响应序列化器能接收的内容类型
        instance.responseSerializer = [AFJSONResponseSerializer serializer];
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    });
    
    return instance;
}

 

- (void)requestWithType:(RequestType)type URL:(NSString *)urlString Parameters:(NSDictionary *)parameter SuccessBlock:(void(^)(id responseObject))success FailureBlock:(void(^)(NSError *error))failure{
    
     
    switch (type) {
            
        case GET:
        {
            [self GET:urlString parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSString* code = [NSString stringWithFormat:@"%d",[responseObject[@"code"] intValue]];
                
                if ([code isEqualToString:@"200"]) {
                    NSLog(@"GET请求成功,获取数据为【%@】",responseObject);
                    success(responseObject[@"result"]);
                }else{
                    
                    NSLog(@"GET请求成功【but fail】");
                    if (responseObject[@"message"]!=nil) {
                        
                        NSError *error = [NSError errorWithDomain:responseObject[@"message"] code:9999 userInfo:nil];
                        failure(error);
                    }else{
                        
                        NSError *error = [NSError errorWithDomain:@"数据异常" code:7777 userInfo:nil];
                        failure(error);
                    }
                }
                
                 
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 
                NSError *connectError = [NSError errorWithDomain:@"网络异常，请再试一次" code:0404 userInfo:nil];
                failure(connectError);
            }];
        }
            break;
            
        case POST:
        {
            if (parameter == nil) {
                
                [self POST:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    NSString* code = [NSString stringWithFormat:@"%d",[responseObject[@"code"] intValue]];
                    
                    if ([code isEqualToString:@"200"]) {
                         
                        NSLog(@"获取数据为【%@】",responseObject);
                        success(responseObject[@"result"]);
                    }else{
                        
                        NSLog(@"POST无参数请求成功【but fail】");
                        if (responseObject[@"message"]!=nil) {
                            
                            NSError *error = [NSError errorWithDomain:responseObject[@"message"] code:9999 userInfo:nil];
                            failure(error);
                        }else{
                            
                            NSError *error = [NSError errorWithDomain:@"数据异常" code:7777 userInfo:nil];
                            failure(error);
                        }
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    //LKLog(@"星途有些迷航，请再试一次");
                    NSLog(@"具体错误信息：%@",error.localizedDescription);
                    NSError *connectError = [NSError errorWithDomain:@"网络异常，请再试一次" code:0404 userInfo:nil];
                    failure(connectError);
                }];
                
            }else{
                
                [self POST:urlString parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    NSString* code = [NSString stringWithFormat:@"%d",[responseObject[@"code"] intValue]];
                    
                    if ([code isEqualToString:@"200"]) {
                        NSLog(@"POST请求成功,响应数据为【%@】",responseObject);
                        success(responseObject[@"result"]);
                    }else{
                         
                        NSLog(@"POST请求成功,响应数据为【%@】",responseObject);
                        
                        if (responseObject[@"message"]!=nil) {
                            
                            NSError *error = [NSError errorWithDomain:responseObject[@"message"] code:9999 userInfo:nil];
                            failure(error);
                        }else{
                            
                            NSError *error = [NSError errorWithDomain:@"数据异常" code:7777 userInfo:nil];
                            failure(error);
                        }
                    }
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                    NSError *connectError = [NSError errorWithDomain:@"网络异常，请再试一次" code:0404 userInfo:nil];
                    failure(connectError);
                }];
            }
        }
            break;
            
        default:
        {
            NSLog(@"暂不支持该类型的请求【sorry】");
        }
            break;
    }
}


@end
