//
//  PGTicketCreateViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 08/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGTicketCreateViewController : UITableViewController

@property (nonatomic, strong, readonly) NSString* ticketName;

@end

@interface PGTicketCreateCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField* inputTextField;

@end