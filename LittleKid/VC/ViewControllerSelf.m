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

@interface ViewControllerSelf ()

@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *howold;

@end

@implementation ViewControllerSelf

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshSelfMsg:) name:NOTIFI_GET_SELF_MSG object:nil];
}

- (void)setUI{
//    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
//    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.image = [RuntimeStatus instance].userInfo.headImage;
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"haha.png"]];
    
    self.nickname.text = [RuntimeStatus instance].userInfo.nickname;
    self.gender.text = [RuntimeStatus instance].userInfo.gender;
    NSTimeInterval dateDiff = [[RuntimeStatus instance].userInfo.birthday timeIntervalSinceNow];
    int age=0-trunc(dateDiff/(60*60*24))/365;
    NSString *str = [[NSString alloc]initWithFormat:@"%d岁",age ];
    self.howold.text = str;
    self.level.text = [self getGradeForNumber:[RuntimeStatus instance].userInfo.score];
    
}
-(NSString *)getGradeForNumber:(NSNumber *)number//0-12
{
    NSInteger i = number.integerValue;
    i = i/10000;
    switch (i) {
        case 0:
            return @"九级棋士";
        case 1:
            return @"八级棋士";
        case 2:
            return @"七级棋士";
        case 3:
            return @"六级棋士";
        case 4:
            return @"五级棋士";
        case 5:
            return @"四级棋士";
        case 6:
            return @"三级棋士";
        case 7:
            return @"二级棋士";
        case 8:
            return @"一级棋士";
        case 9:
            return @"三级大师";
        case 10:
            return @"二级大师";
        case 11:
            return @"一级大师";
        case 12:
            return @"特级大师";
        default:
            return nil;
    }
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
    if ([AVUser currentUser]) {
        [AVUser logOut];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController* nextController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
         [self presentViewController:nextController animated:YES completion:nil];
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
 // Pass the selected object to the new view controller.
 }



- (IBAction)logout:(id)sender {
    [AVUser logOut];
}
@end
