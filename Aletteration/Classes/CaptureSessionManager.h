#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@protocol ImageCapturedDelegate

-(void)imageCaptured:(UIImage*)image;

@end

@interface CaptureSessionManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureDeviceInput *videoInput;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (retain) id<ImageCapturedDelegate> captureDelegate;

-(id)initWithCaptureDelegate:(id<ImageCapturedDelegate>)delegate;

-(void)setPreview:(UIView*)videoPreview;
-(void)addVideoInputWithPosition:(AVCaptureDevicePosition)position;

-(void)captureStillImage;
-(void)captureStillImageWithDelegate:(id)delegate andSelector:(SEL)captureSelector;

-(BOOL)hasFrontCamera;
-(BOOL)hasBackCamera;

@end
