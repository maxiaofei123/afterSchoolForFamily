//
//  Work_type_mp3_ViewController.m
//  afterSchool
//
//  Created by susu on 15/1/26.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Work_type_mp3_ViewController.h"
#import "FSAudioStream.h"
#import "FSAudioController.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@interface Work_type_mp3_ViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>
{
    UILabel * timeLable;
    UISlider * slider;
    NSTimer *_progressUpdateTimer;
    
    double _seekToPoint;
    NSTimer *_playbackSeekTimer;
    FSAudioStreamPrivate *_private;
    
    NSTimer *_volumeRampTimer;
    float _volumeBeforeRamping;
    int _rampStep;
    UIButton *playBt;
    BOOL playOrNot;
    BOOL voicePlay;
    
    //luyin
    NSURL *recordedFile;
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
    BOOL isRecording;
    //    Path
    NSString *_strCAFPath;
    NSString *_strMp3Path;
    
}

@property(strong,nonatomic)UITableView * finishTableView;
@property(strong,nonatomic)NSString * type;
@property (nonatomic,strong) FSAudioStream *audioStream;
@property (nonatomic,strong) FSAudioController *audioController;
@property (nonatomic,strong) UISlider *progressSlider;

@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic)  UIButton *playButton;
@property (strong, nonatomic)  UIButton *recordButton;

@property (retain, nonatomic) NSString* _lastRecordFileName;

@end

@implementation Work_type_mp3_ViewController
@synthesize playButton = _playButton;
@synthesize recordButton = _recordButton;
@synthesize isRecording = _isRecording;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"详细内容";
    [self initTableView];
    
    self.isRecording = NO;
    playOrNot = NO;
    voicePlay = NO;
    [self.playButton setEnabled:NO];
    self.playButton.titleLabel.alpha = 0.5;

    //录音
    
    NSDateFormatter *folderNameFormatter = [[NSDateFormatter alloc] init];
    [folderNameFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *folderName = [folderNameFormatter stringFromDate:[NSDate date]] ;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"documentsDirectory:%@",documentsDirectory);
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:folderName];
    NSLog(@"folderPath:%@",folderPath);
    
    _strCAFPath = [[NSString alloc] initWithFormat:@"%@/%@",documentsDirectory,@"CAF"];
    _strMp3Path = [[NSString alloc] initWithFormat:@"%@/%@",documentsDirectory,@"Mp3"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager createDirectoryAtPath:_strCAFPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:_strMp3Path withIntermediateDirectories:YES attributes:nil error:nil];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
