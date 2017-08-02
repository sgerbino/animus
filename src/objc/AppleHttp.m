#include <Foundation/Foundation.h>
#include "AppleHttp.h"
#include "HttpCallback.h"

@implementation AppleHttp

- (void)sendRequest:(NSString *)urlString method:(NSString *)methodString data:(NSString *)dataString callback:(HttpCallback *)callback {
    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request setHTTPMethod:methodString];
    if ([methodString isEqualToString:@"POST"] || [methodString isEqualToString:@"PUT"] || [methodString isEqualToString:@"PATCH"]) {
        if (dataString) {
            NSData *postData = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
        }
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [callback onNetworkError];
        } else {
            int16_t httpCode = [(NSHTTPURLResponse*) response statusCode];
            NSString * strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [callback onSuccess:httpCode data: strData];
        }
    }] resume];
}

- (void) get:(NSString *)urlString callback:(HttpCallback *)callback {
    [self sendRequest:urlString method:@"GET" data:nil callback:callback];
}

- (void) post:(NSString *)urlString data:(NSString *)dataString callback:(HttpCallback *)callback {
    [self sendRequest:urlString method:@"POST" data:dataString callback:callback];
}

- (void) put:(NSString *)urlString data:(NSString *)dataString callback:(HttpCallback *)callback {
    [self sendRequest:urlString method:@"PUT" data:dataString callback:callback];
}

- (void) patch:(NSString *)urlString data:(NSString *)dataString callback:(HttpCallback *)callback {
    [self sendRequest:urlString method:@"PATCH" data:dataString callback:callback];
}

- (void) del:(NSString *)urlString callback:(HttpCallback *)callback {
    [self sendRequest:urlString method:@"DELETE" data:nil callback:callback];
}
@end
