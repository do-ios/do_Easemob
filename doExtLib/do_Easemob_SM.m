//
//  do_Easemob_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Easemob_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "EMSDK.h"
#import "doServiceContainer.h"
#import "doILogEngine.h"
#import "doIOHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";


@interface do_Easemob_SM()<EMChatManagerDelegate,EMGroupManagerDelegate,EMClientDelegate>
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

@implementation do_Easemob_SM

#pragma mark - 方法
#pragma mark - 同步异步方法的实现
- (void)eventOn:(NSString *)onEvent
{
    BOOL isAutoLogin = [[NSUserDefaults standardUserDefaults]boolForKey:@"EasemobAutologinKey"];
    if (isAutoLogin) {
        if([onEvent isEqualToString:@"autoLogin"])
        {
            [self.EventCenter FireEvent:@"autoLogin" :nil];
        }
    }
    
    NSDictionary *stateChangedDict = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"EasemobConnectionStateChangedKey"];
    if(stateChangedDict)
    {
        if ([onEvent isEqualToString:@"connectionStateChanged"]) {
            [self fireEvent:@"connectionStateChanged" withNode:stateChangedDict];
        }
    }
}
- (void)eventOff:(NSString *)offEvent
{
    
}

//同步
/**
 *
 *  接受入群邀请
 *  @param parms <#parms description#>
 */
- (void)acceptInvitationFromGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    NSString *inviter = [doJsonHelper GetOneText:_dictParas :@"inviter" :@""];
    EMError *error;
    [[EMClient sharedClient].groupManager acceptInvitationFromGroup:groupId inviter:inviter error:&error];
    if (error) {
        [_invokeResult SetError:error.description];
    }
}
/**
 *  批准入群申请, 需要Owner权限
 *
 *  @param parms <#parms description#>
 */
- (void)acceptJoinApplication:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    EMError *error;
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
//    NSString *groupName = [doJsonHelper GetOneText:_dictParas :@"groupName" :@""];
    NSString *applicant = [doJsonHelper GetOneText:_dictParas :@"applicant" :@""];
    [[EMClient sharedClient].groupManager acceptJoinApplication:groupId applicant:applicant];
//    [[EMClient sharedClient].groupManager joinPublicGroup:groupId error:&error];

    if (error) {
        [_invokeResult SetError:error.description];
    }
}
#pragma mark - 有问题
- (void)applyJoinToGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    NSString *reason = [doJsonHelper GetOneText:_dictParas :@"reason" :@""];
    // 申请加入需要审核的公开群组
    EMError *error = nil;
    [[EMClient sharedClient].groupManager applyJoinPublicGroup:groupId message:reason error:&error];
    if (error) {
        [_invokeResult SetError:error.description];
    }
}
/**
 *  修改群组信息
 *
 *  @param parms <#parms description#>
 */
- (void)changeGroupSubject:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    EMError *error;
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    NSString *subject = [doJsonHelper GetOneText:_dictParas :@"subject" :@""];
    NSString *description = [doJsonHelper GetOneText:_dictParas :@"description" :@""];
    [[EMClient sharedClient].groupManager changeDescription:description forGroup:groupId error:&error];
    [[EMClient sharedClient].groupManager changeGroupSubject:subject forGroup:groupId error:&error];
    if (error) {
        [_invokeResult SetError:error.description];
    }
}
/**
 *  创建群组
 *
 *  @param parms <#parms description#>
 */
- (void)createGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    
    NSString *subject = [doJsonHelper GetOneText:_dictParas :@"subject" :@""];
    NSString *description = [doJsonHelper GetOneText:_dictParas :@"description" :@""];
    NSArray *occupants = [doJsonHelper GetOneArray:_dictParas :@"occupants"];
    int style = [doJsonHelper GetOneInteger:_dictParas :@"style" :2];
    int maxUsersCount = [doJsonHelper GetOneInteger:_dictParas :@"maxUsersCount" :200];
    NSString *message = [doJsonHelper GetOneText:_dictParas :@"message" :@""];
    EMError *error = nil;
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = maxUsersCount;
    setting.style = style;// 创建不同类型的群组，这里需要才传入不同的类型
    EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:subject description:description invitees:occupants message:message setting:setting error:&error];
    if(!error){
        NSLog(@"创建成功 -- %@",group);
    }
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:group.groupId forKey:@"groupId"];
    [_invokeResult SetResultNode:node];
}
/**
 *  拒绝入群邀请
 *
 *  @param parms <#parms description#>
 */
