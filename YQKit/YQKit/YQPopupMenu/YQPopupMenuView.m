//
//  YQPopupMenuView.m
//  YQKit
//
//  Created by world on 2018/11/26.
//  Copyright © 2018 xyq. All rights reserved.
//

#import "YQPopupMenuView.h"

@interface YQPopupMenuView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIView *originView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic, copy) void(^completeHandle)(NSUInteger index);
@property (nonatomic, strong) UIView *targetView;
@end

@implementation YQPopupMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        [self initSubView];
    }
    return self;
}

#pragma mark - init subView
- (void)initSubView {
    
    UIControl *control = [[UIControl alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    [control addTarget:self action:@selector(hideMenuView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:control];
    
    self.arrowImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowdown.png"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
    
//    self.originView = ({
//        UIView *view = [[UIView alloc]init];
//        view.backgroundColor = [UIColor whiteColor];
//        view;
//    });
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 44;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.layer.cornerRadius = 5;
        tableView.layer.masksToBounds = YES;
        tableView;
    });
    
    [self addSubview:self.arrowImageView];
    [self addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YQPopupMenuItemCell *cell = [YQPopupMenuItemCell cellWithTableView:tableView];
    [cell configCellWithTitle:self.titlesArray[indexPath.row] image:(indexPath.row < self.iconsArray.count) ? self.iconsArray[indexPath.row] : nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.completeHandle) {
        self.completeHandle(indexPath.row);
    }
    [self hideMenuView];
}

#pragma mark - public method
- (void)configMenuViewWithTitleArray:(NSArray *)titleArray iconArray:(NSArray *)iconArray completeHandle:(void(^)(NSUInteger index))completeHandle{
    self.titlesArray = titleArray;
    self.iconsArray = iconArray;
    self.completeHandle = completeHandle;
    
    [self.tableView reloadData];
}


- (void)showMenuViewWithTargetView:(UIView *)targetView {
    if (self.titlesArray.count == 0) {
        return;
    }
    
    self.targetView = targetView;
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
    
    
    CGRect rect = [self.targetView.superview convertRect:self.targetView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGFloat tableH = ((self.titlesArray.count > 4) ? 4 : self.titlesArray.count) * 44;
    __block CGFloat tableW = 0;
    [self.titlesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat actureW = [obj boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;

        if (actureW > tableW) {
            tableW = actureW;
        }
        
    }];
    tableW += 20;
    if (self.iconsArray.count > 0) {
        tableW += 30;
    }
    if (tableW < [UIApplication sharedApplication].keyWindow.frame.size.width / 3) {
        tableW = [UIApplication sharedApplication].keyWindow.frame.size.width / 3;
    }
    
    
    CGFloat arrowX = rect.origin.x+rect.size.width/2-15;
    if (arrowX < 15) {
        arrowX = 15;
    }
    if (arrowX + 30 > [UIApplication sharedApplication].keyWindow.frame.size.width - 15 ) {
        arrowX = [UIApplication sharedApplication].keyWindow.frame.size.width - 15 - 30;
    }
    
    CGFloat tableX = rect.origin.x+rect.size.width/2 - tableW/2;
    if (tableX < 15) {
        tableX = 15;
    }
    if (tableX + tableW > [UIApplication sharedApplication].keyWindow.frame.size.width - 15 ) {
        tableX = [UIApplication sharedApplication].keyWindow.frame.size.width - 15 - tableW;
    }
    
    if (rect.origin.y < [UIApplication sharedApplication].keyWindow.frame.size.height / 3 * 2) {
        // 下方
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        self.arrowImageView.frame = CGRectMake(arrowX, rect.origin.y+rect.size.height, 30, 15);
        self.tableView.frame = CGRectMake(tableX, CGRectGetMaxY(self.arrowImageView.frame)-2, tableW, tableH);
        
    } else {
        // 上方
        self.arrowImageView.frame = CGRectMake(arrowX, rect.origin.y-15, 30, 15);
        self.tableView.frame = CGRectMake(tableX, CGRectGetMinY(self.arrowImageView.frame)-tableH+2, tableW, tableH);
    }
    
    
}

- (void)hideMenuView {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end



#pragma mark -
#pragma mark -
#pragma mark -

@interface YQPopupMenuItemCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleImageView;
@end

@implementation YQPopupMenuItemCell

static NSString *YQPopupMenuItemCellIdentifier = @"YQPopupMenuItemCellIdentifier";

+ (YQPopupMenuItemCell *)cellWithTableView:(UITableView *)tableView {
    YQPopupMenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:YQPopupMenuItemCellIdentifier];
    if (!cell) {
        cell = [[YQPopupMenuItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:YQPopupMenuItemCellIdentifier];
    }
    cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel = ({
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        self.titleImageView = ({
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView;
        });
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.titleImageView];
    }
    return self;
}

- (void)configCellWithTitle:(NSString *)title image:(NSString *)image {
    self.titleLabel.text = title;
    self.titleImageView.image = [UIImage imageNamed:image];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.titleImageView.image) {
        self.titleImageView.frame = CGRectMake(10, 7, 30, 30);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.titleImageView.frame), 0, self.contentView.frame.size.width - 50, 44);
    } else {
        self.titleLabel.frame = CGRectMake(10, 0, self.contentView.frame.size.width - 20, 44);
    }
}
@end
