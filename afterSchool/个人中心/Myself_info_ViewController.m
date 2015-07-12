//
//  Myself_info_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-7.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Myself_info_ViewController.h"
#import "ImageSizeManager.h"


@interface Myself_info_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSArray * nameArr ;
    UIImageView * headView;
    NSArray * pickerArr;
    UIPickerView * picker;
    UITextField * sexTextField;
    UITextField * nameTextfield;
    UIToolbar *doneToolbar;
    NSDictionary * alldic;
    BOOL sexB;
    UIImage * linshiImage;
    NSString * time;
    BOOL  birthdayChange;
    BOOL  genderChange;
    NSString * sexString;
    BOOL  sexBool;
    BOOL   birthBool;
    UIDatePicker * datePickerios7;
    UIToolbar * dateDoneToolBar;
    UITextField * dateField;
}
@property(nonatomic,strong)UITableView *myInfoTableView;
@property(nonatomic, retain) UITextField * oldPwd;    // 旧密码输入框
@property(nonatomic, retain) UITextField * knewPwd;    // 新密码输入框
@property(nonatomic, retain) UITextField * userPassword;    // 新密码确认框

@end

@implementation Myself_info_ViewController

//-(void)viewWillDisappear:(BOOL)animated
//{
//    if (time.length>0 || sexTextField.text.length>0) {
//        if (birthdayChange || genderChange ) {
//            
//        }
//    }
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人资料";
    nameArr = [[NSArray alloc] initWithObjects:@"头像",@"昵称",@"生日",@"性别",@"班级",@"密码", nil];
    sexB = NO;
    linshiImage = nil;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initPicker];
    [self requestInfo];
}
-(void)requestInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        alldic = responseObject;
        NSLog(@"myInfo = %@",responseObject);
//        [self.myInfoTableView reloadData];
            [self initTableView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"erro =%@",error);
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"请求失败,请检查网络链接";
        [HUD hide:YES afterDelay:1.];
    }];
}

-(void)commitPwd:(NSString *)pwd
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    HUD.labelText = @"正在修改...";
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:_knewPwd.text,@"student[password]" ,_knewPwd.text,@"student[password_confirmation]",nil];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"密码修改成功:%@",responseObject);
        if([responseObject objectForKey:@"error"])
        {
            HUD.labelText = @"用户名或密码错误";
            [HUD hide:YES afterDelay:1.];
        }else{
            HUD.labelText = @"密码修改成功";
            [HUD hide:YES afterDelay:1.];
            //刷新tableView单行数据；
            NSIndexPath * index = [NSIndexPath indexPathForItem:0 inSection:1];
            NSArray * array = [NSArray arrayWithObject:index];
            [_myInfoTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
            [[NSUserDefaults standardUserDefaults] setObject:_knewPwd.text forKey:@"userPassword"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD.labelText = @"请求失败请检查网络连接";
        [HUD hide:YES afterDelay:1.];
        NSLog(@"修改密码error =%@",error);
    }];
}

-(void)commitProfile
{
//    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
//    HUD.labelText = @"正在提交...";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (genderChange) {
        [parameters setObject:sexString forKey:@"profile[gender]"];
    }
    if(birthdayChange)
    {
        [parameters setObject:time forKey:@"profile[birthday]"];
    }
 
    NSLog(@"   pa =%@",parameters);
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@/profile?",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"个人资料:%@",responseObject);
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"提交成功。。。";
        [HUD hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HUD.labelText = @"请求失败请检查网络连接";
        [HUD hide:YES afterDelay:1.];
        NSLog(@"提交用户资料error =%@",error);
    }];
}
-(void)hiden
{
    sexB=YES;
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
    [dateField  resignFirstResponder];
}

//提交更改的信息
- (void)selectButton:(UIButton *)sender {
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
    
    //提交头像
    if (linshiImage !=nil) {
 
//        HUD.labelText = @"正在提交...";
        NSData *imageData = UIImageJPEGRepresentation(linshiImage, 0.5);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/users/%@/profile/replace_avatar",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]  parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData){
            
            NSDate *  senddate=[NSDate date];
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
            
            NSString *  locationString=[dateformatter stringFromDate:senddate];
            [formData appendPartWithFileData:imageData name:@"profile[avatar]" fileName:[NSString stringWithFormat:@"%@avatar.jpg",locationString] mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary * dic =responseObject;
            NSLog(@"dic =%@",dic);
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"提交头像成功。。。";
            [HUD hide:YES afterDelay:1.];
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error =%@ ",error);
            HUD.labelText = @"请求失败,请检查网络链接";
            [HUD hide:YES afterDelay:1.];
        }];
    }
    if (!sexBool || !birthBool) {
        if (time.length>0 || sexTextField.text.length>0) {
            if (birthdayChange || genderChange ) {
                [self commitProfile];
            }
        
    }
        
    }
}