- (void)declineInvitationFromGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
//    //自己的代码实现
//    
//    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    NSString *inviter = [doJsonHelper GetOneText:_dictParas :@"inviter" :@""];
    [[EMClient sharedClient].groupManager declineInvitationFromGroup:groupId inviter:inviter reason:@""];
}
/**
 *   拒绝入群申请, 需要Owner权限
 *
 *  @param parms <#parms description#>
 */
- (void)declineJoinApplication:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    //    NSString *groupName = [doJsonHelper GetOneText:_dictParas :@"groupName" :@""];
    NSString *applicant = [doJsonHelper GetOneText:_dictParas :@"applicant" :@""];
    EMError *error = [[EMClient sharedClient].groupManager declineJoinApplication:groupId applicant:applicant reason:@""];
    if (error) {
        [_invokeResult SetError:error.description];
    }
}
/**
 *  解散群组
 *
 *  @param parms <#parms description#>
 */
- (void)destroyGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
//    //自己的代码实现
//    
//    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    EMError *error = nil;
    [[EMClient sharedClient].groupManager destroyGroup:groupId error:&error];
    if (!error) {
        NSLog(@"解散成功");
    }
}
/**
 *  获取群组详情
 *
 *  @param parms <#parms description#>
 */
- (void)fetchGroupInfo:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //自己的代码实现
    NSString *groupId = [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    BOOL includeMembersList = [doJsonHelper GetOneBoolean:_dictParas :@"includeMembersList" :NO];
    EMError *error = nil;
    EMGroup *group = [[EMClient sharedClient].groupManager fetchGroupInfo:groupId includeMembersList:includeMembersList error:&error];
    if (!error) {
        NSMutableDictionary *node = [NSMutableDictionary dictionary];
        [node setObject:group.subject forKey:@"subject"];
        if (group.description) {
            [node setObject:group.description forKey:@"description"];
        }
        [node setObject:@(group.setting.style) forKey:@"style"];
        if (includeMembersList) {
            [node setObject:group.occupants forKey:@"occupants"];
        }
        [node setObject:@(group.setting.maxUsersCount) forKey:@"maxUsersCount"];
        //_invokeResult设置返回值
        [_invokeResult SetResultNode:node];
    }
    else
    {
        [_invokeResult SetError:error.description];
    }
}
/**
 *  邀请用户加入群组
 *
 *  @param parms <#parms description#>
 */
- (void)inviteToGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    
    NSString *groupId= [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    NSArray *invitee = [doJsonHelper GetOneArray:_dictParas :@"invitee"];
    NSString *reason= [doJsonHelper GetOneText:_dictParas :@"reason" :@""];
    EMError *error = nil;
    [[EMClient sharedClient].groupManager addOccupants:invitee toGroup:groupId welcomeMessage:reason error:&error];
    if (error) {
        [_invokeResult SetError:error.description];
    }
}
/**
 *  退出群组，owner不能退出群，只能销毁群
 *
 *  @param parms <#parms description#>
 */
- (void)leaveGroup:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
//    //自己的代码实现
//    
//    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *groupId= [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    EMError *error = nil;
    [[EMClient sharedClient].groupManager leaveGroup:groupId error:&error];
    if (!error) {
        NSLog(@"退群成功");
    }
}
/**
 *  退出
 *
 *  @param parms <#parms description#>
 */
- (void)logoff:(NSArray *)parms
{
    [[EMClient sharedClient]logout:YES];
    [EMClient sharedClient].options.isAutoLogin = NO;
    [[NSUserDefaults standardUserDefaults] setBool:[EMClient sharedClient].options.isAutoLogin forKey:@"EasemobAutologinKey"];
    //移除消息回调
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient]removeDelegate:self];
}
/**
 *  将群成员移出群组, 需要owner权限
 *
 *  @param parms <#parms description#>
 */
- (void)removeOccupants:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
//    //自己的代码实现
//    
//    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    
    NSArray *occupants = [doJsonHelper GetOneArray:_dictParas :@"occupants"];
    NSString *groupId= [doJsonHelper GetOneText:_dictParas :@"groupId" :@""];
    EMError *error = nil;
    [[EMClient sharedClient].groupManager removeOccupants:occupants fromGroup:groupId error:&error];
    if (!error) {
        NSLog(@"移除成功");
    }
}
//异步
/**
 *  删除一组会话
 *
 *  @param parms <#parms description#>
 */
