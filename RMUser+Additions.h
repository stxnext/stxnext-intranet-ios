//
//  RMUser+Additions.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RMUser.h"

@interface RMUser (Additions) <JSONMapping>

#pragma mark Mapping

extern const NSString* MapKeyUserId;
extern const NSString* MapKeyUserName;
extern const NSString* MapKeyUserImageURL;
extern const NSString* MapKeyUserAvatarURL;
extern const NSString* MapKeyUserLocation;
extern const NSString* MapKeyUserIsFreelancer;
extern const NSString* MapKeyUserIsClient;
extern const NSString* MapKeyUserIsActive;
extern const NSString* MapKeyUserStartWork;
extern const NSString* MapKeyUserStartFullTimeWork;
extern const NSString* MapKeyUserStopWork;
extern const NSString* MapKeyUserPhone;
extern const NSString* MapKeyUserPhoneDesk;
extern const NSString* MapKeyUserSkype;
extern const NSString* MapKeyUserIrc;
extern const NSString* MapKeyUserEmail;
extern const NSString* MapKeyUserTasksLink;
extern const NSString* MapKeyUserAvailabilityLink;
extern const NSString* MapKeyUserRoles;
extern const NSString* MapKeyUserGroups;

+ (NSMutableArray *)loadOutOffOfficePeople;

- (RMLate *)lateForToday;

@end