-(void)initPicker
{
    pickerArr = [[NSArray alloc] initWithObjects:@"男",@"女", nil];
    doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, Main_Screen_Height-49-216-40, Main_Screen_Width-20, 40)];
    doneToolbar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"完成"
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(hiden)];
     myButton.width = 50;
     NSArray *itemsArray = [NSArray arrayWithObjects:myButton, nil];
    doneToolbar.items = itemsArray;
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10,0, Main_Screen_Width-20, 216)];
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate =self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
   
}

-(void)initDatePicker
{
    dateDoneToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, Main_Screen_Height-49-216-40, Main_Screen_Width-20, 40)];
    dateDoneToolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"完成"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(dataValueChanged:)];
    myButton.width = 50;
    NSArray *itemsArray = [NSArray arrayWithObjects:myButton, nil];
    dateDoneToolBar.items = itemsArray;
    
    datePickerios7 = [[UIDatePicker alloc]init];
    [datePickerios7 setLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    datePickerios7.backgroundColor = [UIColor whiteColor];
    datePickerios7.datePickerMode=UIDatePickerModeDate;
    dateField.inputView = datePickerios7;
    dateField.inputAccessoryView = dateDoneToolBar;

}

-(void)initTableView
{
    UIView * backGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-20, Main_Screen_Height-64-59)];
    backGroundView.backgroundColor =[UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    backGroundView.layer.cornerRadius = 8;
    [self.view addSubview:backGroundView];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _myInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)style:UITableViewStyleGrouped];
    _myInfoTableView.backgroundColor = [UIColor clearColor];
    _myInfoTableView.delegate =self;
    _myInfoTableView.dataSource = self;
//    _myInfoTableView.scrollEnabled = NO;
    [_myInfoTableView setTableFooterView:view];
    _myInfoTableView.sectionFooterHeight = 1.0;
    [backGroundView addSubview:_myInfoTableView];
}

//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 5;
    }
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
    [_myInfoTableView setSeparatorInset:UIEdgeInsetsMake(0,80, 0, 0)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    UILabel * nameText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
    nameText.text =[nameArr objectAtIndex:indexPath.row];
    nameText.font = [UIFont systemFontOfSize:14.];
    if (indexPath.section ==1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.backgroundColor = [UIColor whiteColor];
        nameText.text = [nameArr objectAtIndex:5];
        _userPassword = [[UITextField alloc] initWithFrame:CGRectMake(80, 8, Main_Screen_Width-120, 20)];
        _userPassword.delegate = self;
        _userPassword.secureTextEntry = YES;
        _userPassword.userInteractionEnabled = NO;
        _userPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"];
        _userPassword.font = [UIFont systemFontOfSize:16.];
        _userPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        [cell.contentView addSubview:_userPassword];
    }
    [cell.contentView addSubview:nameText];
    if (indexPath.section ==0&&indexPath.row==0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.backgroundColor = [UIColor whiteColor];
        nameText.frame = CGRectMake(10, 20, 50, 40);
        headView = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-40-70, 13, 60, 60)];
        NSString * url;
        if(![[alldic objectForKey:@"profile"] isKindOfClass:[NSNull class]])
        {
            url = [NSString stringWithFormat:@"%@",[[[alldic objectForKey:@"profile"] objectForKey:@"avatar"] objectForKey:@"url"]];
        }
