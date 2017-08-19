
package com.conglin.kookong;


import android.util.Log;
import android.widget.Toast;
import android.os.AsyncTask;

import com.facebook.react.bridge.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;

import com.conglin.kookong.util.Logger;
import com.conglin.kookong.util.TipsUtil;
import com.conglin.kookong.util.ArrayUtil;
import com.conglin.kookong.util.MapUtil;
import com.hzy.tvmao.KookongSDK;
import com.hzy.tvmao.interf.IRequestResult;
import com.hzy.tvmao.ir.Device;
import com.hzy.tvmao.utils.DataStoreUtil;
import com.hzy.tvmao.utils.LogUtil;
import com.kookong.app.data.AppConst;
import com.kookong.app.data.BrandList;
import com.kookong.app.data.BrandList.Brand;
import com.kookong.app.data.IrData;
import com.kookong.app.data.IrDataList;
import com.kookong.app.data.RemoteList;
import com.kookong.app.data.SpList;
import com.kookong.app.data.SpList.Sp;
import com.kookong.app.data.StbList;
import com.kookong.app.data.StbList.Stb;
import android.app.Activity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import com.hzy.tvmao.KKACManagerV2;
import com.hzy.tvmao.KookongSDK;
import com.hzy.tvmao.interf.IRequestResult;
import com.hzy.tvmao.ir.Device;
import com.hzy.tvmao.ir.ac.ACConstants;
import com.hzy.tvmao.ir.ac.ACStateV2.UDWindDirectKey;
import com.hzy.tvmao.ir.ac.ACStateV2.UDWindDirectType;
import com.hzy.tvmao.utils.DataStoreUtil;
import com.kookong.app.data.AppConst;
import com.kookong.app.data.IrData;
import com.kookong.app.data.IrDataList;

public class RCTKooKongModule extends ReactContextBaseJavaModule {

    private static ReactApplicationContext _reactContext;
    /** 控制器 */
    private KKACManagerV2 mKKACManager = new KKACManagerV2();

    /** 红外码 */
    private IrData mIrData;

    public RCTKooKongModule(ReactApplicationContext reactContext) {
        super(reactContext);
        _reactContext = reactContext;

    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        // constants.put(DURATION_SHORT_KEY, Toast.LENGTH_SHORT);
        // constants.put(DURATION_LONG_KEY, Toast.LENGTH_LONG);
        return constants;
    }

    @Override
    public String getName() {
        return "KooKong";
    }

    /*
     * 服务器返回错误代码含义
     * 代码     	意义
     * code 1	secret 错误
     * code 2	secret 不存在
     * code 3	客户已被禁用
     * code 4	客户已超期
     * code 6	选择运营商超出数量限制
     * code 7	无访问权限
     * code 8	试用数超出限制
     * code 9	设备数超出限制
     * code 10	单台设备下载红外超出限制
    */
    @ReactMethod
    protected void initKooKongSDK(String key, String irDeviceId) {
        //1.在App的入口进行初始化, 在Application中初始化也可以
        //按红外设备授权收费的客户，需要传递自己设备唯一的标识，使用KookongSDK.init(Context context, String key, String irDeviceId);
        //其他客户使用KookongSDK.init(Context context, String key);
        final Activity activity = getCurrentActivity();

        Logger.d("key is " + key);
        Logger.d("irDeviceId is " + irDeviceId);
        boolean result = KookongSDK.init(activity, key, irDeviceId);
        Logger.d("Verify result is " + result);
        KookongSDK.setDebugMode(true);
    }

