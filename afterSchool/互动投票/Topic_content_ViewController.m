//
//  Topic_content_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-13.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Topic_content_ViewController.h"
#import "cyCleScroll.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface Topic_content_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
    UIScrollView * scrollView;
    int pageFlag;
    UITextView * contentText;
    NSMutableArray * commentArr;
    NSMutableArray *profeilArr ;
    int page;
    UIPageControl *pageControl;
}
@property (nonatomic , retain) cyCleScroll *mainScorllView;
@property(nonatomic,strong)UITableView * topicTableView;

@end

@implementation Topic_content_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"内容";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    commentArr = [[NSMutableArray alloc] init];
    profeilArr = [[NSMutableArray alloc] init];
    [self initTableView];
    [self requestCommment:1];
    
//    NSLog(@" imagedic =%@",self.imageDic);
}

-(void)initTableView
{
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height -64-59)];
    scrollView.layer.cornerRadius = 8 ;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(Main_Screen_Width-20, Main_Screen_Height -64-59);
    scrollView.userInteractionEnabled = YES;
    [self.view addSubview:scrollView];
    UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiden)];
    [scrollView addGestureRecognizer:pass1];
    //
    //    float height = 0 ;
    //    height = [publicRequest lableSizeWidthFont16:Main_Screen_Width-100 content:[self.topicDic objectForKey:@"body"]];
    //
    //    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, height+20)];
    //    titleView.backgroundColor = [UIColor colorWithRed:233/255. green:233/255. blue:233/255. alpha:1.];
    //    [scrollView addSubview:titleView];
    //
    //    UIImageView * titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    //    titleImage.image = [UIImage imageNamed:@"messegeLogo.png"];
    //    [titleView addSubview:titleImage];
    //
    //    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, Main_Screen_Width-40-60, height)];
    //    titleLable.text = [self.topicDic objectForKey:@"body"];
    //    titleLable.font = [UIFont systemFontOfSize:16.];
    //    titleLable.lineBreakMode = NSLineBreakByWordWrapping;
    //    titleLable.numberOfLines = 0;
    //    [titleView addSubview:titleLable];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    _topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20,Main_Screen_Height-59-64-60)style:UITableViewStylePlain];
    _topicTableView.backgroundColor = [UIColor clearColor];
    _topicTableView.delegate =self;
    _topicTableView.dataSource = self;
    //    [_topicTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    //    [_topicTableView addFooterWithTarget:self action:@selector(footerRefresh)];
    [_topicTableView setTableFooterView:view];
    [scrollView addSubview:_topicTableView];
    //    [_topicTableView headerBeginRefreshing];
    
    contentText = [[UITextView alloc] initWithFrame:CGRectMake(10,scrollView.frame.size.height -55, Main_Screen_Width-40-40, 50)];
    contentText.text = @"输入您想要回复的内容";
    contentText.layer.borderColor =  [[UIColor colorWithRed:210/255. green:210/255. blue:210/255. alpha:1.] CGColor];
    contentText.layer.borderWidth = 1.0f;
    contentText.delegate = self ;
    contentText.font = [UIFont systemFontOfSize:16.];
    [scrollView addSubview:contentText];
    
    
    UIButton * send = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-65,scrollView.frame.size.height-40,40, 15)];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [send addTarget:self action:@selector(commitTopic) forControlEvents:UIControlEventTouchUpInside];
    send.tag = 101;
    [scrollView addSubview:send];
    
    
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(2, 5, 50, 25);
    [btn addTarget:self action:@selector(hiden) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
    [topView setItems:buttonsArray];
    [contentText setInputAccessoryView:topView];
    
}

-(void)requestCommment:(int)pageIndex
{
    //    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageIndex],@"page", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/posts/%@",self.topicId]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSArray * arr = [responseObject objectForKey:@"comments"];
        NSLog(@"requestCommment = %@",responseObject);
        //        if (pageFlag == 1) {
        [commentArr removeAllObjects];
        [profeilArr removeAllObjects];
        //        }
        [commentArr addObjectsFromArray:arr];
        [profeilArr addObjectsFromArray:[responseObject objectForKey:@"comment_profiles"]];
        //        [_topicTableView footerEndRefreshing];
        //        [_topicTableView headerEndRefreshing];
        [_topicTableView reloadData];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //         [_topicTableView footerEndRefreshing];
         //         [_topicTableView headerEndRefreshing];
         NSLog(@"erro =%@",error);
     }];
}

