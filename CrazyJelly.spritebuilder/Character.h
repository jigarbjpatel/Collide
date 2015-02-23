//
//  Character.h
//  CrazyJelly
//
//  Created by Jigar Patel on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#ifndef CrazyJelly_Character_h
#define CrazyJelly_Character_h


#endif

#import "CCSprite.h"
@interface Character : CCSprite

// stores the sprite name of the character
@property (nonatomic, assign) NSString* SpriteName;

- (void)initCharacter;
@end