    @ReactMethod
    public void getBrandListFromNet(final int deviceType,
                                    final Callback successCallback,
                                    final Callback errorCallback) {
        // 获取电视机, 空调等, (除STB以外) 的设备品牌列表
                /*
                 * public int STB = 1; //机顶盒
                 * public int TV  = 2; //电视
                 * public int BOX = 3; //网络盒子
                 * public int DVD = 4; //DVD
                 * public int AC  = 5; //空调
                 * public int PRO = 6; //投影仪
                 * public int PA  = 7; //功放
                 * public int FAN = 8; //风扇
                 * public int SLR = 9; //单反相机
                 * public int Light = 10; //开关灯泡
                 */
        KookongSDK.getBrandListFromNet(deviceType, new IRequestResult<BrandList>()
        {

            @Override
            public void onSuccess(String msg, BrandList result) {
                List<Brand> stbs = result.brandList;
                List<Map> brandsList = new ArrayList<>();

                for (int i = 0; i < stbs.size(); i++) {
                    Logger.d("The Brand is " + stbs.get(i).cname + ":" + stbs.get(i).brandId);
                    Map brandItem = new HashMap();
                    brandItem.put("name", stbs.get(i).cname);
                    brandItem.put("brandId", stbs.get(i).brandId);
                    brandsList.add(brandItem);
                }

                successCallback.invoke(ArrayUtil.toWritableArray((Object[]) brandsList.toArray()));
            }

            @Override
            public void onFail(Integer errorCode, String msg) {
//                TipsUtil.toast(MainActivity.this, msg);
                Logger.d(msg);
                errorCallback.invoke(msg);

            }
        });

    }

    @ReactMethod
    public void testIRDataById(final String rid,
                                    final int deviceType,
                                    final Callback successCallback,
                                    final Callback errorCallback) {

        KookongSDK.testIRDataById(rid, deviceType, new IRequestResult<IrDataList>()
        {

            @Override
            public void onSuccess(String msg, IrDataList result) {
                List<IrData> irDatas = result.getIrDataList();
                List<Map> resultList = new ArrayList<>();
                for (int i = 0; i < irDatas.size(); i++) {
                    Logger.d("The rid is " + irDatas.get(i).rid);
                    Map item = new HashMap();
                    item.put("rid", irDatas.get(i).rid);
                    item.put("fre", irDatas.get(i).fre);
                    item.put("type", irDatas.get(i).type);
                    item.put("exts", irDatas.get(i).exts);
                    resultList.add(item);
                }
                successCallback.invoke(ArrayUtil.toWritableArray((Object[]) resultList.toArray()));

            }

            @Override
            public void onFail(Integer errorCode, String msg) {
                //按红外设备授权的客户，才会用到这个指
                if (errorCode == AppConst.CUSTOMER_DEVICE_NUM_LIMIT) {//设备总数超过了授权的额度
                    msg = "设备总数超过了授权的额度";
                }
                //TipsUtil.toast(MainActivity.this, msg);
                errorCallback.invoke(msg);
            }
        });
    }

    @ReactMethod
    public void getIRDataById(final String rid,
                               final int deviceType,
                               final Callback successCallback,
                               final Callback errorCallback) {
        //获取rid = 4162 的 红外码, 批量获取红外码的方式是逗号隔开
        KookongSDK.getIRDataById(rid, deviceType, new IRequestResult<IrDataList>()
        {

            @Override
            public void onSuccess(String msg, IrDataList result) {
                List<IrData> irDatas = result.getIrDataList();
                List<Map> resultList = new ArrayList<>();
                for (int i = 0; i < irDatas.size(); i++) {
                    Logger.d("The rid is " + irDatas.get(i).rid);
                    Map item = new HashMap();
                    item.put("rid", irDatas.get(i).rid);
                    item.put("fre", irDatas.get(i).fre);
                    item.put("type", irDatas.get(i).type);
                    item.put("exts", irDatas.get(i).exts);
                    resultList.add(item);
                }
                successCallback.invoke(ArrayUtil.toWritableArray((Object[]) resultList.toArray()));
            }

            @Override
            public void onFail(Integer errorCode, String msg) {

                //按红外设备授权的客户，才会用到这两个值
                if(errorCode==AppConst.CUSTOMER_DEVICE_REMOTE_NUM_LIMIT){//同一个设备下载遥控器超过了50套限制
                    msg = "下载的遥控器超过了套数限制";
                }else if(errorCode==AppConst.CUSTOMER_DEVICE_NUM_LIMIT){//设备总数超过了授权的额度
                    msg="设备总数超过了授权的额度";
                }
                //TipsUtil.toast(MainActivity.this, msg);
                errorCallback.invoke(msg);
            }
        });
    }