- (void)deleteConversation:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSArray *conversationIds = [doJsonHelper GetOneArray:_dictParas :@"conversationId"];
    [[EMClient sharedClient].chatManager deleteConversations:conversationIds deleteMessages:YES];
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    
    [_scritEngine Callback:_callbackName :_invokeResult];
}
/**
 *  获取所有会话，如果内存中不存在会从DB中加载
 *
 *  @param parms <#parms description#>
 */
- (void)getAllConversations:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray *nodeArray = [NSMutableArray array];
    for (EMConversation *sation in conversations) {
        EMMessage *message = sation.latestMessage;
        NSMutableDictionary *nodeDict = [NSMutableDictionary dictionary];
        [nodeDict setObject:sation.conversationId forKey:@"conversationId"];
        if (sation.type == EMConversationTypeChat) {
            [nodeDict setObject:@"Chat" forKey:@"type"];
        }
        else
        {
            [nodeDict setObject:@"GroupChat" forKey:@"type"];
        }
        [nodeDict setObject:@(message.timestamp) forKey:@"timestamp"];
        if (message.body.type == EMMessageBodyTypeText) {
            EMTextMessageBody *text = (EMTextMessageBody *)message.body;
            [nodeDict setObject:text.text forKey:@"lastMessage"];
        }
        else if (message.body.type == EMMessageBodyTypeImage) {
            [nodeDict setObject:@"[图片]" forKey:@"lastMessage"];
        }
        else if (message.body.type == EMMessageBodyTypeVideo)
        {
            [nodeDict setObject:@"[视屏]" forKey:@"lastMessage"];
        }
        else if (message.body.type == EMMessageBodyTypeLocation)
        {
            [nodeDict setObject:@"[位置]" forKey:@"lastMessage"];
        }
        else if (message.body.type == EMMessageBodyTypeVoice)
        {
            [nodeDict setObject:@"[音频]" forKey:@"lastMessage"];
        }
        else if (message.body.type == EMMessageBodyTypeVoice)
        {
            [nodeDict setObject:@"[音频]" forKey:@"lastMessage"];
        }
        [nodeArray addObject:nodeDict];
    }
    [_invokeResult SetResultArray:nodeArray];
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)getConversation:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *conversationId = [doJsonHelper GetOneText:_dictParas :@"conversationId" :@""];
    NSString *chatType = [doJsonHelper GetOneText:_dictParas :@"chatType" :@"Chat"];
    EMConversationType type;
    if ([chatType caseInsensitiveCompare:@"Chat"] == NSOrderedSame) {
        type = EMConversationTypeChat;
    }
    else
    {
        type = EMConversationTypeGroupChat;
    }
    
    int maxCount = [doJsonHelper GetOneInteger:_dictParas :@"maxCount" :20];
    NSString *messageId = [doJsonHelper GetOneText:_dictParas :@"messageId" :@""];
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:type createIfNotExist:NO];
    NSArray *messageArray = [conversation loadMoreMessagesFromId:messageId limit:maxCount direction:EMMessageSearchDirectionUp];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (EMMessage *aMessage in messageArray) {
        NSMutableDictionary *node = [NSMutableDictionary dictionary];
        NSMutableDictionary *bodyNode = [NSMutableDictionary dictionary];
        [node setObject:aMessage.messageId forKey:@"messageId"];
        [node setObject:aMessage.conversationId forKey:@"conversationId"];
        [node setObject:aMessage.from forKey:@"from"];
        [node setObject:aMessage.to forKey:@"to"];
        [node setObject:@(aMessage.timestamp) forKey:@"timestamp"];
        
        EMMessageBody *msgBody = aMessage.body;
        switch (msgBody.type) {
            case EMMessageBodyTypeText:
            {
                // 收到的文字消息
                EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                NSString *txt = textBody.text;
                NSLog(@"收到的文字是 txt -- %@",txt);
                [bodyNode setObject:@"0" forKey:@"type"];
                [bodyNode setObject:txt forKey:@"text"];
                [node setObject:bodyNode forKey:@"body"];
            }
                break;
            case EMMessageBodyTypeImage:
            {
                // 得到一个图片消息body
                EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
                NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
                NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
                NSLog(@"大图的secret -- %@"    ,body.secretKey);
                NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
                NSLog(@"大图的下载状态 -- %u",body.downloadStatus);
                
                
                // 缩略图sdk会自动下载
                NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
                NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
                NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
                NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
                NSLog(@"小图的下载状态 -- %u",body.thumbnailDownloadStatus);
                
                [bodyNode setObject:@"1" forKey:@"type"];
                [bodyNode setObject:body.remotePath forKey:@"remotePath"];
                [bodyNode setObject:body.localPath forKey:@"localPath"];
                [bodyNode setObject:body.thumbnailRemotePath forKey:@"thumbnailRemotePath"];
                [bodyNode setObject:body.thumbnailLocalPath forKey:@"thumbnailLocalPath"];
                [node setObject:bodyNode forKey:@"body"];
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
                NSLog(@"纬度-- %f",body.latitude);
                NSLog(@"经度-- %f",body.longitude);
                NSLog(@"地址-- %@",body.address);
                [bodyNode setObject:@"2" forKey:@"type"];
                [bodyNode setObject:@(body.latitude) forKey:@"latitude"];
                [bodyNode setObject:@(body.longitude) forKey:@"longitude"];
                [bodyNode setObject:body.address forKey:@"address"];
                [node setObject:bodyNode forKey:@"body"];
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                // 音频sdk会自动下载
                EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
                NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
                NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
                NSLog(@"音频的secret -- %@"        ,body.secretKey);
                NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
                NSLog(@"音频文件的下载状态 -- %u"   ,body.downloadStatus);
                NSLog(@"音频的时间长度 -- %d"      ,body.duration);
                [bodyNode setObject:@"3" forKey:@"type"];
                [bodyNode setObject:body.remotePath forKey:@"remotePath"];
                [bodyNode setObject:body.localPath forKey:@"localPath"];
                [bodyNode setObject:@(body.fileLength) forKey:@"fileLength"];
                [bodyNode setObject:@(body.duration * 1000) forKey:@"duration"];
                [node setObject:bodyNode forKey:@"body"];
            }
                break;
            case EMMessageBodyTypeVideo:
            {
                EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
                
                NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
                NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
                NSLog(@"视频的secret -- %@"        ,body.secretKey);
                NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
                NSLog(@"视频文件的下载状态 -- %u"   ,body.downloadStatus);
                NSLog(@"视频的时间长度 -- %d"      ,body.duration);
                NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
                
                // 缩略图sdk会自动下载
                NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
                NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
                NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
                NSLog(@"缩略图的下载状态 -- %u"      ,body.thumbnailDownloadStatus);
                [bodyNode setObject:@"1" forKey:@"type"];
                [bodyNode setObject:body.remotePath forKey:@"remotePath"];
                [bodyNode setObject:body.localPath forKey:@"localPath"];
                [bodyNode setObject:body.thumbnailRemotePath forKey:@"thumbnailRemotePath"];
                [bodyNode setObject:body.thumbnailLocalPath forKey:@"thumbnailLocalPath"];
                [bodyNode setObject:@(body.fileLength) forKey:@"fileLength"];
                [bodyNode setObject:@(body.duration * 1000) forKey:@"duration"];
                [node setObject:bodyNode forKey:@"body"];
            }
                break;
            case EMMessageBodyTypeFile:
            {
                EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
                NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
                NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
                NSLog(@"文件的secret -- %@"        ,body.secretKey);
                NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
                NSLog(@"文件文件的下载状态 -- %u"   ,body.downloadStatus);
                [bodyNode setObject:body.remotePath forKey:@"remotePath"];
                [bodyNode setObject:body.localPath forKey:@"localPath"];
                [bodyNode setObject:@(body.fileLength) forKey:@"fileLength"];
                [node setObject:bodyNode forKey:@"body"];
            }
                break;
            default:
                break;
        }
        [resultArray addObject:node];
    }
    
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    [_invokeResult SetResultArray:resultArray];
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)getPublicGroups:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    int cursor = [doJsonHelper GetOneInteger:_dictParas :@"cursor" :1];
    int pageSize = [doJsonHelper GetOneInteger:_dictParas :@"pageSize" :20];
    EMError *error = nil;
    EMCursorResult *result = [[EMClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:[NSString stringWithFormat:@"%d",cursor] pageSize:pageSize error:&error];
    if (!error) {
        NSLog(@"获取成功 -- %@",result);
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    if (result.list.count > 0) {
        for (EMGroup *group in result.list) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:group.groupId forKey:@"groupId"];
            [resultArray addObject:dict];
        }
    }
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    if (resultArray.count > 0) {
        [_invokeResult SetResultArray:resultArray];
    }
    [_scritEngine Callback:_callbackName :_invokeResult];
    
}
/**
 *  登录
 *
 *  @param parms <#parms description#>
 */
