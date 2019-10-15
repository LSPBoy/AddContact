//
//  AddressHandle.m
//  通讯录操作
//
//  Created by 李贻佳 on 16/12/28.
//  Copyright © 2016年 liyijia. All rights reserved.
//

#import "AddressHandle.h"
#import <AddressBook/AddressBook.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import "libkern/OSAtomic.h"

@implementation AddressHandle
+(AddressHandle *)shareManage
{
    static AddressHandle *address = nil;
    static dispatch_once_t manage;
    dispatch_once(&manage, ^{
        address = [[self alloc]init];
        address.storeCount = 0;
    });
    return address;
}


- (void)fetchAddressBookOnIOS9AndLater:(void (^)(NSArray *data))Source{
    
    //创建CNContactStore对象
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    //首次访问需用户授权
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {//首次访问通讯录
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error){
                if (granted) {//允许
                    NSLog(@"已授权访问通讯录");
                    NSArray *contacts = [self fetchContactWithContactStore:contactStore];//访问通讯录
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //----------------主线程 更新 UI-----------------
//                        NSLog(@"所有用户:%@", contacts);
                        Source(contacts);
                        
                        
                    });
                }else{//拒绝
                    NSLog(@"拒绝访问通讯录");
                }
            }else{
                NSLog(@"发生错误!");
            }
        }];
    }else{//非首次访问通讯录
        NSArray *contacts = [self fetchContactWithContactStore:contactStore];//访问通讯录
        dispatch_async(dispatch_get_main_queue(), ^{
            //----------------主线程 更新 UI-----------------
            //NSLog(@"contacts:%@", contacts);
            
            Source(contacts);
            
        });
    }
}

- (NSMutableArray *)fetchContactWithContactStore:(CNContactStore *)contactStore{
     
    
    //判断访问权限
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {//有权限访问
        
        @autoreleasepool {
        
        NSError *error = nil;
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        //获取通讯录数组
        NSArray<CNContact*> *arr = [contactStore unifiedContactsMatchingPredicate:nil keysToFetch:keysToFetch error:&error];
        if (!error) {
            NSMutableArray *contacts = [NSMutableArray array];
            for (int i = 0; i < arr.count; i++) {
                CNContact *contact = arr[i];
                NSString *givenName = contact.givenName;
                NSString *familyName = contact.familyName;
                NSString *phoneNumber = ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue;
                if (phoneNumber==nil) {
                    phoneNumber = @"";
                }
                [contacts addObject:@{@"name": [givenName stringByAppendingString:familyName], @"phoneNumber": phoneNumber}];
            
            }
            return contacts;
        }else {
            return nil;
        }
        }
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        return nil;
    }
}

-(void)run:(NSArray *)contacts completeThredDele:(void (^)(NSInteger))completeDele {

    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *request = [[CNSaveRequest alloc] init];
    for (int j = 0; j < contacts.count; j++) {
        CNMutableContact *con = [contacts[j] mutableCopy]; //[[CNMutableContact alloc] init];

        [request deleteContact:con];

    }
    dispatch_queue_t q = [self YYAsyncLayerGetDisplayQueue];
    dispatch_async(q, ^{

        [store executeSaveRequest:request error:nil];
   
        self.storeCount--;
        NSLog(@"---- 单批删除完成: %lu",self.storeCount);
        dispatch_async(dispatch_get_main_queue(), ^{

            completeDele(self.storeCount);

        });
        
    });
//    [store executeSaveRequest:request error:nil];
//      
//           self.storeCount--;
//           NSLog(@"---- 单批删除完成: %lu",self.storeCount);
//           dispatch_async(dispatch_get_main_queue(), ^{
//
//               completeDele(self.storeCount);
//
//    });
}

