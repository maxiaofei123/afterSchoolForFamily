//
//  Work_type_photo_ViewController.m
//  afterSchool
//
//  Created by susu on 15/1/25.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Work_type_photo_ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "S_homeWork_ViewController.h"
#import "lame.h"
#import "AudioStreamer.h"

@interface Work_type_photo_ViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextViewDelegate>
{
    BOOL photoLib;
    NSMutableArray * imageArr;
    NSMutableArray * mp3UrlArr;
    NSMutableArray * mp4UrlArr;
    NSMutableArray * myVideoUrl;
    NSString *_mp4Path;
    NSMutableArray * imageUrlArr;
    NSDictionary * workPaperDic;
    UITextView * messageword;
    
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
@property(strong,nonatomic)UITableView * finishTableView;
@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic)  UIImageView *photo;//照片展示视图
@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频

@end

@implementation Work_type_photo_ViewController

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
    self.navigationItem.title = @"详细内容";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initTableView];
    _isVideo= 0;//视频
    if([self.type isEqualToString:@"image"])
    {
        _isVideo= 1;
    }
    index = 0 ;
    photoLib = NO;
    imageArr = [[NSMutableArray alloc] init];
    myVideoUrl = [[NSMutableArray alloc] init];

    imageUrlArr = [[NSMutableArray alloc] init];
    mp3UrlArr = [[NSMutableArray alloc] init];
    mp4UrlArr = [[NSMutableArray alloc] init];
    [self request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// tableView
-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _finishTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-49)style:UITableViewStylePlain];
    _finishTableView.backgroundColor = [UIColor clearColor];
    _finishTableView.delegate =self;
    _finishTableView.dataSource = self;
    [_finishTableView setTableFooterView:view];
    [self.view addSubview:_finishTableView];
}

-(void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@",self.photoWorkId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        workPaperDic = [responseObject objectForKey:@"work_paper"];
        
        NSLog(@"workpaper = %@",workPaperDic);
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
        NSLog(@"potimp3 =%@",mp3UrlArr);
         NSLog(@"potomp4 =%@",mp4UrlArr);
         NSLog(@"potoimage =%@",imageUrlArr);
        [_finishTableView reloadData];
//        NSLog(@"作业详细 = %@",workPaperDic);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];
}

-(void)commitHomeWork:(UIButton *)sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"正在提交...";
    NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:[workPaperDic objectForKey:@"title"],@"home_work[title]",messageword.text,@"home_work[description]",[workPaperDic objectForKey:@"id"],@"home_work[work_paper_id]", nil ];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@/home_works",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]]  parameters:dic  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * dic =responseObject;
//        NSLog(@"dic =%@",[[dic objectForKey:@"home_work"] objectForKey:@"id"]);
        if([self.type isEqualToString:@"image"])
        {
            if (imageArr.count > 0) {
               [self commitResource:[[dic objectForKey:@"home_work"] objectForKey:@"id"] resource:imageArr resourceType:@"image"];
            }else
            {
                HUD.labelText = @"提交成功。。。";
                [HUD hide:YES afterDelay:1.];
                [self.delegate headerRefresh];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else
        {
            if (myVideoUrl.count>0) {
                [self commitResource:[[dic objectForKey:@"home_work"] objectForKey:@"id"] resource: myVideoUrl resourceType:@"video"];

            }else {
                HUD.labelText = @"提交成功。。。";
                [HUD hide:YES afterDelay:1.];
                [self.delegate headerRefresh];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }

    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error =%@ ",error);
        HUD.labelText = @"请求失败,请检查网络链接";
        [HUD hide:YES afterDelay:1.];
    }];
 }


