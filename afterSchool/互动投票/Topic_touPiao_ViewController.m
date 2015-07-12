//
//  Topic_touPiao_ViewController.m
//  afterSchool
//
//  Created by susu on 15/1/26.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Topic_touPiao_ViewController.h"
@interface Topic_touPiao_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * voteOptionArr;
    NSString * voteStr ;
    int  valueOption;
    
    NSMutableArray * allVoteArr;
    NSMutableArray * voteChooseBtArr;
    
    int  muBtType;
    int pageVote;
    
    float scrollH;
    NSMutableDictionary * zhuantaiDic;
}
@property (nonatomic , strong) UITableView * voteTableView ;
@end

@implementation Topic_touPiao_ViewController
@synthesize voteTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.view.layer.cornerRadius = 8;
    
    voteChooseBtArr = [[NSMutableArray alloc] init];
    allVoteArr = [[NSMutableArray alloc] init];
    pageVote = 0 ;
    scrollH = 0.0 ;
    zhuantaiDic = [[NSMutableDictionary alloc] init];
    [self requestList];
    [self initView];
    
}

-(void)requestList
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes?school_class_id=%@&user_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey:@"class_id"],[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        voteChooseBtArr = [[NSMutableArray alloc] init];
        allVoteArr = [[NSMutableArray alloc] init];
        NSLog(@"vote list =%@",responseObject);
        NSArray * arr = [responseObject objectForKey:@"votes"];
        NSArray * votedArr = [responseObject objectForKey:@"voted"];
        if (arr.count>0) {
            int count = arr.count ;//<=10?arr.count:10
            for(int i =0;i<count;i++) {
                NSString * state = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"state"]];
                NSString * voted = [NSString stringWithFormat:@"%@",[[votedArr objectAtIndex:i] objectForKey:@"is_voted"]];
                if ([state intValue] == 0 || [state isEqualToString:@"<null>"]) {
                    if (![voted intValue]) {
                        [allVoteArr addObject:[arr objectAtIndex:i]];
                    }
                }
            }
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"没有进行的投票";
            [HUD hide:YES afterDelay:1.];
        }
        if(allVoteArr.count>0)
        {
            NSString * voteId = [[allVoteArr objectAtIndex:0] objectForKey:@"id"];
            [self requestVoteWithId:voteId];
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"没有进行的投票";
            [HUD hide:YES afterDelay:1.];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"请检查网络链接";
        [HUD hide:YES afterDelay:1.];
    }];
    
}

-(void)requestVoteWithId:(NSString * )voteCountId
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],voteCountId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"vote  =%@",responseObject);
        voteChooseBtArr = [[NSMutableArray alloc] init];
        voteOptionArr = [responseObject objectForKey:@"result"];
        voteStr =[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"vote"] objectForKey:@"title"]] ;
        valueOption = 0 ;
        for (int i=0; i<voteOptionArr.count; i++) {
            int  XX = [[[voteOptionArr objectAtIndex:i] objectAtIndex:2] intValue];
            int  XXX = valueOption;
            valueOption = XX + XXX;
            [zhuantaiDic setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
        }
        muBtType = [[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"vote"] objectForKey:@"is_multi"]] intValue];
        
        [self.voteTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"请检查网络链接";
        [HUD hide:YES afterDelay:1.];
    }];
}