-(BOOL)deleteName:(NSString *)name orAlldelete:(BOOL)alldelete completeThredDele:(void (^)(NSInteger))completeDele
{
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *request = [[CNSaveRequest alloc] init];
    __block NSMutableArray *multIdentifiers = [[NSMutableArray alloc] init];
    NSLog(@"读取开始");
    [store enumerateContactsWithFetchRequest:[[CNContactFetchRequest alloc]initWithKeysToFetch:@[CNContactIdentifierKey]] error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {

        //进行添加
        [multIdentifiers addObject:contact];
    }];
    NSLog(@"读取结束");
    __block NSMutableArray *numsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< multIdentifiers.count; i++) {
        [numsArray addObject:multIdentifiers[i]];
        if (numsArray.count == 500) {

            [self run:numsArray completeThredDele:completeDele];
            [numsArray removeAllObjects];
        }
    }
    
    
//    dispatch_queue_t q = [self YYAsyncLayerGetDisplayQueue];
//        dispatch_async(q, ^{
//            
//            for (int i = 0; i< multIdentifiers.count; i++) {
//                   [numsArray addObject:multIdentifiers[i]];
//                   if (numsArray.count == 500) {
//
//                       [self run:numsArray completeThredDele:completeDele];
//                       [numsArray removeAllObjects];
//                   }
//               }
//            
//        });
    
    
    return true;
    
//    f
//    @autoreleasepool {
//
//    BOOL les = false;
//    // 初始化并创建通讯录对象，记得释放内存
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    // 获取通讯录中所有的联系人
//    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
//    // 遍历所有的联系人并删除(这里只删除姓名为张三的)
//    for (id obj in array) {
//        ABRecordRef people = (__bridge ABRecordRef)obj;
//        if (alldelete) {
//            les = ABAddressBookRemoveRecord(addressBook, people, NULL);
//            //return les;
//        }else{
//
//            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonFirstNameProperty);
//            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonLastNameProperty);
//            if (lastName==nil) {
//                lastName = @"";
//            }
//            if (firstName==nil) {
//                firstName = @"";
//            }
//            NSString *namelet = [firstName stringByAppendingString:lastName];
//
//
//
//        name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
//            NSLog(@"传入的名称是：%@,通讯录里拼出来的名称是：%@",name,namelet);
//
//
//            if ([name isEqualToString:namelet]) {
//                les = ABAddressBookRemoveRecord(addressBook, people, NULL);
//            }
//        }
//    }
//
//    // 保存修改的通讯录对象
//    ABAddressBookSave(addressBook, NULL);
//    // 释放通讯录对象的内存
//    if (addressBook) {
//        CFRelease(addressBook);
//    }
//
//     return les;
//
//        }
}