- (void)login:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *username = [doJsonHelper GetOneText:_dictParas :@"username" :@""];
    NSString *password = [doJsonHelper GetOneText:_dictParas :@"password" :@""];
    BOOL isAutoLogin = [doJsonHelper GetOneBoolean:_dictParas :@"autoLogin" :NO];
    
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    
    [[EMClient sharedClient]asyncLoginWithUsername:username password:password success:^{
        //从内存加载会话
        [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
        
        [[EMClient sharedClient].options setIsAutoLogin:isAutoLogin];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"0" forKey:@"state"];
        [dict setObject:@"success" forKey:@"message"];
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        [_invokeResult SetResultNode:dict];
        [_scritEngine Callback:_callbackName :_invokeResult];
        
    } failure:^(EMError *aError) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"1" forKey:@"state"];
        [dict setObject:aError.errorDescription forKey:@"message"];
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        [_invokeResult SetResultNode:dict];
        [_scritEngine Callback:_callbackName :_invokeResult];
    }];
    //注册消息回调
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}
/**
 *  发送位置消息
 *
 *  @param parms <#parms description#>
 */
- (void)sendLocationMessage:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *username = [doJsonHelper GetOneText:_dictParas :@"username" :@""];
    CGFloat latitude = [doJsonHelper GetOneFloat:_dictParas :@"latitude" :0];
    CGFloat longitude = [doJsonHelper GetOneFloat:_dictParas :@"longitude" :0];
    NSString *address = [doJsonHelper GetOneText:_dictParas :@"address":@""];
    NSString *chatType = [doJsonHelper GetOneText:_dictParas :@"chatType" :@"Chat"];
    EMChatType type;
    if ([chatType compare:@"GroupChat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = EMChatTypeGroupChat;
    }
    else
    {
        type = EMChatTypeChat;
    }
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:latitude longitude:longitude address:address];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:username from:from to:username body:body ext:nil];
    message.chatType = type;
    
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            
            NSString *_callbackName = [parms objectAtIndex:2];
            //回调函数名_callbackName
            doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
            NSMutableDictionary *node = [NSMutableDictionary dictionary];
            [node setObject:message.messageId forKey:@"messageId"];
            [_invokeResult SetResultNode:node];
            [_scritEngine Callback:_callbackName :_invokeResult];
        }
    }];
}
/**
 *  发送图片，语音，视频，文件消息
 *
 *  @param parms <#parms description#>
 */
