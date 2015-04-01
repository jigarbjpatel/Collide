//
//  GlobalData.h
//  CrazyJelly
//
//  Created by Jigar Patel on 3/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#ifndef CrazyJelly_GlobalData_h
#define CrazyJelly_GlobalData_h


#endif

#import <Foundation/Foundation.h>
@interface GlobalData : NSObject
{
    
}
@property (nonatomic) int currentLevel;
@property (nonatomic) long currentPoints;
@property (nonatomic) BOOL levelCleared;


+ (GlobalData *)sharedInstance;
@end