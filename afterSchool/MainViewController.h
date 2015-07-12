//
//  MainViewController.h
//  Mfeiji
//
//  Created by susu on 14-10-24.
//  Copyright (c) 2014年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITabBarController


-(void)showTabBar;
-(void)hiddenTabBar;

-(void)loadViewControllers;
-(void)loadCustumTabBarView;
-(void)hiddenTabBarNo;
-(void)hiddenTabBarYes;
-(void)changeViewController:(UIButton *)sender;
@end
