//
//  Finish_MP3_ViewController.m
//  afterSchool
//
//  Created by susu on 15/3/8.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Finish_MP3_ViewController.h"
#import "AudioStreamer.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface Finish_MP3_ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel * timeLable;
    NSDictionary * workPaperDic;
    NSDictionary * myHomeWorkDic;
    NSMutableArray * workPaperMediasArr;
    NSMutableArray * homeWorkMediaArr;
    NSDictionary * teacherRemarkDic;
    
    NSTimer *_progressUpdateTimer;
    UIButton * playMyhomework;
    int index;
    
    NSMutableArray * imageUrlArr;
    NSMutableArray * mp3UrlArr;
    NSMutableArray * mp4UrlArr;
    NSString * teachermarkMp3Str;
    
}
@property (strong, nonatomic)  UIButton *playMusicButton;
@property(strong,nonatomic)UITableView * finishTableView;
@property (nonatomic,strong) UISlider *progressSlider;
@property (strong, nonatomic)  UIButton *playButton;
@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic, retain) AudioStreamer *PaperWorkstreamer;
@property (strong, nonatomic)  UIButton *RemarkplayMusicButton;
@property (nonatomic, retain) AudioStreamer *RemarkStreamer;
@end

@implementation Finish_MP3_ViewController


-(void)viewWillDisappear:(BOOL)animated
{
    [_PaperWorkstreamer stop];
    _PaperWorkstreamer = nil;
    [_progressUpdateTimer invalidate];
    _progressUpdateTimer=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_PaperWorkstreamer];
    
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];

    
    [_streamer stop];
    _streamer = nil;
    // remove notification observer for streamer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_streamer];
    
    [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    [_RemarkStreamer stop];
    _RemarkStreamer = nil;
    // remove notification observer for streamer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_RemarkStreamer];
    
    [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"详细内容";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    imageUrlArr = [[NSMutableArray alloc] init];
    mp3UrlArr = [[NSMutableArray alloc] init];
    mp4UrlArr = [[NSMutableArray alloc] init];
    [self initTableView];
    [self workPaperRequst];
    [self homeWoorkRequest];
    index = 0;
}

-(void)homeWoorkRequest//我的作业详情请求
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works?student_id=%@&work_paper_id=%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],self.mp3WorkId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        myHomeWorkDic = [responseObject objectAtIndex:0] ;
//        NSLog(@" 获取我的作业=%@",myHomeWorkDic);
        homeWorkMediaArr = [[NSMutableArray alloc] init];
        for (int i=0 ; i<[[myHomeWorkDic objectForKey:@"medias"] count]; i++) {
            [homeWorkMediaArr addObject:[[[myHomeWorkDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"avatar"]];
        }
        
        [self requestTeacherRemark:[myHomeWorkDic objectForKey:@"id"]];
        NSIndexPath * indexx = [NSIndexPath indexPathForItem:0 inSection:1];
        NSArray * array = [NSArray arrayWithObject:indexx];
        [_finishTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
        
}failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];
}

