//
//  ViewControllerSelf.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerSelf.h"
#import "CDCommon.h"
#import "RuntimeStatus.h"
#import "CDSessionManager.h"
#import "RuntimeStatus.h"

@interface ViewControllerSelf ()

@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *howold;
@property (weak, nonatomic) IBOutlet UILabel *nowScore;

@end

@implementation ViewControllerSelf

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshSelfMsg:) name:NOTIFI_GET_SELF_MSG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadview:) name:NOTIFI_INFO_UPDATE object:nil];
    
}

- (void)setUI{
//    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
//    self.profileImageView.clipsToBounds = YES;
    if ([RuntimeStatus instance].userInfo.headImage != nil) {
        self.profileImageView.image = [[RuntimeStatus instance] circleImage:[RuntimeStatus instance].userInfo.headImage withParam:0];
    }
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"haha.png"]];
    
    self.nickname.text = [RuntimeStatus instance].userInfo.nickname;
    self.gender.text = [RuntimeStatus instance].userInfo.gender;
    NSTimeInterval dateDiff = [[RuntimeStatus instance].userInfo.birthday timeIntervalSinceNow];
    int age=0-trunc(dateDiff/(60*60*24))/365;
    NSString *str = [[NSString alloc]initWithFormat:@"%d岁",age ];
    self.howold.text = str;
    int score = [[RuntimeStatus instance].userInfo.score intValue];
//    int needscore = 10000 - score%10000;
    self.nowScore.text = [NSString stringWithFormat:@"%d",score];
    self.level.text = [[RuntimeStatus instance]getLevelString:[RuntimeStatus instance].userInfo.score];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)freshSelfMsg:(NSNotification *)notify{
    NSLog(@"I also get the newRemoteMsg");
}


- (IBAction)logoutBtn:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定要退出？" message:nil delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:@"取消", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([AVUser currentUser]) {
            [AVUser logOut];
 //           [[CDSessionManager sharedInstance] clearData];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UIViewController* nextController = [storyboard instantiateViewControllerWithIdentifier:@"mainNavigationcontroller"];
            
            [self presentViewController:nextController animated:YES completion:nil];
        }
    }
}
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
////#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}


// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
// UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellShare" forIndexPath:indexPath];
 
 // Configure the cell...
 
// return cell;
// }


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


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
//     ViewControllerImpInfo *destVC = segue.destinationViewController;
//     destVC.hidesBottomBarWhenPushed = YES;
     
 // Pass the selected object to the new view controller.
 }

- (void) reloadview:(NSNotification *)notify
{
    [self setUI];
}

- (IBAction)logout:(id)sender {
    [AVUser logOut];
}
@end
