package com.openunion.cordova.plugins.unionpay;

import android.util.Log;
import android.content.Intent;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import com.unionpay.UPPayAssistEx;
import com.unionpay.uppay.PayActivity;

/**
 * This class echoes a string called from JavaScript.
 */
public class UnionPay extends CordovaPlugin {

    private final static String LOG_TAG = "com.openunion.cordova.plugins.unionpay";
    private final static String TEST_MODE = "UNIONPAY_TEST";
    private final static String APP_ID = "UNIONPAY_APPID";

    /**
     * Payment mode, defaults to "00"
     *   * "00" => Official
     *   * "01" => Test
     */
    private static String g_TestMode = "00";
    private static String g_AppID = "";
    public CallbackContext g_unionpayCallbackContext;

    @Override
    public void pluginInitialize() {
        super.pluginInitialize();

        initMode();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(LOG_TAG, String.format("Invoking action \"%s\".", action));

        g_unionpayCallbackContext = callbackContext;
        cordova.setActivityResultCallback(this);

        if (action.equals("starPay")) {
            try{
                String tn = args.getString(0);
                if(tn == null || tn.isEmpty()){
                  callbackContext.error("parameter tn is null error");
                }else{
                  Log.d(LOG_TAG, String.format("Start payment with transaction number \"%s\" and mode \"%s\".", tn, g_TestMode));
                  UPPayAssistEx.startPay(cordova.getActivity(), null, null, tn, g_TestMode);
                }
            } catch (Exception e) {
                callbackContext.error(e.getMessage());
            }

            return true;
        }
        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (null == intent) {
            g_unionpayCallbackContext.error("Fail to get result with intent");
            return;
        }
        /*
         * 支付控件返回字符串:success、fail、cancel 分别代表支付成功，支付失败，支付取消
         */
        try {
            JSONObject resultJson = new JSONObject();
            String payResult = intent.getExtras().getString("pay_result");
            resultJson.put("pay_result", payResult);
            if (payResult.equalsIgnoreCase("success")) {
              if (intent.hasExtra("result_data")) {
                  String resultData = intent.getExtras().getString("result_data");
                  JSONObject dataJson = new JSONObject(resultData);
                  resultJson.put("data",dataJson.getString("data"));
                  resultJson.put("sign",dataJson.getString("sign"));
              }
            }
            g_unionpayCallbackContext.success(resultJson.toString());
        } catch (JSONException e) {
            g_unionpayCallbackContext.error(e.getMessage());
        }
    }

    private void initMode() {
      g_TestMode = preferences.getString(TEST_MODE, "00");
      g_AppID = preferences.getString(APP_ID, "");
      Log.d(LOG_TAG, String.format("Initialized payment mode as %s.", g_TestMode));
    }

}
