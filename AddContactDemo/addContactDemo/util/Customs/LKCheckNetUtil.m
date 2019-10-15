//
//  LKCheckNetUtil.m
//  linkeye
//
//  Created by haohao on 2018/4/24.
//  Copyright © 2018年 haohao. All rights reserved.
//

#import "LKCheckNetUtil.h"

@implementation LKCheckNetUtil

+ (BOOL)checkNetCanUse {
    
    NSURL *url = [NSURL URLWithString:BASE_REQ_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (response.statusCode == 200) {
        return YES;
    }else{
        return NO;
    }
}

@end