- (void)recordOrStop:(id)sender {
    
    _isRecording=!_isRecording;
    
    if (_isRecording) {
        [self.playButton setEnabled:NO];
        [self.recordButton setImage:[UIImage imageNamed:@"recoreding.png"] forState:UIControlStateNormal];
        NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
        [fileNameFormatter setDateFormat:@"yyyyMMddhhmmss"];
        NSString *fileName = [fileNameFormatter stringFromDate:[NSDate date]];
        
        fileName = [fileName stringByAppendingString:@".caf"];
        NSString *cafFilePath = [_strCAFPath stringByAppendingPathComponent:fileName];
        NSURL *cafURL = [NSURL fileURLWithPath:cafFilePath];
        
        NSError *error;
        NSLog(@"cafURL:%@" ,cafURL);
        
        NSDictionary *recordFileSettings = [NSDictionary
                                            dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:AVAudioQualityMin],
                                            AVEncoderAudioQualityKey,
                                            [NSNumber numberWithInt:16],
                                            AVEncoderBitRateKey,
                                            [NSNumber numberWithInt: 2],
                                            AVNumberOfChannelsKey,
                                            [NSNumber numberWithFloat:44100.0],
                                            AVSampleRateKey,
                                            nil];
        
        @try {
            if (!player) {
                recorder = [[AVAudioRecorder alloc] initWithURL:cafURL settings:recordFileSettings error:&error];
            }else {
                if ([recorder isRecording]) {
                    [recorder stop];
                }
                recorder=Nil;
                recorder = [[AVAudioRecorder alloc] initWithURL:cafURL settings:recordFileSettings error:&error];
            }
            
            if (recorder) {
                [recorder prepareToRecord];
                recorder.meteringEnabled = YES;
                
                [recorder record];
                NSLog(@"_avRecorder recording");
                
                self._lastRecordFileName=fileName;
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            NSLog(@"%@",[error description]);
        }
        
    }else {
        [self.playButton setEnabled:YES];
        [self.recordButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        if (recorder) {
            NSError *error=nil;
            @try {
                [recorder stop];
                recorder=Nil;
                [self toMp3:self._lastRecordFileName];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",[exception description]);
            }
            @finally {
                NSLog(@"%@",[error description]);
            }
        }
    }
}

#pragma mark -

- (void)toMp3:(NSString*)cafFileName
{
    NSString *cafFilePath =[_strCAFPath stringByAppendingPathComponent:self._lastRecordFileName];
    NSDateFormatter *fileNameFormat=[[NSDateFormatter alloc] init];
    [fileNameFormat setDateFormat:@"yyyyMMddhhmmss"];
    NSString *mp3FileName = [fileNameFormat stringFromDate:[NSDate date]];
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [_strMp3Path stringByAppendingPathComponent:mp3FileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");//被转换的文件
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");//转换后文件的存放位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
    }
}

- (void)toPlay:(id)sender
{
    [self toPlayCAF:nil];
}

- (void)toPlayCAF:(NSString*)cafFileName{
    
    NSString *cafFilePath =[_strCAFPath stringByAppendingPathComponent:cafFileName];
    NSURL *cafURL = [NSURL fileURLWithPath:cafFilePath];
    NSLog(@"cafURL:%@",cafURL);
    
    NSError *error=nil;
    if (!player) {
        player= [[AVAudioPlayer alloc] initWithContentsOfURL:cafURL error:&error];
    }else {
        if ([player isPlaying]) {
            [player stop];
        }
        player=nil;
        player= [[AVAudioPlayer alloc] initWithContentsOfURL:cafURL error:&error];
    }
    player.volume = 1.0;
    player.numberOfLoops= 0;
    if(player== nil)
        NSLog(@"%@", [error description]);
    else
    {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        [player play];
    }    
}

//
-(void)PlayMusic
{
    if (playOrNot) {
        playOrNot = NO;
        [playBt setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [self.audioController pause];
 
    }else
    {
        playOrNot = YES;
        [playBt setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [self.audioController play];
        _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(updatePlaybackProgress)
                                                              userInfo:nil
                                                               repeats:YES];

    }
}

- (void)updatePlaybackProgress
{
    if (self.audioController.stream.continuous) {
        self.progressSlider.enabled = NO;
        self.progressSlider.value = 0;
        timeLable.text = @"";
    } else {
        self.progressSlider.enabled = YES;
        FSStreamPosition cur = self.audioController.stream.currentTimePlayed;
        FSStreamPosition end = self.audioController.stream.duration;
        self.progressSlider.value = cur.position*100;
        timeLable.text = [NSString stringWithFormat:@"%i:%02i / %i:%02i",
                          cur.minute, cur.second,
                          end.minute, end.second];
        
    }
}

-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://other.92wy.com/star/Fanfan/woxiangdashenggaosuni_yanzouban.mp3?";
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

-(FSAudioController *)audioController
{
    if (! _audioController)
    {
        NSURL *url=[self getNetworkUrl];
        _audioController = [[FSAudioController alloc] initWithUrl:url];
        [_audioController setVolume:1];//设置声音
    }
    return _audioController;
}

// tableView
-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _finishTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-49)style:UITableViewStylePlain];
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
    }
    [_finishTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
//    if ([self.type isEqualToString:@"finishi"]) {
        // 如果有音频文件
        if (indexPath.section ==0) {
            
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 20)];
            titleLable.text = @"英语：背诵第三课";
            titleLable.font = [UIFont systemFontOfSize:16.];
            [cell.contentView addSubview:titleLable];
            UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, Main_Screen_Width-40, 20)];
            dateLable.text = @"今天：14.30";
            dateLable.font = [UIFont systemFontOfSize:14.];
            dateLable.textColor = [UIColor grayColor];
            [cell.contentView addSubview:dateLable];
            
            UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, Main_Screen_Width-40, 20)];
            contentLable.text = @"任务：准备A4纸，素描维纳斯，拍照上传，家长请帮忙监督";
            contentLable.font = [UIFont systemFontOfSize:14.];
            [cell.contentView addSubview:contentLable];
            
            UIView * playView = [self drawPlayViewY:80];
            [cell.contentView addSubview:playView];
            self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 190, Main_Screen_Width-100-20, 10)];
            self.progressSlider.value = 0;
            self.progressSlider.minimumValue = 0;
            self.progressSlider.maximumValue = 100;
            self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
            //    [self.progressSlider addTarget:self action:@selector(seek:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:self.progressSlider];
            
            timeLable = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width-100, 145, 100, 20)];
            timeLable.font = [UIFont systemFontOfSize:11.];
            timeLable.text = @"";
            timeLable.textColor = [UIColor grayColor];
            [cell.contentView addSubview:timeLable];
        }else
        {
            UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(10,10, Main_Screen_Width-40, 100)];
            playView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
            [cell.contentView addSubview:playView];
            
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-120, 5, 240, 20)];
            titleLable.textColor = [UIColor greenColor];
            titleLable.text = @"点击开始录音，再次点击终止录音";
            titleLable.font = [UIFont systemFontOfSize:14.];
            titleLable.textAlignment = NSTextAlignmentCenter;
            [playView addSubview:titleLable];
            
            _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-70, 40, 50, 50)];
            [_recordButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
            [_recordButton addTarget:self action:@selector(recordOrStop:) forControlEvents:UIControlEventTouchUpInside];
            [playView addSubview:_recordButton];
            
            _playButton = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2+20, 40, 50, 50)];
            [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            [_playButton addTarget:self action:@selector(toPlay:) forControlEvents:UIControlEventTouchUpInside];
            [playView addSubview:_playButton];
            
             //留言
            UIView * messege = [[UIView alloc] initWithFrame:CGRectMake(10, 160, Main_Screen_Width-40, 50)];
            [messege.layer setBorderColor:[[UIColor grayColor] CGColor]];
            [messege.layer setBorderWidth:1];
            [cell.contentView addSubview:messege];
            
            UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
            image.image = [UIImage imageNamed:@"wenziLiuyan.png"];
            [messege addSubview:image];
            
            UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 220, Main_Screen_Width-40, 60)];
            [commitBt setImage:[UIImage imageNamed:@"commitWork.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:commitBt];
        }
//    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        return 300;
    }
    return 220;
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
    
    playBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-22, 33, 50, 50)];
    [playBt setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [playBt addTarget:self action:@selector(PlayMusic) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:playBt];
    
    UIButton *leftBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 -80, 40, 40, 40)];
    [leftBt setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    [leftBt addTarget:self action:@selector(PlayMusic) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:leftBt];
    
    UIButton *rightBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 +50, 40, 40, 40)];
    [rightBt setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [rightBt addTarget:self action:@selector(PlayMusic) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:rightBt];
    return playView;
}

