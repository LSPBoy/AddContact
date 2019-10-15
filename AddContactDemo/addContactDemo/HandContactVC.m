//
//  HandContactVC.m
//  addContactDemo
//
//  Created by haohao on 2019/10/8.
//  Copyright © 2019 haohao. All rights reserved.
//

#import "HandContactVC.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
//Darwin.libkern.OSAtomic
#import "libkern/OSAtomic.h"

#import <AVFoundation/AVFoundation.h>

@interface HandContactVC ()<AVAudioPlayerDelegate>

//要添加的手机号
@property(nonatomic,strong) NSMutableArray* dataArr;
 

@property(nonatomic,strong) UILabel* lab;

@property(nonatomic,strong) UIProgressView* progressView;

@property (nonatomic, strong) UILabel *numLabel;

// 后台播放音乐
@property(nonatomic,strong)AVAudioPlayer * audioPlayer;

@end

@implementation HandContactVC


-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    for (int i = 0; i<10000; i++) {
        NSString* rand = [self randPhone];
        [self.dataArr addObject:rand];
    }
    
      
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
            if (error) {
                NSLog(@"授权失败");
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{

                     [self initUI];

                           });

            }
        }];
        return;
    }
    else if(status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"用户拒绝");
        [self showAlertViewAboutNotAuthorAccessContact];

    }
    else if (status == CNAuthorizationStatusDenied)
    {
        NSLog(@"用户拒绝");
        [self showAlertViewAboutNotAuthorAccessContact];

    }
    else if (status == CNAuthorizationStatusAuthorized)//已经授权
    {
        //有通讯录权限-- 进行下一步操作
        [self initUI];
    }
    
}
- (void)initUI
{
    [self playVoiceBackground];

       UIButton* addBtn = [UIButton buttonWithType:UIButtonTypeCustom];

       [addBtn setTitle:@"添加通讯录" forState:UIControlStateNormal];
       [addBtn setBackgroundColor:[UIColor colorWithRed:25/255 green:167/255 blue:152/255 alpha:1]];
       addBtn.layer.cornerRadius = 5;
       [addBtn addTarget:self action:@selector(getPhoneInfoReq) forControlEvents:UIControlEventTouchUpInside];
       [self.view addSubview:addBtn];

       [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.width.equalTo(self.view).multipliedBy(0.4);
           make.height.equalTo(@50);
           make.centerY.equalTo(self.view).offset(-40);
           make.centerX.equalTo(self.view);
       }];




       UIButton* delBtn = [UIButton buttonWithType:UIButtonTypeCustom];

       [delBtn setTitle:@"删除通讯录" forState:UIControlStateNormal];
       [delBtn setBackgroundColor:[UIColor colorWithRed:25/255 green:167/255 blue:152/255 alpha:1]];
       delBtn.layer.cornerRadius = 5;
       [delBtn addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
       [self.view addSubview:delBtn];

       [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.width.height.centerX.equalTo(addBtn);
           make.top.equalTo(addBtn.mas_bottom).offset(30);

       }];



//       UIButton* readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//
//       [readBtn setTitle:@"读取通讯录" forState:UIControlStateNormal];
//       [readBtn setBackgroundColor:[UIColor colorWithRed:25/255 green:167/255 blue:152/255 alpha:1]];
//       readBtn.layer.cornerRadius = 5;
//       [readBtn addTarget:self action:@selector(readAction) forControlEvents:UIControlEventTouchUpInside];
//       [self.view addSubview:readBtn];
//
//       [readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//           make.width.height.centerX.equalTo(addBtn);
//           make.top.equalTo(delBtn.mas_bottom).offset(30);
//       }];



       //添加进度条

       UILabel* lab = [UILabel new];
       [lab setText:@"添加进度"];
       [lab setTextAlignment:NSTextAlignmentCenter];
       [lab setHidden:YES];
       [self.view addSubview:lab];
       self.lab = lab;

       [lab mas_makeConstraints:^(MASConstraintMaker *make) {
           make.height.equalTo(@20);
           make.leading.equalTo(self.view).offset(80);
           make.trailing.equalTo(self.view).offset(-80);
           make.top.equalTo(delBtn.mas_bottom).offset(30);
       }];


       // 创建进度视图
       UIProgressView* progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
       //_progressView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
       progressView.progressTintColor = UIColorFromRGB(0xcfa46a);
       //progressView.trackTintColor = [UIColor clearColor];
       progressView.progress = 0.0f;
       progressView.hidden = YES;
       [self.view addSubview:progressView];
       self.progressView = progressView;

       [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.leading.trailing.equalTo(lab);
           make.top.equalTo(lab.mas_bottom).offset(10);
           make.height.equalTo(@4);
       }];


}


