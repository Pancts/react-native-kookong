//
//  KookongSDK.h
//  kookongIphone
//
//  Created by shuaiwen on 16/1/28.
//  Copyright © 2016年 shuaiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface KookongSDK : NSObject
/**
 *  （使用单例）实例化一个KooKongSDK的对象
 *
 *  @return KooKongSDK的对象
 */
+(id)shareKooKongSDK;

/**
 *  验证权限
 *
 *  @param apikey     key
 *  @param uuidString （非数量限制客户，传nil即可，数量限制客户，传设备的id，该id是自己定义的，一个id代表一个设备）
 */
-(void)checkUserAuthority:(NSString * )apikey uuidString:(NSString *)uuidString __deprecated_msg("该接口已过期，请使用：checkUserAuthority: deviceId:");

/**
 *  验证权限
 *
 *  @param apikey     key
 *  @param deviceId （非数量限制客户，传nil即可，数量限制客户，传设备的id，该id是自己定义的，一个id代表一个设备）
 */
-(void)checkUserAuthority:(NSString * )apikey deviceId:(NSString *)deviceId;



/**
 *  1.根据定位到省 ，市，区，获取areaid
 *
 *  @param provinceName 省名称（山东省）
 *  @param cityName     市名称（青岛市）
 *  @param districtName 区名称（崂山区）
 */
-(void)getAreaIdWithProvince:(NSString *)provinceName City:(NSString *)cityName District:(NSString *)districtName;


/**
 *  2.根据areaid获取运营商列表
 *
 *  @param areaid 根据省，市，区获得的areaid
 */
-(void)getOperatersWithAreaid:(NSNumber*)areaid;


/**
 *  3.获取选中的运营商（spid）下，含有的所有的机顶盒的遥控器
 *  devicetypeid:   设备类型1：STB  2：TV  3：BOX  4：DVD   5：AC
 *  @param areaid 根据省，市，区获得的areaid
 *  @param spid   获取的运营商的spid
 *  @param did    devicetypeid
 *  @param bid    brandid
 */
-(void)getAllRemoteIdsWithAreaid:(NSNumber*)areaid spid:(NSNumber*)spid did:(NSNumber *)did bid:(NSNumber *)bid;


/**
 *  4.获取遥控器的红外码（rid）进行测试
 *  (该接口已经过期)
 *  @param remoteIds remoteid（可以是多个，分别用，隔开）
 */
-(void)getIRDataByIdWithRemoteIds:(NSString *)remoteIds __deprecated_msg("该接口已过期，请使用：downloadIRDataByIdWithRemoteId: deviceTypeId:");

/**
 *  5.该接口不用访问
 *
 *  @param functionid
 *  @param remoteid
 *  @param remoteids
 */
//-(void)getFilterIRDataWithFunctionid:(NSNumber *)functionid remoteid:(NSNumber *)remoteid remoteids:(NSString * )remoteids;

/**
 *  6.获取这个运营商（spid）下，所有的品牌（每个品牌都带有他的所有遥控器码）
 *
 *  @param spid 获取到的运营商的spid
 */
-(void)getIPTVWithSpid:(NSNumber *)spid;

/**
 *  7.获取所有的品牌（每个品牌都带有所有他的遥控器码）
 *
 *  @param nameString 品牌名称
 *  @param areaid     根据省市区获取的areaid
 */
-(void)searchSTBWithNameString:(NSString * )nameString areaid:(NSNumber*)areaid;

/**
 *  8.获取电视（或者其他，通过typeid区分）品牌列表
 *  devicetypeid:设备类型(请在IRConstants.h文件中查看所有设备类型)
 *  @param did devicetype
 */
-(void)getBrandListFromNetWithDid:(NSNumber * )did;

/**
 *  9.获得这个品牌（brandid）下，含所有的遥控器
 *
 *  @param did devicetypeid
 *  @param bid brandid(获取所有的品牌，取到brandid)
 */
-(void)getAllRemoteIdsWithDid:(NSNumber *)did bid:(NSNumber *)bid;

/**
 *  10.获得红外数据数据
 *  (该接口已经过期)
 *  @param 调用接口3，得到空调的remoteid
 */
-(void)getAirConditionIRDataWithRemoteId:(NSNumber*)remoteId __deprecated_msg("该接口已过期，请使用：downloadIRDataByIdWithRemoteId: deviceTypeId:");

/**
 *  ***获取遥控器的红外码（rid），进行对码
 *
 *  @param remoteId     remoteid
 *  @param deviceTypeId 设备类型id
 */
-(void)testIRDataByIdWithRemoteId:(NSString *)remoteId deviceTypeId:(NSNumber *)deviceTypeId;

/**
 *  ***对码成功后调用该接口，取完整的码取
 *
 *  @param remoteId     remoteid
 *  @param deviceTypeId 设备类型id
 */
-(void)downloadIRDataByIdWithRemoteId:(NSString *)remoteId deviceTypeId:(NSNumber *)deviceTypeId;

@end
