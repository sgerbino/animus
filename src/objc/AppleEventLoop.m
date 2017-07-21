#include <Foundation/Foundation.h>
#include "AppleEventLoop.h"
#include "AsyncTask.h"

@implementation AppleEventLoop

- (void)post:(AsyncTask *)task {
  dispatch_async(dispatch_get_main_queue(), ^{
      [task execute];
    });
}

@end