-(void)chooReleaseVote
{
    NSString * OK = @"OK";
    NSMutableArray * chooseVoteArr= [[NSMutableArray alloc] init];
    for (int i=0; i<voteChooseBtArr.count; i++) {
        UIButton * bt = [voteChooseBtArr objectAtIndex:i];
        if (bt.selected) {
            [chooseVoteArr addObject:[NSString stringWithFormat:@"%d",bt.tag]];
        }
    }
    if (chooseVoteArr.count == 0){
        OK = @"您还没有进行选择";
    }
    
    if ([OK isEqualToString:@"OK"]) {
        NSString * parStr;
        for (int i=0; i<chooseVoteArr.count; i++) {
            NSString * ss = parStr;
            NSString * s = [NSString stringWithFormat:@"&ticket[vote_option_id][]=%@",[[voteOptionArr objectAtIndex:[[chooseVoteArr objectAtIndex:i] intValue]] objectAtIndex:0]];
            parStr = [NSString stringWithFormat:@"%@%@",ss,s];
        }
        
        NSString * userId =[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager manager] init];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes/%@/choose?ticket[user_id]=%@%@",userId,[[allVoteArr objectAtIndex:pageVote] objectForKey:@"id"],userId,parStr] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"vote =%@",responseObject);
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"投票成功";
            
            [HUD hide:YES afterDelay:1.];
            
             [self requestList];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"errpr =%@",error);
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"请检查网络连接";
            [HUD hide:YES afterDelay:1.];
        }];
        
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:OK delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)chooseBt:(UIButton *)sender
{
    UIButton * bt = [voteChooseBtArr objectAtIndex:sender.tag];
    if (muBtType) {//多选
        if (bt.selected) {
            bt.selected = NO;
            [zhuantaiDic setObject:@"0" forKey:[NSString stringWithFormat:@"%d",sender.tag]];
        }else
        {
            bt.selected = YES;
            [zhuantaiDic setObject:@"1" forKey:[NSString stringWithFormat:@"%d",sender.tag]];
        }
    }else//单选
    {
        for (int i =0; i<voteChooseBtArr.count; i++) {
            UIButton * b = [voteChooseBtArr objectAtIndex:i];
            if (sender.tag ==i) {
                if (b.selected) {
                    b.selected = NO;
                    [zhuantaiDic setObject:@"0" forKey:[NSString stringWithFormat:@"%d",sender.tag]];
                }else
                {
                    b.selected = YES;
                    [zhuantaiDic setObject:@"1" forKey:[NSString stringWithFormat:@"%d",sender.tag]];
                }
            }else
            {
                b.selected = NO;
                [zhuantaiDic setObject:@"1" forKey:[NSString stringWithFormat:@"%d",sender.tag]];
            }
        }
    }
}


-(void)chooseAdd:(UIButton *)sender
{
    if (pageVote >= allVoteArr.count-1) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"已经是最后一个了";
        [HUD hide:YES afterDelay:1.];
    }else{
        pageVote ++ ;
        NSString * voteId = [[allVoteArr objectAtIndex:pageVote] objectForKey:@"id"];
        [self requestVoteWithId:voteId];
    }
}

-(void)chooseMin:(UIButton *)sender
{
    if (pageVote<1) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"已经是第一个了";
        [HUD hide:YES afterDelay:1.];
    }else
    {
        pageVote --;
        NSString * voteId = [[allVoteArr objectAtIndex:pageVote] objectForKey:@"id"];
        [self requestVoteWithId:voteId];
    }
}

