//
//  UserDetailsViewController.m
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserDetailsTableViewController.h"
#import "RMUser+AddressBook.h"

@interface UserDetailsTableViewController ()

@end

@implementation UserDetailsTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //code here
    
    if (INTERFACE_IS_PAD)
    {
        self.title = @"Informacje kontaktowe";
    }
    
    [self.tableView hideEmptySeparators];
    
    [self.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:self.user.avatarURL]];
    self.userImage.layer.cornerRadius = 5;
    self.userImage.clipsToBounds = YES;
    
    self.userName.text = self.user.name;
    
    if (self.user.phone)
    {
        self.phoneLabel.text = self.user.phone;
    }
    else
    {
        self.phoneCell.hidden = YES;
    }
    
    if (self.user.phoneDesk)
    {
        self.phoneDeskLabel.text = self.user.phoneDesk;
    }
    else
    {
        self.phoneDeskCell.hidden = YES;
    }
    
    if (self.user.email)
    {
        self.emailLabel.text = self.user.email;
    }
    else
    {
        self.emailCell.hidden = YES;
    }
    
    if (self.user.skype)
    {
        self.skypeLabel.text = self.user.skype;
    }
    else
    {
        self.skypeCell.hidden = YES;
    }
    
    if (self.user.irc)
    {
        self.ircLabel.text = self.user.irc;
    }
    else
    {
        self.ircCell.hidden = YES;
    }

    if (self.user.location)
    {
        self.locationLabel.text = self.user.location;
    }
    else
    {
        self.locationCell.hidden = YES;
    }
    
    if ([self.user.groups count])
    {
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];

        for (NSString *group in self.user.groups)
        {
            [string appendFormat:@"%@, ", group];
        }
        
        [string  replaceCharactersInRange:NSMakeRange(string.length - 2, 2) withString:@""];
        
        self.groupsLabel.text = [string capitalizedString];
    }
    else
    {
        self.groupsCell.hidden = YES;
    }
    
    if ([self.user.roles count])
    {
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        
        for (NSString *role in self.user.roles)
        {
            [string appendFormat:@"%@, ", role];
        }
        
        [string replaceCharactersInRange:NSMakeRange(string.length - 2, 2) withString:@""];
        
        self.rolesLabel.text = [string capitalizedString];
    }
    else
    {
        self.rolesCell.hidden = YES;
    }
    
    self.clockView.hidden = ((self.user.lates.count + self.user.absences.count) == 0);
    
    __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
    __block NSMutableString *explanation = [[NSMutableString alloc] initWithString:@""];
    
    NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
    absenceDateFormater.dateFormat = @"YYYY-MM-dd";
    
    NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
    latesDateFormater.dateFormat = @"HH:mm";
    
    if (self.user.lates.count)
    {
        self.clockView.color = MAIN_YELLOW_COLOR;
        
        [self.user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMLate *late = (RMLate *)obj;
            
            NSString *start = [latesDateFormater stringFromDate:late.start];
            NSString *stop = [latesDateFormater stringFromDate:late.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@ - %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
            
            if (late.explanation)
            {
                [explanation appendFormat:@" %@", late.explanation];
            }
        }];
    }
    else if (self.user.absences.count)
    {
        self.clockView.color = MAIN_RED_COLOR;
        
        [self.user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMAbsence *absence = (RMAbsence *)obj;
            
            NSString *start = [absenceDateFormater stringFromDate:absence.start];
            NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@  -  %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
            
            if (absence.remarks)
            {
                [explanation appendFormat:@" %@", absence.remarks];
            }
        }];
    }

    [hours setString:[hours  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [explanation setString:[explanation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    NSString *text = [NSString stringWithFormat:@"%@%@%@", hours, (hours.length && explanation.length ? @"\n" : @""), explanation];
        
    self.explanationLabel.text = text;
    
    [self.explanationLabel sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //code here
}

- (void)viewWillAppear:(BOOL)animated
{
    //code here
    
    [super viewWillAppear:animated];
    
    // check if user is in system contacts or not
    [self updateAddToContactsButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //code here
}

- (void)viewWillDisappear:(BOOL)animated
{
    //code here
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.phoneCell)
    {
        [self phoneCall];
    }
    else if (cell == self.phoneDeskCell)
    {
        [self phoneDeskCall];
    }
    else if (cell == self.emailCell)
    {
        [self emailSend];
    }
    else if (cell == self.skypeCell)
    {
        [self skypeCall];
    }
    else if (cell == self.ircCell)
    {
        [self ircSend];
    }
    else if (cell == self.addToContactsCell)
    {
        [self addToContacts];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.mainCell)
    {
        float size = self.explanationLabel.frame.size.height + 10 + self.userName.frame.size.height + 10;
        
        return size > cell.frame.size.height ? size : cell.frame.size.height;
    }
    
    return cell.isHidden ? 0 : cell.frame.size.height;
}

#pragma mark - Actions

- (void)openUrl:(NSURL*)url orAlertWithText:(NSString*)alertText
{
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [UIAlertView alertWithTitle:@"Błąd" withText:alertText];
    }
}

- (void)phoneCall
{
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:self.user.phone]]
  orAlertWithText:@"Nie znaleziono aplikacji obsługującej połączenia telefoniczne."];
}

- (void)phoneDeskCall
{
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:self.user.phoneDesk]]
  orAlertWithText:@"Nie znaleziono aplikacji obsługującej połączenia telefoniczne."];
}

- (void)emailSend
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSArray *toRecipents = [NSArray arrayWithObject:self.user.email];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        [UIAlertView alertWithTitle:@"Błąd"
                           withText:@"Nie znaleziono aplikacji obsługującej wiadomości email."];
    }
}

- (void)skypeCall
{
    [self openUrl:[NSURL URLWithString:[@"skype://" stringByAppendingString:self.user.skype]]
  orAlertWithText:@"Nie znaleziono aplikacji do komunikacji skype."];
}

- (void)ircSend
{
    [self openUrl:[NSURL URLWithString:[@"irc://" stringByAppendingString:self.user.irc]]
  orAlertWithText:@"Nie znaleziono aplikacji do komunikacji IRC."];
}

- (void)addToContacts
{
    if ([_user isInContacts])
    {
        [_user removeFromContacts];
    }
    else
    {
        [_user addToContacts];
    }
    
    [self updateAddToContactsButton];
}

- (void)updateAddToContactsButton
{
    if ([_user isInContacts])
    {
        self.addToContactLabel.text = NSLocalizedString(@"usuń z kontaktów", nil);
    }
    else
    {
        self.addToContactLabel.text = NSLocalizedString(@"dodaj do kontaktów", nil);
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            NSLog(@"Mail cancelled");
        }
            break;
            
        case MFMailComposeResultSaved:
        {
            NSLog(@"Mail saved");
        }
            break;
            
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
        }
            break;
            
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        }
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldAutorotate
{
    [self.explanationLabel sizeToFit];
    
    return YES;
}

@end
