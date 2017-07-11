#银联 cordova 插件
 
##插件安装 

    ## $ cordova plugin add https://github.com/woguava/cordova-plugin-unionpay.git --variable UNIONPAY_APPID=$(uuid)  --variable UNIONPAY_TEST=$(00 生产 01 测试)
    ## $ ionic cordova plugin add https://github.com/woguava/cordova-plugin-unionpay.git --variable UNIONPAY_APPID=$(uuid)  --variable UNIONPAY_TEST=$(00 生产 01 测试)

##插件删除

    ## $ cordova plugin rm cordova-plugin-unionpay
    ## $ ionic plugin rm cordova-plugin-unionpay

#插件调用

    ##在TyptScript中定义对象
    ## declare let cordova: any;

    ##调用方法
    ## tn 银联返回的交易流水号
    ## success 插件成功执行的回调函数 ，返回格式为 jsonstring ,"pay_result"为success、fail、cancel 分别代表支付成功，支付失败，支付取消
    ## 如： {"pay_result":"success",
             "data":"pay_result=success&tn=899394085660622736701&cert_id=68759585097",
             "sign"："Xo/pgkzSJSlRTX2e+CjW/k1IjIV1newqfb7p1sDIpK/yPQv9p1jQAdAdKwhBwtyjO3tkFC6I2aLcTaxLHlYQx6/xw9QE0eumkVqAhypk/VyoDWZXxWske+EcduwEkBTxyIgA0ZsbKlpS1JxsciOc6bT+f36jTLa05ZAKZTVErg9sAG3wMjae1TyKd2511Rvvi+tuihYgOmwuMnKzrqksEyqc69wloqi34qx0YqFolMeqQ1UfoglUhZy6s2s4ChKcxHjAFjp/rU/7iHudjAIGtO7+ySahArmw6ltuIxFWYEvpn5xI3Ceur1d11NBphK62it7kBZ1laxUFI98DzalVFQ=="}
             
    ## error 插件异常的回调函数,异常返回为 string
    ## cordova.plugins.UnionPay.starPay(tn,success, error);

