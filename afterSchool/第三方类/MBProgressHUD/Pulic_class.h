//
//  Pulic_class.h
//  Mfeiji
//
//  Created by susu on 14-10-20.
//  Copyright (c) 2014年 susu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pulic_class : NSObject


+ (void)sendLinkContent:(int)type title:(NSString *)strTitle image:(UIImage *)image url:(NSString *)url
;
+(void)commitMySelfAvatar:(UIImage *)imageView;
+(void)commitMySelfmessage:(NSString *)canshu canshuZhi:(NSString *)params;

+(NSString *)getTime;
@end
