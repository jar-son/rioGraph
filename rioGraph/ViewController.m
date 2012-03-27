//
//  ViewController.m
//  rioGraph
//
//  Created by Jason Clary on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize button;
@synthesize waveformView;
@synthesize label;
@synthesize recording;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLabel:nil];
    [self setWaveformView:nil];
    [self setButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)updateView
{
    [waveformView setNeedsDisplay];
}

-(void)doWork{
    while(recording){
        [NSThread sleepForTimeInterval:.1];
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    }
    [NSThread exit];
}


- (IBAction)button:(id)sender {

    if(sender == button){
        if([button.titleLabel.text isEqualToString:@"GO"]){
            [label setText:@"Recording"];
            [button setTitle:@"Stop" forState:UIControlStateNormal];
            [AudioBufferCache getABCache].width = waveformView.bounds.size.width;
            audio.zoomLevel = 128;
            [audio start];
            recording = YES;
            [NSThread detachNewThreadSelector:@selector(doWork) toTarget:self withObject:nil];
            
        }else{
            [button setTitle:@"GO" forState:UIControlStateNormal];           
            [audio stop];
            [label setText:@"Stopped"];
            recording = NO;
        }
    }
    
}

@end














