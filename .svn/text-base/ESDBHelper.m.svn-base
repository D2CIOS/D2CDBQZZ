//
//  ESDBHelper.m
//  buyer
//
//  Created by quanzhizu on 16/3/17.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ESDBHelper.h"
#import "ESDataBaseManager.h"
#import "ESUser.h"
#import "ESFollowDesignerModel.h"
#import "ESAttentionFollowsModel.h"
#import "ESCollectModel.h"
@implementation ESDBHelper


//获取所有状态
+(void)loadAllStatus{
    
    [[ESUser sharedInstance].statusSignal subscribeNext:^(id x) {
        if ([ESUser sharedInstance].status == ESUserStatusOnline) {
            [ESDBHelper loadFollowDesignerList];
            [ESDBHelper loadMyFollows];
            [ESDBHelper loadCollect];
        }
    }];
    
    
}

//获取关注设计师列表
+(void)loadFollowDesignerList{
    
    [ESRequest removeCahceWithType:ESRequestTypeFollowDesignerList];
    

    ESRequest *re = [ESRequest RequestWithType:ESRequestTypeFollowDesignerList Parameters:@{@"p": @(1), @"pageSize": @(40)} completionBlock:^(ESRequest * _Nonnull request) {
        if (request.responseStatusCode != 1) {
            //HUDFailure(request.responseMsg);
        }{
            NSArray *array = [ESFollowDesignerModel mj_objectArrayWithKeyValuesArray:request.responseData[@"myAttentions"][@"list"]];
            for (ESFollowDesignerModel *model in array) {
                [[ESDataBaseManager shareInstance] insertDesignAttenToDB:model.designerId];
            }
        }
        
        
        
    }] ;
    [re start];

}


//获取关注用户列表
+(void)loadMyFollows{
    
    [ESRequest removeCahceWithType:ESRequestTypemyFollows];
    
    [[ESRequest RequestWithType:ESRequestTypemyFollows Parameters:@{@"p": @(1), @"pageSize": @(40)} completionBlock:^(ESRequest * _Nonnull request) {
        
        if (request.responseStatusCode != 1) {
            //HUDFailure(request.responseMsg);
        }{
          NSArray *array = [ESAttentionFollowsModel mj_objectArrayWithKeyValuesArray:request.responseObject[@"data"][@"myFollows"][@"list"]];
        
         for (ESAttentionFollowsModel *model in array) {
            [[ESDataBaseManager shareInstance] insertUserAttenToDB:model.memberId.integerValue];
            }
        }
        
        
    }] start];
}


//获取收藏列表
+(void)loadCollect{
    [ESRequest removeCahceWithType:ESRequestTypeCollect];
    
    
    [[ESRequest RequestWithType:ESRequestTypeCollect Parameters:@{@"p": @(1), @"pageSize": @(40)} completionBlock:^(ESRequest * _Nonnull request) {
        
        if (request.responseStatusCode != 1) {
            //HUDFailure(request.responseMsg);
        }{
            ESCollectModel *esmodel = [ESCollectModel mj_objectWithKeyValues:[request.responseData objectForKey:@"myCollections"]];
            for (ESCollectCellModel *model in esmodel.list) {
                [[ESDataBaseManager shareInstance] insertCollectToDB:model.productId];
            }
        }
        
        
    }] start];
    
}


@end
