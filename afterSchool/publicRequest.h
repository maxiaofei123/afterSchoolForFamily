//
//  publicRequest.h
//  afterSchool
//
//  Created by susu on 15/3/4.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface publicRequest : NSObject


// 提交作业资源
+(void)commitResource:(NSString * )homeWorkId resource:(NSArray *)resourceArr resourceType:(NSString * )type;
// 通过文字确定lable高度
+(float)lableSizeWidth:(int)width content:(NSString *)str;

// 通过文字确定lable高度 16号字
+(float)lableSizeWidthFont16:(int)width content:(NSString *)str;

// 通过文字确定lable高度 18号字
+(float)lableSizeWidthFont18:(int)width content:(NSString *)str;
//将评分转换成可形式
+(NSString *)rateTostring:(NSString *)rate;
+(void)deleteHomewrk:(NSString *)workId;

+(NSString *)dateNow;
@end