-(void)commitTopic
{
    
    NSString * str2 ;
    NSString * ok = @"请输入消息内容";
    
    if (!([contentText.text isEqualToString:@"输入您想要回复的内容"])) {
        if (contentText.text.length>0) {
            str2 = [NSString stringWithFormat:@"%@",contentText.text];
        }
    }
    
    if (str2.length > 0) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"正在提交...";
        
        NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"comment[body]",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],@"comment[user_id]" ,self.topicId,@"comment[post_id]",nil];
        AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/posts/%@/comments",self.topicId] parameters:pa success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"comment ＝%@",responseObject);
            HUD.labelText = @"提交成功。。。";
            [HUD hide:YES afterDelay:1.];
            
            //            [_topicTableView headerBeginRefreshing];
            [self requestCommment:1];
            contentText.text = @"";
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            HUD.labelText = @"请求超时";
            [HUD hide:YES afterDelay:1.];
        }];
        
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:ok delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)tapImage
{
    
    NSArray * urlArr = [self.imageDic objectForKey:@"urls"];
    int count = urlArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [urlArr[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        //        photo.srcImageView = imageViewArr[i]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    
    // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
    
    //放大图片
}
-(void)handleGer:(int)index{
    NSArray * urlArr = [self.imageDic objectForKey:@"urls"];
    int count = urlArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [urlArr[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        //        photo.srcImageView = imageViewArr[i]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index;
    
    // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
    
    //放大图片
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ( [contentText.text isEqualToString:@"输入您想要回复的内容"]) {
        contentText.text = @"";
    }
    if (textView == contentText)
        [scrollView setContentOffset:CGPointMake(0, 190) animated:YES];
}

-(void)hiden
{
    [contentText resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)headerRefresh
{
    pageFlag = 1 ;
    [self requestCommment:pageFlag];
}

-(void)footerRefresh
{
    [self requestCommment:++pageFlag];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([commentArr count] >0) {
        return [commentArr count]+1;
    }
    return 1;
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
        
    }
    [self.topicTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    if(indexPath.row == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:233/255. green:233/255. blue:233/255. alpha:1.];
        UILabel * timeLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
        timeLable.text =[[self.topicDic objectForKey:@"updated_at"] substringToIndex:10];
        [cell.contentView addSubview:timeLable];
        
        int imageH =0 ;
        NSArray * urlArr = [self.imageDic objectForKey:@"urls"];
//        NSLog(@"urlar =%@",urlArr);
        if (urlArr.count>0) {
            imageH = 155;
            if (urlArr.count > 1) {
                NSMutableArray *viewsArray = [@[] mutableCopy];
                for (int i=0; i<urlArr.count; i++) {
                    UIImage *image;
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlArr[i]]];
                    image = [UIImage imageWithData:data];
                    int imageWith = (image.size.width * 150)/ image.size.height;
                    if (imageWith > Main_Screen_Width-40) {
                        imageWith = Main_Screen_Width-40;
                    }
                    
                    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake((Main_Screen_Width-40)/2-(imageWith/2), 0, imageWith, 150)];
                    [imageView setImageWithURL:urlArr[i] placeholderImage:[UIImage imageNamed:@"introduce_zhanwei.png"]];
                    imageView.userInteractionEnabled = YES ;
                    [viewsArray addObject:imageView];
                }
                
                self.mainScorllView = [[cyCleScroll alloc] initWithFrame:CGRectMake(10, 25, Main_Screen_Width-40, 150) animationDuration:-1];
                self.mainScorllView.backgroundColor = [[UIColor colorWithRed:233/255. green:233/255. blue:233/255. alpha:1.] colorWithAlphaComponent:1.];
                self.mainScorllView.totalPagesCount = ^NSInteger(void){
                    return viewsArray.count;
                };
                self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                    return viewsArray[pageIndex];
                };
                self.mainScorllView.onePage =  ^(NSInteger pageIndex)
                {
                    page = pageIndex ;
                    pageControl.currentPage= page;
                    
                };
                self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
                    [self handleGer:pageIndex];
                };
                [cell.contentView  addSubview:self.mainScorllView];
                [self.mainScorllView firstPage:0];
                
                pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(scrollView.frame.size.width/2-130, 165, 260, 10)];
                pageControl.backgroundColor=[UIColor clearColor];
                pageControl.currentPage=0;
                pageControl.numberOfPages= urlArr.count;
                pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
                [cell.contentView addSubview:pageControl];
                
                
            }else
            {
                
                NSString * url = [urlArr objectAtIndex:0];
                UIImage *image;
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlArr[0]]];
                image = [UIImage imageWithData:data];
                int imageWith = (image.size.width * 150)/ image.size.height;
                if (imageWith > Main_Screen_Width-40) {
                    imageWith = Main_Screen_Width-40;
                }
                UIImageView * topImage = [[UIImageView alloc] initWithFrame:CGRectMake((Main_Screen_Width-20)/2-(imageWith/2), 25, imageWith, 150)];
                topImage.userInteractionEnabled = YES ;
                [topImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
                [cell.contentView  addSubview:topImage];
                
                UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage)];
                [topImage addGestureRecognizer:pass1];
                
            }
        }
        
        float titltheight = 0 ;
        titltheight = [publicRequest lableSizeWidthFont16:Main_Screen_Width-100 content:[self.topicDic objectForKey:@"body"]];
        NSLog(@"height =%f",titltheight);
        if (titltheight) {
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 25+imageH, Main_Screen_Width-40-60, titltheight)];
            titleLable.text = [self.topicDic objectForKey:@"body"];
            titleLable.font = [UIFont systemFontOfSize:16.];
            titleLable.lineBreakMode = NSLineBreakByWordWrapping;
            titleLable.numberOfLines = 0;
            [cell.contentView addSubview:titleLable];
        }
        UIImageView * titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,25+imageH, 30, 30)];
        titleImage.image = [UIImage imageNamed:@"messegeLogo.png"];
        [cell.contentView addSubview:titleImage];
        
        
    }else {
        
        if (commentArr.count >0) {
            
            int userId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] intValue];
            int user_id = [[[commentArr objectAtIndex:indexPath.row-1] objectForKey:@"user_id"] intValue];
            
            
            UIImageView * headView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
            
            [headView setImageWithURL:[[profeilArr objectAtIndex:indexPath.row-1] objectForKey:@"avatar"] placeholderImage:nil];
            if (headView.image ==nil) {
                headView.image = [UIImage imageNamed:@"header.png"];
            }
            [cell.contentView addSubview:headView];
            //圆角设置
            headView.layer.cornerRadius = 30;
            headView.layer.masksToBounds = YES;
            
            UILabel * nameLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 100, 20)];
            nameLable.text = [[profeilArr objectAtIndex:indexPath.row-1] objectForKey:@"nickname"];
            nameLable.font = [UIFont systemFontOfSize:13.];
            [cell.contentView addSubview:nameLable];
            
            UIView * textView;
            if (user_id == userId) {//you bian
                textView = [self bubbleView:[[commentArr objectAtIndex:indexPath.row-1] objectForKey:@"body"] imageName:@"0"];
                headView.frame = CGRectMake(Main_Screen_Width-20-70, 5, 60, 60);
                nameLable.frame = CGRectMake(20,5 , Main_Screen_Width-30-80, 20);
                nameLable.textAlignment = NSTextAlignmentRight;
            }else
            {
                textView = [self bubbleView:[[commentArr objectAtIndex:indexPath.row-1] objectForKey:@"body"] imageName:@"1"];
            }
            [cell.contentView addSubview:textView];
        }
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        int imageH=0;
        NSArray * urlArr = [self.imageDic objectForKey:@"urls"];
        if (urlArr.count>0) {
            imageH = 155;
        }
        float height = 0 ;
        height = [publicRequest lableSizeWidthFont16:Main_Screen_Width-100 content:[self.topicDic objectForKey:@"body"]];
     
        return 40 + imageH +height;
    }else{
        float height =  [publicRequest lableSizeWidth:Main_Screen_Width-140 content:[[commentArr objectAtIndex:indexPath.row-1] objectForKey:@"body"] ];
        float h = height+60>90?(height+60):90;
        return h;
    }
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    [self hiden];
}

