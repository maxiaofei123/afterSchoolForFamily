//
//  ImageSizeManager.m
//  微秘
//
//  Created by apple on 13-11-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ImageSizeManager.h"

@implementation ImageSizeManager

#define iphoneSize [[UIScreen mainScreen] bounds]
#define newSizeWidth [[UIScreen mainScreen] bounds].size.width * 2.0
#define newSizeHeight [[UIScreen mainScreen] bounds].size.height * 2.0

//转换成大图片
+(UIImage*)getMaxImageWithOldImage:(UIImage*)oldImage{
    CGSize newSize = [self changeImage:oldImage.size andScale:2];
    UIImage *newImage = [self imageWithImageSimple:oldImage scaledToSize:newSize];
    return newImage;
}
//转换中图片
+(UIImage*)getMidImageWithOldImage:(UIImage*)oldImage{
    CGSize newSize = [self changeImage:oldImage.size andScale:4];
    UIImage *newImage = [self imageWithImageSimple:oldImage scaledToSize:newSize];
    return newImage;
}
//转换成小图片
+(UIImage*)getSmallImageWithOldImage:(UIImage*)oldImage{
    CGSize newSize = [self changeImage:oldImage.size andScale:8];
    UIImage *newImage = [self imageWithImageSimple:oldImage scaledToSize:newSize];
    return newImage;
}

+(CGSize)changeImage:(CGSize)size andScale:(float)scale
{
    float newWidth =  newSizeWidth/scale;
    float newHeight = newSizeHeight/scale;
    CGSize newSize;
    
    if (size.width <=newWidth && size.height <=newHeight) {
        return size;
    }
    if (size.width>newWidth || size.height >newHeight) {
        if (size.width > size.height) {
            //如果宽大，就把宽度缩小到,高按同比例缩放
            newSize.width = newWidth;
            newSize.height = (int) ((newWidth/size.width) * size.height);
        }
        else if(size.width < size.height)
        {
            newSize.height = newHeight;
            newSize.width =(int) ((newHeight/size.height) * size.width);
        }else//宽高相同
        {
            newSize.width = newWidth;
            newSize.height = newWidth;
        }
    }
    return newSize;
}

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    NSData *data = UIImageJPEGRepresentation(newImage, 1.0);
    return newImage;
}

@end
