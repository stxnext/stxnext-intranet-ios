//
//  TeamManager.h
//  Intranet
//
//  Created by Adam on 13.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamMember : NSObject

@property (nonatomic, strong) RMUser *user;
@property (nonatomic, assign) BOOL isSelected;

@end



@interface TeamInfo : NSObject

@property (nonatomic, strong) NSNumber *teamId;
@property (nonatomic, copy) NSString *teamName;

@end



@interface TeamManager : NSObject



+ (void)downloadTeamsWithSuccess:(void (^)(NSArray *teamsInfos, NSArray *teamsMembers))success
                         failure:(void (^)(void))failure;


@end

