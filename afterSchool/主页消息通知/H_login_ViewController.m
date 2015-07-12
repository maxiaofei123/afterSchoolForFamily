//
//  H_login_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-6.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "H_login_ViewController.h"
#import "JSONKit.h"

@interface H_login_ViewController ()<UITextFieldDelegate>
{
    UIScrollView * scrollView;
    UITextField * userTextfield;
    UITextField * pwdTextfield;
}
@end

@implementation H_login_ViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawView];
    
}

-(void)drawView
{
    scrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
    scrollView.backgroundColor = [UIColor colorWithRed:33/255. green:187/255. blue:252/255. alpha:1.];
    scrollView.userInteractionEnabled = YES;
    [self.view addSubview:scrollView];
    
    UITapGestureRecognizer *textFeild = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textFieldEditing)];
    [scrollView addGestureRecognizer:textFeild];
    
    UIImageView  * logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width/2-105, Main_Screen_Height/2-250, 230, 235)];
    logoImage.image = [UIImage imageNamed:@"login_logo.png"];
    [scrollView addSubview:logoImage];
    
    UIImageView * userImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, Main_Screen_Height/2 + 20, Main_Screen_Width -60, 60)];
    userImage.image = [UIImage imageNamed:@"user.png"];
    userImage.userInteractionEnabled = YES ;
    [scrollView addSubview:userImage];
    
    UIImageView * pwdImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, Main_Screen_Height/2 + 90, Main_Screen_Width -60, 60)];
    pwdImage.image = [UIImage imageNamed:@"pwd.png"];
    pwdImage.userInteractionEnabled = YES ;
    [scrollView addSubview:pwdImage];
    
    userTextfield = [[UITextField alloc] initWithFrame:CGRectMake(50, 18, Main_Screen_Width-120, 20)];
    userTextfield.placeholder = @"用户名";
    userTextfield.delegate = self;
    userTextfield.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    userTextfield.font = [UIFont systemFontOfSize:16.];
    userTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [userImage addSubview:userTextfield];
    
    pwdTextfield = [[UITextField alloc] initWithFrame:CGRectMake(50, 18, Main_Screen_Width-120, 20)];
    pwdTextfield.placeholder = @"密码";
    pwdTextfield.delegate = self;
    pwdTextfield.secureTextEntry = YES;
    pwdTextfield.font = [UIFont systemFontOfSize:16.];
    pwdTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [pwdImage addSubview:pwdTextfield];
    
    UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(30, Main_Screen_Height/2+170, Main_Screen_Width - 60, 60)];
    [commitBt setImage:[UIImage imageNamed:@"login.png"] forState:UIControlStateNormal];
    [commitBt addTarget:self action:@selector(loginBt:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:commitBt];
//    
//    UILabel * vesion = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width/2-50, Main_Screen_Height/2+250, 100, 20)];
//    vesion.text = @"版本1.5";
//    vesion.textAlignment = NSTextAlignmentCenter;
//    vesion.textColor = [UIColor whiteColor];
//    [scrollView addSubview:vesion];
}
//隐藏键盘
-(void)textFieldEditing
{
    [userTextfield resignFirstResponder];
    [pwdTextfield resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == userTextfield) {
        [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
    }else if (textField == pwdTextfield)
        [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [userTextfield resignFirstResponder];
    [pwdTextfield resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginBt:(UIButton *)sender {
    
    NSString * msg = @"ok";
    if (!([userTextfield.text length]>0)) {
        msg =@"请输入用户名";
    }
    else if(pwdTextfield.text.length <8 || pwdTextfield.text.length >20)
    {
        msg =@"请输入8-20位密码";
    }
    if ([msg isEqualToString:@"ok"]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"正在请求...";
        NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:userTextfield.text,@"user[email]",pwdTextfield.text ,@"user[password]", nil];
        NSLog(@"用户登陆 =%@",parameters);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/user_tokens/"] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary * dic = responseObject;
            NSLog(@"my login res =%@",responseObject);
            if([dic objectForKey:@"error"])
            {
                HUD.labelText = @"用户名或密码错误";
                [HUD hide:YES afterDelay:1.];
            }else
            {
                [HUD hide:YES ];
                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"user_id"] forKey:@"user_id"];
                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"token"] forKey:@"user_token"];
                [[NSUserDefaults standardUserDefaults] setObject:[[dic objectForKey:@"user"] objectForKey:@"nickname"] forKey:@"nickname"];
                [[NSUserDefaults standardUserDefaults] setObject:[[dic objectForKey:@"user"] objectForKey:@"email"] forKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:pwdTextfield.text forKey:@"userPassword"];
                [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"user"] objectForKey:@"school_class_id"] forKey:@"class_id"];
                [self.delegate initTableView];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError* error) {
            NSDictionary *  dic = error.userInfo;
            NSLog(@"error =%@",error.userInfo);
            NSData * data = [dic objectForKey:@"com.alamofire.serialization.response.error.data"];
            NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary * strDic =  [str objectFromJSONString];
            NSString * msg1= [strDic objectForKey:@"error"];
            if (msg1.length<1) {
                
                msg1 = @"登陆失败,请检查网络链接";
            }
            HUD.labelText = msg1;
            [HUD hide:YES afterDelay:1.5];

        }];
    }
    else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
