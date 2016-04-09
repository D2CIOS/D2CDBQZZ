//
//  ESDataBaseManager.h
//  buyer
//
//  Created by quanzhizu on 16/3/15.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface ESDataBaseManager : NSObject

+(ESDataBaseManager *)shareInstance;


@property (nonatomic, strong) FMDatabaseQueue *queue;


@property (nonatomic, strong) FMDatabaseQueue *gobleMsgQueue;
//创建表
-(void)creatTable;


//插入消息
-(void)insertMsgToDB:(ESMsgItemBean *)msg;
-(void)insertGoblesMsgToDB:(ESMsgItemBean *)msg;

//插入关注用户数据
-(void)insertUserAttenToDB:(NSInteger)memberId;

//插入关注设计师数据
-(void)insertDesignAttenToDB:(NSInteger)designerId;


//插入收藏数据
-(void)insertCollectToDB:(NSInteger)productId;


//插入收藏数据
-(void)insertSupportToDB:(NSInteger)supportMemberId;



/**
 *  删除关注用户
 *
 *  @param model <#model description#>
 */
-(void)deleteUserAttenToDB:(NSInteger)memberId;


//插入关注设计师数据
-(void)deleteDesignAttenToDB:(NSInteger)designerId;


//插入收藏数据
-(void)deleteCollectToDB:(NSInteger)productId;


//插入点赞数据
-(void)deleteSupportToDB:(NSInteger)supportMemberId;


//删除消息
-(void)deleteMsgToDB:(NSNumber *)msgId;
//删除消息
-(void)deleteGoblesMsgToDB:(NSNumber *)msgId;

/**
 *  获取关注用户列表
 *
 *  @param memberId 小于0查全部
 *
 *  @return <#return value description#>
 */

-(NSArray *)getAttenUserByMemberId:(NSInteger)memberId;


//获取关注设计师列表

-(NSArray *) getAttenDesignByDesignId:(NSInteger)designerId;


//获取收藏列表

-(NSArray *)getCollectByProductId:(NSInteger)productId;


//获取收藏列表

-(NSArray *)getSupportByProductId:(NSInteger)supportMemberId;


//获取消息
-(NSArray *)getMsgByMsgId:(NSNumber *)msgId isDel:(NSNumber *)isDel;
-(NSArray *)getMsgByMsgId:(NSNumber *)msgId;


//获取全局消息
-(NSArray *)getGoblesMsgByMsgId:(NSNumber *)msgId isDel:(NSNumber *)isDel;
-(NSArray *)getGoblesMsgByMsgId:(NSNumber *)msgId;
@end
