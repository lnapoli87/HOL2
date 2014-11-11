#import "ProjectClientEx.h"
#import "NSString_Extended.h"

@implementation ProjectClientEx

const NSString *apiUrl = @"/_api/lists";

- (NSURLSessionDataTask *)addReference:(NSDictionary *)reference token:(NSString *)token callback:(void (^)(BOOL, NSError *))callback
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* referenceListName = @"Research References";
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", shpUrl , apiUrl, [referenceListName urlencode]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'URL': %@, 'Comments':'%@', 'Project':'%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [reference valueForKey:@"URL"], [reference valueForKey:@"Comments"], [reference valueForKey:@"Project"]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    [theRequest setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        callback((!jsonResult && [myString isEqualToString:@""]), error);
    }];
    
    return task;
}


- (NSURLSessionDataTask *)getProjectsWithToken:(NSString *)token andCallback:(void (^)(NSMutableArray *listItems, NSError *))callback{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Auth" ofType:@"plist"];
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString* shpUrl = [content objectForKey:@"o365SharepointTenantUrl"];
    
    NSString_Extended* projectListName = @"Research Projects";
    NSString_Extended* filter = @"ID,Title,Modified,Editor/Title";
    NSString *aditionalParams = [NSString stringWithFormat:@"?$select=%@&$expand=Editor", [filter urlencode]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items%@", shpUrl , apiUrl, [projectListName urlencode],aditionalParams];
    
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest addValue:[NSString stringWithFormat: @"Bearer %@", token] forHTTPHeaderField: @"Authorization"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        
        callback(jsonResult ,error);
    }];
    
    return task;
}

- (NSMutableArray *)parseDataArray:(NSData *)data{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error ;
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:[self sanitizeJson:data]
                                                               options: NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSArray *jsonArray = [[jsonResult valueForKey : @"d"] valueForKey : @"results"];
    
    if(jsonArray != nil){
        for (NSDictionary *value in jsonArray) {
            [array addObject: value];
        }
    }else{
        NSDictionary *jsonItem =[jsonResult valueForKey : @"d"];
        
        if(jsonItem != nil){
            [array addObject:jsonItem];
        }
    }
    
    return array;
}

- (NSData*) sanitizeJson : (NSData*) data{
    NSString * dataString = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* replacedDataString = [dataString stringByReplacingOccurrencesOfString:@"E+308" withString:@"E+127"];
    
    NSData* bytes = [replacedDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    return bytes;
}

@end
