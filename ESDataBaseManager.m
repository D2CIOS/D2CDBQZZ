//
//  ESDataBaseManager.m
//  buyer
//
//  Created by quanzhizu on 16/3/15.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESDataBaseManager.h"
#import "ESUser.h"
#import "ESFollowDesignerModel.h"
#import "ESAttentionFollowsModel.h"
#import "ESCollectModel.h"
@implementation ESDataBaseManager

static ESDataBaseManager *dataBaseManager = nil;
@synthesize queue;
@synthesize gobleMsgQueue;

/**
 *  用户关注表
 */
static NSString * const userAttenTableName = @"USERATTENTABLE";

//设计师关注表
static NSString * const designAttenTableName = @"DESIGNATTENTABLE";

//点赞表
static NSString * const userSupportTableName = @"USESUPPORTTABLE";

//收藏表
static NSString * const collectTableName = @"COLLECTTABLE";


//订阅消息
static NSString * const messageTableName = @"MESSAGETABLE";

//全局消息
static NSString * const gobleMsgTableName = @"GOBLEMSGTABLE";

+(ESDataBaseManager *)shareInstance{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSLog(@"documentDirectory = %@\n",documentDirectory);
    if (dataBaseManager == nil) {
        dataBaseManager = [[ESDataBaseManager alloc] init];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"ESDBGOBLEMSG.db"];
        dataBaseManager.gobleMsgQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [dataBaseManager creatGobleTable];
        
    }
    if ([ESUser sharedInstance].status == ESUserStatusOnline) {
       
        if (dataBaseManager.queue == nil) {
            
            NSString *dbPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"ESDB%@.db",@([ESUser sharedInstance].model.memberId)]];
            dataBaseManager.queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
            
            [dataBaseManager creatTable];
        }
        
    }
    
    return dataBaseManager;
    
}


+ (BOOL) isTableOK:(NSString *)tableName withDB:(FMDatabase *)db
{
    BOOL isOK = NO;
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count)
        {
            isOK =  NO;
        }
        else
        {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}


-(void)creatGobleTable{
    
    if ([ESHelper isNull:self.gobleMsgQueue]) {
        return;
    }
    [gobleMsgQueue inDatabase:^(FMDatabase *db) {
        if (![ESDataBaseManager isTableOK:gobleMsgTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GOBLEMSGTABLE (id integer PRIMARY KEY autoincrement,content text,createDate text,title text,type text,url text,msgId integer,isDel integer,status integer)";
            [db executeUpdate:createTableSQL];
            
            NSString *createIndexSQL=@"CREATE unique INDEX idx_msgId ON GOBLEMSGTABLE(msgId);";
            [db executeUpdate:createIndexSQL];
        }
    }];
    
}


-(void)creatTable{
    
    if ([ESHelper isNull:self.queue]) {
        return;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        if (![ESDataBaseManager isTableOK:userAttenTableName withDB:db]) {
            
            NSString *createTableSQL = @"CREATE TABLE USERATTENTABLE (id integer PRIMARY KEY autoincrement, myMemberId integer,attenMemberId integer)";
            [db executeUpdate:createTableSQL];
            
            NSString *createIndexSQL=@"CREATE unique INDEX idx_attenMemberId ON USERATTENTABLE(attenMemberId);";
            [db executeUpdate:createIndexSQL];
            
        }
        
        if (![ESDataBaseManager isTableOK:designAttenTableName withDB:db]) {
            
            NSString *createTableSQL = @"CREATE TABLE DESIGNATTENTABLE (id integer PRIMARY KEY autoincrement, myMemberId integer,designerId integer)";
            [db executeUpdate:createTableSQL];
            
            NSString *createIndexSQL=@"CREATE unique INDEX idx_designerId ON DESIGNATTENTABLE(designerId);";
            [db executeUpdate:createIndexSQL];
            
        }
        
        if (![ESDataBaseManager isTableOK:userSupportTableName withDB:db]) {
            
            NSString *createTableSQL = @"CREATE TABLE USESUPPORTTABLE (id integer PRIMARY KEY autoincrement, myMemberId integer,supportMemberId integer)";
            [db executeUpdate:createTableSQL];
            
            NSString *createIndexSQL=@"CREATE unique INDEX idx_supportMemberId ON USESUPPORTTABLE(supportMemberId);";
            [db executeUpdate:createIndexSQL];
        }
        
        
        if (![ESDataBaseManager isTableOK:collectTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE COLLECTTABLE (id integer PRIMARY KEY autoincrement, myMemberId integer,productId integer)";
            [db executeUpdate:createTableSQL];
            
            NSString *createIndexSQL=@"CREATE unique INDEX idx_productId ON COLLECTTABLE(productId);";
            [db executeUpdate:createIndexSQL];
        }
       
        
        if (![ESDataBaseManager isTableOK:messageTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE MESSAGETABLE (id integer PRIMARY KEY autoincrement,content text,createDate text,title text,type text,url text,msgId integer,isDel integer,status integer)";
            [db executeUpdate:createTableSQL];
            
            NSString *createIndexSQL=@"CREATE unique INDEX idx_msgId ON MESSAGETABLE(msgId);";
            [db executeUpdate:createIndexSQL];
        }
        
    }];
}



//插入消息
-(void)insertMsgToDB:(ESMsgItemBean *)msg{
    
    NSString *insertSql = @"REPLACE INTO MESSAGETABLE (content ,createDate ,title ,type ,url ,msgId ,isDel ,status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,msg.content,msg.createDate,msg.title,msg.type,msg.url,msg.msgId,msg.isDel,msg.status];
    }];
    
    
}


