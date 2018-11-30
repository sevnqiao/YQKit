//
//  YQPopupMenuViewController.m
//  YQKit
//
//  Created by world on 2018/11/26.
//  Copyright © 2018 xyq. All rights reserved.
//

#import "YQPopupMenuViewController.h"
#import "YQPopupMenuView.h"

@interface YQPopupMenuViewController ()

@end

@implementation YQPopupMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    
}

- (IBAction)popupMenu:(UIButton *)sender {
    YQPopupMenuView *menuView = [[YQPopupMenuView alloc]init];
    [menuView configMenuViewWithTitleArray:@[@"条目一",@"条目二",@"条目三",@"条目四",@"条目一",@"条目二",@"条目三",@"条目四"] iconArray:@[@"tiaoshi",@"tiaoshi",@"tiaoshi",@"tiaoshi",@"tiaoshi",@"tiaoshi",@"tiaoshi",@"tiaoshi"] completeHandle:^(NSUInteger index) {
        NSLog(@"%@", @(index));
    }];
    [menuView showMenuViewWithTargetView:sender];
    
}


@end
