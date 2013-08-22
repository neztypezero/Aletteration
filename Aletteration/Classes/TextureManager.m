//
//  TextureManager.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/4/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "TextureManager.h"
#import "PVRLoader.h"

/* Degrees / Radians conversion */
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / M_PI * 180.0)

/* Generic error reporting */
#define REPORT_ERROR(__FORMAT__, ...) printf("%s: %s\n", __FUNCTION__, [[NSString stringWithFormat:__FORMAT__, __VA_ARGS__] UTF8String])

/* EAGL and GL functions calling wrappers that log on error */
#define CALL_EAGL_FUNCTION(__FUNC__, ...) ({ EAGLError __error = __FUNC__( __VA_ARGS__ ); if(__error != kEAGLErrorSuccess) printf("%s() called from %s returned error %i\n", #__FUNC__, __FUNCTION__, __error); (__error ? NO : YES); })
#define CHECK_GL_ERROR() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s\n", __error, __FUNCTION__); (__error ? NO : YES); })

//CONSTANTS:
#define kMaxTextureSize 2048

#define __DEBUG__ 0

@interface TextureInfoWrapper : NSObject {
@public
	TextureInfo info;
}

+(TextureInfoWrapper*)makeTextureInfoWrapper:(TextureInfo)texInfo;
-(id)initWithTextureInfo:(TextureInfo)texInfo;

@end

@implementation TextureInfoWrapper

+(TextureInfoWrapper*)makeTextureInfoWrapper:(TextureInfo)texInfo {
	return [[[TextureInfoWrapper alloc] initWithTextureInfo:texInfo] autorelease];
}

-(id)initWithTextureInfo:(TextureInfo)texInfo {
	if ((self = [super init])) {
		info = texInfo;
	}
	return self;
}

@end

TextureManager *g_TextureManager;
NSLock *textureMutex;

@implementation TextureManager

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_TextureManager = [[TextureManager alloc] init];
		textureMutex = [NSLock new];
    }
}

+(TextureManager*)instance {
	return(g_TextureManager);
}

+(BOOL)isPvrSupported {
	char *glExtString = (char*)glGetString(GL_EXTENSIONS);
	return (strstr(glExtString, "GL_IMG_texture_compression_pvrtc") != NULL);
}

-(id)init {
	if ((self = [super init])) {
		textureDict = [[NSMutableDictionary dictionaryWithCapacity:32] retain];
	}
	return self;
}

-(TextureInfo)loadTextureWithPathForResource:(NSString*)filename ofType:(NSString*)fileType inDirectory:(NSString*)dir withPixelFormat:(Texture2DPixelFormat)pixelFormat {
	NSString *name = [NSString stringWithFormat:@"%@/%@.%@", dir, filename, fileType];
	[textureMutex lock];
	TextureInfoWrapper *texInfoWrapper = [textureDict objectForKey:name];
	if (texInfoWrapper) {
		[textureMutex unlock];
		if (texInfoWrapper->info.level == -1) {
			return texInfoWrapper->info;
		}
	}
	[textureMutex unlock];
	
	TextureInfo texInfo;
	texInfo.level = -1;
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
	if ([fileType isEqualToString:@"pvr"]) {
		texInfo = loadPVR([path cStringUsingEncoding:NSUTF8StringEncoding]);
	} else {
		UIImage *uiImage = [[UIImage alloc] initWithContentsOfFile:path];
		
		[self loadTextureWithName:name CGImage:[uiImage CGImage] orientation:[uiImage imageOrientation] sizeToFit:NO pixelFormat:pixelFormat TextureInfo:&texInfo];
		
		[uiImage release];
	}
	return texInfo;
}

-(TextureInfo)loadTextureWithPathForResource:(NSString*)filename ofType:(NSString*)fileType inDirectory:(NSString*)dir {
	return [self loadTextureWithPathForResource:filename ofType:fileType inDirectory:dir withPixelFormat:kTexture2DPixelFormat_Automatic];
}

