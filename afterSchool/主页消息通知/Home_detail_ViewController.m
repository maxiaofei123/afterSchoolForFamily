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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    bcView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64 -49 -10)];
    bcView.layer.cornerRadius = 8;
    bcView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bcView];
    [self drawView];
}

-(void)drawView
{
    float titleLableSizeHeight= [publicRequest lableSizeWidthFont16:Main_Screen_Width-40 content:[self.messageDic objectForKey:@"topic"]] ;
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, titleLableSizeHeight)];
    titleLable.text = [self.messageDic objectForKey:@"topic"];
    titleLable.lineBreakMode = NSLineBreakByWordWrapping;
    titleLable.numberOfLines = 0;
    [bcView addSubview:titleLable];
    UILabel  * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10+titleLableSizeHeight, Main_Screen_Width-40, 20)];
    dateLable.text = [[self.messageDic objectForKey:@"updated_at"] substringToIndex:10];
    dateLable.textColor = [UIColor grayColor];
    dateLable.font = [UIFont  systemFontOfSize:14.];
    [bcView addSubview:dateLable];
    int height=0;
    if (imageArr.count >0) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 30+titleLableSizeHeight, Main_Screen_Width-40, 100)];
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
        height = 110;
    }
    float textSizeHeight= [publicRequest lableSizeWidthFont16:Main_Screen_Width-40 content:[self.messageDic objectForKey:@"body"]] ;
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(10,30+height+titleLableSizeHeight, Main_Screen_Width-40, Main_Screen_Height -59 -64- height-titleLableSizeHeight-30)];
    textView.textColor = [UIColor grayColor];
    textView.font = [UIFont systemFontOfSize:16.];
    textView.text = [self.messageDic objectForKey:@"body"];
    [bcView addSubview:textView];
     NSLog(@"%f     %f",textView.frame.origin.y+textSizeHeight+64+30, Main_Screen_Height-59);
    if (textView.frame.origin.y+textSizeHeight+64+30+titleLableSizeHeight > Main_Screen_Height-59) {
        textView.frame = CGRectMake(10,30+height+titleLableSizeHeight, Main_Screen_Width-40, Main_Screen_Height -59 -64- height-titleLableSizeHeight-30);
    }
    
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