- (void)sendMediaMessage:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    //自己的代码实现
    NSString *username = [doJsonHelper GetOneText:_dictParas :@"username" :@""];
    NSString *chatType = [doJsonHelper GetOneText:_dictParas :@"chatType" :@"Chat"];
    NSString *path = [doJsonHelper GetOneText:_dictParas :@"path" :@""];
    NSString *title = [doJsonHelper GetOneText:_dictParas :@"title" :[path lastPathComponent]];
    
    EMChatType type;
    if ([chatType compare:@"GroupChat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = EMChatTypeGroupChat;
    }
    else
    {
        type = EMChatTypeChat;
    }
    int messageType = [doJsonHelper GetOneInteger:_dictParas :@"messageType" :0];
    NSString *localPath = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentApp :path];
    EMMessageBody *messageBody;
    if (messageType == 0) {//Image
        EMImageMessageBody *body = [[EMImageMessageBody alloc]initWithData:[NSData dataWithContentsOfFile:localPath] displayName:title];
        messageBody = body;
    }
    else if (messageType == 1)//Voice
    {
        EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:localPath displayName:title];
        
        body.duration = (int)[self durationWithVideo:[NSURL URLWithString:localPath]];
        messageBody = body;
    }
    else if (messageType == 2)//Video
    {
        EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:localPath displayName:title];
        messageBody = body;
    }
    else if (messageType == 3)//File
    {
        EMFileMessageBody *body = [[EMFileMessageBody alloc] initWithLocalPath:localPath    displayName:title];
        messageBody = body;
    }
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:username from:from to:username body:messageBody ext:nil];
    message.chatType = type;
    
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
            NSMutableDictionary *node = [NSMutableDictionary dictionary];
            [node setObject:message.messageId forKey:@"messageId"];
            [_invokeResult SetResultNode:node];
            [_scritEngine Callback:_callbackName :_invokeResult];
        }
    }];
}
/**
 *  发送文本消息
 *
 *  @param parms <#parms description#>
 */
