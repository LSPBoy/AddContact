//
//  LKPickerBox.m
//  linkeye
//
//  Created by haohao on 2018/3/16.
//  Copyright © 2018年 haohao. All rights reserved.
//

#import "LKPickerBox.h"

#define TopBarH 49
#define PickerW SCREEN_WIDTH
#define PickerH SCREEN_HEIGHT*0.25

@interface LKPickerBox ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic,strong) UIView *baseCover;

@end

@implementation LKPickerBox{
    UIView       *_topBar;
    UIView       *_separator;
    UIButton     *_cancelBtn;
    UIButton     *_completeBtn;
    UIPickerView *_simplePicker;
}

static dispatch_once_t addressOnce;
static LKPickerBox *addressPicker;

+ (instancetype)defaultPickerBox{
    
    dispatch_once(&addressOnce, ^{
        
        addressPicker = [[self alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, PickerW, TopBarH + PickerH)];
        addressPicker.backgroundColor = [UIColor whiteColor];
    });
    
    return addressPicker;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUI];
        [self setupTargets];
    }
    return self;
}

+ (void)showPickerBox{
    
    LKPickerBox *picker = [LKPickerBox defaultPickerBox];
    [[UIApplication sharedApplication].keyWindow addSubview:picker.baseCover];
    [[UIApplication sharedApplication].keyWindow addSubview:picker];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        picker.frame = CGRectMake(0, SCREEN_HEIGHT-PickerH-TopBarH, PickerW, TopBarH + PickerH);
        picker.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
    }];
}

+ (void)dismissPickerBox{
    
    LKPickerBox *picker = [LKPickerBox defaultPickerBox];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        picker.frame = CGRectMake(0, SCREEN_HEIGHT, PickerW, TopBarH + PickerH);
        picker.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        
        [picker removeFromSuperview];
        [picker.baseCover removeFromSuperview];
        
        addressOnce = 0;
        addressPicker =nil;
    }];
}

#pragma mark - Methods: Targets

- (void)cancelBtnDidClick:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(cancelPicker)]) {
        
        [self.delegate cancelPicker];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.frame = CGRectMake(0, SCREEN_HEIGHT, PickerW, TopBarH + PickerH);
        self.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        [self.baseCover removeFromSuperview];
        
        addressOnce = 0;
        addressPicker =nil;
    }];
}

- (void)completeBtnDidClick:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(completePickerWithContent:)]) {
        
        NSInteger index = [_simplePicker selectedRowInComponent:0];
        NSString *currentIndex = [NSString stringWithFormat:@"%ld",(long)index];
        NSDictionary *content = @{@"content":self.dataArr[index],
                                  @"index":currentIndex
                                  };
        
        [self.delegate completePickerWithContent:content];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.frame = CGRectMake(0, SCREEN_HEIGHT, PickerW, TopBarH + PickerH);
        self.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        [self.baseCover removeFromSuperview];
        
        addressOnce = 0;
        addressPicker =nil;
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return self.dataArr.count;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 42;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return self.dataArr[row];
}

#pragma mark - Methods: BasicUI

- (void)setUI {
    
    _topBar = [[UIView alloc] init];
    _topBar.backgroundColor = UIColorFromRGB(0xffffff);
    
    _separator = [[UIView alloc] init];
    _separator.backgroundColor = UIColorFromRGB(0xd5d5d5);
    
    _cancelBtn = [[UIButton alloc] init];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:UIColorFromRGB(0xcfa46a) forState:UIControlStateNormal];
    [_cancelBtn sizeToFit];
    
    _completeBtn = [[UIButton alloc] init];
    _completeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_completeBtn setTitleColor:UIColorFromRGB(0xcfa46a) forState:UIControlStateNormal];
    [_completeBtn sizeToFit];
    
    _simplePicker = [[UIPickerView alloc] init];
    _simplePicker.delegate = self;
    _simplePicker.dataSource = self;
    
    [_topBar addSubview:_cancelBtn];
    [_topBar addSubview:_completeBtn];
    [_topBar addSubview:_separator];
    [self addSubview:_topBar];
    [self addSubview:_simplePicker];
}

- (void)setupTargets {
    
    [_cancelBtn addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_completeBtn addTarget:self action:@selector(completeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.leading.trailing.equalTo(self);
        make.height.mas_equalTo(TopBarH);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.leading.equalTo(_topBar.mas_leading).offset(5);
        make.centerY.equalTo(_topBar.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(52, TopBarH));
    }];
    
    [_completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.trailing.equalTo(_topBar.mas_trailing).offset(-5);
        make.centerY.equalTo(_topBar.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(52, TopBarH));
    }];
    
    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(_topBar.mas_bottom);
        make.leading.trailing.equalTo(_topBar);
        make.height.mas_equalTo(1.5);
    }];
    
    [_simplePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_topBar.mas_bottom);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(PickerH);
    }];
}

#pragma mark - getters && setters

- (UIView *)baseCover{
    
    if (!_baseCover) {
        
        _baseCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PickerW, SCREEN_HEIGHT)];
        _baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    
    return _baseCover;
}

@end
