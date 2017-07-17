#include <Foundation/Foundation.h>
#include "EventLoopObjc.h"
#include "AsyncTask.h"

@implementation EventLoopObjc

- (void)post:(AsyncTask *)task {
  dispatch_async(dispatch_get_main_queue(), ^{
      [task execute];
    });
}

@end
