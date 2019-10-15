//
//  LKPickerBox.h
//  linkeye
//
//  Created by haohao on 2018/3/16.
//  Copyright © 2018年 haohao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKPickerBoxDelegate <NSObject>
@required
- (void)completePickerWithContent:(NSDictionary *)content;
@optional
- (void)cancelPicker;

@end


@interface LKPickerBox : UIView

@property(nonatomic,strong)NSArray<NSString*> *dataArr;
@property(nonatomic,weak)id<LKPickerBoxDelegate> delegate;

+ (instancetype)defaultPickerBox;
+ (void)showPickerBox;
+ (void)dismissPickerBox;
@end
