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

@property(nonatomic, strong) NSMutableArray *contactList;


@end

@implementation ViewControllerContact

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ABAddressBookRef ABRef = [self getABWithGranted];
    if (ABRef) {
        [self getABContactList:ABRef];
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

- (void)getABContactList:(ABAddressBookRef)addressBook{
    
    ///-2
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    self.dataArrayDic = [NSMutableArray arrayWithCapacity:0];
    self.index=[NSMutableDictionary dictionaryWithCapacity:0];
    
    self.contactList =[[NSMutableArray alloc] init];
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
         ///add
        if ([contact.firstName isEqualToString:@" "] == NO || [contact.lastName isEqualToString:@" "]) {
            [self.dataArrayDic addObject:dicInfoLocal];
        }///
        
        [self.contactList addObject:contact];
    
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
        
        if ([[self.index allKeys]containsObject:strFirLetter]) {
            //判断index字典中，是否有这个key如果有，取出值进行追加操作
            [[self.index objectForKey:strFirLetter] addObject:dic];
        }else{
            NSMutableArray*tempArray=[NSMutableArray arrayWithCapacity:0];
            [tempArray addObject:dic];
            [self.index setObject:tempArray forKey:strFirLetter];
        }

    }
    
    [self.dataArray addObjectsFromArray:[self.index allKeys]];
    
    //NSLog(@"%@", self.index);
    
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
//构建数组排序方法SEL
//NSInteger cmp(id, id, void *);
//NSInteger cmp(NSString * a, NSString* b, void * p)
//{
//    if([a compare:b] == 1){
//        return NSOrderedDescending;//(1)
//    }else
//        return  NSOrderedAscending;//(-1)
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (self.contactList == nil){
        return 0;
    }
    else{
        return [self.contactList count];
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellContact" forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] init];
    }
    cell.name.text = [NSString stringWithFormat:@"%@ %@",((Contact *)[self.contactList objectAtIndex:indexPath.row]).firstName, ((Contact *)[self.contactList objectAtIndex:indexPath.row]).lastName];
    cell.phoneNumber.text = ((Contact *)[self.contactList objectAtIndex:indexPath.row]).phoneNumber;
    
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"L",@"H", nil];
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