- (void)sendTextMessage:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *username = [doJsonHelper GetOneText:_dictParas :@"username" :@""];
    NSString *text = [doJsonHelper GetOneText:_dictParas :@"text" :@""];
    NSString *chatType = [doJsonHelper GetOneText:_dictParas :@"chatType" :@"Chat"];
    EMChatType type;
    if ([chatType compare:@"GroupChat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = EMChatTypeGroupChat;
    }
    else
    {
        type = EMChatTypeChat;
    }
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:username from:from to:username body:body ext:nil];
    message.chatType = type;
    
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            
            NSString *_callbackName = [parms objectAtIndex:2];
            //回调函数名_callbackName
            doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
            NSMutableDictionary *node = [NSMutableDictionary dictionary];
            [node setObject:message.messageId forKey:@"messageId"];
            [_invokeResult SetResultNode:node];
            [_scritEngine Callback:_callbackName :_invokeResult];
        }
    }];
    
}
/**
 *  会话未读消息数量
 *
 *  @param parms <#parms description#>
 */
- (void)unreadMessagesCount:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    NSString *conversationId = [doJsonHelper GetOneText:_dictParas :@"conversationId" :@""];
    NSString *chatType = [doJsonHelper GetOneText:_dictParas :@"chatType" :@"Chat"];
    EMConversation *conversation;
    if ([chatType caseInsensitiveCompare:@"Chat"] == NSOrderedSame) {
        conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:EMConversationTypeChat createIfNotExist:NO];
    }
    else
    {
        conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:EMConversationTypeGroupChat createIfNotExist:NO];
    }
    [_invokeResult SetResultInteger:conversation.unreadMessagesCount];
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)revokeMessage:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    //自己的代码实现
    NSString *conversationId = [doJsonHelper GetOneText:_dictParas :@"conversationId" :@""];
    NSString *messageId = [doJsonHelper GetOneText:_dictParas :@"messageId" :@""];
    
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"REVOKE_FLAG"];
    NSDictionary *ext = @{@"msgId":messageId};
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    EMMessage *msg = [[EMMessage alloc] initWithConversationID:conversationId
                                                          from:currentUser
                                                            to:conversationId
                                                          body:body
                                                           ext:ext];
    [[EMClient sharedClient].chatManager asyncSendMessage:msg progress:nil completion:^(EMMessage *message, EMError *error) {
        BOOL isSecsuss;
        if (!error) {
            isSecsuss = YES;
        }
        else
        {
            isSecsuss = NO;
        }
        doInvokeResult *result = [[doInvokeResult alloc]init];
        [result SetResultBoolean:isSecsuss];
        [_scritEngine Callback:_callbackName :result];
    }];
}

#pragma mark - 私有方法
- (void)fireEvent:(NSString *)eventName withNode:(NSDictionary *)node
{
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    if (node) {
        [invokeResult SetResultNode:node];
    }
    [self.EventCenter FireEvent:eventName :invokeResult];
}
/**
 *  获得音频文件属性
 *
 *  @param videoUrl <#videoUrl description#>
 *
 *  @return <#return value description#>
 */
-(long long)durationWithVideo:(NSURL *)videoUrl{
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoUrl options:opts]; // 初始化视频媒体文件
    long long second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    
    return second;
}
- (void)downLoadMessage:(EMMessage *)message withCompletion:(void (^)(EMMessage *message,EMError *error))completion
{
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus != EMDownloadStatusSuccessed)
        {
            //下载缩略图
            [[[EMClient sharedClient] chatManager] asyncDownloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus != EMDownloadStatusSuccessed)
        {
            //下载缩略图
            [[[EMClient sharedClient] chatManager] asyncDownloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus != EMDownloadStatusSuccessed)
        {
            //下载语言
            [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeFile)
    {
        EMFileMessageBody *fileBody = (EMFileMessageBody *)messageBody;
        //下载文件
        if (fileBody.downloadStatus != EMDownloadStatusSuccessed) {
            [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:message progress:nil completion:completion];
        }
    }
}
- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = @"图片";
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = @"位置";
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = @"语音";
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = @"视频";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.chatType == EMChatTypeGroupChat) {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationId]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                    break;
                }
            }
        }
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = @"有一条消息";
    }
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
#pragma mark - 回调
/*!
 *  自动登录返回结果
 *
 *  @param aError 错误信息
 */
