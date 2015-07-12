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
#import "Work_type_mp3_ViewController.h"
#import "Work_type_photo_ViewController.h"
#import "Work_type_text_ViewController.h"
#import "Finish_MP3_ViewController.h"
#import "Finish_Photo_ViewController.h"

@interface S_homePage_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIViewPassValueDelegate,loginDelegate>
{
    NSMutableArray * workArr;
    NSArray * topArr;
    int pageFlag;
}

@end

@implementation S_homePage_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"首页";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.view.backgroundColor =[UIColor colorWithRed:62/255. green:56/255. blue:65/255. alpha:1.];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    H_login_ViewController * lo = [[H_login_ViewController alloc] init];
    lo.delegate = self;
    [self presentViewController:lo animated:YES completion:nil];

    workArr = [[NSMutableArray alloc] init];

}
-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20,Main_Screen_Height-64-49)style:UITableViewStylePlain];
    _homeTableView.backgroundColor = [UIColor clearColor];
    _homeTableView.delegate =self;
    _homeTableView.dataSource = self;
    [_homeTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [_homeTableView addFooterWithTarget:self action:@selector(footerRefresh)];
    [self.homeTableView setTableFooterView:view];
    [self.view addSubview:_homeTableView];
    [self requestTopMessege];
    [_homeTableView headerBeginRefreshing];
}

-(void)headerRefresh
{
    pageFlag = 1 ;
    [self requestHomeWork:pageFlag];
}

-(void)footerRefresh
{
    [self requestHomeWork:++pageFlag];
}

-(void)requestTopMessege
{
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"TOP",@"message_type",nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@/user_messages",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]]parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        topArr = [responseObject objectForKey:@"user_messages"];
        
        [_homeTableView reloadData];
//        NSLog(@"res messege list = %@",responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [_homeTableView footerEndRefreshing];
         [_homeTableView headerEndRefreshing];
         NSLog(@"erro =%@",error);
     }];
}

-(void)requestHomeWork:(int)pageIndex
{
    [self requestTopMessege];
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageIndex],@"page",@"NOTOP",@"message_type",nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@/user_messages",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]]parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray * arr = [responseObject objectForKey:@"user_messages"];
        if (pageFlag == 1) {
            [workArr removeAllObjects];
            if (topArr.count>0) {
                for (int i=0; i<topArr.count; i++) {
                    [workArr addObject:[topArr objectAtIndex:i]];
                }
            }
        }
        [workArr addObjectsFromArray:arr];
        [_homeTableView footerEndRefreshing];
        [_homeTableView headerEndRefreshing];
        [_homeTableView reloadData];
//        NSLog(@"res messege list = %@",workArr);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [_homeTableView footerEndRefreshing];
         [_homeTableView headerEndRefreshing];
         NSLog(@"erro =%@",error);
     }];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [workArr count];
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
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
        
    }
    [_homeTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    
    NSDictionary * workDic = [workArr objectAtIndex:indexPath.section];
    //消息图标
    
    UIImageView * notifaceImage = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 60, 60)];
    //圆角设置
    notifaceImage.layer.cornerRadius = 30;
    notifaceImage.layer.masksToBounds = YES;

   
   NSString * type =  [[workArr objectAtIndex:indexPath.section] objectForKey:@"message_type"];
    if ([type isEqualToString:@"user_message"]) {
         notifaceImage.image = [UIImage imageNamed:@"header.png"];
    }else if ([type isEqualToString:@"work_paper"]) {
         notifaceImage.image = [UIImage imageNamed:@"home_3.png"];
    }else if ([type isEqualToString:@"TOP"]) {
         notifaceImage.image = [UIImage imageNamed:@"home_1.png"];
    }else
    {
        notifaceImage.image = [UIImage imageNamed:@"home_2.png"];
    }
    
    [cell.contentView addSubview:notifaceImage];
    
    
    //消息类型
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 200, 20)];
    lable.text = [workDic objectForKey:@"topic"];
    lable.font = [UIFont systemFontOfSize:16.];
    [cell.contentView addSubview:lable];
    UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 20)];
    dateLable.textColor = [UIColor grayColor];
    dateLable.font = [UIFont systemFontOfSize:13.];
    dateLable.text = [[workDic objectForKey:@"updated_at"] substringToIndex:10];
    [cell.contentView addSubview:dateLable];
    
    //内容
    UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 67, Main_Screen_Width-40, 40)];
    contentLable.text = [workDic objectForKey:@"body"];
    contentLable.font = [UIFont systemFontOfSize:14.];
    contentLable.lineBreakMode = NSLineBreakByWordWrapping;
    contentLable.numberOfLines = 0;
    contentLable.alpha = 0.6;
    [cell.contentView addSubview:contentLable];
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    NSString * messageType = [[workArr objectAtIndex:indexPath.section] objectForKey:@"message_type"];
    NSString * state = [[workArr objectAtIndex:indexPath.section] objectForKey:@"home_work_state"];
    NSString * typeStr = [[workArr objectAtIndex:indexPath.section] objectForKey:@"type"];
    if ([typeStr isEqualToString:@"sound"]) {//音频类型
            Work_type_mp3_ViewController * mp3 = [[Work_type_mp3_ViewController alloc] init];
            mp3.delegate = self;
            mp3.mp3WorkId = [[workArr objectAtIndex:indexPath.section]objectForKey:@"id"];
            [self.navigationController pushViewController:mp3 animated:YES];
    }else if([typeStr isEqualToString:@"image"]||[typeStr isEqualToString:@"video"])
    {
            Work_type_photo_ViewController * photo = [[Work_type_photo_ViewController alloc] init];
            photo.type = typeStr;
            photo.delegate = self;
            photo.photoWorkId = [[workArr objectAtIndex:indexPath.section]objectForKey:@"id"];
            [self.navigationController pushViewController:photo animated:YES];
        
    }else if([typeStr isEqualToString:@"text"])//文字类型
    {
        Work_type_text_ViewController * text = [[Work_type_text_ViewController alloc] init];
        text.delegate = self;
        text.textWorkId = [[workArr objectAtIndex:indexPath.section]objectForKey:@"id"];
        [self.navigationController pushViewController:text animated:YES];
        
    }
    if([messageType isEqualToString:@"work_paper"])
    {}else
    {
        Home_detail_ViewController * detail = [[Home_detail_ViewController alloc] init];
        detail.messageDic = [workArr objectAtIndex:indexPath.section];
        [self.navigationController pushViewController:detail animated:YES];
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
