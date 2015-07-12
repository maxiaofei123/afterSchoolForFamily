//
//  H_login_ViewController.h
//  AfterSchool
//
//  Created by susu on 15-1-6.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol loginDelegate <NSObject>

-(void)initTableView;

@end

@interface H_login_ViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<loginDelegate> delegate;

@end
