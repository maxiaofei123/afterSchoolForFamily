//
//  Work_type_text_ViewController.h
//  afterSchool
//
//  Created by susu on 15/3/2.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Work_type_text_ViewController : UIViewController

@property(nonatomic,strong) NSString * textWorkId;

@property(nonatomic,assign) NSObject<UIViewPassValueDelegate> *delegate;
@end
