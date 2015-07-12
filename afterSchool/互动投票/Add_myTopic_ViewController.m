//
//  Add_myTopic_ViewController.m
//  afterSchool
//
//  Created by susu on 15/5/21.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Add_myTopic_ViewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface Add_myTopic_ViewController ()<UIScrollViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

{
    UIScrollView * scrollView;
    int pageFlag;
    NSMutableArray * workArr;
    UITextView * titleText;
    UITextView * contentText;
    NSMutableArray * imageMutableArr;
    NSMutableArray * topicImageArr;
    int height;
}

@end

@implementation Add_myTopic_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"新增话题";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    workArr = [[NSMutableArray alloc] init];
    imageMutableArr = [[NSMutableArray alloc] init];
    topicImageArr = [[NSMutableArray alloc] init];
    height = 0;
    
    [self initTableView];
}

-(void)initTableView
{
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height -64-59)];
    scrollView.layer.cornerRadius = 8 ;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(Main_Screen_Width-20, Main_Screen_Height -64-59);
    scrollView.userInteractionEnabled = YES;
    [self.view addSubview:scrollView];

    
    titleText = [[UITextView alloc] initWithFrame:CGRectMake(10,10, Main_Screen_Width-40, 40)];
    titleText.layer.borderColor = [[UIColor grayColor] CGColor];
    titleText.text = @"输入消息标题";
    titleText.font = [UIFont systemFontOfSize:18.];
    titleText.layer.borderWidth = 1.0f;
    titleText.tag = 101 ;
    titleText.delegate = self ;
    [scrollView addSubview:titleText];
    
    contentText = [[UITextView alloc] initWithFrame:CGRectMake(10,60, Main_Screen_Width-40, 110)];
    contentText.text = @"输入消息内容";
    contentText.layer.borderColor = [[UIColor grayColor] CGColor];
    contentText.layer.borderWidth = 1.0f;
    contentText.delegate = self ;
    contentText.font = [UIFont systemFontOfSize:16.];
    [scrollView addSubview:contentText];
    
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
    [titleText setInputAccessoryView:topView];
    [contentText setInputAccessoryView:topView];
    
    UIButton * photoBt = [[UIButton alloc] initWithFrame:CGRectMake(10,175, 30, 30)];
    [photoBt setImage:[UIImage imageNamed:@"addPhoto.png"] forState:UIControlStateNormal];
    [photoBt addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:photoBt];
    
    UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width -110,175, 80, 30)];
    [commitBt setImage:[UIImage imageNamed:@"tijiao.png"] forState:UIControlStateNormal];
    [commitBt addTarget:self action:@selector(commitTopic) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:commitBt];
}

-(void)addPhotoView
{
    if (imageMutableArr.count > 0) {
        height = 100;
        scrollView.contentSize = CGSizeMake(Main_Screen_Width-20, Main_Screen_Height -64-59 +100);
        UIScrollView * scrollViewImage = [[UIScrollView alloc] initWithFrame:CGRectMake(0,210 , Main_Screen_Width-20, 100)];
        scrollViewImage.showsHorizontalScrollIndicator = NO;
        scrollViewImage.contentSize = CGSizeMake(108 * imageMutableArr.count,100);
        scrollViewImage.delegate =self;
        scrollViewImage.pagingEnabled = YES;
        scrollViewImage.userInteractionEnabled = YES;
        [scrollView addSubview:scrollViewImage];
        
        for (int i=0; i<imageMutableArr.count; i++) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+88*i,0, 80, 80)];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            // 内容模式
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [scrollViewImage addSubview:imageView];
            imageView.image = [imageMutableArr objectAtIndex:i];
            imageView.tag =i;
            UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
            [imageView addGestureRecognizer:pass1];
        }
    }
}

-(void)commitTopic
{
    NSString * str1;
    NSString * str2 ;
    NSString * ok = @"请输入消息内容";
    
    if (!([titleText.text isEqualToString:@"输入消息标题"])) {
        if (titleText.text.length>0) {
            str1 = [NSString stringWithFormat:@"%@",titleText.text];
        }
    }
    if (!([contentText.text isEqualToString:@"输入消息内容"])) {
        if (contentText.text.length>0) {
            str2 = [NSString stringWithFormat:@"%@",contentText.text];
        }
    }
    NSLog(@"str1 =%@  str2 =%@",str1,str2);
    if (str1.length >0 && str2.length > 0) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"正在提交...";
        
        NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:str1,@"post[title]",str2,@"post[body]",[[NSUserDefaults standardUserDefaults] objectForKey:@"class_id"],@"post[school_class_id]",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],@"post[user_id]" ,nil];
        
        AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/posts"] parameters:pa constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for (int i =0; i<imageMutableArr.count; i++) {
                
                NSData *imageData =UIImageJPEGRepresentation([imageMutableArr objectAtIndex:i], 0.5);
                [formData appendPartWithFileData:imageData name:@"media_resource[avatar][]"fileName:[NSString stringWithFormat:@"anyImage_%d.jpg",1] mimeType:@"image/jpeg"];
            }
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"topict commit =%@",responseObject);
            HUD.labelText = @"提交成功。。。";
            [HUD hide:YES afterDelay:1.];
            
            titleText.text = @"";
            contentText.text = @"";
            [imageMutableArr removeAllObjects];
            [self addPhotoView];
            
            [self.delegate pull];
            
            [self.navigationController popViewControllerAnimated:YES];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag ==101) {
        
        if ( [titleText.text isEqualToString:@"输入消息标题"]) {
            titleText.text = @"";
        }
        
    }else if ( [contentText.text isEqualToString:@"输入消息内容"]) {
        contentText.text = @"";
    }
    
//    if (textView == titleText) {
//        [scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
//        
//    }else if (textView == contentText)
//        [scrollView setContentOffset:CGPointMake(0, 150) animated:YES];
}

-(void)hiden
{
    [titleText resignFirstResponder];
    [contentText resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


-(void)choosePhoto
{
    UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:@"选择图片来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"摄像头拍摄",@"取消", nil];
    sheet.tag =101;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    
}

//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        
        UIImage * image =info[UIImagePickerControllerOriginalImage];
        [imageMutableArr addObject:image];
        
    }else {
        UIImage *image;
        image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        [imageMutableArr addObject:image];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self addPhotoView];
}

- (void) tapImage:(UITapGestureRecognizer *)tap
{
    int count = imageMutableArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.srcImageView.image = [imageMutableArr objectAtIndex:i];
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag;
    
    // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