-(void)commitResource:(NSString * )homeWorkId resource:(NSArray *)resourceArr resourceType:(NSString * )type
{
    for (int i =0;i<resourceArr.count ; i++) {
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works/%@/media_resources",homeWorkId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
//            NSLog(@"type =%@",type);
           if([self.type isEqualToString:@"video"])
            {
//                 NSLog(@"type =%@",type);
                NSData * mp4data = [NSData dataWithContentsOfFile:[resourceArr objectAtIndex:0]];
                [formData appendPartWithFileData:mp4data name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyVideo_%d.mp4",i+1] mimeType:@"video/mp4"];
            }else
            {// NSLog(@"type =%@",type);
                
                NSData *imageData =UIImageJPEGRepresentation([resourceArr objectAtIndex:i], 0.5);
                [formData appendPartWithFileData:imageData name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyImage_%d.jpg",i+1] mimeType:@"image/jpeg"];
            }
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if([type isEqualToString:@"video"]){
                 NSFileManager * caffileManager = [[NSFileManager alloc]init];
                 if ([caffileManager removeItemAtPath:_mp4Path error:nil]) {
                     NSLog(@"删除mp4缓存");
                 }
             }
             NSDictionary * dic =responseObject;
             NSLog(@"dic =%@",dic);
             HUD.labelText = @"提交成功。。。";
             [HUD hide:YES afterDelay:1.];
             
            [self.delegate headerRefresh];
            [self.navigationController popViewControllerAnimated:YES];
            
         }failure:^(AFHTTPRequestOperation *operation, NSError *error){
             NSLog(@"error =%@ ",error);
            [publicRequest deleteHomewrk:homeWorkId];
            HUD.labelText = @"请求超时";
             [HUD hide:YES afterDelay:1.];
         }  ];
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
    
    [_finishTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
        UIView * bcview = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 140)];
        bcview.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
        [cell.contentView addSubview:bcview];
    
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(bcview.frame.size.width/2-50, 5, 100, 20)];
        titleLable.textColor = [UIColor greenColor];
        titleLable.text = @"点击开始拍照";
        titleLable.font = [UIFont systemFontOfSize:14.];
        titleLable.textAlignment = NSTextAlignmentCenter;
        [bcview addSubview:titleLable];
        
        UIButton * photoBt = [[UIButton alloc] initWithFrame:CGRectMake(bcview.frame.size.width/2-50, 30, 100, 100)];
        [photoBt addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [photoBt setImage:[UIImage imageNamed:@"takePhoto.png"] forState:UIControlStateNormal];
        [bcview addSubview:photoBt];
        int height = 0 ;
        
        // 我的的图片或者视频
        if (imageArr.count>0) {
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 157, Main_Screen_Width-20, 100)];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.contentSize = CGSizeMake(108 * imageArr.count,100);
            scrollView.delegate =self;
            scrollView.pagingEnabled = YES;
            scrollView.userInteractionEnabled = YES;
            [cell.contentView addSubview:scrollView];
            for (int i=0; i<imageArr.count; i++) {
                UIImageView * myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+108*i, 0, 100, 100)];
                myImageView.image = [imageArr objectAtIndex:i];
                [scrollView addSubview:myImageView];
                
                if (_isVideo==0) {
                    myImageView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
                    UIButton * imageBt = [[UIButton alloc] initWithFrame:CGRectMake(35+108*i,25, 50, 50)];
                    [imageBt setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                    imageBt.tag = i;
                    [imageBt addTarget:self action:@selector(initMpMOviePlayerHomeWorks:) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:imageBt];
                }else
                {
                    UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
                    [myImageView addGestureRecognizer:pass1];
                }
            }
            height = 100+5;
        }
        //留言输入框
        UIView * messege = [[UIView alloc] initWithFrame:CGRectMake(10, 160+height, Main_Screen_Width-40, 50)];
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
        
        //提交作业
        UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 220+height, Main_Screen_Width-40, 58)];
        [commitBt setImage:[UIImage imageNamed:@"commitWork.png"] forState:UIControlStateNormal];
        [commitBt addTarget:self action:@selector(commitHomeWork:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:commitBt];
        
    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        if (imageArr.count>0)
            return 400;
        return  300;
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

#pragma mark- takePhoto

-(void)takePhoto:(UIButton *)sender
{
    if (_isVideo) {// _isvideo ==1 拍照
        UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:@"选择图片来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"摄像头拍摄",@"取消", nil];
        sheet.tag =101;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }else //摄像
    {
        UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:@"选择视频来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"摄像头拍摄",@"取消", nil];
        sheet.tag =102;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==101) {
        
        switch (buttonIndex) {
            case 1:
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                    UIImagePickerController *imgPicker = [UIImagePickerController new];
                    imgPicker.delegate = self;
                    imgPicker.allowsEditing= NO;//获取原始图片不允许编辑
                    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:imgPicker animated:YES completion:nil];
                    return;
                }
                else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:@"该设备没有摄像头"
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"好", nil];
                    [alertView show];
                    
                }
            }
                break;
            case 0:
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                photoLib = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }else if (actionSheet.tag ==102)
    {
       switch (buttonIndex) {
           case 1:
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                    UIImagePickerController *imgPicker = [UIImagePickerController new];
                    imgPicker.delegate = self;
                    imgPicker.allowsEditing= NO;
                    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imgPicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
                    imgPicker.mediaTypes=@[(NSString *)kUTTypeMovie];
                    imgPicker.videoQuality=UIImagePickerControllerQualityTypeIFrame960x540;//视频质量设置
//                    imgPicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
                    imgPicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
                    imgPicker.videoMaximumDuration = 60.0f;//设置最长录制1分钟
                    [self presentViewController:imgPicker animated:YES completion:nil];
                    return;
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:@"该设备没有摄像头"
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"好", nil];
                    [alertView show];
                    
                }
            }
            break;
        case 0:
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:( NSString *)kUTTypeMovie];
                [imagePicker setMediaTypes:mediaTypes];
                photoLib = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            break;
       }
    }
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

