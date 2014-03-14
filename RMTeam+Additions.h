//
//  RMTeam+Additions.h
//  Intranet
//
//  Created by Adam on 14.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMTeam.h"

@interface RMTeam (Additions) <JSONMapping>

#pragma mark Mapping

extern const NSString* MapKeyTeamId;
extern const NSString* MapKeyTeamName;
extern const NSString* MapKeyTeamUsers;

@end
