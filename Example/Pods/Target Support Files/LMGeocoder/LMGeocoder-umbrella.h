#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LMAddress.h"
#import "LMGeocoder.h"
#import "LMGeocodingOperation.h"

FOUNDATION_EXPORT double LMGeocoderVersionNumber;
FOUNDATION_EXPORT const unsigned char LMGeocoderVersionString[];