- (void)didAutoLoginWithError:(EMError *)aError
{
    if (!aError) {
       [self fireEvent:@"autoLogin" withNode:nil];
        [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
    }
}
/*!
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  有以下几种情况，会引起该方法的调用：
 *  1. 登录成功后，手机无法上网时，会调用该回调
 *  2. 登录成功后，网络状态变化时，会调用该回调
 *
 *  @param aConnectionState 当前状态
 */
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
    [self fireEvent:@"connectionStateChanged" withNode:node];
}
/*!
 *  当前登录账号在其它设备登录时会接收到该回调
 */
- (void)didLoginFromOtherDevice
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:@"1" forKey:@"state"];
    [self fireEvent:@"logout" withNode:node];
    [self logoff:nil];
}
/*!
 *  当前登录账号已经被从服务器端删除时会收到该回调
 */
- (void)didRemovedFromServer
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:@"0" forKey:@"state"];
    [self fireEvent:@"logout" withNode:node];
    [self logoff:nil];
}
// 接收在线透传消息
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    NSMutableArray *revokeMessageIds = nil;
    for (EMMessage *cmdMessage in aCmdMessages)
    {
        EMCmdMessageBody *body = (EMCmdMessageBody *)cmdMessage.body;
        if ([body.action isEqualToString:@"REVOKE_FLAG"]) {
            NSString *revokeMessageId = cmdMessage.ext[@"msgId"];
            BOOL isSuccess = [self removeRevokeMessageWithChatter:cmdMessage.from
                                                 conversationType:(EMConversationType)cmdMessage.chatType
                                                        messageId:revokeMessageId];
            if (isSuccess) {
                if (revokeMessageIds == nil) {
                    revokeMessageIds = [NSMutableArray arrayWithObjects:revokeMessageId, nil];
                }
                else {
                    [revokeMessageIds addObject:revokeMessageId];
                }
            }
        }
    }
    if (revokeMessageIds.count > 0) {
        doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
        [self.EventCenter FireEvent:@"revoke" :invokeResult];
    }
}
// 删除消息
- (BOOL)removeRevokeMessageWithChatter:(NSString *)aChatter
                      conversationType:(EMConversationType)type
                             messageId:(NSString *)messageId{
    
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aChatter type:type createIfNotExist:YES];
    return [conversation deleteMessageWithId:messageId];
}
// 收到消息的回调，带有附件类型的消息可以用 SDK 提供的下载附件方法下载（后面会讲到）
- (void)didReceiveMessages:(NSArray *)aMessages
{
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        
    };
    for (EMMessage *message in aMessages) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground) {
            [self showNotificationWithMessage:message];
            return;
        }
        completion(message,nil);
        [self handleMessage:message];
    }
}
- (void)handleMessage:(EMMessage *)aMessage
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    NSMutableDictionary *bodyNode = [NSMutableDictionary dictionary];
    if (aMessage.chatType == EMChatTypeChat) {
        [node setObject:@"Chat" forKey:@"chatType"];
    }
    else
    {
        [node setObject:@"GroupChat" forKey:@"chatType"];
    }
    [node setObject:aMessage.messageId forKey:@"messageId"];
    [node setObject:aMessage.conversationId forKey:@"conversationId"];
    [node setObject:aMessage.from forKey:@"from"];
    [node setObject:aMessage.to forKey:@"to"];
    [node setObject:@(aMessage.timestamp) forKey:@"timestamp"];
    
    EMMessageBody *msgBody = aMessage.body;
    switch (msgBody.type) {
        case EMMessageBodyTypeText:
        {
            // 收到的文字消息
            EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
            NSString *txt = textBody.text;
            NSLog(@"收到的文字是 txt -- %@",txt);
            [bodyNode setObject:@"0" forKey:@"type"];
            [bodyNode setObject:txt forKey:@"text"];
            [node setObject:bodyNode forKey:@"body"];
        }
            break;
        case EMMessageBodyTypeImage:
        {
            // 得到一个图片消息body
            EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);

            [bodyNode setObject:@"1" forKey:@"type"];
            [bodyNode setObject:body.remotePath forKey:@"remotePath"];
            [bodyNode setObject:body.thumbnailRemotePath forKey:@"thumbnailRemotePath"];
            [node setObject:bodyNode forKey:@"body"];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
            [bodyNode setObject:@"2" forKey:@"type"];
            [bodyNode setObject:@(body.latitude) forKey:@"latitude"];
            [bodyNode setObject:@(body.longitude) forKey:@"longitude"];
            [bodyNode setObject:body.address forKey:@"address"];
            [node setObject:bodyNode forKey:@"body"];
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            // 音频sdk会自动下载
            EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
            [bodyNode setObject:@"3" forKey:@"type"];
            [bodyNode setObject:body.remotePath forKey:@"remotePath"];
            [bodyNode setObject:@(body.fileLength) forKey:@"fileLength"];
            [bodyNode setObject:@(body.duration * 1000) forKey:@"duration"];
            [node setObject:bodyNode forKey:@"body"];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
            [bodyNode setObject:@"4" forKey:@"type"];
            [bodyNode setObject:body.remotePath forKey:@"remotePath"];
            [bodyNode setObject:body.thumbnailRemotePath forKey:@"thumbnailRemotePath"];
            [bodyNode setObject:@(body.fileLength) forKey:@"fileLength"];
            [bodyNode setObject:@(body.duration * 1000) forKey:@"duration"];
            [node setObject:bodyNode forKey:@"body"];
        }
            break;
        case EMMessageBodyTypeFile:
        {
            EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
            [bodyNode setObject:@"5" forKey:@"type"];
            [bodyNode setObject:body.remotePath forKey:@"remotePath"];
            [bodyNode setObject:@(body.fileLength) forKey:@"fileLength"];
            [node setObject:bodyNode forKey:@"body"];
        }
            break;
        default:
            break;
    }
    [self fireEvent:@"messages" withNode:node];

}

