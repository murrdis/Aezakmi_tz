#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "bluetooth" asset catalog image resource.
static NSString * const ACImageNameBluetooth AC_SWIFT_PRIVATE = @"bluetooth";

#undef AC_SWIFT_PRIVATE
