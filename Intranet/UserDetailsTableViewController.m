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

#pragma mark - Init Methods

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //code here
    
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
    
    self.warningImage.hidden = ((self.user.lates.count + self.user.absences.count) == 0);
    self.explanationLabel.hidden = ((self.user.lates.count + self.user.absences.count) == 0);
    
    if (self.user.lates.count)
    {
        self.warningImage.image = [UIImage imageNamed:@"late"];
    
        __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
        __block NSMutableString *explanation = [[NSMutableString alloc] initWithString:@""];
        
        [self.user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            RMLate *late = (RMLate *)obj;
            NSLog(@"%@ %@ %@", late.start, late.stop, late);
            
            if (late.start || late.stop)
            {
                [hours appendFormat:@" %@ - %@", late.start ? late.start : @"...",
                 late.stop ? late.stop : @"..."];
            }
            
            if (late.explanation)
            {
                [explanation appendFormat:@" %@", late.explanation];
            }
        }];
        
        self.explanationLabel.text = [NSString stringWithFormat:@"%@\n%@", hours, explanation];
    }
    else if (self.user.absences.count)
    {
        self.warningImage.image = [UIImage imageNamed:@"absence"];
        
        __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
        __block NSMutableString *explanation = [[NSMutableString alloc] initWithString:@""];
        
        [self.user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            RMAbsence *absence = (RMAbsence *)obj;
            NSLog(@"%@ %@ %@", absence.start, absence.stop, absence);
            
            if (absence.start || absence.stop)
            {
                [hours appendFormat:@" %@ - %@", absence.start ? absence.start : @"...",
                 absence.stop ? absence.stop : @"..."];
            }
            
            if (absence.remarks)
            {
                [explanation appendFormat:@" %@", absence.remarks];
            }
        }];
        
        self.explanationLabel.text = [NSString stringWithFormat:@"%@\n%@", hours, explanation];
    }
    self.explanationLabel.textAlignment = NSTextAlignmentRight;
    
//[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom]
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetShouldAntialias(ctx, YES);
    UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithArcCenter:self.explanationLabel.center
                                                                radius:MAX(self.warningImage.frame.size.width, self.warningImage.frame.size.height) * 0.5 + 40
                                                            startAngle:0
                                                              endAngle:2 * M_PI
                                                             clockwise:YES];
    
//    [[UIColor colorWithRed:0.329f green:0.584f blue:0.898f alpha:1.0f] setFill];
//    [exclusionPath stroke];
//self.view dra
//    NSLog(@"%@", exclusionPath);
    
    self.explanationLabel.textContainer.exclusionPaths = @[exclusionPath];
    
//    self.explanationLabel.layer.borderColor = MAIN_APP_COLOR.CGColor;
//    self.explanationLabel.layer.borderWidth = 1;
    
    [self.tableView reloadData];
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
    
    // TO DO: check if user is in system contacts or not
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
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.isHidden ? 0 : cell.frame.size.height;
}

#pragma mark - Actions

- (void)openUrl:(NSURL*)url orAlertWithText:(NSString*)alertText
{
    if ([[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url];
    else
        [UIAlertView alertWithTitle:@"Błąd" withText:alertText];
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
        [UIAlertView alertWithTitle:@"Błąd" withText:@"Nie znaleziono aplikacji obsługującej wiadomości email."];
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

- (IBAction)addToContacts:(id)sender
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
        [self.addToContactsButton setTitle:NSLocalizedString(@"Usuń z kontaktów", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.addToContactsButton setTitle:NSLocalizedString(@"Dodaj do kontaktów", nil) forState:UIControlStateNormal];
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

@end