/*!
 @method
 @brief 用户A向群组G发送入群申请，群组G的群主O会接收到该回调
 */
- (void)didReceiveJoinGroupApplication:(EMGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:aGroup.groupId forKey:@"groupId"];
    [node setObject:aGroup.subject forKey:@"groupName"];
    [node setObject:aApplicant forKey:@"applicant"];
    [node setObject:aReason forKey:@"reason"];
    //群主收到进群申请
    [self fireEvent:@"joinGroup" withNode:node];
}
/*!
 @method
 @brief 接收到离开群组，群组被销毁或者被从群中移除
 */
- (void)didReceiveLeavedGroup:(EMGroup *)aGroup
                       reason:(EMGroupLeaveReason)aReason
{
    NSString *reasonStr;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        reasonStr = @" 被移除";
    }
    else if (aReason == EMGroupLeaveReasonDestroyed)
    {
        reasonStr = @" 被销毁";
    }
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:aGroup.groupId forKey:@"groupId"];
    [node setObject:aGroup.subject forKey:@"groupName"];
    [node setObject:reasonStr forKey:@"reason"];
    //被动离群
    [self fireEvent:@"leavedGroup" withNode:node];
}
/*!
 *  \~chinese
 *  用户A邀请用户B入群,用户B接收到该回调
 *
 *  @param aGroupId    群组ID
 *  @param aInviter    邀请者
 *  @param aMessage    邀请信息
 *
 */
- (void)didReceiveGroupInvitation:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:aGroupId forKey:@"groupId"];
    [node setObject:aInviter forKey:@"inviter"];
    [node setObject:aMessage forKey:@"reason"];
    //收到进群邀请
    [self fireEvent:@"groupInvitation" withNode:node];
}
/*!
 *  \~chinese
 *  用户B同意用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组实例
 *  @param aInvitee  被邀请者
 *
 */
- (void)didReceiveAcceptedGroupInvitation:(EMGroup *)aGroup
                                  invitee:(NSString *)aInvitee
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:aGroup.groupId forKey:@"groupId"];
    [node setObject:aInvitee forKey:@"invitee"];
    [node setObject:@"" forKey:@"reason"];
    //进群邀请被接受
    [self fireEvent:@"invitationAccpted" withNode:node];
}
/*!
 *  \~chinese
 *  用户B拒绝用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组
 *  @param aInvitee  被邀请者
 *  @param aReason   拒绝理由
 */
- (void)didReceiveDeclinedGroupInvitation:(EMGroup *)aGroup
                                  invitee:(NSString *)aInvitee
                                   reason:(NSString *)aReason
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:aGroup.groupId forKey:@"groupId"];
    [node setObject:aInvitee forKey:@"invitee"];
    [node setObject:@"" forKey:@"reason"];
    //进群邀请被拒绝
    [self fireEvent:@"invitationDeclined" withNode:node];
}


@end

















