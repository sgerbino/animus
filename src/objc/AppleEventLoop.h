#pragma once
#include "EventLoop.h"

@interface AppleEventLoop : NSObject <EventLoop>

- (void)post:(AsyncTask *)task;

@end