- (UIView*)bubbleView:(NSString *)text  imageName:(NSString *)name

{
    UIView *returnView= [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImage*bubble;
    
    returnView.backgroundColor= [UIColor clearColor];//ImageBubble@2x~iphone
    
    if([name isEqualToString:@"1"]){//bubble-default-outgoing@2x
        
        bubble = [[UIImage imageNamed:@"commentOther.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        
    }else{
        
        bubble = [[UIImage imageNamed:@"commentMy.png"]stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
    }
    
    UIImageView *bubbleImageView= [[UIImageView alloc] initWithImage:bubble];
    
    UIFont *font= [UIFont systemFontOfSize:14];
    
    CGSize size= [text sizeWithFont:font constrainedToSize:CGSizeMake(Main_Screen_Width-80-40,1000.0f)lineBreakMode: NSLineBreakByWordWrapping];
    
    CGSize new1= [text sizeWithFont:font constrainedToSize:CGSizeMake(Main_Screen_Width-80-40,size.height)lineBreakMode: NSLineBreakByWordWrapping];
    
    UILabel*bubbleText;
    
    if([name isEqualToString:@"1"]){
        bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(12.0f,5.0f,new1.width+10,new1.height+10)];
        
    }else{
        bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(5.0f,5.0f,new1.width+10,new1.height+10)];
        
    }
    
    bubbleText.backgroundColor= [UIColor clearColor];
    
    bubbleText.font= font;
    
    bubbleText.numberOfLines= 0;
    
    bubbleText.lineBreakMode= NSLineBreakByWordWrapping;
    
    bubbleText.text= text;
    
    bubbleImageView.frame= CGRectMake(0.0f,0.0f,new1.width+ 20, new1.height+20.0f);
    
    if([name isEqualToString:@"1"]){
        
        returnView.frame= CGRectMake(75.0f,25.0f,new1.width+ 20, new1.height+20.0f);
        
    }else{
        
        returnView.frame= CGRectMake((Main_Screen_Width-115)- new1.width,25.0f,new1.width+ 20, new1.height+20.0f);
        
    }
    
    [returnView addSubview:bubbleImageView];
    
    [returnView addSubview:bubbleText];
    
    return returnView ;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
