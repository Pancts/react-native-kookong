//
//  AirConditionViewController.h
//  kookongIphone
//
//  Created by shuaiwen on 16/1/18.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AirConditionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *modeLable;//模式
@property (weak, nonatomic) IBOutlet UILabel *temperatureLable;//温度
@property (weak, nonatomic) IBOutlet UILabel *handWindDirection;//显示首手动风向或自动风向
@property (weak, nonatomic) IBOutlet UILabel *windDirectionLable;//风向
@property (weak, nonatomic) IBOutlet UILabel *windPowerLable;//风量
@property (weak, nonatomic) IBOutlet UILabel *temperatureSmallLable;//温度加和温度减中间的温度leble

@property (weak, nonatomic) IBOutlet UIButton *_modestate;
@property (weak, nonatomic) IBOutlet UIButton *_powerstate;
@property (weak, nonatomic) IBOutlet UIButton *_swipestate;
@property (weak, nonatomic) IBOutlet UIButton *_makehote;
@property (weak, nonatomic) IBOutlet UIButton *_addtemperature;
@property (weak, nonatomic) IBOutlet UIButton *_windstate;
@property (weak, nonatomic) IBOutlet UIButton *_makecool;
@property (weak, nonatomic) IBOutlet UIButton *_subtempterature;
@property (weak, nonatomic) IBOutlet UIButton *_windpower;
@property (weak, nonatomic) IBOutlet UIButton *_sendwind;
@property (weak, nonatomic) IBOutlet UIButton *_drymodestate;
@property (weak, nonatomic) IBOutlet UIButton *_automodestate;
@property (weak, nonatomic) IBOutlet UIButton *_temperatureone;
@property (weak, nonatomic) IBOutlet UIButton *_temperaturetwo;
@property (weak, nonatomic) IBOutlet UIButton *_temperaturethree;
@property (weak, nonatomic) IBOutlet UIButton *_lowpower;
@property (weak, nonatomic) IBOutlet UIButton *_middlepower;
@property (weak, nonatomic) IBOutlet UIButton *_highpower;
@property (weak, nonatomic) IBOutlet UIButton *_autopower;

@property(nonatomic,strong)NSDictionary * ACDataSource;//红外码库
@property(nonatomic,copy)NSString * ACRemoteId;//remoteid


@property(nonatomic,copy)NSString * apikey;

@end
