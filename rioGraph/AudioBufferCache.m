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

    }
    return self;
}

-(node *)first{
    return head;
}

-(node *)next :(node *)current{
    return current->next;
}

-(node *)last{
    return tail;
}

-(void)add:(int32_t)max :(int32_t)min{
    
    node *c = (node *)malloc(sizeof(node));
    c->max = max;
    c->min = min;
    
    if(count == width)
        [self remove];
    
    if(!head && !tail){
        head = tail = c;
    } else {
        tail->next = c;
        tail = c;
    }
    
    count++;
}


-(void)remove{
    
    if(!head && !tail) return;

    node *h = head;
    node *c = h->next;
    
    free(h);
    head = c;
    if(!head) tail = head;
    
    count--;
}


@end
