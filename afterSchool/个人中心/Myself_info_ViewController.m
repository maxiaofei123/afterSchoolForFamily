//
//  Myself_info_ViewController.m
//  AfterSchool
//
//  Created by susu on 15-1-7.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Myself_info_ViewController.h"

@interface Myself_info_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
{
    NSArray * nameArr ;
    UIImageView * headView;
    NSArray * infoArr;
    NSArray * pickerArr;
    UIPickerView * picker;
    UITextField * sexTextField;
    UITextField * nameTextfield;
    UIToolbar *doneToolbar;
    BOOL sexB;
}
@property(nonatomic,strong)UITableView *myInfoTableView;

@end

@implementation Myself_info_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人资料";
    nameArr = [[NSArray alloc] initWithObjects:@"头像",@"昵称",@"生日",@"性别",@"班级",@"密码", nil];
    infoArr = [[NSArray alloc] initWithObjects:@"",@"",@"2002-9-9",@" ",@"B1001", nil];
    sexB = NO;
    [self initTableView];
    [self initPicker];
}
-(void)requestInfo
{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    if (![str isEqualToString:@"麦飞机会员"]) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"];
        NSString *email =[[NSUserDefaults standardUserDefaults]objectForKey:@"user_email"];
        NSDictionary * dic =[[NSDictionary alloc] initWithObjectsAndKeys:token,@"user_token", email,@"user_email",nil];
        NSString *str =[[NSString alloc] initWithFormat:@"http://api.mfeiji.com/v1/users/%@",userId];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:str parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary * dic =responseObject;
            NSLog(@"dic =%@",dic);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"erro =%@",error.userInfo);
        }];
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
                                  action:@selector(selectButton:)];
     myButton.width = 50;
     NSArray *itemsArray = [NSArray arrayWithObjects:myButton, nil];
    doneToolbar.items = itemsArray;
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10,0, Main_Screen_Width-20, 216)];
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate =self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
   
}

-(void)initTableView
{
    UIView * backGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-20, Main_Screen_Height-64-49-20)];
    backGroundView.backgroundColor =[UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    backGroundView.layer.cornerRadius = 5;
    [self.view addSubview:backGroundView];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _myInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20,350)style:UITableViewStyleGrouped];
    _myInfoTableView.backgroundColor = [UIColor clearColor];
    _myInfoTableView.delegate =self;
    _myInfoTableView.dataSource = self;
    _myInfoTableView.scrollEnabled = NO;
    [_myInfoTableView setTableFooterView:view];
    _myInfoTableView.sectionFooterHeight = 1.0;
    [backGroundView addSubview:_myInfoTableView];
    
    UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 365, Main_Screen_Width-40, 60)];
    [commitBt setImage:[UIImage imageNamed:@"info_commit.png"] forState:UIControlStateNormal];
    [backGroundView addSubview:commitBt];
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
    }
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
    [_myInfoTableView setSeparatorInset:UIEdgeInsetsMake(0,80, 0, 0)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UILabel * nameText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
    nameText.text =[nameArr objectAtIndex:indexPath.row];
    nameText.font = [UIFont systemFontOfSize:14.];
    if (indexPath.section ==1) {
        nameText.text = [nameArr objectAtIndex:5];
    }
    [cell.contentView addSubview:nameText];
    if (indexPath.section ==0&&indexPath.row==0) {
        nameText.frame = CGRectMake(10, 20, 50, 40);
        headView = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-40-70, 13, 60, 60)];
        headView.image =[UIImage imageNamed:@"defultImage.png"];
        //    UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(upLoad)];
        //    [headView addGestureRecognizer:pass1];
        //圆角设置
        headView.layer.cornerRadius = 30;
        headView.layer.masksToBounds = YES;
        //边框宽度及颜色设置
        [headView.layer setBorderWidth:2];
        [headView.layer setBorderColor:(__bridge CGColorRef)([UIColor grayColor])];
        [cell.contentView addSubview:headView];
    }
    if (indexPath.section==0) {
        cell.textLabel.text = [infoArr objectAtIndex:indexPath.row];
        if (indexPath.row ==1) {
            nameTextfield = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, Main_Screen_Width-80, 40)];
            nameTextfield.delegate = self;
            nameTextfield.text = @"小明";
            [cell.contentView addSubview:nameTextfield];
        }
        if (indexPath.row == 3 ) {
            sexTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, Main_Screen_Width-80, 40)];
            sexTextField.delegate = self;
            sexTextField.inputView = picker;
            sexTextField.inputAccessoryView = doneToolbar;
            [cell.contentView addSubview:sexTextField];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
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
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
    NSInteger row = [picker selectedRowInComponent:0];
    if(sexB)
    {
        sexB = NO;
        sexTextField.text= [pickerArr objectAtIndex:row];

    }else
    {
        sexTextField.text= @"";

    }
   
}
- (IBAction)selectButton:(id)sender {
    sexB=YES;
    [sexTextField resignFirstResponder];
    [nameTextfield resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
