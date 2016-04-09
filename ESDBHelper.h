//
//  ESDBHelper.h
//  buyer
//
//  Created by quanzhizu on 16/3/17.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESDBHelper : NSObject

+(void)loadAllStatus;
/**
 *  获取关注设计师列表
 */
+(void)loadFollowDesignerList;

/**
 *  获取关注用户列表
 */
+(void)loadMyFollows;


/**
 *  获取收藏列表
 */
+(void)loadCollect;

@end
