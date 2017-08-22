 //
//  AirConditionViewController.m
//  kookongIphone
//
//  Created by shuaiwen on 16/1/18.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import "AirConditionViewController.h"
#import "IRConstants.h"
#import "KKACManager.h"
#import "KookongSDK.h"
@interface AirConditionViewController ()
- (IBAction)modeState:(id)sender;
- (IBAction)powerState:(id)sender;
- (IBAction)windSwipe:(id)sender;
- (IBAction)makeHot:(id)sender;
- (IBAction)addTemperature:(id)sender;
- (IBAction)windDirection:(id)sender;
- (IBAction)makeCool:(id)sender;
- (IBAction)subtractTemperature:(id)sender;
- (IBAction)windPower:(id)sender;
- (IBAction)sendWind:(id)sender;
- (IBAction)removeWet:(id)sender;
- (IBAction)autoModeState:(id)sender;
- (IBAction)setTemperatureOne:(id)sender;
- (IBAction)setTemperatureTwo:(id)sender;
- (IBAction)setTemperatureThree:(id)sender;
- (IBAction)setLowWindPower:(id)sender;
- (IBAction)setMiddleWindPower:(id)sender;
- (IBAction)setHighWindPower:(id)sender;
- (IBAction)autoWindPower:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
- (IBAction)downloadACData:(id)sender;
@end

@implementation AirConditionViewController
{
    KKACManager * manager;
    KookongSDK * _kookong;
    int modeState;//模式
    int powerState;//开关状态
    int temperature;//温度
    int windState;//风的状态（扫风／固定风）
    int windPower;//风量
    NSMutableArray * modeBtnArray;//存储模式button的数组
    NSMutableArray * tempBtnArray;//存储温度button的数组
    NSMutableArray * winPBtnArray;//存储风量button的数组
    NSMutableArray * winSBtnArray;//存储风向button的数组
}
-(id)init
{
    if (self=[super init]) {
        manager=[[KKACManager alloc] init];
        _kookong=[KookongSDK shareKooKongSDK];
        modeBtnArray=[[NSMutableArray alloc] init];
        tempBtnArray=[[NSMutableArray alloc] init];
        winPBtnArray=[[NSMutableArray alloc] init];
        winSBtnArray=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkUserAuthorityAndRegisterNotice];
}
-(void)checkUserAuthorityAndRegisterNotice
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataSource:) name:@"downloadsuccess" object:nil];//注册通知中心，接收数据。
}
-(void)getDataSource:(NSNotification*)notification
{
     NSArray * array=[NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",array);
    NSDictionary * dictionary=array[2];
    NSArray * arr=dictionary[@"irDataList"];
    NSDictionary * dictionary2=arr[0];
    self.ACRemoteId=self.textfield.text;
    self.ACDataSource=dictionary2;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self assignAndHandleAirData];//赋值
        [self getAllKindsOfBtnArray];//将每个button加入数组
        [self initModeStateAndValue];//根据码库数据，更改面板显示和button是否可点击
    });
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSString * showString=[NSString stringWithFormat:@"%d,%d,%d,%d,%d",modeState,powerState,temperature,windPower,windState];
    [[NSUserDefaults standardUserDefaults] setObject:showString forKey:self.ACRemoteId];//保存当前模式及模式下对应的状态
    [[NSUserDefaults standardUserDefaults] setObject:[manager getAirConditionAllModeAndValue] forKey:[NSString stringWithFormat:@"air%@air",self.ACRemoteId]];
}

-(BOOL)isFirstUser
{
    BOOL isFirst=NO;
    NSDictionary * _dict=[[NSUserDefaults standardUserDefaults] objectForKey:self.ACRemoteId];
    if (_dict==NULL) {
        isFirst=YES;
    }
    else
    {
        isFirst=NO;
    }
    return isFirst;
}


