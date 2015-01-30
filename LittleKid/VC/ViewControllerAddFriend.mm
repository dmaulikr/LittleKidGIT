//
//  ViewControllerAddFriend.m
//  LittleKid
//
//  Created by 李允恺 on 1/24/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import "ViewControllerAddFriend.h"
#import "ZXingWidgetController.h"
#import "MultiFormatReader.h"
#import "QREncoder.h"
#import "DataMatrix.h"
#import "TableViewControllerFriendConfirm.h"
#import "CDSessionManager.h"

@interface ViewControllerAddFriend () <ZXingDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *cellNumberTextField;
@property(strong, nonatomic) NSDictionary *toAddFriendInfoDict;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeSelfImgView;

@property (weak, atomic) NSString * peerID;

@end

@implementation ViewControllerAddFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSelfBarCode];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAddFriendRequest:) name:NOTIFICATION_ADD_FRIEND_UPDATED object:nil]; //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAddFriendRequestAck:) name:NOTIFICATION_ADD_FRIEND_ACK_UPDATED object:nil]; //注册通知
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addSelfBarCode{
    //the qrcode is square. now we make it 250 pixels wide
    int qrcodeImageDimension = 250;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[AVUser currentUser].username forKey:@"uid"];
    [dict setObject:@"nickname" forKey:@"nickname"];
    [dict setObject:@"otherinfo" forKey:@"otherinfo"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //first encode the string into a matrix of bools, TRUE for black dot and FALSE for white. Let the encoder decide the error correction level and version
    DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:json];
    
    //then render the matrix
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    self.barcodeSelfImgView.image = qrcodeImage;
}

- (IBAction)editEndToFindFriend:(id)sender {
    NSString *inputStr = [[NSString alloc] initWithString:((UITextField *)sender).text];
    if (inputStr.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"输入不合法" message:@"提示原因" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil , nil] show];
        return;
    }
    //在服务器查找该UID或昵称,异步，在里面回调赋值self.toAddFriendInfoDict
    [self queryWithUID_NICKNAME:inputStr];
    //等待状态动画
    [self waitStatus];
    
    [[CDSessionManager sharedInstance] sendAddFriendRequest:inputStr];
    NSLog(@"send add friend request to: %@",inputStr);
}

-(void)waitStatus{
    
}

- (void)queryWithUID_NICKNAME:(NSString *)uid_nickName{

}

- (void)receiveAddFriendRequest:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    dict = [dict objectForKey:@"cmd"];
    self.peerID = [dict objectForKey:@"fromid"];
    NSString *str = [dict objectForKey:@"cmd_type"];
    if ([str isEqualToString:ADD_FRIEND_CMD] ) {
        [[[UIAlertView alloc] initWithTitle:@"请求加好友" message:@"是否同意" delegate:(self) cancelButtonTitle:@"否" otherButtonTitles:@"是", nil] show];
    }
}

- (void)receiveAddFriendRequestAck:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    dict = [dict objectForKey:@"cmd"];
    NSString *str = [dict objectForKey:@"cmd_type"];
    if ([str isEqualToString:ADD_FRIEND_CMD_ACK] ) {
        str = [dict objectForKey:@"ack_value"];
        if ([str isEqualToString:@"OK"])
        {
            [[AVUser currentUser] follow:self.peerID andCallback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //TODO
                    NSLog(@"Add friend %@ sucaessful", self.peerID);
                } else {
                    NSLog(@"Add friend %@ error %@", self.peerID, error);
                }
            }];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( indexPath.row == 2 ) {//点击扫一扫cell
        [self addScan];
    }
    if (indexPath.row == 1) {//通讯录，mainstoryboard已处理跳转，直接返回
        return;
    }
}

- (void)addScan {
    ZXingWidgetController *widController =
    [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc ] init];
    MultiFormatReader* reader = [[MultiFormatReader alloc] init];
    [readers addObject:reader];
    widController.readers = readers;
    [self presentViewController:widController animated:YES completion:^{ }];
}

#pragma mark - ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, result);//假定二维码是由用户昵称，ID等信息构成的json字串
    [self dismissViewControllerAnimated:NO completion:^{
        NSDictionary *dict = nil;
        NSError *error = nil;
        NSLog(@"result: %@",result);
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (dict) {
            self.toAddFriendInfoDict = [[NSDictionary alloc] initWithDictionary:dict];
            [self performSegueWithIdentifier:@"segueToFriendConfirm" sender:self];
        }
    }];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissViewControllerAnimated:NO completion:^{ }];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier compare:@"segueToFriendConfirm"] == NSOrderedSame ) {
        TableViewControllerFriendConfirm *destVC = segue.destinationViewController;
        destVC.toAddFriendInfoDict = [[NSDictionary alloc] initWithDictionary:self.toAddFriendInfoDict];
    }

}

#pragma mark -- UITextField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- UIAlertView Delegate Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [[CDSessionManager sharedInstance] sendAddFriendRequestAck:@"OK" toPeerId:self.peerID];
    }
    else {
        [[CDSessionManager sharedInstance] sendAddFriendRequestAck:@"NO" toPeerId:self.peerID];
    }
}


@end
