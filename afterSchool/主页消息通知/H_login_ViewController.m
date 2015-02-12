//
//  H_login_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-6.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "H_login_ViewController.h"

@interface H_login_ViewController ()<UITextFieldDelegate>
{
    UIScrollView * scrollView;
    UITextField * userTextfield;
    UITextField * pwdTextfield;
}
@end

@implementation H_login_ViewController

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
        [scrollView setContentOffset:CGPointMake(0, 70) animated:YES];
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
//    if (!([userTextfield.text length]>0)) {
//        msg =@"请输入用户名";
//    }
//    else if(pwdTextfield.text.length <6 || pwdTextfield.text.length >20)
//    {
//        msg =@"请输入6-20位密码";
//    }
    if ([msg isEqualToString:@"ok"]) {
//        NSLog(@"str =%@",@"http://114.215.125.31/api/v1/user_tokens?user[email]=abc@gmail.com&user[password]=11111111");
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/user_tokens?user[nickname]=abc&user[password]=11111111"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"res =%@",responseObject);
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError* error) {
              NSLog(@"err =%@",error);
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
