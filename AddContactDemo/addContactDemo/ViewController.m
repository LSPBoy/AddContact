//
//  ViewController.m
//  addContactDemo
//
//  Created by haohao on 2019/10/8.
//  Copyright © 2019 haohao. All rights reserved.
//

#import "ViewController.h"
#import "HandContactVC.h"




@interface ViewController ()<LKPickerBoxDelegate,UITextFieldDelegate>

//登录名
@property(nonatomic,strong) UITextField* accountText;
//密码
@property(nonatomic,strong) UITextField* pwdText;

//当前选中
@property(nonatomic,strong) UITextField* currText;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    self.view.backgroundColor = [UIColor whiteColor];
    
     
    CGFloat leading = 25;
    CGFloat top = 100;
    CGFloat padding = 8;
    
    //左侧文字
    UILabel* tipLab = [[UILabel alloc]init];
    
    CGFloat width = [@"账户名：" boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:GlobalFont(12)} context:nil].size.width + 5;
    
    
    [tipLab setText:@"账户名："];
    //[tipLab setFrame:CGRectMake(25, 100, width, 30)];
    [tipLab setFont:GlobalFont(12)];
    [tipLab setTextColor:GlobalLabColor];
    [self.view addSubview:tipLab];
    
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(leading);
        make.width.mas_equalTo(width);
        make.top.mas_equalTo(top);
        make.height.equalTo(@30);
    }];
    
    
    //选择后内容展示
    UITextField* accountText = [[UITextField alloc]init];
    //[accountText setFrame:CGRectMake(25+width+8, 100, SCREEN_WIDTH - (25+width+8) - 25, 30)];
    [accountText setPlaceholder:@"请选择登录账户"];
    [accountText setFont:GlobalFont(15)];
    [accountText setTextColor:GlobalLabColor];
    //[accountText setTextAlignment:NSTextAlignmentRight];
    accountText.delegate = self;
    [self.view addSubview:accountText];
    self.accountText = accountText;
    
    [accountText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(tipLab.mas_trailing).offset(padding);
        make.centerY.height.equalTo(tipLab);
        make.trailing.mas_equalTo(-leading);
    }];
    
    
    //下拉三角
    UIImage* img = [UIImage imageNamed:@"drop_down"];
    UIImageView* rightImgView = [[UIImageView alloc]initWithImage:img];
    
    //[rightImgView setFrame:CGRectMake(accountText.frame.size.width - 10, (accountText.frame.size.height-img.size.height)/2, img.size.width, img.size.height)];
    
    //右侧下拉三角  三角距view 右侧距离
    [accountText addSubview:rightImgView];
    
    [rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(img.size);
        make.centerY.equalTo(accountText);
        make.trailing.mas_equalTo(-padding);
    }];
    
    
    //下划线
    UILabel* bottomLineLab = [UILabel new];
    //[bottomLineLab setFrame:CGRectMake(25+width+8, 100 + 30, SCREEN_WIDTH - (25+width+8) - 25, 1)];
    [bottomLineLab setBackgroundColor:UIColorFromRGB(0XE3E3E3)];
    [self.view addSubview:bottomLineLab];
    
    [bottomLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(accountText);
        make.height.equalTo(@1);
        make.top.equalTo(accountText.mas_bottom);
    }];
    
    
    
    //密码
    UILabel* pwdTipLab = [[UILabel alloc]init];
     
    
    
    [pwdTipLab setText:@"密 码："];
    //[tipLab setFrame:CGRectMake(25, 100, width, 30)];
    [pwdTipLab setFont:GlobalFont(12)];
    [pwdTipLab setTextColor:GlobalLabColor];
    [self.view addSubview:pwdTipLab];
    
    [pwdTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.height.width.equalTo(tipLab);
        make.top.equalTo(bottomLineLab.mas_bottom).offset(padding);
    }];
    
    
    //选择后内容展示
    UITextField* pwdText = [[UITextField alloc]init];
    //[accountText setFrame:CGRectMake(25+width+8, 100, SCREEN_WIDTH - (25+width+8) - 25, 30)];
    [pwdText setPlaceholder:@"请输入登录密码"];
    [pwdText setFont:GlobalFont(15)];
    [pwdText setTextColor:GlobalLabColor];
    //[accountText setTextAlignment:NSTextAlignmentRight];
    //pwdText.delegate = self;
    [self.view addSubview:pwdText];
    self.pwdText = pwdText;
    
    [pwdText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.height.equalTo(accountText);
        make.centerY.equalTo(pwdTipLab);
    }];
    
    //下划线
    UILabel* bottomLineLab2 = [UILabel new];
    //[bottomLineLab setFrame:CGRectMake(25+width+8, 100 + 30, SCREEN_WIDTH - (25+width+8) - 25, 1)];
    [bottomLineLab2 setBackgroundColor:UIColorFromRGB(0XE3E3E3)];
    [self.view addSubview:bottomLineLab2];
    
    [bottomLineLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.height.equalTo(bottomLineLab);
        make.top.equalTo(pwdText.mas_bottom);
    }];
    
    
    UIButton* loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //[loginBtn setFrame:CGRectMake(leading, SCREEN_HEIGHT - 100, SCREEN_WIDTH - leading*2, 50)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:[UIColor colorWithRed:25/255 green:167/255 blue:152/255 alpha:1]];
    loginBtn.layer.cornerRadius = 5;
    [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.6);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset(-40);
        make.centerX.equalTo(self.view);
    }];
     
    
}


 

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //隐藏键盘，避免遮挡pickerView
    [self.view endEditing:YES];
    [textField resignFirstResponder];
    
    self.currText = textField;
    
    
    if (textField == self.accountText) {
        NSArray* data = @[@"1",@"2",@"3",@"4",@"5"];
        [LKPickerBox defaultPickerBox].delegate = self;
        [LKPickerBox defaultPickerBox].dataArr = data;
        [LKPickerBox showPickerBox];
        return NO;
    }
    
    return YES;
    
}

//picker 选择事件
- (void)completePickerWithContent:(NSDictionary *)content{
    
    NSLog(@"选择的是：%@",content);
    NSString* str = [content objectForKey:@"content"];
    
    //NSString* index = [NSString stringWithFormat:@"%@",[content objectForKey:@"index"]];
     
    
    self.currText.text = str ;
     
    
}



-(void)loginAction{ 
    
    NSString* account = self.accountText.text;
    NSString* pwd = self.pwdText.text;
     
    if(account.length<=0){
        [MSPromptBox showMessage:@"请选择登录名"];
        return ;
    }
      
    
    HandContactVC* handle = [HandContactVC new];
    handle.loginType = account;
    [self.navigationController pushViewController:handle animated:YES]; 
    
}


@end
