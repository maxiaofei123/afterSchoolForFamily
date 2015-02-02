//
//  S_Interaction_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-5.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "S_Interaction_ViewController.h"
#import "Topic_touPiao_ViewController.h"
#import "Topic_all_ViewController.h"
#import "Topic_myself_ViewController.h"
#import "Topic_content_ViewController.h"

@interface S_Interaction_ViewController ()

@property(retain,nonatomic)Topic_all_ViewController *all;
@property(retain,nonatomic)Topic_myself_ViewController *myself;
@property(retain,nonatomic)Topic_touPiao_ViewController *touPiao;
@end

@implementation S_Interaction_ViewController
@synthesize all,myself,touPiao;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.view.backgroundColor =[UIColor colorWithRed:62/255. green:56/255. blue:65/255. alpha:1.];
    __block S_Interaction_ViewController *vc=self;
    all = [[Topic_all_ViewController alloc] init];
    all.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"indepath.row =%ld",(long)pageIndex);
        Topic_content_ViewController * info = [[Topic_content_ViewController alloc] init];
        [vc.navigationController pushViewController:info animated:YES];

    };
    myself = [[Topic_myself_ViewController alloc] init];
    myself.myselfTopicTapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"myself _indepath.row =%ld",(long)pageIndex);
        Topic_content_ViewController * info = [[Topic_content_ViewController alloc] init];
        [vc.navigationController pushViewController:info animated:YES];
    };
    touPiao = [[Topic_touPiao_ViewController alloc] init];
    
    all.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-64-49-50);
    myself.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-64-49-50);
    touPiao.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-49-50);
    [self.view addSubview:touPiao.view];
    _segmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)topic:(id)sender {

    if([sender selectedSegmentIndex]==0){
        [all removeFromParentViewController];
        [myself removeFromParentViewController];
        [self.view addSubview:touPiao.view];
    }else if([sender selectedSegmentIndex]==1){
        [myself removeFromParentViewController];
        [touPiao removeFromParentViewController];
        [self.view addSubview:all.view];
    }else if([sender selectedSegmentIndex]==2){
        [all removeFromParentViewController];
        [touPiao removeFromParentViewController];
        [self.view addSubview:myself.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
