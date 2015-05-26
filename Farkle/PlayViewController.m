//
//  PlayViewController.m
//  Farkle
//
//  Created by David Seitz Jr on 5/21/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PlayViewController.h"
#import "DieLabel.h"
#import "Player.h"

@interface PlayViewController () <DieLabelDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic,strong) IBOutletCollection(DieLabel) NSArray* dieLabels;
@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;
@property int turnCount, numberOfDiceSelected, currentScore, scoreBank, outOfMovesCount, scoreAlreadyBanked, currentPlayer;
@property (weak, nonatomic) IBOutlet UIButton *bankScoreButton;
@property (weak, nonatomic) IBOutlet UILabel *scoreBankLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextGameButton;
@property BOOL bankedScore, playAgain;
@property int oneRolled, twoRolled, threeRolled, fourRolled, fiveRolled, sixRolled; //for keeping track of dice combo selections during a roll
@property (weak, nonatomic) IBOutlet UILabel *playerLabel;
@property NSMutableArray *scoreTracker; //Record player scores, find greatest score, match score index with players array index to determine winner
@property NSNumber *winningScore;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playButton.layer.cornerRadius = self.playButton.frame.size.width / 4;
    for (DieLabel *dice in self.dieLabels) {
        dice.delegate = self;
    }
    self.turnCount = 0;
    self.numberOfDiceSelected = 0;
    self.bankScoreButton.alpha = 0;
    self.nextGameButton.alpha = 0;
    self.bankedScore = NO;
    self.outOfMovesCount = 0;
    self.scoreAlreadyBanked = 0;
    self.currentScore = 0;
    self.playAgain = 0;

    //Setup for first player
    self.currentPlayer = 0;
    Player *player = [[Player alloc] init];
    player = [self.players objectAtIndex:self.currentPlayer];
    self.playerLabel.text = player.name;
    if (player.score == nil) {
        self.scoreBankLabel.text = @"0";
    } else {
    self.scoreBankLabel.text = [NSString stringWithFormat:@"%@", [player.score stringValue]];
    }

}


-(void) newTurn {
    [self saveCurrentPlayerScore];
    [self checkPlayerScores];
    [self checkForWin];
    [self updateCurrentPlayer];

    Player *newPlayer = [self.players objectAtIndex:self.currentPlayer];
    NSLog(@"It is %@'s turn now.",newPlayer.name);

    [self setupNewTurn];
    [self rollDice]; //Roll all the dice to prevent selecting the last game's winning dice again.
}

- (IBAction)nextGameButtonPressed:(id)sender {
    [self newTurn];
}


-(void)diceSelected {
    self.numberOfDiceSelected++;
    NSLog(@"Dice selected.");
    self.bankScoreButton.alpha = 1;
    [self countSelectedNumbers];

}


- (void) countSelectedNumbers {
    //Check the number of dice numbers rolled, looking for any number that has been selected three or more times in this roll
    for (DieLabel *dice in self.dieLabels) {
        if ([dice.text integerValue] == 1 && dice.backgroundColor == [UIColor grayColor] && dice.counted == NO) {
            _oneRolled++;
            dice.counted = YES;
            NSLog(@"1 selected %i times this roll.", _oneRolled);
        }

        if ([dice.text integerValue] == 2 && dice.backgroundColor == [UIColor grayColor] && dice.counted == NO) {
            _twoRolled++;
            dice.counted = YES;
            NSLog(@"2 selected %i times this roll.", _twoRolled);
        }

        if ([dice.text integerValue] == 3 && dice.backgroundColor == [UIColor grayColor] && dice.counted == NO) {
            _threeRolled++;
            dice.counted = YES;
            NSLog(@"3 selected %i times this roll.", _threeRolled);
        }

        if ([dice.text integerValue] == 4 && dice.backgroundColor == [UIColor grayColor] && dice.counted == NO) {
            _fourRolled++;
            dice.counted = YES;
            NSLog(@"4 selected %i times this roll.", _fourRolled);
        }

        if ([dice.text integerValue] == 5 && dice.backgroundColor == [UIColor grayColor] && dice.counted == NO) {
            _fiveRolled++;
            dice.counted = YES;
            NSLog(@"5 selected %i times this roll.", _fiveRolled);
        }

        if ([dice.text integerValue] == 6 && dice.backgroundColor == [UIColor grayColor] && dice.counted == NO) {
            _sixRolled++;
            dice.counted = YES;
            NSLog(@"6 selected %i times this roll.", _sixRolled);
        }
    }
}


