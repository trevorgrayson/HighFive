//
//  InviteWallController.m
//  HighFive
//
//  Created by Trevor Grayson on 2/20/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "InviteWallController.h"
#import "HighFive-Swift.h"

@interface InviteWallController ()

@end

@implementation InviteWallController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)linkToRegister:(id)sender {
    [[UIApplication sharedApplication] openURL: [SlapRouter baseUrl]];
}

@end