-(void)assignAndHandleAirData
{
    manager.apikey=self.apikey;//验证apikey
    manager.AC_RemoteId=self.ACRemoteId;//空调的remoteid
    manager.airDataDict=self.ACDataSource;//空调的红外码库
    NSLog(@"%p",manager);
    if ([self isFirstUser]) {//是第一次使用。
        [manager airConditionModeDataHandle];//空调数据处理。
    }
    if ([self isFirstUser]==NO) {//不是第一次使用
        NSArray * array=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"air%@air",self.ACRemoteId]];
        for (NSArray * arr in array ) {
            [manager readAirConditionStateAndValueWihtModestate:[arr[0] intValue] powerState:[arr[1] intValue] temperature:[arr[2] intValue] windPower:[arr[3] intValue] windState:[arr[4] intValue]isShowState:NO];
        }
        NSArray * showArray=[[[NSUserDefaults standardUserDefaults] objectForKey:self.ACRemoteId] componentsSeparatedByString:@","];
        [manager readAirConditionStateAndValueWihtModestate:[showArray[0] intValue] powerState:[showArray[1] intValue] temperature:[showArray[2] intValue] windPower:[showArray[3] intValue] windState:[showArray[4] intValue] isShowState:YES];
    }
    powerState=[manager getPowerState];//得到开关的状态
}

//根据码库数据，更改面板显示
-(void)initModeStateAndValue
{
    [self getModeStateValue];//面板展示
    [self changeModeStateButtonAndWindStateBackgroundColor];//设置模式和风向的button
    [self changeButtonBackgroundColor];//设置面板温度button，风量butotn
}

//将button添加在数组中，
-(void)getAllKindsOfBtnArray
{//给除开关以外的其它案件设置tag
    self._modestate.tag=1500+MODESTATEBUTTON_TAG;//模式
    self._makecool.tag=1501+MODESTATEBUTTON_TAG;//制冷
    self._makehote.tag=1502+MODESTATEBUTTON_TAG;//制热
    self._automodestate.tag=1503+MODESTATEBUTTON_TAG;//自动
    self._sendwind.tag=1504+MODESTATEBUTTON_TAG;//送风
    self._drymodestate.tag=1505+MODESTATEBUTTON_TAG;//除湿
    
    self._addtemperature.tag=0+TEMPERATUREBUTTON_TAG;//+
    self._subtempterature.tag=1+TEMPERATUREBUTTON_TAG;//-
    self._temperatureone.tag=2+TEMPERATUREBUTTON_TAG;//17度
    self._temperaturetwo.tag=3+TEMPERATUREBUTTON_TAG;//27度
    self._temperaturethree.tag=4+TEMPERATUREBUTTON_TAG;//20度
    
    self._autopower.tag=0+WINDPOWERBUTTON_TAG;//自动风量
    self._lowpower.tag=1+WINDPOWERBUTTON_TAG;//低
    self._middlepower.tag=2+WINDPOWERBUTTON_TAG;//中
    self._highpower.tag=3+WINDPOWERBUTTON_TAG;//高
    self._windpower.tag=4+WINDPOWERBUTTON_TAG;//风量
    
    self._swipestate.tag=0+WINDSTATEBUTTON_TAG;//扫风
    self._windstate.tag=1+WINDSTATEBUTTON_TAG;//风向
    
    [modeBtnArray addObject:self._modestate];
    [modeBtnArray addObject:self._makecool];
    [modeBtnArray addObject:self._makehote];
    [modeBtnArray addObject:self._automodestate];
    [modeBtnArray addObject:self._sendwind];
    [modeBtnArray addObject:self._drymodestate];
    
    [tempBtnArray addObject:self._addtemperature];
    [tempBtnArray addObject:self._subtempterature];
    [tempBtnArray addObject:self._temperatureone];
    [tempBtnArray addObject:self._temperaturetwo];
    [tempBtnArray addObject:self._temperaturethree];
    
    [winPBtnArray addObject:self._lowpower];
    [winPBtnArray addObject:self._middlepower];
    [winPBtnArray addObject:self._highpower];
    [winPBtnArray addObject:self._autopower];
    [winPBtnArray addObject:self._windpower];
    
    [winSBtnArray addObject:self._swipestate];
    [winSBtnArray addObject:self._windstate];
}

#pragma mark-------------------按钮点击事件--------------------