- (void) calculatePoints {

    //Add points for the numbers selected in the last roll.
    if (self.oneRolled >= 3) {
        self.currentScore = self.currentScore + 1000;
    } else {
        self.currentScore = self.currentScore + (self.oneRolled * 100);
    }

    if (self.twoRolled >= 3) {
        self.currentScore = self.currentScore + 200;
    }

    if (self.threeRolled >= 3) {
        self.currentScore = self.currentScore + 300;
    }

    if (self.fourRolled >= 3) {
        self.currentScore = self.currentScore + 400;
    }

    if (self.fiveRolled >= 3) {
        self.currentScore = self.currentScore + 500;
    } else {
        self.currentScore = self.currentScore + (self.fiveRolled * 50);
    }

    if (self.sixRolled >= 3) {
        self.currentScore = self.currentScore + 600;
    }

    //Reset counted dice selected in a single turn for new roll
    self.oneRolled = 0;
    self.twoRolled = 0;
    self.threeRolled = 0;
    self.fourRolled = 0;
    self.fiveRolled = 0;
    self.sixRolled = 0;

    //Update score label
    self.currentScoreLabel.text = [[NSNumber numberWithInt: self.currentScore] stringValue];

}

- (IBAction)onRollButtonPressed:(id)sender {

    [self calculatePoints];

    //Count the amount of selected/gray dice.
    for (UILabel *dice in self.dieLabels) {
        if (dice.backgroundColor == [UIColor grayColor]) {
            self.outOfMovesCount++;
        }
    }

    //If all dice are selected, inform the user to begin the next game.
    if (self.outOfMovesCount >= 6) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No more dice to roll" message:@"You've run out of dice to roll. Bank your score and begin the next game!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }

    //Reset the count for selected dice to prevent the number from adding up later and being prematurely triggered
    self.outOfMovesCount = 0;


    if (self.bankedScore == YES) {
        //Do nothing. Alert the user that the score from this game has been banked, begin a new game.
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Begin the next turn" message:@"You banked your score this turn. Press 'Next Turn' to begin the next turn." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    } else {

        if (self.turnCount == 0) {
            //First turn, roll.
            int diceRolled = 0;
            for (DieLabel *dice in self.dieLabels) {
                if (dice.backgroundColor != [UIColor grayColor]) {
                    [dice roll];
                    diceRolled++;
                }
            }
        }
        else if (self.numberOfDiceSelected == 0) {
            //Dice was not selected, and not first turn. Do nothing.
            NSLog(@"Roll did not happen because no dice were selected and it is not the first turn.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select a dice" message:@"You must select at least one dice before your next roll." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        } else if (self.numberOfDiceSelected > 0) {
            //Valid turn, roll.
            int diceRolled = 0;
            for (DieLabel *dice in self.dieLabels) {
                if (dice.backgroundColor != [UIColor grayColor]) {
                    [dice roll];
                    diceRolled++;
                }
            }
            self.numberOfDiceSelected = 0;
            NSLog(@"%i dice rolled.", diceRolled);
        }
        self.turnCount++;
        NSLog(@"Turn counted at %i", self.turnCount);
        self.numberOfDiceSelected = 0;
    }
}


- (IBAction)bankScoreButtonPressed:(id)sender {
    if (self.bankedScore != YES) {
        [self calculatePoints];
        self.bankedScore = YES;
        self.scoreBank = self.scoreBank + self.currentScore;
        self.scoreBankLabel.text = [[NSNumber numberWithInt:self.scoreBank] stringValue];
        self.nextGameButton.alpha = 1;
        if (self.currentPlayer == (self.players.count - 1)) {
            self.nextGameButton.titleLabel.text = @"Finish Round";
        }
    } else {
        //Inform player that scores cannot be banked more than once.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Score already banked" message:@"You cannot bank your score more than once during your turn. Click 'Next Turn' to begin the next turn." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }
}


- (void) checkPlayerScores {
    for (Player *player in self.players) {
        NSLog(@"%@ %@ - Score tracker", player.name, player.score);
    }
}


- (void) saveCurrentPlayerScore {
    Player *currentPlayer = [self.players objectAtIndex:self.currentPlayer];
    currentPlayer.score = [NSNumber numberWithInt:[currentPlayer.score intValue] + self.scoreBank];
    NSLog(@"%@'s score saved as %@", currentPlayer.name, currentPlayer.score);
}


- (void) updateCurrentPlayer {

    if ((self.players.count - 1) > self.currentPlayer) {
        //If any players are left, play the next round
        self.currentPlayer = self.currentPlayer + 1;
        Player *nextPlayer = [self.players objectAtIndex:self.currentPlayer];
        self.playerLabel.text = nextPlayer.name;
        self.outOfMovesCount = 0;
        NSLog(@"New player is %@", nextPlayer.name);

        //Update score label
        if (nextPlayer.score == nil) {
            self.scoreBank = 0;
            self.scoreBankLabel.text = @"0";
        } else {
            self.scoreBank = [nextPlayer.score intValue];
            self.scoreBankLabel.text = [[NSNumber numberWithInt:self.scoreBank] stringValue];
        }
    } else {
        //All players have played
        if (self.playAgain == NO) {
            [self declareWinner];
        }
        else {
            //No one won, play another round!
            self.currentPlayer = 0;
            Player *nextPlayer = [self.players objectAtIndex:self.currentPlayer];
            self.playerLabel.text = nextPlayer.name;
            self.outOfMovesCount = 0;
            self.playAgain = NO;
            NSLog(@"New player is %@", nextPlayer.name);
            //Update score label
            if (nextPlayer.score == nil) {
                self.scoreBank = 0;
                self.scoreBankLabel.text = @"0";
            } else {
                self.scoreBank = [nextPlayer.score intValue];
                self.scoreBankLabel.text = [[NSNumber numberWithInt:self.scoreBank] stringValue];
            }
        }
    }
}


-(void) setupNewTurn {
    //set up for next player
    self.currentScore = 0;
    self.currentScoreLabel.text = @"0";
    for (DieLabel *dice in self.dieLabels) {
        dice.backgroundColor = [UIColor blackColor];
    }
    self.bankScoreButton.alpha = 0;
    self.nextGameButton.alpha = 0;
    self.bankedScore = NO;
    self.numberOfDiceSelected = 0;
    self.turnCount = 0;
    self.scoreBankLabel.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:self.scoreBank]];
    self.scoreAlreadyBanked = 0;
    self.currentScore = 0;
    for (DieLabel *dice in self.dieLabels) {
        dice.counted = NO;
    }
    //Make sure scores counted in a single roll are 0 again - May not be necessary due to same thing happening in -calculateScore
    self.oneRolled = 0;
    self.twoRolled = 0;
    self.threeRolled = 0;
    self.fourRolled = 0;
    self.fiveRolled = 0;
    self.sixRolled = 0;
}


