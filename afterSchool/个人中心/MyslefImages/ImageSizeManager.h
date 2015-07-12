//
//  ImageSizeManager.h
//  微秘
//
//  Created by apple on 13-11-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSizeManager : NSObject

//转换成大图片
+(UIImage*)getMaxImageWithOldImage:(UIImage*)oldImage;
//获取中图片
+(UIImage*)getMidImageWithOldImage:(UIImage*)oldImage;
//转换成小图片
+(UIImage*)getSmallImageWithOldImage:(UIImage*)oldImage;
@end
