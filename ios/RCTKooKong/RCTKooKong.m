#import "RCTKooKong.h"


@interface RCTKooKong : NSObject<RCTBridgeModule>
@property(nonatomic,copy)NSString * rid;
@property(nonatomic,copy)NSString * apikey;
@end


@implementation RCTKooKong
{
    KookongSDK * kookong;
    KKACManager * manager;
    RCTResponseSenderBlock onGetBrandListFromNetDataSourceSuccess;
    RCTResponseSenderBlock onGetBrandListFromNetDataSourceError;
    RCTResponseSenderBlock testIRDataByIdDataSourceSuccess;
    RCTResponseSenderBlock getIRDataByIdDataSourceSuccess;
    RCTResponseSenderBlock getAllRemoteIdsDataSourceSuccess;
    RCTResponseSenderBlock powerOnDataSourceSuccess;
    RCTResponseSenderBlock powerOffDataSourceSuccess;
    RCTResponseSenderBlock testIRDataByIdDataSourceError;
    RCTResponseSenderBlock getIRDataByIdDataSourceError;
    RCTResponseSenderBlock getAllRemoteIdsDataSourceError;
    RCTResponseSenderBlock powerOnDataSourceError;
    RCTResponseSenderBlock powerOffDataSourceError;

}
RCT_EXPORT_MODULE();

- (instancetype)init
{
    kookong=[KookongSDK shareKooKongSDK];
    manager=[[KKACManager alloc] init];
    return self;
}


RCT_EXPORT_METHOD(initKooKongSDK:(NSString * _Nonnull)key
                  string:(NSString * _Nonnull)deviceId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

  NSLog(@"initKooKongSDK key: %@", key);
  NSLog(@"initKooKongSDK deviceId: %@", deviceId);
  self.apikey = key;
  [kookong checkUserAuthority:key deviceId:deviceId];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBrandListFromNetDataSource:) name:@"downloadsuccess" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testIRDataByIdDataSource:) name:@"downloadsuccess" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getIRDataByIdDataSource:) name:@"downloadsuccess" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllRemoteIdsDataSource:) name:@"downloadsuccess" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerOnDataSource:) name:@"downloadsuccess" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerOffDataSource:) name:@"downloadsuccess" object:nil];
}

