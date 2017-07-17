#include <Foundation/Foundation.h>
#include "ThreadLauncherObjc.h"
#include "AsyncTask.h"

@implementation ThreadLauncherObjc

- (void)startThread:(NSString *)name runFn:(AsyncTask *)runFn {
  NSThread *thread = [[NSThread alloc] initWithTarget:runFn selector:@selector(execute) object:nil];
  if (name) {
    [thread setName:name];
  }
  [thread start];
}

@end