-(void)workPaperRequst//老师布置的作业
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@",self.mp3WorkId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        workPaperDic = [responseObject objectForKey:@"work_paper"];
//        NSLog(@"workPaperRequst =%@",workPaperDic);
        
        workPaperMediasArr = [[NSMutableArray alloc] init];
        for (int i=0 ; i<[[workPaperDic objectForKey:@"medias"] count]; i++) {
            NSString * type = [[[workPaperDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"content_type"];
            NSString * str = [[[workPaperDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"avatar"];
            if(![str isKindOfClass:[NSNull class]])
            {
                NSRange range = [type rangeOfString:@"/"];
                NSString * rangeType = [type substringToIndex:range.location];
                //                NSLog(@"range =%d =%@",range.location,rangeType);
                
                if ([rangeType isEqualToString:@"video"]) {
                    [mp4UrlArr addObject:str];
                }else if ([rangeType isEqualToString:@"audio"]||[rangeType isEqualToString:@"sound"])
                {
                    [mp3UrlArr addObject:str];
                    
                }else if ([rangeType isEqualToString:@"image"])
                {
                    [imageUrlArr addObject:str];
                }
            }
        }
        NSIndexPath * indexx = [NSIndexPath indexPathForItem:0 inSection:0];
        NSArray * array = [NSArray arrayWithObject:indexx];
        [_finishTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];
}

-(void)requestTeacherRemark:(NSString * )homeWorkId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works/%@/work_review",homeWorkId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        teacherRemarkDic = [responseObject objectForKey:@"work_review"] ;
        NSLog(@"teacher remark =%@",responseObject);
        if ([[responseObject allKeys] containsObject:@"review_medias"])
        {
            NSDictionary * dicR = [[responseObject objectForKey:@"review_medias"]objectAtIndex:0];
            if ([[dicR allKeys] containsObject:@"avatar"]) {
                
                teachermarkMp3Str = [NSString stringWithFormat:@"%@",[[dicR objectForKey:@"avatar"] objectForKey:@"url"]];
            }
            
        }
        NSIndexPath * indexx = [NSIndexPath indexPathForItem:0 inSection:1];
        NSArray * array = [NSArray arrayWithObject:indexx];
        [_finishTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];

}

#pragma mark -playMusci

-(void)playMusic:(UIButton * )sender
{
    if (sender.tag == 2 ) {
        
        -- index ;
        if (index<0) {
            index = 0;
        }
        [_PaperWorkstreamer stop];
        _PaperWorkstreamer = nil;
    }else if (sender.tag ==3)
    {
        [_PaperWorkstreamer stop];
        _PaperWorkstreamer = nil;
        ++ index ;
        if (index>=mp3UrlArr.count) {
            index = mp3UrlArr.count-1;
        }
    }

    if (!_PaperWorkstreamer) {
       self.PaperWorkstreamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[mp3UrlArr objectAtIndex:index]]];
        _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paperWorkPlaybackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_PaperWorkstreamer];
    }
    if (![_PaperWorkstreamer isPlaying]) {
        [_PaperWorkstreamer start];
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
        if ([_streamer isPlaying]) {
            [_streamer pause];
            [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        if ([self.RemarkStreamer isPlaying]) {
            [self.RemarkStreamer pause];
            [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
       
    }
    else {
        
        [_PaperWorkstreamer pause];
        [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];

    }
}

-(void)update
{
    self.progressSlider.value = (_PaperWorkstreamer.progress/_PaperWorkstreamer.duration)*100;
    if (_PaperWorkstreamer.progress <= _PaperWorkstreamer.duration ) {
        int allMin = (int)_PaperWorkstreamer.duration/60;
        int allSec = (int)_PaperWorkstreamer.duration%60;
        timeLable.text = [NSString stringWithFormat:@"%d:%d",allMin,allSec];
    }
}

-(void)seek
{
    double seekPoint = self.progressSlider.value;
    [_PaperWorkstreamer seekToTime:seekPoint];
}

//播放的各种状态通知。
- (void)paperWorkPlaybackStateChanged:(NSNotification *)notification
{
    if ([_PaperWorkstreamer isWaiting])
    {
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_PaperWorkstreamer isIdle]) {
        [_PaperWorkstreamer stop];
        _PaperWorkstreamer = nil;
        [_progressUpdateTimer invalidate];
        _progressUpdateTimer=nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_PaperWorkstreamer];
        
        [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_PaperWorkstreamer isPaused]) {//暂停。进入后台暂停播放
//        [_PaperWorkstreamer pause];
        [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_PaperWorkstreamer isPlaying] || [_PaperWorkstreamer isFinishing]) {
        
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        
    }
}

///---------------------------------------
-(void)playMyhomeWorkMusic:(UIButton * )sender
{
//    NSLog(@"homework =%@",[homeWorkMediaArr objectAtIndex:0]);
    if (!_streamer) {
        self.streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[homeWorkMediaArr objectAtIndex:0]]];
          [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_streamer];
    }
    if (![_streamer isPlaying]) {
        if ([_PaperWorkstreamer isPlaying]) {
            [_PaperWorkstreamer pause];
            [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        if ([self.RemarkStreamer isPlaying]) {
            [self.RemarkStreamer pause];
            [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        
        [_streamer start];
        [playMyhomework setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    else {
        [_streamer pause];
        [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    if ([_streamer isWaiting])
    {
         [playMyhomework setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isIdle]) {
            [_streamer stop];
            _streamer = nil;
        // remove notification observer for streamer
         [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        
        [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPaused]) {
//        [_streamer pause];
        [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPlaying] || [_streamer isFinishing]) {
        
        [playMyhomework setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];

    } else {
        
    }
   
}
//play  remark liuyan
///---------------------------------------
-(void)playRemarkMusic:(UIButton * )sender
{

    if (!_RemarkStreamer) {
        _RemarkStreamer= [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:teachermarkMp3Str]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playRemarkbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_RemarkStreamer];
    }
    if (![_RemarkStreamer isPlaying]) {
 
        if ([_PaperWorkstreamer isPlaying]) {
            [_PaperWorkstreamer pause];
            [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        if ([_streamer isPlaying]) {
            [_streamer pause];
            [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        [_RemarkStreamer start];
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    else {
        [_RemarkStreamer pause];
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (void)playRemarkbackStateChanged:(NSNotification *)notification
{
    if ([_RemarkStreamer isWaiting])
    {
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_RemarkStreamer isIdle]) {
        [_RemarkStreamer stop];
        _RemarkStreamer = nil;
        // remove notification observer for streamer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_RemarkStreamer];
        
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_RemarkStreamer isPaused]) {
        //        [_streamer pause];
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_RemarkStreamer isPlaying] || [_RemarkStreamer isFinishing]) {
        
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        
    }
    
}



#pragma mark - tableView
-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _finishTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-49-64)style:UITableViewStylePlain];
    _finishTableView.backgroundColor = [UIColor clearColor];
    _finishTableView.delegate =self;
    _finishTableView.dataSource = self;
    [_finishTableView setTableFooterView:view];
    [self.view addSubview:_finishTableView];
}

//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
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
    [_finishTableView setSeparatorInset:UIEdgeInsetsMake(0,80, 0, 0)];
    [_finishTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    // 如果有音频文件
    if (indexPath.section ==0) {
        float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workPaperDic objectForKey:@"title"]] ;
        float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workPaperDic objectForKey:@"description"]] ;
        
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, titleLableSizeHeight)];
        titleLable.text = [workPaperDic objectForKey:@"title"];
        titleLable.font = [UIFont systemFontOfSize:16.];
        titleLable.lineBreakMode = NSLineBreakByWordWrapping;
        titleLable.numberOfLines = 0;
        [cell.contentView addSubview:titleLable];
        
        UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30+(titleLableSizeHeight-20), Main_Screen_Width-40, 20)];
        dateLable.text = [[workPaperDic objectForKey:@"updated_at"] substringToIndex:10];
        dateLable.font = [UIFont systemFontOfSize:14.];
        dateLable.textColor = [UIColor grayColor];
        [cell.contentView addSubview:dateLable];
        
        UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 50+(titleLableSizeHeight-20), Main_Screen_Width-40, contentLableSizeHeight)];
        contentLable.text = [workPaperDic objectForKey:@"description"];
        contentLable.lineBreakMode = NSLineBreakByWordWrapping;
        contentLable.numberOfLines = 0;
        contentLable.alpha = 0.6;
        contentLable.font = [UIFont systemFontOfSize:14.];
        [cell.contentView addSubview:contentLable];
        
        int mp3Heigh = 0;
        if (mp3UrlArr.count>0) {
            UIView * playView = [self drawPlayViewY:45+titleLableSizeHeight+contentLableSizeHeight];
            [cell.contentView addSubview:playView];
            self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20,163+titleLableSizeHeight+contentLableSizeHeight, Main_Screen_Width-100-20, 10)];
            self.progressSlider.value = 0;
            self.progressSlider.minimumValue = 0;
            self.progressSlider.maximumValue = 100;
            self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
            [self.progressSlider addTarget:self action:@selector(seek) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:self.progressSlider];
            
            timeLable = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width-90,155+titleLableSizeHeight+contentLableSizeHeight, 100, 20)];
            timeLable.font = [UIFont systemFontOfSize:11.];
            timeLable.text = @"00:00";
            timeLable.textColor = [UIColor grayColor];
            [cell.contentView addSubview:timeLable];
            mp3Heigh = 140;
        }
        int  imageHeight = 0;
        if (imageUrlArr.count > 0) {
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mp3Heigh+50+titleLableSizeHeight+contentLableSizeHeight, Main_Screen_Width-20, 100)];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.contentSize = CGSizeMake(10+108 * imageUrlArr.count,100);
            //        scrollView.bounces = NO;
            scrollView.delegate =self;
            scrollView.pagingEnabled = YES;
            scrollView.userInteractionEnabled = YES;
            [cell.contentView addSubview:scrollView];
            
            for (int i= 0; i<[imageUrlArr count]; i++) {
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+108*i, 0, 100, 100)];
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [scrollView addSubview:imageView];
                NSURL * imageUrl = [NSURL URLWithString:[imageUrlArr objectAtIndex:i]];
                [imageView setImageWithURL:imageUrl];
                imageView.tag =i;
                UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
                [imageView addGestureRecognizer:pass1];
            }
            imageHeight = 115;
        }
        if (mp4UrlArr.count > 0) {
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,imageHeight+mp3Heigh+50+titleLableSizeHeight+contentLableSizeHeight, Main_Screen_Width-20, 100)];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.contentSize = CGSizeMake(10+108 * mp4UrlArr.count,100);
            //        scrollView.bounces = NO;
            scrollView.delegate =self;
            scrollView.pagingEnabled = YES;
            scrollView.userInteractionEnabled = YES;
            [cell.contentView addSubview:scrollView];
            
            for (int i= 0; i<[mp4UrlArr count]; i++) {
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+108*i, 0, 100, 100)];
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [scrollView addSubview:imageView];
                //如果有mp4则播放按钮显示
                imageView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
                UIButton * imageBt = [[UIButton alloc] initWithFrame:CGRectMake(35+108*i,25, 50, 50)];
                [imageBt setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                imageBt.tag = i;
                [imageBt addTarget:self action:@selector(initMpMOviePlayerPapers:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:imageBt];
            }
        }

    }else
    {
        //学生留言
        UIImageView * imageLiuYan= [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        imageLiuYan.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",@"wenziLiuyan.png"]];
        [cell.contentView addSubview:imageLiuYan];
        
        UILabel * lable1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,Main_Screen_Width-40 -50, 30)];
        lable1.text = @"学生作业";
        [cell.contentView addSubview:lable1];
        
        //学生的留言
        NSString * str = [myHomeWorkDic objectForKey:@"description"];
        float homeWorkHeight= [publicRequest lableSizeWidth:Main_Screen_Width-90 content:[myHomeWorkDic objectForKey:@"description"]];
        
        NSLog(@"str =%@",str);
        if (![str isKindOfClass:[NSNull class]]) {
            UILabel * myHomeworkLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 40, Main_Screen_Width-90, homeWorkHeight)];
            myHomeworkLable.font = [UIFont systemFontOfSize:16.];
            myHomeworkLable.text = [myHomeWorkDic objectForKey:@"description"];
            myHomeworkLable.lineBreakMode = NSLineBreakByWordWrapping;
            myHomeworkLable.numberOfLines = 0;
            myHomeworkLable.alpha = 0.5 ;
            myHomeworkLable.font = [UIFont systemFontOfSize:14.];
            [cell.contentView addSubview:myHomeworkLable];
        }

        float h = 0;
        if (homeWorkMediaArr.count > 0) {
            UIView * View = [[UIView alloc] initWithFrame:CGRectMake(10,45+homeWorkHeight, Main_Screen_Width-40, 100)];
            View.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
            [cell.contentView addSubview:View];
            
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(View.frame.size.width/2-150, 5, 300, 20)];
            titleLable.textColor = [UIColor greenColor];
            titleLable.text = @"点击试听已完成的作业";
            titleLable.font = [UIFont systemFontOfSize:14.];
            titleLable.textAlignment = NSTextAlignmentCenter;
            [View addSubview:titleLable];
            
            playMyhomework = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width/2-30, 30, 60, 60)];
            [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            [playMyhomework addTarget:self action:@selector(playMyhomeWorkMusic:) forControlEvents:UIControlEventTouchUpInside];
            [View addSubview:playMyhomework];
            
            UIButton *leftBt = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width/2 -80, 40, 40, 40)];
            [leftBt setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
            //    [leftBt addTarget:self action:@selector(PlayMusic) forControlEvents:UIControlEventTouchUpInside];
            [View addSubview:leftBt];
            
            UIButton *rightBt = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width/2 +50, 40, 40, 40)];
            [rightBt setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
            //    [rightBt addTarget:self action:@selector(PlayMusic) forControlEvents:UIControlEventTouchUpInside];
            [View addSubview:rightBt];

            h = 110 ;
        }
        float Height = h ;

        //老师评语
        float PingYuHeight = 0;
        UIImageView * imagePingYu = [[UIImageView alloc] initWithFrame:CGRectMake(10, Height+40+homeWorkHeight, 30, 30)];
        imagePingYu.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",@"laoshiPingyu.png"]];
        [cell.contentView addSubview:imagePingYu];
        
        UILabel * lable2 = [[UILabel alloc] initWithFrame:CGRectMake(50, Height+40+homeWorkHeight,Main_Screen_Width-80, 30)];
        lable2.text = @"老师评语";
        [cell.contentView addSubview:lable2];
        
        if(![teacherRemarkDic isKindOfClass:[NSNull class]])
        {
            if ([[teacherRemarkDic objectForKey:@"rate"] isKindOfClass:[NSNull class]]) {
                UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(Main_Screen_Width-110, Height+40+homeWorkHeight, 70,28 ) ];
                image.image = [UIImage imageNamed:@"weiYue.png"];
                [cell.contentView addSubview:image];
            }else{
                
                UIButton * rateBUtton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                rateBUtton.frame = CGRectMake(Main_Screen_Width-110, Height+40+homeWorkHeight, 70,28 );
                rateBUtton.layer.cornerRadius = 15 ;
                [rateBUtton setTitle:[publicRequest rateTostring:[teacherRemarkDic objectForKey:@"rate"]] forState:UIControlStateNormal];
                rateBUtton.backgroundColor = [UIColor colorWithRed:76/255. green:197/255. blue:36/255. alpha:1.];
                [rateBUtton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                rateBUtton.titleLabel.font = [UIFont systemFontOfSize:16.];
                [cell.contentView addSubview:rateBUtton];
                }
          }
            if ([[teacherRemarkDic objectForKey:@"remark"] isKindOfClass:[NSNull class]]) {
                
            }else {
                
                NSString *markGood;
                NSString *markBad;
                NSRange range1Start = [[teacherRemarkDic objectForKey:@"remark"] rangeOfString:@"精彩点:"];
                NSRange range2Start = [[teacherRemarkDic objectForKey:@"remark"] rangeOfString:@"可改善之处:"];
                
                if (range1Start.location!=NSNotFound &&range2Start.location!=NSNotFound){
                    
                    markGood = [[teacherRemarkDic objectForKey:@"remark"] substringWithRange:NSMakeRange(range1Start.location+4, range2Start.location-4)];
                    
                    markBad = [[teacherRemarkDic objectForKey:@"remark"] substringFromIndex:range2Start.location+6];
                }else if(range1Start.location!=NSNotFound &&range2Start.location == NSNotFound)
                {
                    markGood = [[teacherRemarkDic objectForKey:@"remark"] substringFromIndex:range1Start.location+4] ;
                    
                }else if (range1Start.location==NSNotFound &&range2Start.location != NSNotFound)
                {
                    markBad = [[teacherRemarkDic objectForKey:@"remark"] substringFromIndex:range2Start.location+6];
                }
                
               float markBadHeight;
                float markGoodHeight ;
                if (markGood.length >0) {
                    markGoodHeight = [publicRequest lableSizeWidth:Main_Screen_Width-90 content:markGood] ;
                    UILabel * PingYuLable = [[UILabel alloc] initWithFrame:CGRectMake(50, Height+70+homeWorkHeight , Main_Screen_Width-40-50,markGoodHeight)];
                    PingYuLable.text =[NSString stringWithFormat:@"精彩点：%@",markGood];
                    PingYuLable.lineBreakMode = NSLineBreakByWordWrapping;
                    PingYuLable.numberOfLines = 0;
                    PingYuLable.font = [UIFont systemFontOfSize:14.];
                    PingYuLable.alpha = 0.5 ;
                    [cell.contentView addSubview:PingYuLable];
                }
                if (markBad.length >0) {
                    markBadHeight =[publicRequest lableSizeWidth:Main_Screen_Width-90 content:markBad] ;
                    UILabel * badLable = [[UILabel alloc] initWithFrame:CGRectMake(50, Height+70+homeWorkHeight+markGoodHeight , Main_Screen_Width-40-50,markBadHeight)];
                    badLable.text = [NSString stringWithFormat:@"可改善之处：%@",markBad];
                    badLable.lineBreakMode = NSLineBreakByWordWrapping;
                    badLable.numberOfLines = 0;
                    badLable.font = [UIFont systemFontOfSize:14.];
                    badLable.alpha = 0.5 ;
                    [cell.contentView addSubview:badLable];
                    
                }
                PingYuHeight = markGoodHeight + markBadHeight;
            }
        
        //老师语音留言
        UIImageView * imageYuYin = [[UIImageView alloc] initWithFrame:CGRectMake(10, Height+40+homeWorkHeight+PingYuHeight +35, 30, 30)];
        imageYuYin.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",@"yuyinLiuyan.png"]];
        [cell.contentView addSubview:imageYuYin];
        
        UILabel * lable3 = [[UILabel alloc] initWithFrame:CGRectMake(50, Height+40+homeWorkHeight + PingYuHeight +35 ,Main_Screen_Width-40 -50, 30)];
        lable3.text = @"老师语音留言";
        [cell.contentView addSubview:lable3];
        
        if (teachermarkMp3Str.length >0) {
            UIView * View = [[UIView alloc] initWithFrame:CGRectMake(10,Height+40+homeWorkHeight + PingYuHeight +35+38, Main_Screen_Width-40, 100)];
            View.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
            [cell.contentView addSubview:View];
            
            self.RemarkplayMusicButton = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width/2-30, 15, 60, 60)];
            [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            [self.RemarkplayMusicButton addTarget:self action:@selector(playRemarkMusic:) forControlEvents:UIControlEventTouchUpInside];
            [View addSubview:self.RemarkplayMusicButton];
            h = 90 ;
        }
    
    }
    return cell;
}

