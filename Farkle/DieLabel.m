//
//  DieLabel.m
//  Farkle
//
//  Created by David Seitz Jr on 5/21/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "DieLabel.h"

@implementation DieLabel

-(id)initWithCoder:(NSCoder *)aDecoder {
   self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"Notice from dieLabel class!");
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        [self addGestureRecognizer:tapGestureRecognizer];
        self.backgroundColor = [UIColor blackColor];
    }

    return self;
}

-(void)tapDetected {
    NSLog(@"Tap detected from DieLabel");
}

-(void)roll {

    int randomNumber = arc4random_uniform(7);
    NSLog(@"random number = %i", randomNumber);

    self.text = [NSString stringWithFormat:@"%i", randomNumber];
}

@end