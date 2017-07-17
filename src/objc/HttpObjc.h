#pragma once
#include "Http.h"

@interface HttpObjc : NSObject <Http>

- (void)get:(NSString *)url callback:(HttpCallback *)callback;

@end
