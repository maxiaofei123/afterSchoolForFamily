//
//  Work_type_photo_ViewController.h
//  afterSchool
//
//  Created by susu on 15/1/25.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Work_type_photo_ViewController : UIViewController
@property(nonatomic,strong) NSString * photoWorkId;
@property(nonatomic,strong) NSString * type;

@property(nonatomic,assign) NSObject<UIViewPassValueDelegate> *delegate;
@end
