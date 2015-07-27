//
//  ViewController.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15-7-23.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "ViewController.h"
#import "NHDetailViewController.h"
#import "NHDrawerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"NetEasy Policy Test";
    CGRect infoRect = CGRectMake(100, 100, 100, 50);
    UIButton *t_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    t_btn.frame = infoRect;
    [t_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [t_btn setTitle:@"loadTest" forState:UIControlStateNormal];
    [t_btn addTarget:self action:@selector(loadTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:t_btn];
    
    infoRect.origin.y += 100;
    t_btn =[UIButton buttonWithType:UIButtonTypeCustom];
    t_btn.frame = infoRect;
    [t_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [t_btn setTitle:@"Drawer" forState:UIControlStateNormal];
    [t_btn addTarget:self action:@selector(drawerView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:t_btn];
}
-(void)loadTest{
    NHDetailViewController *detailVCR = [[NHDetailViewController alloc] init];
    [self.navigationController pushViewController:detailVCR animated:true];
}
-(void)drawerView{
    NHDrawerView *drawerView = [[NHDrawerView alloc] init];
    [self.navigationController pushViewController:drawerView animated:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
