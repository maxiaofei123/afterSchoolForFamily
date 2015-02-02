//
//  Topic_content_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-13.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Topic_content_ViewController.h"

@interface Topic_content_ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(strong ,nonatomic)UITableView * topicTableView;

@end

@implementation Topic_content_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"内容";
    [self initTableView];
}

-(void)initTableView
{
    UIView * backGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-20, Main_Screen_Height-64-49-20)];
    backGroundView.backgroundColor =[UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    backGroundView.layer.cornerRadius = 8;
    [self.view addSubview:backGroundView];
    
    _topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, Main_Screen_Width-20, Main_Screen_Height-49-50)style:UITableViewStylePlain];
    _topicTableView.backgroundColor = [UIColor clearColor];
    _topicTableView.delegate =self;
    _topicTableView.dataSource = self;
    [backGroundView addSubview:_topicTableView];
    
    UIView * topicView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, backGroundView.frame.size.width-20, 50)];
    topicView.backgroundColor = [UIColor colorWithRed:236/266. green:236/255. blue:236/255. alpha:1.];
    [backGroundView addSubview:topicView];
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, backGroundView.frame.size.width-20-60, 40)];
    titleLable.text = @"小明最近考试退步了";
    [topicView addSubview:titleLable];
}
//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    [cell removeFromSuperview];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }
    [_topicTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
