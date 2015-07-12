//
//  S_mySelf_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-7.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "S_mySelf_ViewController.h"
#import "Myself_info_ViewController.h"
#import "Myself_count_ViewController.h"
@interface S_mySelf_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *myTableView;


@end

@implementation S_mySelf_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"个人中心";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.view.backgroundColor =[UIColor colorWithRed:62/255. green:56/255. blue:65/255. alpha:1.];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initTableView];
}

-(void)initTableView
{
    UIView * backGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-20, Main_Screen_Height-64-49-20)];
//    if (Version< 8) {
//        backGroundView.frame =CGRectMake(10, 64, Main_Screen_Width-20,Main_Screen_Height-64-59);
//    }
    backGroundView.backgroundColor =[UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    backGroundView.layer.cornerRadius = 5;
    [self.view addSubview:backGroundView];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, Main_Screen_Height/2-89, Main_Screen_Width-20,150)style:UITableViewStyleGrouped];
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.delegate =self;
    _myTableView.dataSource = self;
    _myTableView.scrollEnabled = NO;
    [_myTableView setTableFooterView:view];
    [self.view addSubview:_myTableView];
    
    // header
   UIImageView* headView = [[UIImageView alloc] initWithFrame:CGRectMake(backGroundView.frame.size.width/2-30, 30, 60, 60)];
    headView.image = [UIImage imageNamed:@"header.png"];
    //圆角设置
    headView.layer.cornerRadius = 30;
    headView.layer.masksToBounds = YES;
    [backGroundView addSubview:headView];
    
    UILabel * userLable =[[UILabel alloc] initWithFrame:CGRectMake(backGroundView.frame.size.width/2-100, 95, 200, 20)];
    userLable.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    userLable.font = [UIFont systemFontOfSize:14.];
    userLable.textAlignment = NSTextAlignmentCenter;
    [backGroundView addSubview:userLable];

}
- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section

{
    if (section==0) {
        return 8.0 ;
    }
    return 1.0 ;
}

//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
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

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 27, 27)];
    image.image = [UIImage imageNamed:[NSString stringWithFormat:@"myself_%ld",(long)indexPath.section]];
    [cell.contentView addSubview:image];
    
    UILabel * nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 100, 40)];
    nameLable.text =@"个人资料";
    nameLable.font = [UIFont systemFontOfSize:14.];
    [cell.contentView addSubview:nameLable];
    if (indexPath.section == 1) {
        nameLable.text = @"统计分析";
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    if (indexPath.section ==0) {
        Myself_info_ViewController * info = [[Myself_info_ViewController alloc] init];
        [self.navigationController pushViewController:info animated:YES];

    }else
    {
//        Myself_count_ViewController * count = [[Myself_count_ViewController alloc] init];
//        [self.navigationController pushViewController:count animated:YES];
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"此功能继续开发中。。。";
        [HUD hide:YES afterDelay:1.];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