-(TextureInfo)loadTextureOfType:(NSString*)fileType inDirectory:(NSString*)dir withPixelFormat:(Texture2DPixelFormat)pixelFormat {
	NSString *name = [NSString stringWithFormat:@"%@-mip", dir];
	[textureMutex lock];
	TextureInfoWrapper *texInfoWrapper = [textureDict objectForKey:name];
	if (texInfoWrapper) {
		[textureMutex unlock];
		return texInfoWrapper->info;
	}
	[textureMutex unlock];
	
	TextureInfo texInfo;
	texInfo.level = 0;
	glGenTextures(1, &texInfo.name);
	
	NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:fileType inDirectory:dir];
	for (NSString *filename in paths) {
		filename = [[filename componentsSeparatedByString:@"/"] lastObject];
		filename = [[filename componentsSeparatedByString:@"."] objectAtIndex:0];
		NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
		UIImage *uiImage = [[UIImage alloc] initWithContentsOfFile:path];
		
		if (uiImage.size.width <= 512) {
			[self loadTextureWithName:name CGImage:[uiImage CGImage] orientation:[uiImage imageOrientation] sizeToFit:NO pixelFormat:pixelFormat TextureInfo:&texInfo];
			texInfo.level++;
		}
		
		[uiImage release];
	}
	return texInfo;
}

-(TextureInfo)loadTextureOfType:(NSString*)fileType inDirectory:(NSString*)dir {
	return [self loadTextureOfType:fileType inDirectory:dir withPixelFormat:kTexture2DPixelFormat_Automatic];
}

-(void)loadTextureWithName:(NSString*)name CGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat TextureInfo:(TextureInfo*)texInfo {
	NSUInteger				width,
	height,
	i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned char*			inPixel8;
	unsigned int*			inPixel32;
	unsigned char*			outPixel8;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	
	
	if(image == NULL) {
		return;
	}
	if(pixelFormat == kTexture2DPixelFormat_Automatic) {
		info = CGImageGetAlphaInfo(image);
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		if(CGImageGetColorSpace(image)) {
			if(CGColorSpaceGetModel(CGImageGetColorSpace(image)) == kCGColorSpaceModelMonochrome) {
				if(hasAlpha) {
					pixelFormat = kTexture2DPixelFormat_LA88;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 16))
						REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", name);
#endif
				}
				else {
					pixelFormat = kTexture2DPixelFormat_L8;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
						REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", name);
#endif
				}
			}
			else {
				if((CGImageGetBitsPerPixel(image) == 16) && !hasAlpha)
					pixelFormat = kTexture2DPixelFormat_RGBA5551;
				else {
					if(hasAlpha)
						pixelFormat = kTexture2DPixelFormat_RGBA8888;
					else {
						pixelFormat = kTexture2DPixelFormat_RGB565;
#if __DEBUG__
						if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 24))
							REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%s\"", name);
#endif
					}
				}
			}		
		}
		else { //NOTE: No colorspace means a mask image
			pixelFormat = kTexture2DPixelFormat_A8;
#if __DEBUG__
			if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
				REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", name);
#endif
		}
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	switch(orientation) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	if((orientation == UIImageOrientationLeftMirrored) || (orientation == UIImageOrientationLeft) || (orientation == UIImageOrientationRightMirrored) || (orientation == UIImageOrientationRight))
		imageSize = CGSizeMake(imageSize.height, imageSize.width);
	
	width = imageSize.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
#if __DEBUG__
		REPORT_ERROR(@"Image at %ix%i pixels is too big to fit in texture", width, height);