//        NSLog(@"avatar  url =%@",url);
        if (linshiImage == nil) {
            if (url.length > 0) {
                [headView setImageWithURL:[NSURL URLWithString:url]];
            }else{
                 headView.image =[UIImage imageNamed:@"defultImage.png"];;
            }
        }
        if (headView.image ==nil) {
            headView.image = [UIImage imageNamed:@"defultImage.png"];
        }
        headView.userInteractionEnabled = YES ;
        //圆角设置
        headView.layer.cornerRadius = 30;
        headView.layer.masksToBounds = YES;
        //边框宽度及颜色设置
        [headView.layer setBorderWidth:2];
        [headView.layer setBorderColor:(__bridge CGColorRef)([UIColor grayColor])];
        [cell.contentView addSubview:headView];
    }
    if (indexPath.section==0) {
        if (indexPath.row ==1) {
            NSString * name = [NSString stringWithFormat:@"%@",[[alldic objectForKey:@"student"] objectForKey:@"nickname"]];
            if (![name isKindOfClass:[NSNull class]]) {
                cell.textLabel.text = [[alldic objectForKey:@"student"] objectForKey:@"nickname"];
            }
            
        }else if (indexPath.row ==2)
        {
            if(![[alldic objectForKey:@"profile"] isKindOfClass:[NSNull class]])
            {
                 NSString*string =[NSString stringWithFormat:@"%@",[[alldic objectForKey:@"profile"] objectForKey:@"birthday"]];
   
                if (![[[alldic objectForKey:@"profile"] objectForKey:@"birthday"] isKindOfClass:[NSNull class]]) {
                    time = [string substringToIndex:10];
                    birthdayChange = YES ;
                    birthBool = YES ;
                }else
                {
                    birthdayChange = NO;
                    birthBool = NO ;
                    cell.backgroundColor = [UIColor whiteColor];
                    
                    dateField = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, Main_Screen_Width-80, 40)];
                    dateField.delegate = self;
                    dateField.inputAccessoryView = dateField;
                    [cell.contentView addSubview:dateField];
                    [self initDatePicker];
                }
                
                if (time.length>0) {
                    
                    birthdayChange = YES ;
                }
            }
               cell.textLabel.text = time;
        }
        else if (indexPath.row == 3 ) {
            if(![[alldic objectForKey:@"profile"] isKindOfClass:[NSNull class]])
            {
                NSString * sex = [NSString stringWithFormat:@"%@",[[alldic objectForKey:@"profile"] objectForKey:@"gender"]];
                NSLog(@"sex =%@",sex);
                if (![[[alldic objectForKey:@"profile"] objectForKey:@"gender"] isKindOfClass:[NSNull class]]) {
                    sexString =[[alldic objectForKey:@"profile"] objectForKey:@"gender"];
                    genderChange = YES;
                    sexBool = YES ;
                    cell.textLabel.text = [[alldic objectForKey:@"profile"] objectForKey:@"gender"];
                }else
                {
                    genderChange = NO;
                    sexBool = NO ;
                    cell.backgroundColor = [UIColor whiteColor];
                    sexTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, Main_Screen_Width-80, 40)];
                    sexTextField.delegate = self;
                    sexTextField.inputView = picker;
                    sexTextField.inputAccessoryView = doneToolbar;
                    [cell.contentView addSubview:sexTextField];

                }
            }

        }else if(indexPath.row ==4)
        {
            cell.textLabel.text = [[alldic objectForKey:@"school_class"] objectForKey:@"class_no"];
        }
    }
       return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (indexPath.section ==0) {
        if (indexPath.row ==0) {
            return 80;
        }
    }
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView  heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 70;
    }
    return 1.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, 60)];
    if (section ==1) {
        UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 60)];
        [commitBt setImage:[UIImage imageNamed:@"info_commit.png"] forState:UIControlStateNormal];
        [commitBt addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:commitBt];
    }
    return view;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
    [dateField resignFirstResponder];
    if (indexPath.section ==0 && indexPath.row ==0) {
        [self upLoad];
    }else if (indexPath.section ==1)
    {
        if (Version< 8) {
            [self creatAlertViewIos7];
        }else
        {
            [self creatAlertViewIos8];
        }
        
    }
    if (!birthdayChange) {

     }

}

//datapicker值攺变事件
- (void) dataValueChanged:(UIButton *)sender
{
    UIDatePicker *dataPicker_one = (UIDatePicker *)datePickerios7;
    NSDate *date_one = dataPicker_one.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSLog(@"date =%@",[formatter stringFromDate:date_one]);
    time = [formatter stringFromDate:date_one];
    formatter = nil;
    birthdayChange = YES ;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
    [_myInfoTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)creatAlertViewIos7
{

    UIAlertView * customAlertView = [[UIAlertView alloc] initWithTitle:@"修改密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",  nil];

    [customAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    _oldPwd = [customAlertView textFieldAtIndex:0];
    _oldPwd.placeholder = @"请输入原密码";
    
    _knewPwd = [customAlertView textFieldAtIndex:1];
    [_knewPwd setSecureTextEntry:NO];
    _knewPwd.placeholder = @"请输入修改后的密码";
    
    [customAlertView show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        if([_userPassword.text isEqualToString:_oldPwd.text] )
        {
            if (_knewPwd.text.length<8) {
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = @"密码长度须大于8位";
                [HUD hide:YES afterDelay:1.];
            }else
            {
                [self commitPwd:_knewPwd.text];
            }
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"与原密码不匹配";
            [HUD hide:YES afterDelay:1.];
        }
    }
    
}
-(void)creatAlertViewIos8
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改密码" message:@"请输入原密码" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"请输入原密码";
        textField.secureTextEntry = YES;
        _oldPwd = textField;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        if([_userPassword.text isEqualToString:_oldPwd.text])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改密码" message:@"密码不能少于8位" preferredStyle:UIAlertControllerStyleAlert];
            //
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
                textField.placeholder = @"请输入修改后的密码";
                textField.secureTextEntry = YES;
                _knewPwd = textField;
            }];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                [self commitPwd:_knewPwd.text];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];
            ok.enabled = NO;
            [alert addAction:cancel];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"与原密码不匹配";
            [HUD hide:YES afterDelay:1.];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];
    [alertController addAction:cancel];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *pwd = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = pwd.text.length >7;
    }
}

#pragma mark -pickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [pickerArr count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArr objectAtIndex:row];
}
//性别
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
    NSInteger row = [picker selectedRowInComponent:0];
    if(sexB)
    {
        sexB = NO;
        sexTextField.text= [pickerArr objectAtIndex:row];
        sexString = sexTextField.text;
        genderChange = YES ;

    }else
    {
        sexTextField.text= @"";
    }
}

- (void)upLoad
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

- (void)imagePickerController:(UIImagePickerController *)pickerView didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    linshiImage = [ImageSizeManager getSmallImageWithOldImage:info[UIImagePickerControllerEditedImage]];
    [pickerView dismissViewControllerAnimated:YES completion:^{
        headView.image = linshiImage;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}




@end
