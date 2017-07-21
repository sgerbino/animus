#pragma once
#include "ThreadLauncher.h"

@interface AppleThreadLauncher : NSObject <ThreadLauncher>

- (void)startThread:(NSString *)name runFn:(AsyncTask *)runFn;

@end
