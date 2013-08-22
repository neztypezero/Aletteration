#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import "CaptureSessionManager.h"

@interface CaptureSessionManager(private)

-(void)addStillImageOutput;
-(void)addVideoDataOutput;

@end

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize videoDataOutput;
@synthesize captureDelegate;

#pragma mark Capture Session Configuration

- (id)initWithCaptureDelegate:(id<ImageCapturedDelegate>)delegate {
	if ((self = [super init])) {
		self.captureSession = [[AVCaptureSession alloc] init];
		self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
		[self addStillImageOutput];
//		[self addVideoDataOutput];
		self.captureDelegate = delegate;
		videoInput = nil;
	}
	return self;
}

-(void)setPreview:(UIView*)videoPreview {	
	self.previewLayer = [[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession] autorelease];
	
	CGRect layerRect = [[videoPreview layer] bounds];
	[self.previewLayer setBounds:layerRect];
	[self.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	self.previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
	
	[[videoPreview layer] addSublayer:self.previewLayer];
}

-(BOOL)hasCameraAtPosition:(AVCaptureDevicePosition)position {
	NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	if (deviceArray && deviceArray.count > 0) {
		for (AVCaptureDevice *videoDevice in deviceArray) {
			if (videoDevice.position == position) {
				return YES;
			}
		}
	}
	return NO;
}

-(BOOL)hasFrontCamera {
	return [self hasCameraAtPosition:AVCaptureDevicePositionFront];
}

-(BOOL)hasBackCamera {
	return [self hasCameraAtPosition:AVCaptureDevicePositionBack];
}

-(void)addVideoInputWithPosition:(AVCaptureDevicePosition)position {
	if (videoInput != nil) {
		[self.captureSession removeInput:videoInput];
		videoInput = nil;
	}
	NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	if (deviceArray && deviceArray.count > 0) {
		NSError *error;
		for (AVCaptureDevice *videoDevice in deviceArray) {
			if (videoDevice.position == position) {
				AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
				if (!error) {
					if ([self.captureSession canAddInput:videoIn]) {
						[self.captureSession addInput:videoIn];
						videoInput = videoIn;
						return;
					} else {
						//NSLog(@"Couldn't add video input:%@", [error localizedDescription]);		
					}
				} else {
					//NSLog(@"Couldn't create video input");
				}
			}
		}
	}
	//NSLog(@"Couldn't create video capture device");
}

-(void)addStillImageOutput {
	[self setStillImageOutput:[[[AVCaptureStillImageOutput alloc] init] autorelease]];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
	self.stillImageOutput.outputSettings = outputSettings;
	[[self captureSession] addOutput:[self stillImageOutput]];
}

-(void)addVideoDataOutput {
	self.videoDataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
	self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
	
	dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
	
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[self.videoDataOutput setVideoSettings:videoSettings];
	
	[self.captureSession addOutput:self.videoDataOutput];
}

#pragma mark AVCaptureSession delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection {
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
													width, height, 8, bytesPerRow, colorSpace,
													kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
	
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
	
    UIImage *image= [UIImage imageWithCGImage:newImage];
	
    CGImageRelease(newImage);
	
	id delegate = captureDelegate;
    [delegate performSelectorOnMainThread:@selector(frameCaptured:) withObject:image waitUntilDone:YES];
	
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    [pool drain];
}

-(void)captureStillImage {  
	[self captureStillImageWithDelegate:captureDelegate andSelector:@selector(imageCaptured:)];
}

-(void)captureStillImageWithDelegate:(id)delegate andSelector:(SEL)captureSelector {  
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break; 
		}
	}
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection 
		completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
			NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];    
			CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)imageData);
			CGImageRef imageRef = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
			[delegate performSelector:captureSelector withObject:[UIImage imageWithCGImage:imageRef]];
			CGImageRelease(imageRef);
			CGDataProviderRelease(imgDataProvider);
		}
	];
}

- (void)dealloc {
	[self.captureSession stopRunning];

	self.previewLayer = nil;
	self.captureSession = nil;
	self.stillImageOutput = nil;
	self.captureDelegate = nil;

	[super dealloc];
}

@end
