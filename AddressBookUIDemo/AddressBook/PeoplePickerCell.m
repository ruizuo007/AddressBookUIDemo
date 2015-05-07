//
//  PeoplePickerCell.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/2.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "PeoplePickerCell.h"

@interface PeoplePickerCell ()

@end

@implementation PeoplePickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    CGFloat x = 0;
    CGFloat y = 0;
    CGRect frame = CGRectZero;
    [_imgv_member sizeToFit];
    frame = _imgv_member.frame;
    x = 10;
    y = (self.frame.size.height - frame.size.height) * 0.5;
    frame.origin.x = x;
    frame.origin.y = y;
    _imgv_member.frame = frame;
    [_lb_main sizeToFit];
    [_lb_sub sizeToFit];
    x += (frame.size.width + 5);
    y = (self.frame.size.height - _lb_main.frame.size.height - _lb_sub.frame.size.height) * 0.5;
    frame = _lb_main.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    _lb_main.frame = frame;
    y += _lb_main.frame.size.height;
    frame = _lb_sub.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    _lb_sub.frame = frame;
}

#pragma mark - private methods

- (void)setup {
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    _lb_main = [[UILabel alloc] init];
    _lb_sub = [[UILabel alloc] init];
    [_lb_sub setTextColor:[UIColor colorWithRed:26.0 / 255.0 green:118.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    [_lb_sub setFont:[UIFont systemFontOfSize:13]];
    _imgv_member = [[UIImageView alloc] init];
    _imgv_member.contentMode = UIViewContentModeScaleAspectFit;
    _imgv_backGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h - 1.0)];
    _imgv_rightArrow = [[UIImageView alloc] init];
    
    [self.contentView addSubview:_lb_main];
    [self.contentView addSubview:_lb_sub];
    [self.contentView addSubview:_imgv_member];
    [self.contentView addSubview:_imgv_backGround];
    [self.contentView addSubview:_imgv_rightArrow];
    
    _seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, h - 2.0, w - 15.0, 1.0)];
    _seperatorLine.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    _seperatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_seperatorLine];
}

@end
