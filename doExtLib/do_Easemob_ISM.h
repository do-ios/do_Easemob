//
//  do_Easemob_IMethod.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_Easemob_ISM <NSObject>

//实现同步或异步方法，parms中包含了所需用的属性
@required
- (void)acceptInvitationFromGroup:(NSArray *)parms;
- (void)acceptJoinApplication:(NSArray *)parms;
- (void)applyJoinToGroup:(NSArray *)parms;
- (void)changeGroupSubject:(NSArray *)parms;
- (void)createGroup:(NSArray *)parms;
- (void)declineInvitationFromGroup:(NSArray *)parms;
- (void)declineJoinApplication:(NSArray *)parms;
- (void)deleteConversation:(NSArray *)parms;
- (void)destroyGroup:(NSArray *)parms;
- (void)fetchGroupInfo:(NSArray *)parms;
- (void)getAllConversations:(NSArray *)parms;
- (void)getConversation:(NSArray *)parms;
- (void)getPublicGroups:(NSArray *)parms;
- (void)inviteToGroup:(NSArray *)parms;
- (void)leaveGroup:(NSArray *)parms;
- (void)login:(NSArray *)parms;
- (void)logoff:(NSArray *)parms;
- (void)removeOccupants:(NSArray *)parms;
- (void)sendLocationMessage:(NSArray *)parms;
- (void)sendMediaMessage:(NSArray *)parms;
- (void)sendTextMessage:(NSArray *)parms;
- (void)unreadMessagesCount:(NSArray *)parms;
- (void)revokeMessage:(NSArray *)parms;

@end
