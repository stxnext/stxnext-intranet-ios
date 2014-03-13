//
//  UserListCell.m
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserListCell.h"

@implementation UserListCell



- (void)setUser:(RMUser *)user
{
    self.userName.text = user.name;
    self.userImage.layer.cornerRadius = 5;
    self.userImage.clipsToBounds = YES;
    
    self.userImage.layer.borderColor = [[UIColor grayColor] CGColor];
    self.userImage.layer.borderWidth = 1;
    
    self.clockView.hidden = self.warningDateLabel.hidden = ((user.lates.count + user.absences.count) == 0);
    
    NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
    absenceDateFormater.dateFormat = @"YYYY-MM-dd";
    
    NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
    latesDateFormater.dateFormat = @"HH:mm";
    
    __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
    
    if (user.lates.count)
    {
        self.clockView.color = MAIN_YELLOW_COLOR;
        
        [user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMLate *late = (RMLate *)obj;
            
            NSString *start = [latesDateFormater stringFromDate:late.start];
            NSString *stop = [latesDateFormater stringFromDate:late.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@ - %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    else if (user.absences.count)
    {
        self.clockView.color = MAIN_RED_COLOR;
        
        [user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMAbsence *absence = (RMAbsence *)obj;
            
            NSString *start = [absenceDateFormater stringFromDate:absence.start];
            NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@  -  %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    
    [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    self.warningDateLabel.text = hours;
    
    if (user.avatarURL)
    {
        [self.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]];
    }
    else
    {
        self.userImage.image = nil;
    }

    _user = user;
}

+ (NSString *)cellId
{
    static NSString *UserListCellId = @"UserCell";
    
    return UserListCellId;
}
@end
