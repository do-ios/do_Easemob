//
//  do_Easemob_App.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Easemob_App.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"
#import "EMSDK.h"
#import "do_Easemob_SM.h"
#import "doScriptEngineHelper.h"

static do_Easemob_App* instance;
@interface do_Easemob_App()<EMClientDelegate>

@end
@implementation do_Easemob_App
@synthesize OpenURLScheme;
+(id) Instance
{
    if(instance==nil)
        instance = [[do_Easemob_App alloc]init];
    return instance;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *huanxinKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doEasemob.plist" :@"EASEMOB_APPKEY"];
    NSString *apnsName = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doEasemob.plist" :@"IOS_PUSH_KEY"];
    EMOptions *options = [EMOptions optionsWithAppkey:huanxinKey];
    options.apnsCertName = apnsName;
//    options.enableConsoleLog = YES;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    return YES;
}
// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}
/*!
 *  自动登录返回结果
 *
 *  @param aError 错误信息
 */
- (void)didAutoLoginWithError:(EMError *)aError
{
    NSLog(@"errorDescription = %@",aError.errorDescription);
    [[NSUserDefaults standardUserDefaults] setBool:[EMClient sharedClient].options.isAutoLogin forKey:@"EasemobAutologinKey"];
    [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
}
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    if (aConnectionState == EMConnectionConnected) {
        [node setObject:@"1" forKey:@"state"];
    }
    else
    {
        [node setObject:@"0" forKey:@"state"];
    }
    [[NSUserDefaults standardUserDefaults]setObject:node forKey:@"EasemobConnectionStateChangedKey"];
}

@end
