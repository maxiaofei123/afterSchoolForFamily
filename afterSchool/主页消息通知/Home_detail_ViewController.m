//
//  Home_detail_ViewController.m
//  afterSchool
//
//  Created by susu on 15/1/28.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Home_detail_ViewController.h"

@interface Home_detail_ViewController ()<UIScrollViewDelegate>
{
    UIView * bcView;
    UIScrollView* scrollView;
    UIPageControl *pageControl;
    NSArray * imageArr;
}
@end
@implementation Home_detail_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"详细内容";
    bcView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64 -49 -10)];
    bcView.layer.cornerRadius = 8;
    bcView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bcView];
    
    [self drawView];
}

-(void)drawView
{
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 20)];
    titleLable.text = @"今天班级举行圣诞活动";
    [bcView addSubview:titleLable];
    UILabel  * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, Main_Screen_Width-40, 20)];
    dateLable.text = @"今天 14：30";
    dateLable.textColor = [UIColor grayColor];
    dateLable.font = [UIFont  systemFontOfSize:14.];
    [bcView addSubview:dateLable];
    
    if (imageArr.count >0) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 50, Main_Screen_Width-40, 100)];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake((Main_Screen_Width-40)*imageArr.count, 150);
        scrollView.bounces = NO;
        scrollView.delegate =self;
        scrollView.pagingEnabled = YES;
        [bcView addSubview:scrollView];
        
        for (int i=0; i<imageArr.count; i++) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*(Main_Screen_Width-40), 0, Main_Screen_Width-40, 100)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"引导页%d.jpg",i+1]];
            [scrollView addSubview:imageView];
        }
        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 90, Main_Screen_Width-40, 3)];
        pageControl.backgroundColor=[UIColor clearColor];
        pageControl.currentPage = 0;
        pageControl.numberOfPages = 4;
        pageControl.currentPageIndicatorTintColor=[UIColor grayColor];
        pageControl.pageIndicatorTintColor = [UIColor redColor];
        [bcView addSubview:pageControl];
    }
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 210, Main_Screen_Width-40, bcView.frame.size.height -350)];
    textView.textColor = [UIColor grayColor];
    textView.font = [UIFont systemFontOfSize:16.];
    textView.text = @"我么回事怎么回事的的的乐乐乐乐你猜踩踩踩是的分手的方式地方撒旦发射点发撒旦发射点发电风扇电风扇地方水电费水电费水电费是对方的风格的风格反对股电饭锅发给奋斗过大范甘迪风格豆腐干的风格的风格的风格豆腐干豆腐干电饭锅电饭锅电饭锅豆腐干豆腐干电饭锅对方感动感\n动过的风格的风格风格的风格的风格的风格电饭锅对方感动的歌豆腐干豆腐干电饭锅对方更多更多风格地方发给的风格的风格豆腐干豆腐干电饭锅大概风格的烦的风格的歌风格的风格风格丹甫股份感豆腐干地方股份的歌发给的风格的风格风格豆腐干豆腐干 的风格反对感豆腐干的风格对方给对方改革的风格的风格的风格的风格的风格的风格的风格的风格的风格的风格的风格的风格的风格的风格的风格反对";
    [bcView addSubview:textView];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)ascrollView{
    int x = ascrollView.contentOffset.x/Main_Screen_Width;
    pageControl.currentPage=x;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
