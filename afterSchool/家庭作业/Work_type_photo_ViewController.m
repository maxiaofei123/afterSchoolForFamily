//
//  Work_type_photo_ViewController.m
//  afterSchool
//
//  Created by susu on 15/1/25.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Work_type_photo_ViewController.h"


@interface Work_type_photo_ViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property(strong,nonatomic)UITableView * finishTableView;

@end

@implementation Work_type_photo_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"详细内容";
    [self initTableView];
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
    }
    [_finishTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
   if (indexPath.section ==0) {
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 20)];
        titleLable.text = @"美术：维纳斯铅笔画";
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
        
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, Main_Screen_Width-20, 100)];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(105 * 4,100);
//        scrollView.bounces = NO;
        scrollView.delegate =self;
        scrollView.pagingEnabled = YES;
        scrollView.userInteractionEnabled = YES;
        [cell.contentView addSubview:scrollView];
        for (int i=0; i<4; i++) {
            UIButton * imageBt = [[UIButton alloc] initWithFrame:CGRectMake(0+105*i, 0, 100, 100)];
            [imageBt setImage:[UIImage imageNamed:@"takePhoto.png"] forState:UIControlStateNormal];
            [scrollView addSubview:imageBt];
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
        
        UIView * messege = [[UIView alloc] initWithFrame:CGRectMake(10, 160, Main_Screen_Width-40, 40)];
        [messege.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [messege.layer setBorderWidth:1];
        [cell.contentView addSubview:messege];
        
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        image.image = [UIImage imageNamed:@"wenziLiuyan.png"];
        [messege addSubview:image];
        
        UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 210, Main_Screen_Width-40, 50)];
        [commitBt setImage:[UIImage imageNamed:@"commitWork.png"] forState:UIControlStateNormal];
        [cell.contentView addSubview:commitBt];
    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        return  280;
    }
    return 200;
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
-(void)takePhoto:(UIButton *)sender
{
    UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:@"选择图片来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"摄像头拍摄",@"取消", nil];
    sheet.tag =101;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];

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
                    imgPicker.allowsEditing= YES;
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
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
                break;
            case 2:
                
                break;
            default:
                break;
        }
    }

}



@end