-(UIView *)drawPlayViewY:(int)y
{
    UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(10,y, Main_Screen_Width-40, 100)];
    playView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-50, 5, 100, 20)];
    titleLable.textColor = [UIColor greenColor];
    titleLable.text = @"课间试听";
    titleLable.font = [UIFont systemFontOfSize:14.];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [playView addSubview:titleLable];
    
    _playMusicButton = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-25, 30, 60, 60)];
    [_playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    _playMusicButton.tag = 1;
    [_playMusicButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:_playMusicButton];

    
    UIButton *leftBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 -80, 40, 40, 40)];
    leftBt.tag =2 ;
    [leftBt setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    [leftBt addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:leftBt];
    
    UIButton *rightBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 +50, 40, 40, 40)];
    rightBt.tag =3 ;
    [rightBt setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [rightBt addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:rightBt];
    
    return playView;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        float PingYuHeight = 0;
        if(![teacherRemarkDic isKindOfClass:[NSNull class]])
        {
            PingYuHeight  = [publicRequest lableSizeWidth:Main_Screen_Width-90 content:[teacherRemarkDic objectForKey:@"remark"]] ;
        }
        float homeWorkHeight= [publicRequest lableSizeWidth:Main_Screen_Width-90 content:[myHomeWorkDic objectForKey:@"description"]];
        int mediaheight = 0 ;
        if (homeWorkMediaArr.count > 0) {
            mediaheight = 110 ;
        }
        int remarkHeight = 0;
         if (teachermarkMp3Str.length >0) {
             remarkHeight = 90 ;
         }
        return 130+ homeWorkHeight + PingYuHeight+remarkHeight+mediaheight;
    }
    float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workPaperDic objectForKey:@"title"]] ;
    float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workPaperDic objectForKey:@"description"]] ;
    int  imageheight = 0 ;
    int  mp3Height = 0 ;
    int  mp4Height = 0 ;
    if (imageUrlArr.count>0)
        imageheight = 110 ;
    if (mp3UrlArr.count >0)
        mp3Height = 125;
    if(mp4UrlArr.count > 0)
        mp4Height = 105;
    return 80+titleLableSizeHeight+contentLableSizeHeight+mp3Height +imageheight + mp4Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失

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