//插入全局消息
-(void)insertGoblesMsgToDB:(ESMsgItemBean *)msg{
    
    NSString *insertSql = @"REPLACE INTO GOBLEMSGTABLE (content ,createDate ,title ,type ,url ,msgId ,isDel ,status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    
    [gobleMsgQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,msg.content,msg.createDate,msg.title,msg.type,msg.url,msg.msgId,msg.isDel,msg.status];
    }];
    
    
}

//插入关注用户数据
-(void)insertUserAttenToDB:(NSInteger)memberId{
    
    NSString *insertSql = @"REPLACE INTO USERATTENTABLE (myMemberId, attenMemberId) VALUES (?, ?)";
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,@([ESUser sharedInstance].model.memberId),@(memberId)];
    }];
    
}

//插入关注设计师数据
-(void)insertDesignAttenToDB:(NSInteger )designerId{
    
    NSString *insertSql = @"REPLACE INTO DESIGNATTENTABLE (myMemberId, designerId) VALUES (?, ?)";
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,@([ESUser sharedInstance].model.memberId),@(designerId)];
    }];
    
}


//插入收藏数据
-(void)insertCollectToDB:(NSInteger )productId{
    
    NSString *insertSql = @"REPLACE INTO COLLECTTABLE (myMemberId, productId) VALUES (?, ?)";
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,@([ESUser sharedInstance].model.memberId),@(productId)];
    }];
    
}


//插入点赞数据
-(void)insertSupportToDB:(NSInteger )supportMemberId{
    
    NSString *insertSql = @"REPLACE INTO USESUPPORTTABLE (myMemberId, supportMemberId) VALUES (?, ?)";
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,@([ESUser sharedInstance].model.memberId),@(supportMemberId)];
    }];
    
}


/**
 *  删除关注用户
 *
 *  @param model <#model description#>
 */
-(void)deleteUserAttenToDB:(NSInteger)memberId{
    
    NSString *insertSql = [NSString stringWithFormat:@"DELETE FROM USERATTENTABLE WHERE attenMemberId=%@",@(memberId)];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql];
    }];
    
}



