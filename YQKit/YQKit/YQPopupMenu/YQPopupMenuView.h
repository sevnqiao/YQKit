//
//  YQPopupMenuView.h
//  YQKit
//
//  Created by world on 2018/11/26.
//  Copyright © 2018 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YQPopupMenuView : UIView
- (void)configMenuViewWithTitleArray:(NSArray *)titleArray iconArray:(NSArray *)iconArray completeHandle:(void(^)(NSUInteger index))completeHandle;
- (void)showMenuViewWithTargetView:(UIView *)targetView;
@end



@interface YQPopupMenuItemCell : UITableViewCell
+ (YQPopupMenuItemCell *)cellWithTableView:(UITableView *)tableView;
- (void)configCellWithTitle:(NSString *)title image:(NSString *)image;
@end