#endif
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat) {
			
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_RGBA5551:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 2);
			context = CGBitmapContextCreate(data, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_RGB888:
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_L8:
			colorSpace = CGColorSpaceCreateDeviceGray();
			data = malloc(height * width);
			context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_A8:
			data = malloc(height * width);
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
			break;
			
		case kTexture2DPixelFormat_LA88:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
			
	}
	if(context == NULL) {
		REPORT_ERROR(@"Failed creating CGBitmapContext", NULL);
		free(data);
		return;
	}
	
	if(sizeToFit)
		CGContextScaleCTM(context, (CGFloat)width / imageSize.width, (CGFloat)height / imageSize.height);
	else {
		CGContextClearRect(context, CGRectMake(0, 0, width, height));
		CGContextTranslateCTM(context, 0, height - imageSize.height);
	}
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if(pixelFormat == kTexture2DPixelFormat_RGBA5551) {
		outPixel16 = (unsigned short*)data;
		for(i = 0; i < width * height; ++i, ++outPixel16)
			*outPixel16 = *outPixel16 << 1 | 0x0001;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if(pixelFormat == kTexture2DPixelFormat_RGB888) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_RGBA4444) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGBA4444", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_LA88) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to LA88", NULL);
#endif
	}

	[self loadTexture:data Width:width Height:height Name:name PixelFormat:pixelFormat TextureInfo:texInfo];
	
	CGContextRelease(context);
	free(data);

	return;
}

-(void)loadTexture:(unsigned char*)pixels Width:(int)width Height:(int)height Name:(NSString*)textureName PixelFormat:(Texture2DPixelFormat)pixelFormat TextureInfo:(TextureInfo*)texInfo {
	[textureMutex lock];
	TextureInfoWrapper *texInfoWrapper = [textureDict objectForKey:textureName];
	if (texInfoWrapper) {
		if (texInfo->level == texInfoWrapper->info.level) {
			*texInfo = texInfoWrapper->info;
			[textureMutex unlock];
			return;
		}
	}
	GLuint textureId;
	
	if (texInfo->level == -1) {
		// Generate a texture object
		glGenTextures(1, &textureId);
	} else {
		textureId = texInfo->name;
	}
	// Bind the texture object

	int mipLevel;
	if (texInfo->level == -1) {
		mipLevel = 0;
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	} else {
		mipLevel = texInfo->level;
		if (mipLevel == 0) {
			glBindTexture(GL_TEXTURE_2D, textureId);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		}
	}
	switch(pixelFormat) {
			
		case kTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
			break;
			
		case kTexture2DPixelFormat_RGBA4444:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, pixels);
			break;
			
		case kTexture2DPixelFormat_RGBA5551:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, pixels);
			break;
			
		case kTexture2DPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, pixels);
			break;
			
		case kTexture2DPixelFormat_RGB888:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels);
			break;
			
		case kTexture2DPixelFormat_L8:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels);
			break;
			
		case kTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, pixels);
			break;
			
		case kTexture2DPixelFormat_LA88:
			glTexImage2D(GL_TEXTURE_2D, mipLevel, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, pixels);
			break;
			
		case kTexture2DPixelFormat_RGB_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, mipLevel, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, pixels);
			break;
			
		case kTexture2DPixelFormat_RGB_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, mipLevel, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, pixels);
			break;
			
		case kTexture2DPixelFormat_RGBA_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, mipLevel, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, pixels);
			break;
			
		case kTexture2DPixelFormat_RGBA_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, mipLevel, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, pixels);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@""];
			
	}
	if(mipLevel == 0) {
		texInfo->name = textureId;
		texInfo->width = width;
		texInfo->height = height;
	}
	[textureDict setObject:[TextureInfoWrapper makeTextureInfoWrapper:*texInfo] forKey:textureName];
	[textureMutex unlock];
	return;
}

- (void) dealloc {
	[self releaseAll];
	[textureDict release];
	
    [super dealloc];
}

- (void) releaseAll {
	NSNumber *texName;
	NSEnumerator *enumerator = [textureDict objectEnumerator];
	while ((texName = [enumerator nextObject])) {
		GLuint texId = [texName unsignedIntValue];
		glDeleteTextures(1, &texId);
	}
	[textureDict removeAllObjects];
}

@end