- (void) tapImage:(UITapGestureRecognizer *)tap
{
    int count = imageUrlArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [imageUrlArr[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

- (void) homeWorkTapImage:(UITapGestureRecognizer *)tap
{
    int count = homeWorkMediaArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [homeWorkMediaArr[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

-(void)initMpMOviePlayerPapers:( UIButton  *)sender
{
    [_streamer pause];
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [_RemarkStreamer pause];
    [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [_PaperWorkstreamer pause];
    [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    
    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ]  initWithContentURL :[NSURL URLWithString:[mp4UrlArr objectAtIndex:sender.tag]]];
    [self createMPPlayerController:moviePlayer];
}

-(void)initMpMOviePlayerHomeWorks:( UIButton  *)sender
{
    [_streamer pause];
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [_RemarkStreamer pause];
    [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [_PaperWorkstreamer pause];
    [playMyhomework setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
     
    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ]  initWithContentURL :[NSURL URLWithString:[homeWorkMediaArr objectAtIndex:sender.tag]]];
    [self createMPPlayerController:moviePlayer];
}

- ( void )createMPPlayerController:( MPMoviePlayerViewController  *)moviePlayer {
    
    [moviePlayer. moviePlayer   prepareToPlay ];
    
    [ self   presentMoviePlayerViewControllerAnimated :moviePlayer]; // 这里是presentMoviePlayerViewControllerAnimated
    
    [moviePlayer. moviePlayer   setControlStyle : MPMovieControlStyleFullscreen ];
    
    [moviePlayer. view   setBackgroundColor :[ UIColor   clearColor ]];
    
    [moviePlayer. view   setFrame : self . view . bounds ];
    
    [[ NSNotificationCenter   defaultCenter ]  addObserver : self
     
                                                  selector : @selector (movieFinishedCallback:)
     
                                                      name : MPMoviePlayerPlaybackDidFinishNotification
     
                                                    object :moviePlayer. moviePlayer ];
    
    
}

-( void )movieStateChangeCallback:( NSNotification *)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
}

-( void )movieFinishedCallback:( NSNotification *)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MPMoviePlayerController * theMovie = [notify  object ];
    
    [[ NSNotificationCenter   defaultCenter ]  removeObserver : self
     
                                                         name : MPMoviePlayerPlaybackDidFinishNotification
     
                                                       object :theMovie];
    
    [ self   dismissMoviePlayerViewControllerAnimated ];
}


-(UIImage *)requestFirstImage:(NSURL *)url
{
    //获取视频首张图片
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
