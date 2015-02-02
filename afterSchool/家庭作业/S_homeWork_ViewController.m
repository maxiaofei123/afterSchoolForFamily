//
//  S_homeWork_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-5.
//  Copyright (c) 2015年 susu. All rights reserved.
//
#define cellY 70
#import "S_homeWork_ViewController.h"
#import "Work_type_mp3_ViewController.h"
#import "Work_type_photo_ViewController.h"
@interface S_homeWork_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * imageNameArr;
}
@property(strong ,nonatomic)UITableView * homeTableView;
@end

@implementation S_homeWork_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor colorWithRed:62/255. green:56/255. blue:65/255. alpha:1.];
    imageNameArr = [[NSArray alloc] initWithObjects:@"header.png", @"chineseteach.png", @"meishuTeacher.png", @"meishuTeacher.png", @"header.png", nil];
    [self initTableView];

}
-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20,Main_Screen_Height-49)style:UITableViewStylePlain];
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
    [cell removeFromSuperview];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }
    [_homeTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    //消息图标
    UIImageView * notifaceImage = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 60, 60)];
    notifaceImage.image = [UIImage imageNamed:[imageNameArr objectAtIndex:indexPath.section]];
    [cell.contentView addSubview:notifaceImage];

    //消息类型
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 200, 20)];
    lable.text = @"语文老师";
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
    
    //完成状态
    UIImageView * finishImage = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-100, 20, 70, 26)];
    finishImage.image = [UIImage imageNamed:@"finishi.png"];
    [cell.contentView addSubview:finishImage];
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    NSArray * arr = [[NSArray alloc] initWithObjects:@"mp3",@"photo",@"mp4",@"text", nil];
    NSString * typeStr = [arr objectAtIndex:indexPath.section];
    if ([typeStr isEqualToString:@"mp3"]) {
        Work_type_mp3_ViewController * mp3 = [[Work_type_mp3_ViewController alloc] init];
        [self.navigationController pushViewController:mp3 animated:YES];
    }else if([typeStr isEqualToString:@"photo"])
    {
        Work_type_photo_ViewController * photo = [[Work_type_photo_ViewController alloc] init];
        [self.navigationController pushViewController:photo animated:YES];
    }else if([typeStr isEqualToString:@"mp4"])
    {
    
    }else if([typeStr isEqualToString:@"text"])
    {
    
    }

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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
