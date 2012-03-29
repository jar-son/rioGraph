//
//  AudioBufferCache.h
//  rioGraph
//
//  Created by Jason Clary on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct __node{
    struct __node *next;
    int32_t max;
    int32_t min;
} node;

@interface AudioBufferCache : NSObject{
    @private
    int count;
    node *head;
    node *tail;
}

@property int width;
+(AudioBufferCache *)getABCache;
-(void)add:(int32_t)max :(int32_t)min;
-(void)remove;
-(node *)first;
-(node *)next :(node *)current;
-(node *)last;
@end