#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        if(photoLib)
        {
            UIImage * image =info[UIImagePickerControllerOriginalImage];
            [imageArr addObject:image];
            [_finishTableView reloadData];
            photoLib = NO;
        }else {
            UIImage *image;
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
            [imageArr addObject:image];
            //刷新tableView单行数据；
            NSIndexPath * index3 = [NSIndexPath indexPathForItem:0 inSection:1];
            NSArray * array = [NSArray arrayWithObject:index3];
            [_finishTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        }
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        if (photoLib ) {
            photoLib = NO;
             NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
            NSLog(@"选取的视频路径 =%@",url);
            [self movToMp4:url];
//
        }else
        {
            NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
             NSLog(@"保存视频 url＝%@",url);
            [self movToMp4:url];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
}

-(void)movToMp4:(NSURL *)videoURL
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    _mp4Path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4", [formater stringFromDate:[NSDate date]]];
//    NSLog(@"mp4Path =%@",_mp4Path);
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
        //大小是5M多点，如果是Low则为600KB左右,一般选取Medium即可
        exportSession.outputURL = [NSURL fileURLWithPath:_mp4Path];
        exportSession.outputFileType = AVFileTypeMPEG4;
        //
                CMTime start = CMTimeMakeWithSeconds(0, 600);
                CMTime duration = CMTimeMakeWithSeconds(60.0, 600);
                CMTimeRange range = CMTimeRangeMake(start, duration);//剪切视频
                exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"转换失败: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    //   NSLog(@"开始上传屏幕快照");
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_mp4Path)) {
                        //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
                        UISaveVideoAtPathToSavedPhotosAlbum(_mp4Path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
                    }
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功");
        //获取视频首张图片
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        [imageArr addObject:[self requestFirstImage:url]];
        [myVideoUrl addObject:url];
        //刷新tableView单行数据；
        NSIndexPath * index1 = [NSIndexPath indexPathForItem:0 inSection:1];
        NSArray * array = [NSArray arrayWithObject:index1];
        [_finishTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)initMpMOviePlayerHomeWorks:( UIButton  *)sender
{
    [_streamer pause];
    [self.playMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    

    NSLog(@"urlurl =%@,",[myVideoUrl objectAtIndex:sender.tag]);
    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ] initWithContentURL:[myVideoUrl objectAtIndex:sender.tag]];
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


@end