- (void) rollDice {
    for (DieLabel *dice in self.dieLabels) {
        [dice roll];
    }
}


- (void) checkForWin {
    NSMutableArray *gatheredScores = [[NSMutableArray alloc] init];
    for (Player *player in self.players) {
        if (player.score != nil) {
            NSLog(@"Adding score %@ to gathered scores.", player.score);
            [gatheredScores addObject:player.score];
            NSLog(@"Gathered scores updated to: %@", gatheredScores);
        } else {
            NSLog(@"Adding no score to gatheredScores. Gathered score remains: %@", gatheredScores);
        }
    }
    //check gathered scores for the greatest number
    NSNumber *max = [gatheredScores valueForKeyPath:@"@max.self"];
    NSLog(@"Greatest score is %@", [max stringValue]);

    if ([max intValue] > 1000) {
        self.playAgain = 0;
        self.winningScore = max;
        NSLog(@"Greateset score of %@ was higher than 10,000. Game over.", [max stringValue]);
    } else {
        self.playAgain = 1;
        NSLog(@"Greatest score of %@ was not higher than 10,000. Play again.", [max stringValue]);
    }
}

- (void) declareWinner {
    Player *winner = [[Player alloc] init];

    for (Player *player in self.players) {
        NSLog(@"Player: %@ Score: %@", player.name, player.score); //Show players and scores

        if (player.score == self.winningScore) {
            winner = player;
            NSLog(@"Winner is %@", winner.name);
        }
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ won!", winner.name]
                                                    message:[NSString stringWithFormat:@"%@ won with %@ points", winner.name, winner.score]
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles: nil];
    [alert show];
}


@end