-(void)getBrandListFromNetDataSource:(NSNotification * )notification
{
    // notification.userInfo[@"data”];   //这就是返回的数据,是NSData类型，转成相对应的数据类型即可使用
    // notification.userInfo[@"taskid"];    //区分是什么操作
    NSLog(@"taskid - %@",notification.userInfo[@"taskid"]);
    NSLog(@"errorCode - %@",notification.userInfo[@"errorCode"]);
    if ([notification.userInfo[@"errorCode"] intValue] == -1) {
      onGetBrandListFromNetDataSourceError(@[@'onGetBrandListFromNetDataSourceError']);
    }

    if ([notification.userInfo[@"taskid"] intValue] == 7) {
      id jsonObject = [NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
      NSArray *jsonArray = (NSArray *)jsonObject;
      NSLog(@"jsonArray - %@",jsonArray);
      NSDictionary *jsonDictionary = [jsonArray objectAtIndex:2];
      NSArray *dataArray = [jsonDictionary objectForKey:@"brandList"];
      onGetBrandListFromNetDataSourceSuccess(@[dataArray]);
    }
}


RCT_EXPORT_METHOD(getBrandListFromNet:(NSNumber * _Nonnull)deviceType
                  callback:(RCTResponseSenderBlock)success
                  callback:(RCTResponseSenderBlock)error)
{

  NSLog(@"getBrandListFromNet deviceType: %@", deviceType);
  // -(void)getBrandListFromNetWithDid:(NSNumber * )did;
  onGetBrandListFromNetDataSourceSuccess = success;
  onGetBrandListFromNetDataSourceError = error;
  [kookong getBrandListFromNetWithDid:deviceType];
}

// -(void)AC_DataDownloadSuccess:(NSNotification*)notification
// {
//     airConditionData=[[NSArray alloc] init];
//     NSArray * array=[NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
// //    NSLog(@"%@",array);
//     NSDictionary * dictionary=array[2];
//     NSArray * arr=dictionary[@"irDataList"];
//     NSDictionary * dictionary2=arr[0];
//     if ([dictionary2[@"type"] intValue]==1) {
//          airConditionData=dictionary2[@"keys"];
//         dispatch_async(dispatch_get_main_queue(), ^{
//             [self createFunctionButton:dictionary2[@"keys"]];
//         });
//
//     }
//     if ([dictionary2[@"type"] intValue]==2) {
//          NSLog(@"**************该数据为有状态空调数据,请打开另一个面板***************");
//     }
// }



// @ReactMethod
// public void testIRDataById(final String rid,
//                                 final int deviceType,
//                                 final Callback successCallback,
//                                 final Callback errorCallback) {

RCT_EXPORT_METHOD(testIRDataById:(NSString * _Nonnull)rid
                  string:(NSNumber * _Nonnull)deviceType
                  callback:(RCTResponseSenderBlock)success
                  callback:(RCTResponseSenderBlock)error)
{
  testIRDataByIdDataSourceSuccess = success;
  testIRDataByIdDataSourceError = error;
  // testIRDataByIdWithRemoteId:(NSString *)remoteId deviceTypeId:(NSNumber *)deviceTypeId;
  //notification.userInfo[@"taskid"]=19
  [kookong testIRDataByIdWithRemoteId:rid deviceTypeId:deviceType];
}
-(void)testIRDataByIdDataSource:(NSNotification * )notification
{
    // notification.userInfo[@"data”];   //这就是返回的数据,是NSData类型，转成相对应的数据类型即可使用
    // notification.userInfo[@"taskid"];    //区分是什么操作
    NSLog(@"taskid - %@",notification.userInfo[@"taskid"]);
    NSLog(@"errorCode - %@",notification.userInfo[@"errorCode"]);
    if ([notification.userInfo[@"errorCode"] intValue] == -1) {
      testIRDataByIdDataSourceError(@[@'getIRDataByIdDataSourceError']);
    }
    if ([notification.userInfo[@"taskid"] intValue] == 19) {
      /* code */
      id jsonObject = [NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
      NSArray *jsonArray = (NSArray *)jsonObject;
      NSLog(@"jsonArray - %@",jsonArray);
      NSDictionary *jsonDictionary = [jsonArray objectAtIndex:2];
      NSArray *dataArray = [jsonDictionary objectForKey:@"brandList"];
      testIRDataByIdDataSourceSuccess(@[dataArray]);
    }


}
// @ReactMethod
// public void getIRDataById(final String rid,
//                            final int deviceType,
//                            final Callback successCallback,
//                            final Callback errorCallback) {
RCT_EXPORT_METHOD(getIRDataById:(NSString * _Nonnull)rid
                  string:(NSNumber * _Nonnull)deviceType
                  callback:(RCTResponseSenderBlock)success
                  callback:(RCTResponseSenderBlock)error)
{
  getIRDataByIdDataSourceSuccess = success;
  getIRDataByIdDataSourceError = error;
  //-(void)downloadIRDataByIdWithRemoteId:(NSString *)remoteId deviceTypeId:(NSNumber *)deviceTypeId;
  [kookong downloadIRDataByIdWithRemoteId:rid deviceTypeId:deviceType];
}
-(void)getIRDataByIdDataSource:(NSNotification * )notification
{
    // notification.userInfo[@"data”];   //这就是返回的数据,是NSData类型，转成相对应的数据类型即可使用
    // notification.userInfo[@"taskid"];    //区分是什么操作
    NSLog(@"taskid - %@",notification.userInfo[@"taskid"]);
    NSLog(@"errorCode - %@",notification.userInfo[@"errorCode"]);
    if ([notification.userInfo[@"errorCode"] intValue] == -1) {
      getIRDataByIdDataSourceError(@[@'getIRDataByIdDataSourceError']);
      getIRDataByIdDataSourceSuccess = nil;
      getIRDataByIdDataSourceError = nil;
    }
    if ([notification.userInfo[@"taskid"] intValue] == 20 && getIRDataByIdDataSourceSuccess != nil) {
      /* code */
      id jsonObject = [NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
      NSArray *jsonArray = (NSArray *)jsonObject;
      NSLog(@"jsonArray - %@",jsonArray);
      NSDictionary *jsonDictionary = [jsonArray objectAtIndex:2];
      NSArray *dataArray = [jsonDictionary objectForKey:@"brandList"];
      getIRDataByIdDataSourceSuccess(@[dataArray]);
      getIRDataByIdDataSourceSuccess = nil;
      getIRDataByIdDataSourceError = nil;
    }


}
// @ReactMethod
// public void getAllRemoteIds(final int deviceType,
//                             final int brandId,
//                           final Callback successCallback,
//                           final Callback errorCallback) {
RCT_EXPORT_METHOD(getAllRemoteIds:(NSNumber * _Nonnull)deviceType
                  string:(NSNumber * _Nonnull)brandId
                  callback:(RCTResponseSenderBlock)success
                  callback:(RCTResponseSenderBlock)error)
{
  getAllRemoteIdsDataSourceSuccess = success;
  getAllRemoteIdsDataSourceError = error;
  // -(void)getAllRemoteIdsWithDid:(NSNumber *)did bid:(NSNumber *)bid;
  [kookong getAllRemoteIdsWithDid:deviceType bid:brandId];

}
-(void)getAllRemoteIdsDataSource:(NSNotification * )notification
{
    // notification.userInfo[@"data”];   //这就是返回的数据,是NSData类型，转成相对应的数据类型即可使用
    // notification.userInfo[@"taskid"];    //区分是什么操作
    NSLog(@"taskid - %@",notification.userInfo[@"taskid"]);
    NSLog(@"errorCode - %@",notification.userInfo[@"errorCode"]);
    if ([notification.userInfo[@"errorCode"] intValue] == -1) {
      getAllRemoteIdsDataSourceError(@[@'getAllRemoteIdsDataSourceError']);
    }
    if ([notification.userInfo[@"taskid"] intValue] == 8) {
    id jsonObject = [NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
      NSArray *jsonArray = (NSArray *)jsonObject;
      NSLog(@"jsonArray - %@",jsonArray);
      NSDictionary *jsonDictionary = [jsonArray objectAtIndex:2];
      NSArray *dataArray = [jsonDictionary objectForKey:@"rids"];
      getAllRemoteIdsDataSourceSuccess(@[dataArray]);
    }

}
// @ReactMethod
// public void powerOn(final String rid,
//                           final int deviceType,
//                           final Callback successCallback,
//                           final Callback errorCallback) {
//获取rid = 4162 的 红外码, 批量获取红外码的方式是逗号隔开
// KookongSDK.getIRDataById(rid, deviceType, new IRequestResult<IrDataList>()
// {
//
//     @Override
//     public void onSuccess(String msg, IrDataList result) {
//         List<IrData> irDatas = result.getIrDataList();
//         mIrData = irDatas.get(0);
//         mKKACManager.initIRData(mIrData.rid, mIrData.exts, null);//根据空外数据初始化空调解码器
//         String acState = DataStoreUtil.i().getString("AC_STATE_" + rid, "");//获取以前保存过的空调状态
//         mKKACManager.setACStateV2FromString(acState);
//         mKKACManager.changePowerState();
//         Log.d("acState", acState);
//         int[] patternsInArray = mKKACManager.getACIRPatternIntArray();//这些码可以直接给ConsumerIR发送出去
//         Log.d("IRPattern", Arrays.toString(patternsInArray));
//         successCallback.invoke(Arrays.toString(patternsInArray));
//     }
//
//     @Override
//     public void onFail(Integer errorCode, String msg) {
//
//         //按红外设备授权的客户，才会用到这两个值
//         if(errorCode==AppConst.CUSTOMER_DEVICE_REMOTE_NUM_LIMIT){//同一个设备下载遥控器超过了50套限制
//             msg = "下载的遥控器超过了套数限制";
//         }else if(errorCode==AppConst.CUSTOMER_DEVICE_NUM_LIMIT){//设备总数超过了授权的额度
//             msg="设备总数超过了授权的额度";
//         }
//         //TipsUtil.toast(MainActivity.this, msg);
//         errorCallback.invoke(msg);
//     }
// });
RCT_EXPORT_METHOD(powerOn:(NSString * _Nonnull)rid
                  string:(NSNumber * _Nonnull)deviceType
                  callback:(RCTResponseSenderBlock)success
                  callback:(RCTResponseSenderBlock)error)
{
  powerOnDataSourceSuccess = success;
  powerOnDataSourceError = error;
  self.rid = rid;
  [kookong downloadIRDataByIdWithRemoteId:rid deviceTypeId:deviceType];
}
-(void)powerOnDataSource:(NSNotification * )notification
{
    // notification.userInfo[@"data”];   //这就是返回的数据,是NSData类型，转成相对应的数据类型即可使用
    // notification.userInfo[@"taskid"];    //区分是什么操作

    NSLog(@"taskid - %@",notification.userInfo[@"taskid"]);
    NSLog(@"errorCode - %@",notification.userInfo[@"errorCode"]);
    if ([notification.userInfo[@"errorCode"] intValue] == -1) {
      powerOnDataSourceError(@[@'powerOnDataSourceError']);
        powerOnDataSourceSuccess = nil;
        powerOnDataSourceError = nil;
    }
    if ([notification.userInfo[@"taskid"] intValue] == 20 && powerOnDataSourceSuccess != nil) {
      NSArray * array=[NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
      NSLog(@"%@",array);
      NSDictionary * dictionary=array[2];
      NSArray * arr=dictionary[@"irDataList"];
      NSDictionary * dictionary2=arr[0];
      manager.apikey=self.apikey;//验证apikey
      manager.AC_RemoteId=self.rid;//空调的remoteid
      manager.airDataDict=dictionary2;//空调的红外码库
      [manager airConditionModeDataHandle];//空调数据处理。
      [manager changePowerStateWithPowerstate:AC_POWER_ON];

      /**
       *  该接口用来做测试用，直接传对应的状态值，然后取得红外码
       *
       *  @param powersta   开关
       *  @param modesta    模式
       *  @param windSta    风向
       *  @param windPow    风量
       *  @param temperat   温度
       *  @param functionid 按键id（IRConstants.h对每种类型的functionid有明确的标注）
       *
       *  @return 将取到的值直接发送出去
       */
      // (NSArray * )getAirConditionInfraredWithPower:(int)powersta modeState:(int)modesta windState:(int)windSta windPower:(int)windPow temperature:(int)temperat functionid:(int)functionid;
      // NSArray *resultArray=[manager getAirConditionInfraredWithPower:AC_POWER_ON modeState:AC_MODE_AUTO windState:AC_UD_WIND_DIRECT_SWING windPower:AC_WIND_SPEED_AUTO temperature:AC_MODE_AUTOTEMP functionid:FUNCTION_POWER];
      NSArray *resultArray = [manager getAirConditionInfrared];
      NSLog(@"%@",[manager getAirConditionInfrared]);//按键参数
      powerOnDataSourceSuccess(@[resultArray]);
      // NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resultArray];
      // NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      // NSLog(@"%@",result);
      // powerOnDataSourceSuccess(@[result]);
      powerOnDataSourceSuccess = nil;
      powerOnDataSourceError = nil;
    }
}
// @ReactMethod
// public void powerOff(final String rid,
//                     final int deviceType,
//                     final Callback successCallback,
//                     final Callback errorCallback) {
RCT_EXPORT_METHOD(powerOff:(NSString * _Nonnull)rid
                  string:(NSNumber * _Nonnull)deviceType
                  callback:(RCTResponseSenderBlock)success
                  callback:(RCTResponseSenderBlock)error)
{
  powerOffDataSourceSuccess = success;
  powerOffDataSourceError = error;
  self.rid = rid;
  [kookong downloadIRDataByIdWithRemoteId:rid deviceTypeId:deviceType];
}
-(void)powerOffDataSource:(NSNotification * )notification
{
    // notification.userInfo[@"data”];   //这就是返回的数据,是NSData类型，转成相对应的数据类型即可使用
    // notification.userInfo[@"taskid"];    //区分是什么操作
    NSLog(@"taskid - %@",notification.userInfo[@"taskid"]);
    NSLog(@"errorCode - %@",notification.userInfo[@"errorCode"]);
    if ([notification.userInfo[@"errorCode"] intValue] == -1) {
      powerOffDataSourceError(@[@'powerOffDataSourceError']);
        powerOffDataSourceSuccess = nil;
        powerOffDataSourceError = nil;
    }
    if ([notification.userInfo[@"taskid"] intValue] == 20 && powerOffDataSourceSuccess != nil) {
      NSArray * array=[NSJSONSerialization JSONObjectWithData:notification.userInfo[@"data"] options:NSJSONReadingMutableContainers error:nil];
      NSLog(@"%@",array);
      NSDictionary * dictionary=array[2];
      NSArray * arr=dictionary[@"irDataList"];
      NSDictionary * dictionary2=arr[0];
      manager.apikey=self.apikey;//验证apikey
      manager.AC_RemoteId=self.rid;//空调的remoteid
      manager.airDataDict=dictionary2;//空调的红外码库
      [manager airConditionModeDataHandle];//空调数据处理。
      [manager changePowerStateWithPowerstate:AC_POWER_OFF];


      /**
       *  该接口用来做测试用，直接传对应的状态值，然后取得红外码
       *
       *  @param powersta   开关
       *  @param modesta    模式
       *  @param windSta    风向
       *  @param windPow    风量
       *  @param temperat   温度
       *  @param functionid 按键id（IRConstants.h对每种类型的functionid有明确的标注）
       *
       *  @return 将取到的值直接发送出去
       */
      // (NSArray * )getAirConditionInfraredWithPower:(int)powersta modeState:(int)modesta windState:(int)windSta windPower:(int)windPow temperature:(int)temperat functionid:(int)functionid;
      // NSArray *resultArray = [manager getAirConditionInfraredWithPower:AC_POWER_OFF modeState:AC_MODE_AUTO windState:AC_UD_WIND_DIRECT_SWING windPower:AC_WIND_SPEED_AUTO temperature:AC_MODE_AUTOTEMP functionid:FUNCTION_POWER];
      NSArray *resultArray = [manager getAirConditionInfrared];
//      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resultArray];
//      NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",result);
      powerOffDataSourceSuccess(@[resultArray]);

      powerOffDataSourceSuccess = nil;
      powerOffDataSourceError = nil;
    }

}
@end
