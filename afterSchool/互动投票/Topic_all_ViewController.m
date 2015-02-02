//
//  Topic_all_ViewController.m
//  afterSchool
//
//  Created by susu on 15/1/26.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Topic_all_ViewController.h"

@interface Topic_all_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(strong ,nonatomic)UITableView * topicTableView;
@end

@implementation Topic_all_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.view.layer.cornerRadius = 8;
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTableView
{
    UIImageView * logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 77, 70)];
    logoView.image = [UIImage imageNamed:@"topicLogo.png"];
    [self.view addSubview:logoView];
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 200, 20)];
    titleLable.text =@"全部话题";
    titleLable.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:titleLable];
    
    UIButton * addBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width -70, 25, 30, 30)];
    [addBt setImage:[UIImage imageNamed:@"addTopic.png"] forState:UIControlStateNormal];
    [addBt addTarget:self action:@selector(addTopic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBt];
    
    _topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, Main_Screen_Width-20,  Main_Screen_Height-49-40-64-100)];
    _topicTableView.backgroundColor = [UIColor clearColor];
    _topicTableView.delegate =self;
    _topicTableView.dataSource = self;
    [self.view addSubview:_topicTableView];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
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
    
    [_topicTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    UIImageView * meImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 25, 25)];
    meImage.image = [UIImage imageNamed:@"messegeLogo.png"];
    [cell.contentView addSubview:meImage];
    
    UILabel * contenLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, self.view.frame.size.width -130 , 30)];
    contenLable.font = [UIFont systemFontOfSize:14.];
    contenLable.text = @"全部话题全部话题全部话题全部话题全部话题全部话题";
    [cell.contentView addSubview:contenLable];
    
    UILabel * commentlable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width -80, 5, 80, 30)];
    commentlable.text =@"评论321次";
    commentlable.font = [UIFont systemFontOfSize:14.];
    commentlable.textColor = [UIColor grayColor];
    [cell.contentView addSubview:commentlable];
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

-(void)addTopic:(UIButton *)sender
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    if (self.TapActionBlock) {
        self.TapActionBlock(indexPath.row);
    }
}
@end
