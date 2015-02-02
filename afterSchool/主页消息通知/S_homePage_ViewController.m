//
//  S_homePage_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-5.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "S_homePage_ViewController.h"
#import "H_login_ViewController.h"
#import "Home_detail_ViewController.h"

@interface S_homePage_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *nameArr;

}

@end

@implementation S_homePage_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor colorWithRed:62/255. green:56/255. blue:65/255. alpha:1.];
    H_login_ViewController * lo = [[H_login_ViewController alloc] init];
    [self presentViewController:lo animated:YES completion:nil];
    
    nameArr = [[NSArray alloc] initWithObjects:@"校长通知",@"班级活动",@"作业消息",@"放假通知", nil];
    [self initTableView];
}

-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-49)style:UITableViewStylePlain];
    _homeTableView.backgroundColor = [UIColor clearColor];
    _homeTableView.delegate =self;
    _homeTableView.dataSource = self;
    [self.homeTableView setTableFooterView:view];
    [self.view addSubview:_homeTableView];
}
//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }else{
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }
    [_homeTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
//消息图标
    UIImageView * notifaceImage = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 60, 60)];
    notifaceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"home_%d.png",indexPath.section+1]];
    [cell.contentView addSubview:notifaceImage];
//消息类型
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 200, 20)];
    lable.text = @"校长通知";
    lable.font = [UIFont systemFontOfSize:16.];
    [cell.contentView addSubview:lable];
    UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 20)];
    dateLable.textColor = [UIColor grayColor];
    dateLable.font = [UIFont systemFontOfSize:13.];
    dateLable.text = @"今天 12:30";
    [cell.contentView addSubview:dateLable];
    //内容
    UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, Main_Screen_Width-40, 20)];
    contentLable.text = @"明天是消防安全日";
    contentLable.font = [UIFont systemFontOfSize:14.];
    contentLable.alpha = 0.6;
    [cell.contentView addSubview:contentLable];
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    Home_detail_ViewController * detail = [[Home_detail_ViewController alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
}

- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section

{  if(section ==0 )
    return 0;
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];// Dispose of any resources that can be recreated.
}


@end