//添加通讯录
-(void)addAction{
     
//    CNMutableGroup *group = [[CNMutableGroup alloc] init];
//        group.name = @"Luck";
//        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
//        [saveRequest addGroup:group toContainerWithIdentifier:nil];
//        // 写入
//        CNContactStore *store = [[CNContactStore alloc] init];
//        [store executeSaveRequest:saveRequest error:nil];
//
//    
//     CNMutableContact *contact = [[CNMutableContact alloc] init];
//        // 设置联系人姓名
//        contact.givenName = @"测试";
//        // 设置姓氏
//        contact.familyName = @"测试";
//     CNPhoneNumber *mobileNumber = [[CNPhoneNumber alloc] initWithStringValue:@"15201596724"];
//     CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:CNLabelPhoneNumberMobile value:mobileNumber];
//     contact.phoneNumbers = @[mobilePhone];
//   
//    
//    
//        [saveRequest addMember:[contact copy] toGroup:group];
//        // 写入
//        [store executeSaveRequest:saveRequest error:nil];
//   
//   
//   
//    return;
    
    
    NSString* time1 = [self currentdateInterval];
    NSLog(@"当前开始处理时间是:%@",time1);
    
    if(self.dataArr.count<=0){
        return;
    }
     
    self.lab.hidden = NO;
    self.progressView.hidden = NO;
    
    dispatch_queue_t q = [self YYAsyncLayerGetDisplayQueue];

    __block int count = 0;
    __block NSMutableArray *numsArray = [[NSMutableArray alloc] init];
    [AddressHandle shareManage].storeCount = 0;
    dispatch_async(q, ^{
    for (int i = 0; i<self.dataArr.count; i++) {

        NSString* nameAndPhone = self.dataArr[i];

        [numsArray addObject:nameAndPhone];
        if (numsArray.count == 500) {

            [[AddressHandle shareManage] creatPeopleNames:[numsArray copy] AndphoneNums:[numsArray copy] completeThredStore:^(NSInteger storeCount) {
                float percen = (double)storeCount * 500 / (double)self.dataArr.count ;
                           NSLog(@"当前执行的进度：%f,当前插入次数:%ld,总条数:%lu",percen,(long)storeCount,(unsigned long)self.dataArr.count);

                               [self.progressView setProgress:percen];

                               if(storeCount == self.dataArr.count / 500){
                                   [MSPromptBox showMessage:[NSString stringWithFormat:@"添加完成,共添加了%ld条",storeCount * 500]];
                               }
            }];
           
            count += 1;

            [numsArray removeAllObjects];
        }

    }

    });

}
 

//删除通讯录
-(void)delAction{

//    CNMutableGroup *group = [[CNMutableGroup alloc] init];
//    group.name = @"Luck";
//     CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
//        [saveRequest deleteGroup:group];
//        // 写入
//        CNContactStore *store = [[CNContactStore alloc] init];
//        [store executeSaveRequest:saveRequest error:nil];
//  
//    return;
    
    self.progressView.hidden = NO;
    NSString* time1 = [self currentdateInterval];
    NSLog(@"当前开始处理时间是:%@",time1);

    [AddressHandle shareManage].storeCount = 20;

    [[AddressHandle shareManage] deleteName:@"" orAlldelete:YES completeThredDele:^(NSInteger storeCount) {

        float percen = (double)storeCount * 500 / 10000;
        NSLog(@"当前执行的进度：%f,当前插入次数:%ld,总条数:%lu",percen,(long)storeCount,(unsigned long)self.dataArr.count);

            [self.progressView setProgress:percen];

            if(storeCount == 0){
                [MSPromptBox showMessage:@"删除完成!"];
            }


    }];

}

//读取通讯录
-(void)readAction{
    
    /*
    [[LJContactManager sharedInstance] accessContactsComplection:^(BOOL succeed, NSArray<LJPerson *> *contacts) {
        
        NSLog(@"第三方工具:%@",contacts);
    }];
    */
    
    [[AddressHandle shareManage] fetchAddressBookOnIOS9AndLater:^(NSArray *data) {
        
        NSLog(@"通讯录总条数:%lu,通讯录内容：%@",(unsigned long)data.count,data);
        
        /*
        for (NSDictionary* dict in data) {
            NSString* name = dict[@"name"];
            [self.dataArr addObject:name];
        }
        */
        
    }];
    
     /*
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        if (granted) {
            //解析通讯录数据
            [self handContactsDataWithAB:addressBook];
        }else{
             
        }
    });
     */
}


-(NSString*)randPhone{
    int y = (arc4random() % 90001) + 10000;
    NSString* yy = [NSString stringWithFormat:@"%d",y];
    return yy;
}




