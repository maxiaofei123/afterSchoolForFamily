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
#import "Add_myTopic_ViewController.h"

@interface S_Interaction_ViewController ()<PassValueDelegate>

@property (weak, nonatomic) UISegmentedControl *segmentedControl;
@property(retain,nonatomic)Topic_all_ViewController *all;
@property(retain,nonatomic)Topic_myself_ViewController *myself;
@property(retain,nonatomic)Topic_touPiao_ViewController *touPiao;
@end

@implementation S_Interaction_ViewController
@synthesize all,myself,touPiao;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"家校互动";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    [self initUIsegmentedcontrol];
    __block S_Interaction_ViewController *vc=self;
    all = [[Topic_all_ViewController alloc] init];


        all.TapActionBlock = ^(NSInteger pageIndex,NSDictionary * allDic,NSDictionary * imageDic){

            Topic_content_ViewController *cotent =[[Topic_content_ViewController alloc] init];
            cotent.topicId = [allDic objectForKey:@"id"];
            cotent.topicDic = allDic;
            cotent.imageDic = imageDic;
            [vc.navigationController pushViewController:cotent animated:YES];
        };
    

        all.addTopicBlock = ^()
        {
            Add_myTopic_ViewController * addTopic =[[Add_myTopic_ViewController alloc] init];
            addTopic.delegate = self;
            [vc.navigationController pushViewController:addTopic animated:YES];
        
        };
    
    myself = [[Topic_myself_ViewController alloc] init];
    myself.myselfTopicTapActionBlock =  ^(NSInteger pageIndex,NSDictionary * allDic,NSDictionary * imageDic){
        
        Topic_content_ViewController *cotent =[[Topic_content_ViewController alloc] init];
        cotent.topicId = [allDic objectForKey:@"id"];
        cotent.topicDic = allDic;
        cotent.imageDic = imageDic;
        [vc.navigationController pushViewController:cotent animated:YES];
        
    };
    myself.addTopicBlock = ^()
    {
        Add_myTopic_ViewController * addTopic =[[Add_myTopic_ViewController alloc] init];
        addTopic.delegate = self;
        [vc.navigationController pushViewController:addTopic animated:YES];
        
    };

    touPiao = [[Topic_touPiao_ViewController alloc] init];
    
    all.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-49-64-50);
    myself.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-64-49-50);
    touPiao.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-49);
    if (Version< 8.0f) {
        touPiao.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-49);
    }
    [self.view addSubview:touPiao.view];
}

-(void)pull
{
    [all headerRefresh];
    [myself headerRefresh];
}

-(void)initUIsegmentedcontrol
{
    NSArray * arr = [[NSArray alloc] initWithObjects:@"我的投票",@"全部话题",@"我的话题", nil];
    UISegmentedControl *segmentedTemp = [[UISegmentedControl alloc]initWithItems:arr];
    self.segmentedControl = segmentedTemp;
    self.segmentedControl.frame = CGRectMake(40 ,0,Main_Screen_Width-80 , 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor colorWithRed:33/255. green:187/255. blue:252/255. alpha:1.];
//    self.segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
   [ self.segmentedControl addTarget:self action:@selector(topic:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,  [UIFont systemFontOfSize:15.],UITextAttributeFont ,[UIColor whiteColor],UITextAttributeTextShadowColor ,nil];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    [self.view addSubview:self.segmentedControl];
}

- (void)topic:(id)sender {
    
    if ([sender selectedSegmentIndex]==0) {
        
        [myself.view removeFromSuperview];
        [all.view removeFromSuperview];
        
        [self.view addSubview:touPiao.view];
    }else if([sender selectedSegmentIndex]==1){
        
        [myself.view removeFromSuperview];
        [touPiao.view removeFromSuperview];
        
        [self.view addSubview:all.view];
    }else if([sender selectedSegmentIndex]==2){
        
        [all.view removeFromSuperview];
        [touPiao.view removeFromSuperview];
        
        [self.view addSubview:myself.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