    @ReactMethod
    public void getAllRemoteIds(final int deviceType,
                                final int brandId,
                              final Callback successCallback,
                              final Callback errorCallback) {
        //指定brand下的电视机所有的红外码的id spid和areaid都传0
        //获取指定设备类型(机顶盒是spId和areaid,所以这里不是机顶盒的获取方
        //式，机顶盒的红外码都是按区域划分和品牌关系不大),指定品牌下的红外码 192 AUX 格力 97
        KookongSDK.getAllRemoteIds(deviceType, brandId, 0, 0, new IRequestResult<RemoteList>()
        {

            @Override
            public void onSuccess(String msg, RemoteList result) {
                List<Integer> remoteids = result.rids;
                String res = Arrays.toString(remoteids.toArray());
                Logger.d("tv remoteids: " + res);
                successCallback.invoke(ArrayUtil.toWritableArray((Object[]) remoteids.toArray()));
            }

            @Override
            public void onFail(Integer errorCode, String msg) {
                //TipsUtil.toast(MainActivity.this, msg);
                errorCallback.invoke(msg);
            }
        });
    }


    @ReactMethod
    public void powerOn(final String rid,
                              final int deviceType,
                              final Callback successCallback,
                              final Callback errorCallback) {
        //获取rid = 4162 的 红外码, 批量获取红外码的方式是逗号隔开
        KookongSDK.getIRDataById(rid, deviceType, new IRequestResult<IrDataList>()
        {

            @Override
            public void onSuccess(String msg, IrDataList result) {
                List<IrData> irDatas = result.getIrDataList();
                mIrData = irDatas.get(0);
                mKKACManager.initIRData(mIrData.rid, mIrData.exts, null);//根据空外数据初始化空调解码器
                String acState = DataStoreUtil.i().getString("AC_STATE_" + rid, "");//获取以前保存过的空调状态
                mKKACManager.setACStateV2FromString(acState);
                mKKACManager.changePowerState();
                Log.d("acState", acState);
                int[] patternsInArray = mKKACManager.getACIRPatternIntArray();//这些码可以直接给ConsumerIR发送出去
                Log.d("IRPattern", Arrays.toString(patternsInArray));
                successCallback.invoke(Arrays.toString(patternsInArray));
            }

            @Override
            public void onFail(Integer errorCode, String msg) {

                //按红外设备授权的客户，才会用到这两个值
                if(errorCode==AppConst.CUSTOMER_DEVICE_REMOTE_NUM_LIMIT){//同一个设备下载遥控器超过了50套限制
                    msg = "下载的遥控器超过了套数限制";
                }else if(errorCode==AppConst.CUSTOMER_DEVICE_NUM_LIMIT){//设备总数超过了授权的额度
                    msg="设备总数超过了授权的额度";
                }
                //TipsUtil.toast(MainActivity.this, msg);
                errorCallback.invoke(msg);
            }
        });
    }

    @ReactMethod
    public void powerOff(final String rid,
                        final int deviceType,
                        final Callback successCallback,
                        final Callback errorCallback) {
        //获取rid = 4162 的 红外码, 批量获取红外码的方式是逗号隔开
        KookongSDK.getIRDataById(rid, deviceType, new IRequestResult<IrDataList>()
        {

            @Override
            public void onSuccess(String msg, IrDataList result) {
                List<IrData> irDatas = result.getIrDataList();
                mIrData = irDatas.get(0);
                mKKACManager.initIRData(mIrData.rid, mIrData.exts, null);//根据空外数据初始化空调解码器
                String acState = DataStoreUtil.i().getString("AC_STATE_" + rid, "");//获取以前保存过的空调状态
                mKKACManager.setACStateV2FromString(acState);
                Log.d("acState", acState);
                int[] patternsInArray = mKKACManager.getACIRPatternIntArray();//这些码可以直接给ConsumerIR发送出去
                successCallback.invoke(Arrays.toString(patternsInArray));
            }

            @Override
            public void onFail(Integer errorCode, String msg) {

                //按红外设备授权的客户，才会用到这两个值
                if(errorCode==AppConst.CUSTOMER_DEVICE_REMOTE_NUM_LIMIT){//同一个设备下载遥控器超过了50套限制
                    msg = "下载的遥控器超过了套数限制";
                }else if(errorCode==AppConst.CUSTOMER_DEVICE_NUM_LIMIT){//设备总数超过了授权的额度
                    msg="设备总数超过了授权的额度";
                }
                //TipsUtil.toast(MainActivity.this, msg);
                errorCallback.invoke(msg);
            }
        });
    }


}
