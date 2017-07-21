#pragma once
#include "Http.h"

@interface AppleHttp : NSObject <Http>

- (void)get:(NSString *)url callback:(HttpCallback *)callback;

@end
