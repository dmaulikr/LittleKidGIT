//
//  ViewControllerRecent.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerRecent.h"
#import "RecentTableViewCell.h"
#import "ViewControllerChat.h"
#import "CDSessionManager.h"
#import "CDChatRoomController.h"

@interface ViewControllerRecent ()

@property (strong, nonatomic) UITableView *recentTableView;
@property (strong, nonatomic) UIImage *headImage;
@property( strong, nonatomic) UIImage *iconImage;
@property(strong, nonatomic) NSString *str;
@property NSInteger toChatUsrIndex;

@end

@implementation ViewControllerRecent

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshRecentContacts:) name:NOTIFI_GET_RECENT_MSG object:nil];
    self.headImage = [UIImage imageNamed:@"head.jpg"];
    self.iconImage = [UIImage imageNamed:@"5.png"];
//    [self startFetchUserList];
    [self waitStatus];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageview setImage:[UIImage imageNamed:@"zuijin_background"]];
    _recentTableView.backgroundView = imageview;
}

- (void)setUI{
    
}

- (void)startFetchUserList {
    AVQuery * query = [AVUser query];
    query.cachePolicy = kAVCachePolicyIgnoreCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSMutableArray *users = [NSMutableArray array];
            for (AVUser *user in objects) {
                if (![user isEqual:[AVUser currentUser]]) {
                    [users addObject:user];
                    [[CDSessionManager sharedInstance] addChatWithPeerId:user.username];
                }
            }
            
        } else {
            NSLog(@"error:%@", error);
        }
    }];
}


/* display a waiting indictor */
- (void)waitStatus{
    
}


- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)freshRecentContacts:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recentTableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return [[RuntimeStatus instance].recentUsrList count];
    NSInteger i = [[[CDSessionManager sharedInstance] chatRooms] count];
    return i;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecentTableViewCell *cell;
    cell = (RecentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellRecentMsg" forIndexPath:indexPath];
    //[[tableView tableHeaderView] setNeedsUpdateConstraints];
    if (cell == nil) {
        cell = [[RecentTableViewCell alloc] init];
    }
    NSDictionary *chatRoom = [[[CDSessionManager sharedInstance] chatRooms] objectAtIndex:indexPath.row];
    if (chatRoom == nil) {
        return cell;
    }
    CDChatRoomType type = [[chatRoom objectForKey:@"type"] integerValue];
    NSString *otherid = [chatRoom objectForKey:@"otherid"];
    NSMutableString *nameString = [[NSMutableString alloc] init];
    if (type == CDChatRoomTypeGroup) {
        [nameString appendFormat:@"group:%@", otherid];
    } else {
        [nameString appendFormat:@"%@", otherid];
    }
    
    
//    UserOther *recent1Usr = [[RuntimeStatus instance].recentUsrList objectAtIndex:[indexPath row]];
//    if (recent1Usr == nil) {
//        return cell;
//    }
    cell.nickName.text = otherid;
//    cell.headPicture.image = self.headImage;
//    cell.msgIcon.image = self.iconImage;
//    cell.share.text = @"empty";
//    ChatMessage *lastMsg = [recent1Usr.msgs lastObject];
//    if (lastMsg == nil) {
//        return cell;
//    }
    /* 根据不同类型消息显示不同 */
    NSString *msg = [chatRoom objectForKey:@"msg"];
    cell.lastMsg.text = msg;
    

    
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"最近的";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //hit the index of the row to get the recentMsg in runtimestatus
    self.toChatUsrIndex = [indexPath row];
    NSDictionary *chatRoom = [[[CDSessionManager sharedInstance] chatRooms] objectAtIndex:indexPath.row];
    CDChatRoomType type = [[chatRoom objectForKey:@"type"] integerValue];
    NSString *otherid = [chatRoom objectForKey:@"otherid"];
    CDChatRoomController *controller = [[CDChatRoomController alloc] init];
    controller.type = type;
    if (type == CDChatRoomTypeGroup) {
        AVGroup *group = [[CDSessionManager sharedInstance] joinGroup:otherid];
        controller.group = group;
        controller.otherId = otherid;
    } else {
        controller.otherId = otherid;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

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


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
//     ViewControllerChat *desVC = segue.destinationViewController;
//     
//     desVC.toChatUsrIndex = self.toChatUsrIndex;
//     
//     NSDictionary *chatRoom = [[[CDSessionManager sharedInstance] chatRooms] objectAtIndex:self.toChatUsrIndex];
//     NSString *otherid = [chatRoom objectForKey:@"otherid"];
//    
//    desVC.othreId = otherid;
//     [desVC setHidesBottomBarWhenPushed:YES];
     

 }



@end
