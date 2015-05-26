//
//  ViewController.m
//  Farkle
//
//  Created by David Seitz Jr on 5/21/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ViewController.h"
#import "Player.h"
#import "PlayViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addPlayerTextfield;
@property NSMutableArray *dice;
@property NSMutableArray *players;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.players = [[NSMutableArray alloc] init];
    self.playButton.enabled = NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    Player *player = [[Player alloc] init];
    player.name = textField.text;
    [self.players addObject:player];
    [self.tableView reloadData];
    self.addPlayerTextfield.text = @"";
    self.playButton.enabled = YES;

    return YES;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.players.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];

    Player *player = [self.players objectAtIndex:indexPath.row];

    cell.textLabel.text = player.name;

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PlayViewController *destinationVC = segue.destinationViewController;
    destinationVC.players = self.players;
    [self.addPlayerTextfield resignFirstResponder];
}


@end