//
//  PlayViewController.m
//  Farkle
//
//  Created by David Seitz Jr on 5/21/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PlayViewController.h"
#import "DieLabel.h"

@interface PlayViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic,strong) IBOutletCollection(DieLabel) NSArray* dieLabels;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playButton.layer.cornerRadius = self.playButton.frame.size.width / 4;
}


- (IBAction)onRollButtonPressed:(id)sender {
    for (DieLabel *dice in self.dieLabels) {
        [dice roll];
    }
}

@end
