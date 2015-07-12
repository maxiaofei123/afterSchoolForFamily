//
//  publicRequest.m
//  afterSchool
//
//  Created by susu on 15/3/4.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "publicRequest.h"

@implementation publicRequest


+(NSString *)dateNow
{
    //获得系统日期
    NSDate * senddate=[NSDate date];
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    NSString *monthStr ;
    NSString * dayStr;
    if (month <10) {
        monthStr = [NSString stringWithFormat:@"0%d",month];
    }else
    {
         monthStr = [NSString stringWithFormat:@"%d",month];
    }
    if (day <10) {
        dayStr = [NSString stringWithFormat:@"0%d",day];
    }else
    {
        dayStr = [NSString stringWithFormat:@"%d",day];
    }
    
    
    NSString * nsDateString= [NSString stringWithFormat:@"%d-%@-%@",year,monthStr,dayStr];
    return nsDateString;
}

+(NSString *)rateTostring:(NSString *)rate
{
//    int r = [rate integerValue];
//    NSLog(@"r= %d",r);
    NSArray * arr = [[NSArray alloc] initWithObjects:@"E",@"D",@"C",@"B",@"A", nil];
    if([rate isKindOfClass:[NSNull class]])
    {
        return @"已阅";
    }else
    {
        int r = [rate integerValue];
        if(r < 1)
            return @"已阅";
        return [arr objectAtIndex:r-1];
    }
    return @"已阅";
}
// 通过文字确定lable高度
+(float)lableSizeWidth:(int)width content:(NSString *)str
{
    if ([str isKindOfClass:[NSNull class]]) {
        return 0;
    }
    UIFont *font = [UIFont systemFontOfSize:14.];
    CGSize size = CGSizeMake( width, 2000);
    CGSize labelsize =[str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    float   h;
    h = labelsize.height>20?labelsize.height+5:20;
    return h;
}

// 通过文字确定lable高度 16号字
+(float)lableSizeWidthFont16:(int)width content:(NSString *)str
{
    UIFont *font = [UIFont systemFontOfSize:16.];
    CGSize size = CGSizeMake( width, 2000);
    CGSize labelsize =[str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    float   h;
    h = labelsize.height>20?labelsize.height+5:20;
    return h;
}

// 通过文字确定lable高度 18号字
+(float)lableSizeWidthFont18:(int)width content:(NSString *)str
{
    UIFont *font = [UIFont systemFontOfSize:18.];
    CGSize size = CGSizeMake( width, 2000);
    CGSize labelsize =[str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    float   h;
    h = labelsize.height>20?labelsize.height+5:20;
    return h;
}

+(void)deleteHomewrk:(NSString *)workId
{
//    curl -X DELETE http://127.0.0.1:3000/api/v1/home_works/1
//    - action: DELETE
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager DELETE:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works/%@",workId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"delete =%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteError =%@",error);
    }];
    
}

// 提交作业资源
+(void)commitResource:(NSString * )homeWorkId resource:(NSArray *)resourceArr resourceType:(NSString * )type
{
    NSLog(@"resouece =%@",resourceArr);
    for (int i =0;i<resourceArr.count ; i++) {
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works/%@/media_resources",homeWorkId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
            NSLog(@"type =%@",type);
            
            if ([type isEqualToString:@"image"]) {
                NSData *imageData =UIImageJPEGRepresentation([resourceArr objectAtIndex:i], 0.5);
                [formData appendPartWithFileData:imageData name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyImage_%d.jpg",i+1] mimeType:@"image/jpeg"];
            }
            else if([type isEqualToString:@"sound"])
            {
                NSFileManager* manager = [NSFileManager defaultManager];
                if ([manager fileExistsAtPath:[resourceArr objectAtIndex:0]]){
                    NSLog(@"文件大小 =%llu",[[manager attributesOfItemAtPath:[resourceArr objectAtIndex:0] error:nil] fileSize]);
                }
                NSData * mp3data = [NSData dataWithContentsOfFile:[resourceArr objectAtIndex:0]];
//                NSLog(@"mp3 data =%@",mp3data);
                [formData appendPartWithFileData:mp3data name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anySound_%d.mp3",i+1] mimeType:@"sound/*"];
            }
            else if([type isEqualToString:@"video"])
            {
                NSData * mp4data = [NSData dataWithContentsOfFile:[resourceArr objectAtIndex:0]];
//                NSLog(@"mp4 data =%@",mp3data);
                [formData appendPartWithFileData:mp4data name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyVideo_%d.mp4",i+1] mimeType:@"video/mp4"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary * dic =responseObject;
             NSLog(@"dic =%@",dic);
             HUD.labelText = @"提交成功。。。";
             [HUD hide:YES afterDelay:1.];
         }failure:^(AFHTTPRequestOperation *operation, NSError *error){
             NSLog(@"error =%@ ",error);
             HUD.labelText = @"请求失败,请检查网络链接";
             [HUD hide:YES afterDelay:1.];
         }  ];
    }

}


@end
