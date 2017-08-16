
package com.conglin.kookong;


import android.util.Log;
import android.widget.Toast;
import android.os.AsyncTask;

import com.facebook.react.bridge.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;

import com.conglin.kookong.util.Logger;
import com.conglin.kookong.util.TipsUtil;
import com.hzy.tvmao.KookongSDK;
import com.hzy.tvmao.interf.IRequestResult;
import com.hzy.tvmao.ir.Device;
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


public class RCTKooKongModule extends ReactContextBaseJavaModule {
    //    public static final String APP_KEY = "4E70159C5A3533C842ECFEED65333DB9";//7252EB5D43374424D19037432D411960
    public static final String APP_KEY = "7252EB5D43374424D19037432D411960";
    public static final String irDeviceId = "1";//如果是按红外设备授权收费则填上设备的id，否则使用KookongSDK.init(this,APP_KEY);
    private static ReactApplicationContext _reactContext;

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
        boolean result = KookongSDK.init(_reactContext, key, irDeviceId);
        LogUtil.d("Verify result is " + result);
        KookongSDK.setDebugMode(true);
    }

    @ReactMethod
    public void getBrandListFromNet(final int deviceType, final Promise promise) {
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
                for (int i = 0; i < stbs.size(); i++) {
                    Logger.d("The Brand is " + stbs.get(i).cname + ":" + stbs.get(i).brandId);
                }
            }

            @Override
            public void onFail(Integer errorCode, String msg) {
//                TipsUtil.toast(MainActivity.this, msg);
                Logger.d(msg);

            }
        });

    }

}
