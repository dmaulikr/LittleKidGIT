//
//  ViewControllerRecent.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerRecent.h"
#import "RecentTableViewCell.h"
#import "HTTTClient.h"

@interface ViewControllerRecent ()

@property (weak, nonatomic) IBOutlet UITableView *recentTableView;
@property (strong, nonatomic) UIImage *headImage;
@property( strong, nonatomic) UIImage *iconImage;
@property(strong, nonatomic) NSString *str;

@end

@implementation ViewControllerRecent

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshRecentContacts:) name:NOTIFI_GET_RECENT_MSG object:nil];
    self.headImage = [UIImage imageNamed:@"head.jpg"];
    self.iconImage = [UIImage imageNamed:@"5.png"];
    
    ///-2 add bg
    UIImage* img = [UIImage imageNamed:@"zuijin_bg_00179.png"];
    self.view.layer.contents = (id) img.CGImage;
    
    //get info from local
    [[RuntimeStatus instance] loadLocalInfo];
    //get info from server
    [HTTTClient sendData:nil withProtocol:GET_RECENT_MSG];
    //[HTTTClient sendData:nil withProtocol:GET_SELF_MSG];
    
    //[self waitStatus];
    
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
    NSLog(@"fresh recent");
    NSString *nameString = [notification name];
    NSString *objectString = [notification object];
    NSDictionary *dictionary = [notification userInfo];
    NSLog(@"name = %@,object = %@,userInfo = %@",nameString,objectString,[dictionary objectForKey:@"key"]);
    self.str = @"hello";
    [self.recentTableView reloadData];
    
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static int i = 1;
    RecentTableViewCell *cell;
    cell = (RecentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellRecentMsg" forIndexPath:indexPath];
    //[[tableView tableHeaderView] setNeedsUpdateConstraints];
    if (cell == nil) {
        cell = [[RecentTableViewCell alloc] init];
    }
    
    ///add-2
    //cell所在的层绘制圆角
//    cell.selectedBackgroundView.layer.cornerRadius =20;
//    cell.selectedBackgroundView.layer.masksToBounds = YES;

    
    cell.nickName.text = @"now can";
    if (self.str != nil) {
        cell.share.text = self.str;
    }
    if (i==1) {
        cell.headPicture.image = self.headImage;
        cell.msgIcon.image = self.iconImage;
    }
    else{
        cell.headPicture.image = self.iconImage;
        cell.msgIcon.image = self.headImage;
    }
    

    i = (i+1)%2;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"最近的";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSData *data = [[NSData alloc] initWithBytes:"hello world" length:11];
    [HTTTClient sendData:data withProtocol:GET_RECENT_MSG];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
