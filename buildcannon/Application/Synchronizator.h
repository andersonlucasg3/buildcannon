//
//  Synchronizator.h
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 18/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Synchronizable)(void);

@interface Synchronizator : NSObject

+ (void)synchronize:(Synchronizable)block toObject:(id)obj;

@end
