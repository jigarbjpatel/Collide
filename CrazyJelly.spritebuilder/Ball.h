//
//  Ball.h
//  CrazyJelly
//
//  Created by Jigar Patel on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#ifndef CrazyJelly_Ball_h
#define CrazyJelly_Ball_h


#endif

@interface Ball : CCSprite
// stores the sprite name of the ball
@property (nonatomic, assign) NSString* SpriteName;

- (void)changeSprite;
@end