//删除关注设计师数据
-(void)deleteDesignAttenToDB:(NSInteger)designerId{
    
    NSString *insertSql = [NSString stringWithFormat:@"DELETE FROM DESIGNATTENTABLE WHERE designerId=%@",@(designerId)];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql];
    }];
    
}


//删除收藏数据
-(void)deleteCollectToDB:(NSInteger )productId{
    
    NSString *insertSql = [NSString stringWithFormat:@"DELETE FROM COLLECTTABLE WHERE productId=%@",@(productId)];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql];
    }];
    
}


//删除点赞数据
-(void)deleteSupportToDB:(NSInteger )supportMemberId{
    
    NSString *insertSql = [NSString stringWithFormat:@"DELETE FROM USESUPPORTTABLE WHERE supportMemberId=%@",@(supportMemberId)];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql];
    }];
    
}


//删除消息
-(void)deleteMsgToDB:(NSNumber *)msgId{
    
    NSString *insertSql = [NSString stringWithFormat:@"DELETE FROM MESSAGETABLE WHERE msgId=%@",msgId];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql];
    }];
    
}


//删除全局消息
-(void)deleteGoblesMsgToDB:(NSNumber *)msgId{
    
    NSString *insertSql = [NSString stringWithFormat:@"DELETE FROM GOBLEMSGTABLE WHERE msgId=%@",msgId];
    
    [gobleMsgQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql];
    }];
    
}

/**
 *  获取关注用户列表
 *
 *  @param memberId 小于0查全部
 *
 *  @return <#return value description#>
 */

-(NSArray *) getAttenUserByMemberId:(NSInteger)memberId
{
    NSMutableArray *allUsers = [NSMutableArray new];
    
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM USERATTENTABLE WHERE attenMemberId=%@",@(memberId)];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (memberId < 0) {
            rs = [db executeQuery:@"SELECT * FROM USERATTENTABLE"];
        }
        while ([rs next]) {
            ESAttentionFollowsModel *model;
            model = [[ESAttentionFollowsModel alloc] init];
            model.memberId = [rs stringForColumn:@"attenMemberId"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}


//获取关注设计师列表

-(NSArray *) getAttenDesignByDesignId:(NSInteger)designerId
{
    NSMutableArray *allUsers = [NSMutableArray new];
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM DESIGNATTENTABLE WHERE designerId = %@",@(designerId)];
    [queue inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:str];
        if (designerId < 0) {
            rs = [db executeQuery:@"SELECT * FROM DESIGNATTENTABLE"];
        }
        while ([rs next]) {
            ESFollowDesignerModel *model;
            model = [[ESFollowDesignerModel alloc] init];
            model.designerId = [rs intForColumn:@"designerId"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}


//获取收藏列表

-(NSArray *)getCollectByProductId:(NSInteger)productId
{
    NSMutableArray *allUsers = [NSMutableArray new];
     NSString *str = [NSString stringWithFormat:@"SELECT * FROM COLLECTTABLE WHERE productId = %@",@(productId)];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (productId < 0) {
            rs = [db executeQuery:@"SELECT * FROM COLLECTTABLE"];
        }
        while ([rs next]) {
            ESCollectCellModel *model;
            model = [[ESCollectCellModel alloc] init];
            model.productId = [rs intForColumn:@"productId"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}


//获取收藏列表

-(NSArray *)getSupportByProductId:(NSInteger)supportMemberId
{
    NSMutableArray *allUsers = [NSMutableArray new];
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM USESUPPORTTABLE WHERE supportMemberId = %@",@(supportMemberId)];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (supportMemberId < 0) {
            rs = [db executeQuery:@"SELECT * FROM USESUPPORTTABLE"];
        }
        while ([rs next]) {
            ESAttentionFollowsModel *model;
            model = [[ESAttentionFollowsModel alloc] init];
            model.memberId = [rs stringForColumn:@"supportMemberId"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}




//获取全局消息

-(NSArray *)getMsgByMsgId:(NSNumber *)msgId isDel:(NSNumber *)isDel
{
    NSMutableArray *allUsers = [NSMutableArray new];
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM MESSAGETABLE WHERE msgId = %@ AND isDel = %@",msgId,isDel];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (msgId.integerValue < 0) {
            rs = [db executeQuery:@"SELECT * FROM MESSAGETABLE"];
        }
        while ([rs next]) {
            ESMsgItemBean *msg;
            msg = [[ESMsgItemBean alloc] init];
            msg.msgId = @([rs intForColumn:@"msgId"]);
            msg.content = [rs stringForColumn:@"content"];
            msg.createDate = [rs stringForColumn:@"createDate"];
            msg.title = [rs stringForColumn:@"title"];
            msg.type = @([rs intForColumn:@"type"]);
            msg.url = [rs stringForColumn:@"url"];
            [allUsers addObject:msg];
        }
        [rs close];
    }];
    return allUsers;
}


//获取全局消息

-(NSArray *)getMsgByMsgId:(NSNumber *)msgId
{
    NSMutableArray *allUsers = [NSMutableArray new];
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM MESSAGETABLE WHERE msgId = %@",msgId];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (msgId.integerValue < 0) {
            rs = [db executeQuery:@"SELECT * FROM MESSAGETABLE"];
        }
        while ([rs next]) {
            ESMsgItemBean *msg;
            msg = [[ESMsgItemBean alloc] init];
            msg.msgId = @([rs intForColumn:@"msgId"]);
            msg.content = [rs stringForColumn:@"content"];
            msg.createDate = [rs stringForColumn:@"createDate"];
            msg.title = [rs stringForColumn:@"title"];
            msg.type = @([rs intForColumn:@"type"]);
            msg.url = [rs stringForColumn:@"url"];
            [allUsers addObject:msg];
        }
        [rs close];
    }];
    return allUsers;
}




