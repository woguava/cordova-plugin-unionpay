/********* UnionPay.m Cordova Plugin Implementation *******/
#import <Cordova/CDV.h>
#import "UPPaymentControl.h"

@interface UnionPay : CDVPlugin {
  // Member variables go here.
    NSString* g_mode;
    NSString* g_appid;
    NSString* g_schemeStr;
    NSString* g_callbackId;
}

- (void)starPay:(CDVInvokedUrlCommand*)command;
@end

@implementation UnionPay

NSString* const TEST_MODE       = @"unionpay_test";
NSString* const APP_ID          = @"unionpay_appid";

//插件初始化
- (void)pluginInitialize {
    //获取模式类型 00 生产 01 测试
    NSString* mode = [[self.commandDelegate settings] objectForKey:TEST_MODE];
    NSLog(@"Get preference \"%@\": \"%@\"", TEST_MODE, mode);
    if (mode) {
        g_mode = mode;
    } else {
        g_mode = @"01";
    }
    NSLog(@"Initialized unionpay payment mode as \"%@\".", g_mode);
    //获取appid ，可使用uuid生成
    NSString* appid = [[self.commandDelegate settings] objectForKey:APP_ID];
    NSLog(@"Get unionpay preference \"%@\": \"%@\"", APP_ID, appid);
    g_appid = appid;
    NSLog(@"Initialized unionpay appid as \"%@\".", g_appid);
    
}

//支付
- (void)starPay:(CDVInvokedUrlCommand*)command
{
    g_callbackId = command.callbackId;

     @try {
        NSString* tn = [command.arguments objectAtIndex:0];
        if (tn != nil && [tn length] > 0) {            
            NSLog(@"Start payment with transaction number \"%@\" and mode \"%@\".", tn, g_mode);

            //应用注册scheme,*-Info.plist定义URL types
            NSMutableString * schema = [NSMutableString string];
            [schema appendFormat:@"UP%@", g_appid];
            NSLog(@"unionpay schema = %@",schema);

            [[UPPaymentControl defaultControl] startPay:tn fromScheme:schema mode:g_mode viewController:self.viewController];

        } else {
            NSLog(@"payment tn invalid!");
            [self failWithCallbackID:g_callbackId withMessage:@"payment tn invalid!"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"payment exception: \"%@\"", exception);
        [self failWithCallbackID:g_callbackId withMessage:@"payment exception!"];
    }
    @finally {
    }
}


//事件通知
- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL* url = [notification object];
    NSLog(@"handleOpenURL unionpay message: \"%@\"", url);

    if ([url.scheme rangeOfString:g_appid].length > 0)
    {
         [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            NSMutableDictionary * resultDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 @"",@"pay_result",
                                                 @"",@"data",
                                                 @"",@"sign",nil];
            [resultDict setValue:code forKey:@"pay_result"];
            
            if([code isEqualToString:@"success"]) {            
                //结果code为成功时，去商户后台查询一下确保交易是成功的再展示成功
                if(data != nil){
                    [resultDict addEntriesFromDictionary:data];
                }
            }
            NSString * resultString = [self jsonStringWitchDictionary:resultDict];
            NSLog(@"resultString : \"%@\"", resultString);
            [self successWithCallbackID:g_callbackId withMessage:resultString];
            
        }];
    }
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

//
-(NSString *)jsonStringWitchDictionary:(NSDictionary *)infoDict
{
    NSError *error =nil;
    NSData *jsonData =nil;
    
    jsonData = [NSJSONSerialization dataWithJSONObject:infoDict options:NSJSONWritingPrettyPrinted error:&error];
    if([jsonData length] == 0 || error != nil){
        return nil;
    }
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

@end
