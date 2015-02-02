//
//  Topic_myself_ViewController.h
//  afterSchool
//
//  Created by susu on 15/1/26.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Topic_myself_ViewController : UIViewController
/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^myselfTopicTapActionBlock)(NSInteger pageIndex);
@end
