#pragma once
#include "Http.h"

@interface AppleHttp : NSObject <Http>

- (void)sendRequest:(NSString *)url method:(NSString *)methodString data:(NSString *)dataString callback:(HttpCallback *)callback;
- (void)get:(NSString *)url callback:(HttpCallback *)callback;
- (void)post:(NSString *)url data:(NSString *)dataString callback:(HttpCallback *)callback;
- (void)put:(NSString *)url data:(NSString *)dataString callback:(HttpCallback *)callback;
- (void)patch:(NSString *)url data:(NSString *)dataString callback:(HttpCallback *)callback;
- (void)del:(NSString *)url callback:(HttpCallback *)callback;

@end
