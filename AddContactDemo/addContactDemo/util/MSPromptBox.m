//
//  MSPromptBox.m
//  HuiDemo
//
//  Created by 马士超 on 2017/7/19.
//  Copyright © 2017年 马士超. All rights reserved.
//

#import "MSPromptBox.h"

#define BOX_WIDTH kScale_ValueX(260)
#define BOX_HEIGHT kScale_ValueX(200)

@interface MSPromptBox ()
@property (nonatomic,strong) UIView *baseCover;

@end

@implementation MSPromptBox{
    
    UILabel *_messageLab;
    UIButton *_cancelBtn;
    UIView *_separator;
    UIView *_container;
}

#pragma mark - Methods: Targets

- (void)setPrompt:(NSString *)prompt{
    
    _prompt = prompt;
    
    _messageLab.text = prompt;
}

- (void)setOperateString:(NSString *)operateString{
    
    _operateString = operateString;
    
    [_cancelBtn setTitle:_operateString forState:UIControlStateNormal];
}

- (void)didClickedCancelBtn:(UIButton *)sender{
    
    
    if ([self.delegate respondsToSelector:@selector(ClosePromptBox:)]) {
        
        [self.delegate ClosePromptBox:sender.titleLabel.text];
    }
    
    MSPromptBox *prompt = [MSPromptBox defaultPromptUI];
    [UIView animateWithDuration:0.25 animations:^{
        
        prompt.frame = CGRectMake((SCREEN_WIDTH-BOX_WIDTH)/2, SCREEN_HEIGHT, BOX_WIDTH, BOX_HEIGHT);
        prompt.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        
        [prompt removeFromSuperview];
        [prompt.baseCover removeFromSuperview];
    }];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if ([super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self setUI];
    }
    return self;
}

#pragma mark - Methods: trigger

+ (void)showPromptMessage:(NSString *)message{
    #warning message - DO:提示封装
}

#pragma mark - Methods: trigger

+ (void)showProcessing{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:1.25];
    [SVProgressHUD setFadeOutAnimationDuration:0.25];
    [SVProgressHUD setFadeInAnimationDuration:0.25];
    [SVProgressHUD showWithStatus:@"正在加载中"];
}

+ (void)showMessage:(NSString *)message{
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:UIColorFromRGB(0xffffff)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
    
    [SVProgressHUD setCornerRadius:8];
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD setMinimumDismissTimeInterval:1.25];
    [SVProgressHUD setFadeOutAnimationDuration:0.25];
    [SVProgressHUD setFadeInAnimationDuration:0.25];
    [SVProgressHUD showInfoWithStatus:message];
}

+ (void)showError:(NSError *)error{
    
    //[SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    //[SVProgressHUD setForegroundColor:UIColorFromRGB(0xcfa46a)];
    //[SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
    
    [SVProgressHUD setCornerRadius:8];
    [SVProgressHUD setErrorImage:nil];
    [SVProgressHUD setMinimumDismissTimeInterval:1.25];
    [SVProgressHUD setFadeOutAnimationDuration:0.25];
    [SVProgressHUD setFadeInAnimationDuration:0.25];
     
    [SVProgressHUD showErrorWithStatus:error.domain];
    
}

+ (void)showSuccess:(NSString *)successString{
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:UIColorFromRGB(0xcfa46a)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
    
    [SVProgressHUD setCornerRadius:8];
    [SVProgressHUD setSuccessImage:nil];
    [SVProgressHUD setMinimumDismissTimeInterval:1.25];
    [SVProgressHUD showSuccessWithStatus:successString];
}

+ (void)dissmissBox{
    
    [SVProgressHUD dismiss];
}

#pragma mark - Methods: trigger

+ (instancetype)defaultPromptUI{
    
    static MSPromptBox *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-BOX_WIDTH)/2, SCREEN_HEIGHT, BOX_WIDTH, BOX_HEIGHT)];
        instance.backgroundColor = [UIColor cyanColor];
    });
    return instance;
}

+ (void)showPromptUI{
    
    MSPromptBox *prompt = [MSPromptBox defaultPromptUI];
    [[UIApplication sharedApplication].keyWindow addSubview:prompt.baseCover];
    [[UIApplication sharedApplication].keyWindow addSubview:prompt];
    [UIView animateWithDuration:0.25 animations:^{
        
        prompt.center = [UIApplication sharedApplication].keyWindow.center;
        prompt.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
    }];
}

+ (void)dissmissPromptUI{
    
    MSPromptBox *prompt = [MSPromptBox defaultPromptUI];
    [UIView animateWithDuration:0.05 animations:^{
        
        prompt.frame = CGRectMake((SCREEN_WIDTH-BOX_WIDTH)/2, SCREEN_HEIGHT, BOX_WIDTH, BOX_HEIGHT);
        prompt.baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        
        [prompt removeFromSuperview];
        [prompt.baseCover removeFromSuperview];
    }];
}

#pragma mark - Methods: BasicUI

- (void)setUI {
    
    _container = [[UIView alloc] init];
    _container.backgroundColor = UIColorFromRGB(0xffffff);
    _container.layer.cornerRadius = 5.0;
    _container.layer.masksToBounds = YES;
    
    _messageLab = [[UILabel alloc] init];
    _messageLab.text = @"即将显示系统相关提示信息，请注意阅读";
    _messageLab.textColor = UIColorFromRGB(0x666666);
    _messageLab.textAlignment = NSTextAlignmentCenter;
    _messageLab.numberOfLines = 0;
    
    _separator = [[UIView alloc] init];
    _separator.backgroundColor = UIColorFromRGB(0xd5d5d5);
    
    _cancelBtn = [[UIButton alloc] init];
    [_cancelBtn setTitle:@"我知道了" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:UIColorFromRGB(0xcfa46a) forState:UIControlStateNormal];
    
    [_container addSubview:_messageLab];
    [_container addSubview:_separator];
    [_container addSubview:_cancelBtn];
    [self addSubview:_container];
    
    // 事件处理
    [_cancelBtn addTarget:self action:@selector(didClickedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 布局子控件
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.leading.trailing.equalTo(self);
    }];
    
    [_messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_container.mas_top).offset(kScale_ValueY(8));
        make.leading.equalTo(_container.mas_leading).offset(kScale_ValueX(10));
        make.trailing.equalTo(_container.mas_trailing).offset(kScale_ValueX(-10));
    }];
    
    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_messageLab.mas_bottom);
        make.leading.trailing.equalTo(_container);
        make.height.mas_equalTo(1.5);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_separator.mas_bottom);
        make.leading.trailing.bottom.equalTo(_container);
        make.height.mas_equalTo(BOX_HEIGHT*0.25);
    }];
}

#pragma mark - Methods: getters && setters

- (UIView *)baseCover{
    
    if (!_baseCover) {
        
        _baseCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _baseCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    
    return _baseCover;
}


@end
