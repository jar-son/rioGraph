//
//  ViewController.h
//  rioGraph
//
//  Created by Jason Clary on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "waveView.h"
#import "Audio.h"

@interface ViewController : UIViewController
    


@property (weak, nonatomic) IBOutlet waveView *waveformView;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)button:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property bool recording;


@end
