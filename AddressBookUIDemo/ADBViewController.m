//
//  ADBViewController.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14-11-3.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "ADBViewController.h"

@interface ADBViewController ()

@end

@implementation ADBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = back;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -

- (void)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
