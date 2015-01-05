//
//  ViewControllerContact.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerContact.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"


@interface ViewControllerContact ()
//字典序保存联系人信息
@property(nonatomic,retain)NSMutableDictionary*contactDic;
//未排序的联系人首字母数组
//@property(nonatomic,retain)NSMutableArray*dataArray;
//数组里面保存每个获取Vcard（名片）
@property(nonatomic,retain)NSMutableArray*dataArrayDic;
//联系人首字母数组
@property(nonatomic,retain) NSArray*initials;

@end

@implementation ViewControllerContact

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ABAddressBookRef ABRef = [self getABWithGranted];
    if (ABRef) {
        [self getABContactDic:ABRef];
        [self sortAB];
        
        NSLog(@"test");
    }
}

- (ABAddressBookRef)getABWithGranted{       
    CFErrorRef abErr = NULL;
    ABAddressBookRef localAddressBook;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0){
        localAddressBook = ABAddressBookCreateWithOptions(NULL, &abErr);
        if(abErr == NULL){
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(localAddressBook, ^(bool granted, CFErrorRef requestErr) {
                if (granted) {
                }
                else{
                    NSLog(@"contacts requested error");
                    [[[UIAlertView alloc] initWithTitle:@"重要" message:@"您未允许访问通讯录，请在系统设置中开启该权限" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
                }
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else{
            NSLog(@"ab created error");
        }
    }else{
        localAddressBook = ABAddressBookCreate();
    }
    return localAddressBook;
}

- (void)getABContactDic:(ABAddressBookRef)addressBook{

    ///-2
    self.dataArrayDic = [NSMutableArray arrayWithCapacity:0];
    self.contactDic=[NSMutableDictionary dictionaryWithCapacity:0];
    
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex counts = CFArrayGetCount(allContacts);
    for (CFIndex index=0; index<counts; ++index) {
        NSMutableDictionary *dicInfoLocal = [NSMutableDictionary dictionaryWithCapacity:0];
        
        ABRecordRef contactRecord = CFArrayGetValueAtIndex(allContacts, index);
        Contact *contact = [[Contact alloc] init];
        //获取firstName
        contact.firstName = (__bridge NSString*)ABRecordCopyValue(contactRecord, kABPersonFirstNameProperty);
        if (contact.firstName==nil) {
            contact.firstName = @" ";
        }
        ///-1
        [dicInfoLocal setObject:contact.firstName forKey:@"firstName"];
        
        //获取secondName
        contact.lastName = (__bridge NSString*)ABRecordCopyValue(contactRecord, kABPersonLastNameProperty);
        if (contact.lastName==nil) {
            contact.lastName = @" ";
        }
        ///-1
        [dicInfoLocal setObject:contact.lastName forKey:@"lastName"];
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(contactRecord, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取該Label下的电话值
            contact.phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            if (k==0) {
                break;
            }
        }
        ///add-4
        if (contact.phoneNumber==nil) {
            contact.phoneNumber = @" ";
        }
        [dicInfoLocal setObject:contact.phoneNumber forKey:@"phoneNumber"];
        
         ///add
        if ([contact.firstName isEqualToString:@" "] == NO || [contact.lastName isEqualToString:@" "]) {
            [self.dataArrayDic addObject:dicInfoLocal];
        }///
        
    
    }
    
    //排序
    //建立一个字典，字典保存key是A-Z  值是数组

    
    for ( NSDictionary*dic in self.dataArrayDic) {
         NSString* str=[dic objectForKey:@"firstName"];
        //获得中文拼音首字母，如果是英文或数字则#
        
        NSString *strFirLetter = [NSString stringWithFormat:@"%c",pinyinFirstLetter([str characterAtIndex:0])];
        
        
        if ([strFirLetter isEqualToString:@"#"]) {
            //转换为小写
            strFirLetter= [self upperStr:[str substringToIndex:1]];
        }
        
        if ([[self.contactDic allKeys]containsObject:strFirLetter]) {
            //判断index字典中，是否有这个key如果有，取出值进行追加操作
            [[self.contactDic objectForKey:strFirLetter] addObject:dic];
        }else{
            NSMutableArray*tempArray=[NSMutableArray arrayWithCapacity:0];
            [tempArray addObject:dic];
            [self.contactDic setObject:tempArray forKey:strFirLetter];
        }

    }
    
    
    self.initials = [[self.contactDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
//    NSLog(@"%@", self.contactDic);
//    NSLog(@"***************%@++++++++++++++++++",self.initials);
}

#pragma  mark 字母转换大小写--6.0
-(NSString*)upperStr:(NSString*)str{

    NSString *lowerStr = [str lowercaseStringWithLocale:[NSLocale currentLocale]];
    //    NSLog(@"lowerStr: %@", lowerStr);
    return lowerStr;
    
}


/* AddressBook is already here in the self.contactList */
-(void)sortAB{
//    NSMutableDictionary*index=[NSMutableDictionary dictionaryWithCapacity:0];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    ///Return the number of sections.
    return [self.initials count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.

    
    //check the current based on the section index
    NSString *ichar = [self.initials objectAtIndex:section];
    
    // return the contacts in that ichar as an array
    
    NSArray *contactSection = [self.contactDic objectForKey:ichar];
    
    return [contactSection count];
    
}


#pragma mark - 数组中相关信息的分离

-(Contact *)getContactfromStringArray:(NSDictionary *)str{
    
    Contact *result=[Contact alloc];
    
    result.firstName = [str objectForKey: @"firstName"];
    result.lastName = [str objectForKey:@"lastName"];
    result.phoneNumber = [str objectForKey:@"phoneNumber"];
    
    return result;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellContact" forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] init];
    }
    
    ///get the initial char
    NSString *ichar = [self.initials objectAtIndex:[indexPath section]];
    
    ///get the list of contacts for that initial charactar
    NSArray *contactSection = [self.contactDic objectForKey:ichar];
    
    Contact * contact = [self getContactfromStringArray:(NSDictionary *) (contactSection[indexPath.row]) ];
    
    
    ///get the particular contacts based on that row
    
    cell.name.text = [NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName];
    cell.phoneNumber.text =contact.phoneNumber;
    
    
    return cell;
}


///
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    ///get the initial character as the section header
    NSString *ichar = [self.initials objectAtIndex:section];
    return ichar;
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"L",@"H", nil];
    return self.initials;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPat{
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


/* contact class implementation */
@implementation Contact

@end