- (IBAction)modeState:(id)sender {
    NSArray * array=[manager getAllModeState];
    for (int i=0; i<=array.count-1; i++) {
        if (modeState==[array[i] intValue]) {
            if (i==array.count-1) {
                [manager changeModeStateWithModeState:[array[0] intValue]];
            }
            if (i!=array.count-1) {
                [manager changeModeStateWithModeState:[array[i+1] intValue]];
            }
            break;
        }
    }
    [self getModeStateValue];
    NSLog(@"所有的模式：%@",[manager getAllWindPower]);
    [self changeButtonBackgroundColor];//面板的lable和按键可能会随着模式的变化而变化
    NSMutableString * ACInfrared=[[NSMutableString alloc] init];
    for (NSNumber * string in [manager getAirConditionInfrared]) {
        [ACInfrared appendFormat:@"%02X",[string unsignedCharValue]];
    }
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)powerState:(id)sender {
    if (powerState==AC_POWER_ON) {
        [manager changePowerStateWithPowerstate:AC_POWER_OFF];
    }
    if (powerState==AC_POWER_OFF) {
        [manager changePowerStateWithPowerstate:AC_POWER_ON];
    }
    powerState=[manager getPowerState];
    [self getModeStateValue];
    [self changeButtonBackgroundColor];
    [self changeModeStateButtonAndWindStateBackgroundColor];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)windSwipe:(id)sender {
    [manager changeWindStateWithWindState:0];//0，表示扫风
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)makeHot:(id)sender {
   [manager changeModeStateWithModeState:TAG_AC_MODE_HEAT_FUNCTION];
    [self getModeStateValue];
    [self changeButtonBackgroundColor];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)addTemperature:(id)sender {
    if ([manager canControlTemp]==YES&&temperature<TEMPERATUREMAX&&[[manager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",temperature+1]]==NO)
    {
        [manager changeTemperatureWithTemperature:temperature+1];
        [self getModeStateValue];
        if (temperature<30&&[[manager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",temperature+1]]==NO) {
            [self setWorkingButtonTitleColor:self._subtempterature];
        }
        else {
            [self setDisableButtonTitleColor:self._addtemperature];
        }
        NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
    }
}

- (IBAction)windDirection:(id)sender {
    NSArray * array=[manager getAllWindState];
    NSLog(@"%@",array);
    for (int i=0; i<=array.count-1; i++) {
        if (windState==[array[i] intValue]) {
            if (i==array.count-1) {
                [manager changeWindStateWithWindState:[array[0] intValue]];
            }
            if (i!=array.count-1) {
                [manager changeWindStateWithWindState:[array[i+1] intValue]];
            }
            break;
        }
    }
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)makeCool:(id)sender {
    [manager changeModeStateWithModeState:TAG_AC_MODE_COOL_FUNCTION];
    [self getModeStateValue];
    [self changeButtonBackgroundColor];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)subtractTemperature:(id)sender {
    if (([manager canControlTemp]==YES&&temperature>TEMPERATUREMIN)&&[[manager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",temperature-1]]==NO) {
        [manager changeTemperatureWithTemperature:temperature-1];
        [self getModeStateValue];
        [self setWorkingButtonTitleColor:self._addtemperature];
        if (temperature>16&&[[manager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",temperature-1]]==NO) {
            [self setWorkingButtonTitleColor:self._addtemperature];
        }
        else
        {
            [self setDisableButtonTitleColor:self._subtempterature];
        }
        NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
    }
}

- (IBAction)windPower:(id)sender {
    NSArray * array=[manager getAllWindPower];
    NSLog(@"allWindPower:%@",array);
    if (array!=NULL) {
        for (int i=0; i<=array.count-1; i++) {
            if (windPower==[array[i] intValue]) {
                if (i==array.count-1) {
                    [manager changeWindPowerWithWindpower:[array[0] intValue]];
                }
                if (i!=array.count-1) {
                    [manager changeWindPowerWithWindpower:[array[i+1] intValue]];
                }
                break;
            }
        }
        
        [self getModeStateValue];
        NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
    }
    
}

- (IBAction)sendWind:(id)sender {
    [manager changeModeStateWithModeState:TAG_AC_MODE_FAN_FUNCTION];
    [self getModeStateValue];
    [self changeButtonBackgroundColor];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)removeWet:(id)sender {
    [manager changeModeStateWithModeState:TAG_AC_MODE_DRY_FUNCTION];
    [self getModeStateValue];
    [self changeButtonBackgroundColor];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)autoModeState:(id)sender{
    [manager changeModeStateWithModeState:TAG_AC_MODE_AUTO_FUNCTION];
    [self getModeStateValue];
    [self changeButtonBackgroundColor];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)setTemperatureOne:(id)sender {
    [manager changeTemperatureWithTemperature:BUTTONTEMP1];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)setTemperatureTwo:(id)sender {
    [manager changeTemperatureWithTemperature:BUTTONTEMP2];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)setTemperatureThree:(id)sender {
    [manager changeTemperatureWithTemperature:BUTTONTEMP3];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)setLowWindPower:(id)sender {
    [manager changeWindPowerWithWindpower:AC_WIND_SPEED_LOW];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)setMiddleWindPower:(id)sender {
    [manager changeWindPowerWithWindpower:AC_WIND_SPEED_MEDIUM];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

- (IBAction)setHighWindPower:(id)sender {
    [manager changeWindPowerWithWindpower:AC_WIND_SPEED_HIGH];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}
- (IBAction)autoWindPower:(id)sender{
    
    [manager changeWindPowerWithWindpower:AC_WIND_SPEED_AUTO];
    [self getModeStateValue];
    NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
}

#pragma mark--------------------------面板显示部分------------------------------

//获得当前模式下的状态值并展示
-(void)getModeStateValue
{
    if (powerState==AC_POWER_ON) {//开关打开时，面板显示
        [self modestateLableShow];//模式显示
        [self windDirectionLabelShow];//风向显示
        [self windPowerLableShow];//风量显示
        [self temperatureLableShow];//温度显示
   }
    if (powerState==AC_POWER_OFF) {
        [self showLableTextNULL];//开关关闭时，面板显示
    }
}

#pragma mark------------------可以根据自己需求修改面板显示的部分----------------
//开关处于关闭状态下lable显示
-(void)showLableTextNULL
{
    self.modeLable.text=@"";
    self.handWindDirection.text=@"";
    self.windDirectionLable.text=@"";
    self.windPowerLable.text=@"";
    self.temperatureLable.text=@"";
}

//显示模式
-(void)modestateLableShow
{
    modeState=[manager getModeState];//得到当前的模式
        switch (modeState) {
            case TAG_AC_MODE_COOL_FUNCTION:
                self.modeLable.text=@"制冷";//制冷模式下，模式leble的显示
                break;
            case TAG_AC_MODE_HEAT_FUNCTION:
                self.modeLable.text=@"制热";//制热模式下，模式lable的显示
                break;
            case TAG_AC_MODE_AUTO_FUNCTION:
                self.modeLable.text=@"自动";//自动模式下，模式lable的显示
                break;
            case TAG_AC_MODE_FAN_FUNCTION:
                self.modeLable.text=@"送风";//送风模式下，模式label的显示
                break;
            case TAG_AC_MODE_DRY_FUNCTION:
                self.modeLable.text=@"除湿";//除湿模式下，模式label的显示
            default:
                break;
        }
}

//显示风向
-(void)windDirectionLabelShow
{
    windState=[manager getWindState];//得到当前风量
    switch (windState) {
        case 0:
            self.windDirectionLable.text=@"扫风";
            break;
        case 1:
            self.windDirectionLable.text=@"下";
            break;
        case 2:
            self.windDirectionLable.text=@"中";
            break;
        case 3:
            self.windDirectionLable.text=@"上";
            break;
        case 4:
            self.windDirectionLable.text=@"风向4";
            break;
        case 5:
            self.windDirectionLable.text=@"风向5";
            break;
        case 6:
            self.windDirectionLable.text=@"风向6";
        default:
            break;
    }
    if (windState==0) {
        self.handWindDirection.text=@"自动风向";//风向为扫风，显示为自动风向
    }
    if (windState!=0) {
        self.handWindDirection.text=@"手动风向";//风向不为扫风，显示为手动风向
    }
    if ([manager canControlWindState]==NO)
    {
        self.windDirectionLable.text=@"";//风向按键失效，风向显示为空
    }
    self.handWindDirection.numberOfLines=0;
}
//显示风量
-(void)windPowerLableShow
{
    windPower=[manager getWindPower];//得到前模式下对应的风量
    switch (windPower) {
        case AC_WIND_SPEED_AUTO:
            self.windPowerLable.text=@"风量自动";
            break;
        case AC_WIND_SPEED_LOW:
            self.windPowerLable.text=@"风量低";
            break;
        case AC_WIND_SPEED_MEDIUM:
            self.windPowerLable.text=@"风量中";
            break;
        case AC_WIND_SPEED_HIGH:
            self.windPowerLable.text=@"风量高";
        default:
            break;
    }
}
//显示温度
-(void)temperatureLableShow
{
    if ([manager canControlTemp]==NO) {
        self.temperatureLable.text=@"NA";//当前模式下，温度不可调
    }
    if ([manager canControlTemp]==YES) {
        temperature=[manager getTemperature];
        self.temperatureLable.text=[NSString stringWithFormat:@"%d",temperature];//当前模式下温度可调
    }
}

//将对应模式下不能点击的按钮关闭交互，改变颜色
-(void)setDisableButtonTitleColor:(UIButton*)button
{
    button.userInteractionEnabled=NO;
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}
//将对应模式下的能点击的按钮，打开交互，改变颜色
-(void)setWorkingButtonTitleColor:(UIButton*)button
{
    button.userInteractionEnabled=YES;
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

#pragma mark-----------------------------------------------------------------
-(void)changeModeStateButtonAndWindStateBackgroundColor
{
    [self._powerstate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    if (powerState==AC_POWER_ON) {
        [self.temperatureSmallLable setTextColor:[UIColor blueColor]];
    }
    if (powerState==AC_POWER_OFF) {
        [self.temperatureSmallLable setTextColor:[UIColor grayColor]];
    }
    //所有button在开关为AC_POWER_ON的前提下，设置是否可以被点击
    for (UIButton * button in modeBtnArray) {
        
        if ([manager canModeStateButtonClickWithTag:button.tag]==YES&&powerState==AC_POWER_ON) {
            [self setWorkingButtonTitleColor:button];
        }
        else{
            [self setDisableButtonTitleColor:button];
        }
    }
    for (UIButton * button in winSBtnArray) {
            //button.tag值为12000~12001
        if ([manager canWindStateButtonClickWithTag:button.tag]==YES&&powerState==AC_POWER_ON) {
            [self setWorkingButtonTitleColor:button];
        }
        else{
            [self setDisableButtonTitleColor:button];
        }
    }
}

-(void)changeButtonBackgroundColor
{
     //所有button在开关为AC_POWER_ON的前提下，设置是否可以被点击
        for (UIButton  * button in tempBtnArray) {
        if (([manager canTemperatureButtonClickWithTag:button.tag]==YES)&&powerState==AC_POWER_ON) {
            //调用方法，得到当前状态下温度是否可控，设置button是否可以点击
            [self setWorkingButtonTitleColor:button];
        }
        else{
            [self setDisableButtonTitleColor:button];
        }
    }
    for (UIButton * button in winPBtnArray) {
        if ([manager canWindPowerButtonClickWithTag:button.tag]==YES&&powerState==AC_POWER_ON) {
            [self setWorkingButtonTitleColor:button];
        }
        else{
            [self setDisableButtonTitleColor:button];
        }
    }
}

- (IBAction)downloadACData:(id)sender {
    [_kookong downloadIRDataByIdWithRemoteId:self.textfield.text deviceTypeId:[NSNumber numberWithInt:5]];
//     [_kookong getAirConditionIRDataWithRemoteId:[[NSNumber alloc] initWithInt:[self.textfield.text intValue]]];
}
@end
