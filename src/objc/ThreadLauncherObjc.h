#pragma once
#include "ThreadLauncher.h"

@interface ThreadLauncherObjc : NSObject <ThreadLauncher>

- (void)startThread:(NSString *)name runFn:(AsyncTask *)runFn;

@end
