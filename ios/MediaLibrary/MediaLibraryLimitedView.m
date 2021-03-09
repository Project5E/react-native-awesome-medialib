//
//  MediaLibraryLimitedView.m
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/14.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "MediaLibraryLimitedView.h"
#import "MediaPickerManager.h"
#import <Masonry/Masonry.h>
#import <PhotosUI/PHPhotoLibrary+PhotosUISupport.h>

@implementation MediaLibraryLimitedView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    UIView *backgourndView = [[UIView alloc] init];
    backgourndView.backgroundColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1];
    backgourndView.layer.cornerRadius = 8;
    backgourndView.layer.masksToBounds = YES;
    [self addSubview:backgourndView];
    [backgourndView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self).mas_offset(10);
      make.right.equalTo(self).mas_offset(-10);
      make.top.equalTo(self).mas_offset(16);
      make.bottom.equalTo(self).mas_offset(-16);
    }];
    
    UILabel *mainLabel = [[UILabel alloc] init];
    mainLabel.textColor = [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1];
    mainLabel.font = [UIFont systemFontOfSize:14];
    mainLabel.text = @"当前访问权限为“选中的照片”";
    [backgourndView addSubview:mainLabel];
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(backgourndView).mas_offset(16);
      make.top.equalTo(backgourndView).mas_offset(10);
    }];
    
    UILabel *subLabel = [[UILabel alloc] init];
    subLabel.textColor = [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1];
    subLabel.font = [UIFont systemFontOfSize:14];
    subLabel.text = @"可以前往“设置”允许访问“全部照片”";
    [backgourndView addSubview:subLabel];
    [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(mainLabel);
      make.bottom.equalTo(backgourndView.mas_bottom).mas_offset(-10);
    }];
    
    UIButton *goToSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goToSettingButton.titleLabel.font = [UIFont systemFontOfSize:14];
    goToSettingButton.layer.cornerRadius = 4;
    goToSettingButton.layer.masksToBounds = YES;
    [goToSettingButton setBackgroundColor:[UIColor whiteColor]];
    [goToSettingButton setTitle:@"去设置" forState:UIControlStateNormal];
    [goToSettingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [goToSettingButton addTarget:self action:@selector(goToSetting:) forControlEvents:UIControlEventTouchUpInside];
    [backgourndView addSubview:goToSettingButton];
    [goToSettingButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.width.mas_equalTo(64);
      make.height.mas_equalTo(24);
      make.right.equalTo(backgourndView).mas_offset(-16);
      make.centerY.equalTo(backgourndView);
    }];
  }
  return self;
}


- (void)goToSetting:(UIButton *)sender {
  [[MediaPickerManager manager] jumpToSetting];
}

@end
