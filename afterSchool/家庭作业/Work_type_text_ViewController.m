//
//  Work_type_text_ViewController.m
//  afterSchool
//
//  Created by susu on 15/3/2.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Work_type_text_ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "lame.h"
#import "AudioStreamer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@interface Work_type_text_ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    NSMutableArray * imageUrlArr;
    NSDictionary * workPaperDic;
    UITextView * messageword;
    NSMutableArray * mp3UrlArr;
    NSMutableArray * mp4UrlArr;
    
    //mp3
    UILabel * timeLable;
    UISlider * slider;
    NSTimer *_progressUpdateTimer;
    
    double _seekToPoint;
    NSTimer *_playbackSeekTimer;
    int index;

    
}
@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic,strong) UISlider *progressSlider;
@property (strong, nonatomic)  UIButton *playMusicButton;
@property(strong,nonatomic)UITableView * textTableView;
@end

@implementation Work_type_text_ViewController
@synthesize delegate;

-(void)viewWillDisappear:(BOOL)animated
{
    [_streamer stop];
    _streamer = nil;
    [_progressUpdateTimer invalidate];
    _progressUpdateTimer=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_streamer];
    
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     index = 0 ;
    imageUrlArr = [[NSMutableArray alloc] init];
    mp3UrlArr = [[NSMutableArray alloc] init];
    mp4UrlArr = [[NSMutableArray alloc] init];
    [self initTableView];
    [self request];
}

// tableView
-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _textTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-49)style:UITableViewStylePlain];
    _textTableView.backgroundColor = [UIColor clearColor];
    _textTableView.delegate =self;
    _textTableView.dataSource = self;
    [_textTableView setTableFooterView:view];
    [self.view addSubview:_textTableView];
}

-(void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@",self.textWorkId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        workPaperDic = [responseObject objectForKey:@"work_paper"];
        imageUrlArr  = [[NSMutableArray alloc] init];
        mp3UrlArr = [[NSMutableArray alloc] init];
        mp4UrlArr = [[NSMutableArray alloc] init];
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
        NSLog(@"作业详细 = %@",workPaperDic);
        [_textTableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];
}

-(void)commitHomeWork:(UIButton *)sender
{
    if (messageword.text.length <1) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未书写任何内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"正在提交...";
        NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:[workPaperDic objectForKey:@"title"],@"home_work[title]",messageword.text,@"home_work[description]",[workPaperDic objectForKey:@"id"],@"home_work[work_paper_id]", nil ];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@/home_works",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]]  parameters:dic  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary * dic =responseObject;
//            NSLog(@"dic =%@",dic);
            HUD.labelText = @"提交成功。。。";
            [HUD hide:YES afterDelay:1.];
            
            [self.delegate headerRefresh];

            [self.navigationController popViewControllerAnimated:YES];

        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error =%@ ",error);
            HUD.labelText = @"请求失败,请检查网络链接";
            [HUD hide:YES afterDelay:1.];
        }];
    }
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
    
    [_textTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    
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
        contentLable.font = [UIFont systemFontOfSize:14.];
        contentLable.alpha = 0.6;
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
            scrollView.contentSize = CGSizeMake(10+108 * imageUrlArr.count,100);
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

        
    }else if (indexPath.section ==1)
    {
        UIView * messege = [[UIView alloc] initWithFrame:CGRectMake(10, 30, Main_Screen_Width-40, 50)];
        [messege.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [messege.layer setBorderWidth:1];
        [cell.contentView addSubview:messege];
        
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(5,5, 40, 40)];
        image.image = [UIImage imageNamed:@"wenziLiuyan.png"];
        [messege addSubview:image];
        
        //监听输入框
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        messageword = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, Main_Screen_Width-90, 50)];
        messageword.font = [UIFont systemFontOfSize:16.];
        messageword.delegate = self;
        [messege addSubview:messageword];
        
        UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, Main_Screen_Width-40, 58)];
        [commitBt setImage:[UIImage imageNamed:@"commitWork.png"] forState:UIControlStateNormal];
        [commitBt addTarget:self action:@selector(commitHomeWork:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:commitBt];
    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        return  200;
    }
    int  imageheight = 0 ;
    int  mp3Height = 0 ;
    int  mp4Height = 0 ;
    if (imageUrlArr.count>0)
        imageheight = 110 ;
    if (mp3UrlArr.count >0)
        mp3Height = 125;
    if(mp4UrlArr.count > 0)
        mp4Height = 105;
    float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workPaperDic objectForKey:@"title"]] ;
    float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workPaperDic objectForKey:@"description"]] ;
    
    return 80+titleLableSizeHeight+contentLableSizeHeight+mp3Height +imageheight + mp4Height;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    [messageword resignFirstResponder];
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
    
    _playMusicButton = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-22, 30, 60, 60)];
    [_playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    _playMusicButton.tag = 1;
    [_playMusicButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:_playMusicButton];
    
    UIButton *leftBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 -80, 40, 40, 40)];
    [leftBt setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    leftBt.tag = 2 ;
    [leftBt addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:leftBt];
    
    UIButton *rightBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 +50, 40, 40, 40)];
    [rightBt setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    rightBt.tag = 3 ;
    [rightBt addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:rightBt];
    
    return playView;
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void) keyboardWillShow:(NSNotification *)note{
    
    int offset = 216.0- 64;//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.view.frame =CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
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
        //        photo.srcImageView = imageViewArr[i]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

#pragma mark -playMusci

-(void)playMusic:(UIButton * )sender
{
    if (sender.tag == 2 ) {
        -- index ;
        if (index<0) {
            index = 0;
        }
        [_streamer stop];
        _streamer = nil;
    }else if (sender.tag ==3)
    {
        [_streamer stop];
        _streamer = nil;
        ++ index ;
        if (index>=mp3UrlArr.count) {
            index = mp3UrlArr.count-1;
        }
    }
    
    if (!_streamer) {
        self.streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[mp3UrlArr objectAtIndex:index]]];
        _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paperWorkPlaybackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_streamer];
        
    }
    if (![_streamer isPlaying]) {
        [_streamer start];
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }else {
        [_streamer pause];
        [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

-(void)update
{
    self.progressSlider.value = (_streamer.progress/_streamer.duration)*100;
    if (_streamer.progress <= _streamer.duration ) {
        int allMin = (int)_streamer.duration/60;
        int allSec = (int)_streamer.duration%60;
        timeLable.text = [NSString stringWithFormat:@"%d:%d",allMin,allSec];
    }
}

-(void)seek
{
    double seekPoint = self.progressSlider.value;
    [_streamer seekToTime:seekPoint];
}

- (void)paperWorkPlaybackStateChanged:(NSNotification *)notification
{
    if ([_streamer isWaiting])
    {
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isIdle]) {
        [_streamer stop];
        _streamer = nil;
        [_progressUpdateTimer invalidate];
        _progressUpdateTimer=nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        
        [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPaused]) {//暂停
        //        [_streamer stop];
        [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPlaying] || [_streamer isFinishing]) {
        
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        
    }
    
}


#pragma mark- playVideo

-(void)initMpMOviePlayerPapers:( UIButton  *)sender
{
    [_streamer pause];
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    

    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ]  initWithContentURL :[NSURL URLWithString:[mp4UrlArr objectAtIndex:sender.tag]]];
    [self createMPPlayerController:moviePlayer];
}

- ( void )createMPPlayerController:( MPMoviePlayerViewController  *)moviePlayer {
    [_streamer pause];
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