-(dispatch_queue_t) YYAsyncLayerGetDisplayQueue{
//最大队列数量
#define MAX_QUEUE_COUNT 8
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

-(void)creatPeopleNames:(NSArray *)names AndphoneNums:(NSArray *)nums completeThredStore:(void (^)(NSInteger storeCount))completeStore
{
    // 初始化一个ABAddressBookRef对象，使用完之后需要进行释放，
    // 这里使用CFRelease进行释放
    // 相当于通讯录的一个引用
    __block CNSaveRequest *request = [[CNSaveRequest alloc] init];
    for (int i=0; i < nums.count; i++) {
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.givenName = names[i];
        contact.familyName = @"";
        contact.phoneNumbers = @[[CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberHomeFax value:[CNPhoneNumber phoneNumberWithStringValue:nums[i]]]];
        [request addContact:contact toContainerWithIdentifier:nil];
    }
    dispatch_queue_t q = [self YYAsyncLayerGetDisplayQueue];
    dispatch_async(q, ^{
        CNContactStore *store = [[CNContactStore alloc] init];
        //NSLog(@"开始存入");
        //NSLog(@"%@", [NSThread currentThread]);
        [store executeSaveRequest:request error:nil];
        //NSLog(@"存入结束");
        self.storeCount++;
        NSLog(@"---- 单批存入完成: %lu",self.storeCount);
         dispatch_async(dispatch_get_main_queue(), ^{

              completeStore(self.storeCount);

         });

        
    });
//    @autoreleasepool {
//
//        ABAddressBookRef addressBook = ABAddressBookCreate();
//
//        //NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
//
//        // 新建一个联系人
//        // ABRecordRef是一个属性的集合，相当于通讯录中联系人的对象
//        // 联系人对象的属性分为两种：
//        // 只拥有唯一值的属性和多值的属性。
//        // 唯一值的属性包括：姓氏、名字、生日等。
//        // 多值的属性包括:电话号码、邮箱等。
//        ABRecordRef person = ABPersonCreate();
//        //NSString *firstName = [name substringFromIndex:1];
//        //NSString *lastName = [name substringToIndex:1];
//
//        NSString *firstName = name;
//        NSString *lastName = @"";
//
//        //NSDate *birthday = [NSDate date];
//        // 电话号码数组
//        NSArray *phones = [NSArray arrayWithObjects:num, nil];
//        // 电话号码对应的名称
//        NSArray *labels = [NSArray arrayWithObjects:@"个人电话", nil];
//        // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNameProperty
//        // 设置firstName属性
//        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, NULL);
//        // 设置lastName属性
//        //ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef) lastName, NULL);
//
//        // 设置birthday属性
//        //ABRecordSetValue(person, kABPersonBirthdayProperty, (__bridge CFDateRef)birthday, NULL);
//        // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
//        ABMultiValueRef mv = ABMultiValueCreateMutable(kABMultiStringPropertyType);
//        // 添加电话号码与其对应的名称内容
//        for (int i = 0; i < [phones count]; i ++) {
//            ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv, (__bridge CFStringRef)[phones objectAtIndex:i], (__bridge CFStringRef)[labels objectAtIndex:i], &mi);
//        }
//        // 设置phone属性
//        ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
//
//        NSLog(@"联系人属性:%@",person);
//
//        // 将新建的联系人添加到通讯录中
//        ABAddressBookAddRecord(addressBook, person, NULL);
//        // 保存通讯录数据
//        ABAddressBookSave(addressBook, NULL);
//
//        // 释放该数组
//        CFRelease(mv);
//        CFRelease(person);
//        CFRelease(addressBook);
//     }
}
/*
 升到iOS10之后，需要设置权限的有：
 
 麦克风权限：Privacy - Microphone Usage Description 是否允许此App使用你的麦克风？
 
 相机权限： Privacy - Camera Usage Description 是否允许此App使用你的相机？
 
 相册权限： Privacy - Photo Library Usage Description 是否允许此App访问你的媒体资料库？
 
 通讯录权限： Privacy - Contacts Usage Description 是否允许此App访问你的通讯录？
 
 蓝牙权限：Privacy - Bluetooth Peripheral Usage Description 是否许允此App使用蓝牙？
 
 语音转文字权限：Privacy - Speech Recognition Usage Description 是否允许此App使用语音识别？
 
 日历权限：Privacy - Calendars Usage Description
 
 定位权限：Privacy - Location When In Use Usage Description
 
 定位权限: Privacy - Location Always Usage Description
 
 位置权限：Privacy - Location Usage Description
 
 媒体库权限：Privacy - Media Library Usage Description
 
 健康分享权限：Privacy - Health Share Usage Description
 
 健康更新权限：Privacy - Health Update Usage Description
 
 运动使用权限：Privacy - Motion Usage Description
 
 音乐权限：Privacy - Music Usage Description
 
 提醒使用权限：Privacy - Reminders Usage Description
 
 Siri使用权限：Privacy - Siri Usage Description
 
 电视供应商使用权限：Privacy - TV Provider Usage Description
 
 视频用户账号使用权限：Privacy - Video Subscriber Account Usage Description
 
 文／孤独雪域（简书作者）
 原文链接：http://www.jianshu.com/p/bfbed5b7fbc8
 著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。*/
@end
