//
//  Audio.m
//  rioGraph
//
//  Created by Jason Clary on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Audio.h"
#import "AudioBufferCache.h"
#import "ViewController.h"

Audio* audio;

void checkStatus(int status, char* string){
	if (status) {
		printf("Status not 0! %d\nAt: %s\n", status,string);
	}
}

@implementation Audio

@synthesize audioUnit;
@synthesize tempBuffer;
@synthesize zoomLevel;

Audio *audio;
static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData)
{
    for(int i = 0; i < ioData->mNumberBuffers; ++i){
        AudioBuffer buffer = ioData->mBuffers[i];
        UInt32 size = min(buffer.mDataByteSize, [audio tempBuffer].mDataByteSize); // dont copy more data then we have, or then fits
		memcpy(buffer.mData, [audio tempBuffer].mData, size);
		buffer.mDataByteSize = size; // indicate how much data we wrote in the buffer
        
        UInt16 *frameBuffer = buffer.mData;
		for (int j = 0; j < inNumberFrames; j++) {
			frameBuffer[j] = rand();
		}
    }
    return noErr;  
}

static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlag, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData)
{
    AudioBuffer buffer;
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = inNumberFrames * 2;
    buffer.mData = malloc(inNumberFrames * 2);
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    OSStatus status;
    status = AudioUnitRender([audio audioUnit], ioActionFlag, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    checkStatus(status,"inside recording callback");
    
    [audio processAudio:&bufferList];
    
    free(bufferList.mBuffers[0].mData);
    
    return noErr;
}


-(id)init
{
    self = [super init];
    NSLog(@"in init");
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status,"Creating new instance of Audio Component");
    //Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
    checkStatus(status, "At setting property for input");
    
    //Enable IO for playback
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &flag, sizeof(flag));
    checkStatus(status,"At setting property for playback");
    
    //set up format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 44100.00;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 2;
    audioFormat.mBytesPerFrame = 2;
    
    //apply format
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kInputBus, &audioFormat, sizeof(audioFormat));
    checkStatus(status,"At setting property for AudioStreamBasicDescription for input");
    
    status = AudioUnitSetProperty(audioUnit,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,kOutputBus, &audioFormat,sizeof(audioFormat));
    checkStatus(status,"At setting property for AudioStreamBasicDescription for output");
    
    //set up input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    status = AudioUnitSetProperty(audioUnit,kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, kInputBus, &callbackStruct, sizeof(callbackStruct));
    checkStatus(status,"At setting property for recording callback");
    
    //set up output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
   // status = AudioUnitSetProperty(audioUnit,  kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, kOutputBus,&callbackStruct, sizeof(callbackStruct));
   // checkStatus(status,"At setting property for playback callback");
    
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
	flag = 0;
	status = AudioUnitSetProperty(audioUnit,kAudioUnitProperty_ShouldAllocateBuffer,kAudioUnitScope_Output, kInputBus,&flag, sizeof(flag));
    checkStatus(status, "At set property should allocate buffer");
    // Allocate our own buffers (1 channel, 16 bits per sample, thus 16 bits per frame, thus 2 bytes per frame).
	// Practice learns the buffers used contain 512 frames, if this changes it will be fixed in processAudio.
	tempBuffer.mNumberChannels = 1;
	tempBuffer.mDataByteSize = 512 * 2;
	tempBuffer.mData = malloc( 512 * 2 );
    
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status,"At Audio Unit Initalize");
    return self;
}


-(void)start{
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status,"At starting");
}

-(void)stop{
    OSStatus status = AudioOutputUnitStop(audioUnit);
    checkStatus(status,"At stopping");
}


-(void)processAudio:(AudioBufferList *)bufferList{
    AudioBuffer sourceBuffer = bufferList->mBuffers[0];

	// fix tempBuffer size if it's the wrong size
	if (tempBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
		free(tempBuffer.mData);
		tempBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
		tempBuffer.mData = malloc(sourceBuffer.mDataByteSize);
	}
	
   // NSLog(@"%lu",tempBuffer.mDataByteSize);
	// copy incoming audio data to temporary buffer
	memcpy(tempBuffer.mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);

    int16_t* samples = (int16_t*)(tempBuffer.mData);
    int16_t max = 0, min = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    for ( int i = 0; i < tempBuffer.mDataByteSize / sizeof(int32_t); ++i )
    {
        max = max(max, samples[i]);
        min = min(min, samples[i]);
        if(i % zoomLevel == 0){
            [[AudioBufferCache getABCache] add:max :min];
            max = 0; min = 0;
        }
    }
    [pool drain];
}


- (void) dealloc {
	AudioUnitUninitialize(audioUnit);
	free(tempBuffer.mData);
}

@end




























