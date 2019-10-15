//
//  UIImage+RenderMode.m
//  HJBZCnew
//
//  Created by hjbsj on 16/7/28.
//  Copyright © 2016年 masc. All rights reserved.
//

#import "UIImage+RenderMode.h"

@implementation UIImage (RenderMode)

+ (UIImage *)imageNamed:(NSString *)name RenderMode:(UIImageRenderingMode)mode{
    
    return [[UIImage imageNamed:name] imageWithRenderingMode:mode];
}

@end
