//
//  AudioBufferCache.m
//  rioGraph
//
//  Created by Jason Clary on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioBufferCache.h"
#import "waveView.h"
static AudioBufferCache *abCache;

@implementation AudioBufferCache
@synthesize width;


+(AudioBufferCache *)getABCache{
    if(!abCache){
        abCache = [[AudioBufferCache alloc] init];
    }
    return abCache;
}

-(id)init{
    if(self = [super init]){
        if(!head){
            head = (node *)malloc(sizeof(node));
            last = (node *)malloc(sizeof(node));
            head->next = last;
        }
    }
    return self;
}

-(node *)first{
    return head->next;
}

-(node *)next :(node *)current{
    return current->next;
}

-(node *)last{
    return last;
}

-(void)add:(int32_t)max :(int32_t)min{

    if(count == width)
        [self removeLast];
    
    node *curr = (node *)malloc(sizeof(node));
    curr->max = max;
    curr->min = min;

    curr->next = head->next;
    head->next = curr;
    count++;
}


-(void)removeLast{
    node *tmp = head;
    node *prev = head;
    while(tmp->next != last){
        prev = tmp;
        tmp = tmp->next;
    }
    free(tmp);
    prev->next = last;
    count--;
}


@end
