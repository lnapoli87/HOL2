#import <Foundation/Foundation.h>

@interface ProjectClientEx : NSObject

- (NSURLSessionDataTask *)addReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(BOOL, NSError *))callback;
- (NSURLSessionDataTask *)getProjectsWithToken:(NSString *)token andCallback:(void (^)(NSMutableArray *listItems, NSError *))callback;

@end
