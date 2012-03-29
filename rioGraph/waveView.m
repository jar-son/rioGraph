//
//  waveView.m
//  rioGraph
//
//  Created by Jason Clary on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "waveView.h"
#import "AudioBufferCache.h"

@implementation waveView
CGRect line;

int b;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         b = self.bounds.size.height * .58;
    }
    return self;
}

-(void)getData:(CGContextRef) context{
    
    if(!b){
        b = self.bounds.size.height * .58;
    }
     
    AudioBufferCache *abCache = [AudioBufferCache getABCache];
    int i = 0;
    for (node* tmp = [abCache first]; tmp != [abCache last] && i < self.bounds.size.width;tmp=tmp->next, i++)
    {
        int length = abs(tmp->max - tmp->min);
        CGContextAddRect(context,CGRectMake(i, self.bounds.size.height / 2 - tmp->max/b   , .5, length/b));
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    [self getData:context];
    CGContextStrokePath(context);
 
    CGContextAddRect(context, CGRectMake(0, self.bounds.size.height/2, self.bounds.size.width, .1));
      CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokePath(context);
}


@end
