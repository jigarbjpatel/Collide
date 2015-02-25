//
//  Ball.m
//  CrazyJelly
//
//  Created by Jigar Patel on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Ball.h"
#import "CCTexture.h"
@implementation Ball

#define ARC4RANDOM_MAX      0x100000000


static const CGFloat minimumXPosition = 15;

static const CGFloat maximumXPosition = 0;

- (void)didLoadFromCCB {
//    _bottomPipe.physicsBody.collisionType = @"level";
//    _bottomPipe.physicsBody.sensor = YES;

}
-(void)changeSprite{

    self.texture = [[CCSprite spriteWithImageNamed:@"Resources/Balls/Black.png"] texture];

}
- (void)setupRandomPosition {
    // value between 0.f and 1.f
//    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
//    CGFloat range = maximumYPosition - minimumYPosition;
//    self.position = ccp(0.15*self.parent.position.x, minimumYPosition + (random * range));
    self.position = ccp(0.15*self.parent.position.x, 86);
}
@end
