#pragma once
#include "EventLoop.h"

@interface EventLoopObjc : NSObject <EventLoop>

- (void)post:(AsyncTask *)task;

@end