//获取全局消息

-(NSArray *)getGoblesMsgByMsgId:(NSNumber *)msgId isDel:(NSNumber *)isDel
{
    NSMutableArray *allUsers = [NSMutableArray new];
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM GOBLEMSGTABLE WHERE msgId = %@ AND isDel = %@",msgId,isDel];
    [gobleMsgQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (msgId.integerValue < 0) {
            rs = [db executeQuery:@"SELECT * FROM GOBLEMSGTABLE"];
        }
        while ([rs next]) {
            ESMsgItemBean *msg;
            msg = [[ESMsgItemBean alloc] init];
            msg.msgId = @([rs intForColumn:@"msgId"]);
            msg.content = [rs stringForColumn:@"content"];
            msg.createDate = [rs stringForColumn:@"createDate"];
            msg.title = [rs stringForColumn:@"title"];
            msg.type = @([rs intForColumn:@"type"]);
            msg.url = [rs stringForColumn:@"url"];
            [allUsers addObject:msg];
        }
        [rs close];
    }];
    return allUsers;
}
//获取全局消息

-(NSArray *)getGoblesMsgByMsgId:(NSNumber *)msgId
{
    NSMutableArray *allUsers = [NSMutableArray new];
    NSString *str = [NSString stringWithFormat:@"SELECT * FROM GOBLEMSGTABLE WHERE msgId = %@",msgId];
    [gobleMsgQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:str];
        if (msgId.integerValue < 0) {
            rs = [db executeQuery:@"SELECT * FROM GOBLEMSGTABLE"];
        }
        while ([rs next]) {
            ESMsgItemBean *msg;
            msg = [[ESMsgItemBean alloc] init];
            msg.msgId = @([rs intForColumn:@"msgId"]);
            msg.content = [rs stringForColumn:@"content"];
            msg.createDate = [rs stringForColumn:@"createDate"];
            msg.title = [rs stringForColumn:@"title"];
            msg.type = @([rs intForColumn:@"type"]);
            msg.url = [rs stringForColumn:@"url"];
            [allUsers addObject:msg];
        }
        [rs close];
    }];
    return allUsers;
}

@end
