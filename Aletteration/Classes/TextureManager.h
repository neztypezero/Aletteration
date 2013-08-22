//
//  DataResourceManager.h
//  NezFFModelViewer
//
//  Created by David Nesbitt on 2/14/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Structures.h"

//CONSTANTS:

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGBA4444,
	kTexture2DPixelFormat_RGBA5551,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_RGB888,
	kTexture2DPixelFormat_L8,
	kTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_LA88,
	kTexture2DPixelFormat_RGB_PVRTC2,
	kTexture2DPixelFormat_RGB_PVRTC4,
	kTexture2DPixelFormat_RGBA_PVRTC2,
	kTexture2DPixelFormat_RGBA_PVRTC4
} Texture2DPixelFormat;

@class TextureManager;

@interface TextureManager : NSObject {
	NSMutableDictionary *textureDict;
}

+(TextureManager*)instance;
+(BOOL)isPvrSupported;

-(TextureInfo)loadTextureWithPathForResource:(NSString*)filename ofType:(NSString*)fileType inDirectory:(NSString*)dir withPixelFormat:(Texture2DPixelFormat)pixelFormat;
-(TextureInfo)loadTextureWithPathForResource:(NSString*)filename ofType:(NSString*)fileType inDirectory:(NSString*)dir;
-(TextureInfo)loadTextureOfType:(NSString*)fileType inDirectory:(NSString*)dir withPixelFormat:(Texture2DPixelFormat)pixelFormat;
-(TextureInfo)loadTextureOfType:(NSString*)fileType inDirectory:(NSString*)dir;

-(void)loadTextureWithName:(NSString*)name CGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat TextureInfo:(TextureInfo*)texInfo;
-(void)loadTexture:(unsigned char*)pixels Width:(int)width Height:(int)height Name:(NSString*)textureName PixelFormat:(Texture2DPixelFormat)pixelFormat TextureInfo:(TextureInfo*)texInfo;

-(void)releaseAll;

@end
