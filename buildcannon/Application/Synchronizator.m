//
//  Synchronizator.m
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 18/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

#import "Synchronizator.h"

@implementation Synchronizator

+ (void)synchronize:(Synchronizable)block toObject:(id)obj {
    @synchronized (obj) {
        block();
    }
}

@end
