//
//  DieLabel.h
//  Farkle
//
//  Created by David Seitz Jr on 5/21/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

//Declare a required delegate method called diceSelected
@protocol DieLabelDelegate <NSObject>
- (void) diceSelected;
@end


@interface DieLabel : UILabel

//Declare a delegate property
@property (nonatomic, assign) id <DieLabelDelegate> delegate;
@property BOOL counted;

-(void)roll;

@end