/*
- (void)handContactsDataWithAB:(ABAddressBookRef)addressBook{
    
    // 1.获取所有联系人
    CFArrayRef peosons = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    // 2.遍历所有联系人来获取数据(姓名和电话)
    NSMutableArray *mArr = [NSMutableArray array];
    
    CFIndex count = CFArrayGetCount(peosons);
    for(CFIndex i = 0 ; i < count; i++){
        
        // 2.1获取联系人姓名
        ABRecordRef person = CFArrayGetValueAtIndex(peosons, i);
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSString *firstName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        lastName = lastName.length>0?lastName:@"";
        firstName = firstName.length>0?firstName:@"";
        NSString *contactName = [NSString stringWithFormat:@"%@%@",lastName,firstName];
        
        // 2.2获取联系人电话
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneCount = ABMultiValueGetCount(phones);
        
        for(CFIndex i = 0; i < phoneCount; i++){
            
            NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
            NSString *value = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, i));
            
            [mDict setValue:contactName forKey:@"name"];
            [mDict setValue:value forKey:@"mobilePhone"];
            
            [mArr addObject:mDict];
        }
        
        CFRelease(phones);
    }
    // 3.释放
    CFRelease(peosons);
    CFRelease(addressBook);
    
    
    self.addressBookArr = mArr;
    
    NSString* json = [self convertDataArrayToJsonString:mArr];
    
    NSLog(@"获取到的通讯录总个数是：%lu,数据是：%@,",(unsigned long)mArr.count,json);
    
}




- (NSString *)convertDataArrayToJsonString:(NSArray *)dataArr{
    
    NSError *parseError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArr options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableString *mString = [NSMutableString stringWithString:jsonString];
    
    // 去掉字符串中的空格
    NSRange range = {0,jsonString.length};
    [mString replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    // 去掉字符串中的换行符
    NSRange range2 = {0,mString.length};
    [mString replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    jsonString = mString.copy;
    
    return jsonString;
}



//获取是否授权
- (BOOL)getContactAuthorize:(CNContactStore *)contactStore {
    __block BOOL grandted = YES;
    if (@available(iOS 9.0, *)) {
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted == YES) {
                grandted = YES;
            }else {
                grandted = NO;
            }
        }];
    } else {
        // Fallback on earlier versions
    }
    return grandted;
}

*/




-(NSString *)currentdateInterval
{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    return timeSp;
}



//subSize 每个数组中有多少个数
-(NSArray*)splitArray:(NSArray*)array subSize:(int)subSize{
    
    /*
    unsigned long count = array.count%subSize == 0 ?(array.count/subSize):(array.count/subSize+1);
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    
    for (int i=0; i<count; i++) {
        int index  = i*subSize;
        NSMutableArray* arr1 = [[NSMutableArray alloc]init];
        [arr1 removeAllObjects];
        
        int j = index;
        while (j<subSize*(i+1)&&j<array.count) {
            [arr1 addObject:[array objectAtIndex:j]];
            j +=1;
        }
        [arr addObject:arr1];
    }
    
    return arr;
     */
    
    
    NSMutableArray *arrayOfArrays = [NSMutableArray array];
    NSUInteger itemsRemaining = array.count;
    int j = 0;
    while(itemsRemaining) {
        NSRange range = NSMakeRange(j, MIN(subSize, itemsRemaining));
        NSArray *subLogArr = [array subarrayWithRange:range];
        [arrayOfArrays addObject:subLogArr];
        itemsRemaining-=range.length;
        j+=range.length;
    }
    
    return arrayOfArrays;
}



-(dispatch_queue_t) YYAsyncLayerGetDisplayQueue{
//最大队列数量
#define MAX_QUEUE_COUNT 16
//队列数量
    static int queueCount;
//使用栈区的数组存储队列
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
//串行队列数量和处理器数量相同
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
//创建串行队列，设置优先级
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                //QOS_CLASS_USER_INITIATED
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.ibireme.yykit.render", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.ibireme.yykit.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
//轮询返回队列
    uint32_t cur = (uint32_t)OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    return queues[cur % queueCount];
#undef MAX_QUEUE_COUNT
}


#pragma mark - 网络请求部分
#pragma mark -

-(void)getPhoneInfoReq{ 
     
    
//    NSDictionary* param = @{@"page":@"1",@"size":@"10000",@"type":self.loginType};
//    
//    [[KHNetworkManager shareNetworkManager] requestWithType:GET URL:getPhoneInfo Parameters:param SuccessBlock:^(id responseObject) {
//        
//        NSMutableArray* a = (NSMutableArray*)responseObject;
//        
//        self.dataArr = a;
//        
//        [self addAction];
//        
//    } FailureBlock:^(NSError *error) {
//        // 提示信息
//        [MSPromptBox showError:error];
//    }];
    
     [self addAction];
}





- (void)playVoiceBackground{
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatchQueue, ^(void) {
        
        NSError *audioSessionError = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        if ([audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError]){
            
            NSLog(@"Successfully set the audio session.");
            
        } else {
            
            NSLog(@"Could not set the audio session");
            
        }
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"noVoice" ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        
        if (self.audioPlayer != nil){
            
            self.audioPlayer.delegate = self;
            
            [self.audioPlayer setNumberOfLoops:-1];
            
            if ([self.audioPlayer prepareToPlay] && [self.audioPlayer play]){
                
                NSLog(@"Successfully started playing...");
                
            } else {
                
                NSLog(@"Failed to play.");
                
            }
            
        }
        
    });
}

- (void)showAlertViewAboutNotAuthorAccessContact{

    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"请授权通讯录权限"
        message:@"请在iPhone的\"设置-隐私-通讯录\"选项中,允许访问你的通讯录"
        preferredStyle: UIAlertControllerStyleAlert];

    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