-(void)initView
{
    voteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, Main_Screen_Height-59-64-40)];
    voteTableView .backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    voteTableView .delegate =self;
    voteTableView.layer.cornerRadius = 8 ;
    voteTableView .dataSource =self;
    [self.view addSubview:voteTableView];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (voteOptionArr.count + 4);
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
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.voteTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    if (voteOptionArr.count>0) {
        
        if (indexPath.row == 0 ) {//标题
            NSString * titleStr = [NSString stringWithFormat:@"投票: %@",voteStr];
            cell.textLabel.text = titleStr;
        }else if (indexPath.row == voteOptionArr.count+1)//发布投票按钮
        {
            
            UIButton * leftBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-125, 0, 35, 35)];
            [leftBt setImage:[UIImage imageNamed:@"voteLeft.png"] forState:UIControlStateNormal];
            [leftBt addTarget:self action:@selector(chooseMin:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:leftBt];
            
            UIButton * RBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-80, 0, 35, 35)];
            [RBt addTarget:self action:@selector(chooseAdd:) forControlEvents:UIControlEventTouchUpInside];
            [RBt setImage:[UIImage imageNamed:@"voteRight.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:RBt];
            
        } else if (indexPath.row == voteOptionArr.count+2)
        {
            
            UIButton * voteBt = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width-40, 60)];
            [voteBt setImage:[UIImage imageNamed:@"voteButton.png"] forState:UIControlStateNormal];
            [voteBt addTarget:self action:@selector(chooReleaseVote) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:voteBt];
            
            
        }else if(indexPath.row == voteOptionArr.count+3)
        {}
        else
        {
            UIButton * quanBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
            [quanBt setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            [quanBt setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
            quanBt.tag = indexPath.row-1 ;
            [quanBt addTarget:self action:@selector(chooseBt:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:quanBt];
            [voteChooseBtArr addObject:quanBt];
            
            int state = [[zhuantaiDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.row-1]] integerValue];
            if (state) {
                quanBt.selected = YES;
            }else
            {
                quanBt.selected = NO;
            }
            NSString * voteX = [[voteOptionArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
            float voteXHeight = [publicRequest lableSizeWidth:self.view.frame.size.width-20 content:voteX];
            
            UILabel * voteOptionLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, self.view.frame.size.width-50, voteXHeight)];
            voteOptionLable.text = voteX;
            voteOptionLable.alpha = 0.5;
            [cell.contentView addSubview:voteOptionLable];
            
            //        进度条和后面的%比
            UIImageView * bcView = [[UIImageView alloc] initWithFrame:CGRectMake(40, voteXHeight+20-3, self.view.frame.size.width-110, 9)];
            bcView.image = [UIImage imageNamed:@"pross.png"];
            [cell.contentView  addSubview:bcView];
            
            UIProgressView* progressView_=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            progressView_.frame = CGRectMake(40, voteXHeight+20, self.view.frame.size.width-110,6);
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
            progressView_.transform = transform;
            
            progressView_.backgroundColor = [UIColor clearColor ];
            progressView_.progressTintColor=[UIColor colorWithRed:76/255. green:197/255. blue:36/255. alpha:1.];
            progressView_.layer.masksToBounds = YES;
            progressView_.layer.cornerRadius = 2;
            progressView_.progress = 0;
            [cell.contentView  addSubview:progressView_];
            
            int value=  [[[voteOptionArr objectAtIndex:indexPath.row-1] objectAtIndex:2] intValue];
            
            UILabel * valueLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, voteXHeight+10, 60, 20)];
            valueLable.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
            valueLable.alpha = 0.3;
            valueLable.font = [UIFont systemFontOfSize:14.];
            [cell.contentView  addSubview:valueLable];
            
            if (valueOption > 0) {
                int s =  value/valueOption; // 取整数
                int ss =( value * 10000) / valueOption; //取余
                
                if (s <1 ) {
                    valueLable.text = [NSString stringWithFormat:@"%d.%d%@",ss/100,ss%100,@"%"];
                }else
                {
                    valueLable.text = [NSString stringWithFormat:@"%d%@",100,@"%"];
                }
                
                NSString * aa = [NSString stringWithFormat:@"%d.%d",s,ss];
                progressView_.progress = [aa floatValue];
                NSLog(@"vale=%d  voteoptineValue=%d  ss=%d %d ",value,valueOption,ss,s);
            }
            
        }
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        NSString * titleStr = [NSString stringWithFormat:@"投票: %@",voteStr];
        float height = [publicRequest lableSizeWidthFont18:self.view.frame.size.width-20 content:titleStr];
             scrollH = 120 +height+10+80*voteOptionArr.count;
        return height+10;
    }else if (indexPath.row == voteOptionArr.count+1)//发布投票按钮
    {
        return 40;
        
    }else if(indexPath.row == voteOptionArr.count+2)
    {
        return 70;
    }
    else if(indexPath.row == voteOptionArr.count+3)
    {
    }else{
        NSString * voteX = [[voteOptionArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
        float voteXHeight = [publicRequest lableSizeWidth:self.view.frame.size.width-20 content:voteX];
        return voteXHeight+40;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    if (indexPath.row == voteOptionArr.count+2) {
        [self chooReleaseVote];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