#pragma mark -recorde 

- (void)viewDidUnload
{
    [self setPlayButton:nil];
    [self setRecordButton:nil];
    recorder = nil;
    player = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // [fileManager removeItemAtPath:recordedFile.path error:nil];
    [fileManager removeItemAtURL:recordedFile error:nil];
    recordedFile = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)playPause:(id)sender
{
    //If the track is playing, pause and achange playButton text to "Play"
    if(voicePlay)
    {
        voicePlay = NO;
        [player pause];
        [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }//If the track is not player, play the track and change the play button to "Pause"
    else
    {
        voicePlay = YES;
        [player play];
        [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (void)startStopRecording:(id)sender
{
    //If the app is note recording, we want to start recording, disable the play button, and make the record button say "STOP"
    if(!self.isRecording)
    {
        self.isRecording = YES;
        [self.recordButton setImage:[UIImage imageNamed:@"recoreding.png"] forState:UIControlStateNormal];
        [self.playButton setEnabled:NO];
        [self.playButton.titleLabel setAlpha:0.5];
        recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:nil error:nil];
        [recorder prepareToRecord];
        [recorder record];
        player = nil;
    }
    //If the app is recording, we want to stop recording, enable the play button, and make the record button say "REC"
    else
    {
        self.isRecording = NO;
        [self.recordButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        [self.playButton setEnabled:YES];
        [self.playButton.titleLabel setAlpha:1];
        [recorder stop];
        recorder = nil;
        NSError *playerError;
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile error:&playerError];
        
        if (player == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }
        player.delegate = self;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
     [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
