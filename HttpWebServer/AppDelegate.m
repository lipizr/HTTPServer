//
//  AppDelegate.m
//  HttpWebServer
//
//  Created by Dimas on 10/26/15.
//  Copyright © 2015 Dimas Lipiz. All rights reserved.


#import "AppDelegate.h"
#import "GCDWebServer.h"
#import "GCDWebServerFileResponse.h"
#import "GCDWebServerStreamedResponse.h"
#import "GCDWebServerDataResponse.h"

// Constants that point to local directory where all you files (xml, js, images etc..) are located.
static NSString * const kVideoDirectory = @"client/videos";
static NSString * const kJsDirectory = @"client/js";
static NSString * const kImagesDirectory = @"client/images";
static NSString * const kTemplateDirectory = @"client/templates";

@interface AppDelegate ()


@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSString *videosPath;
@property (nonatomic, strong) NSString *jsPath;
@property (nonatomic, strong) NSString *imagesPath;
@property (nonatomic, strong) NSString *templatesPath;

@end


@implementation AppDelegate

#pragma mark - Properties
- (NSString *)basePath
{
    if (_basePath == nil)
    {
        _basePath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject];
    }
    
    return _basePath;
}

- (NSString *)videosPath
{
    if (_videosPath == nil)
    {
        _videosPath = [self.basePath stringByAppendingPathComponent:kVideoDirectory];
    }
    
    return _videosPath;
}

- (NSString *)jsPath
{
    if (_jsPath == nil)
    {
        _jsPath = [self.basePath stringByAppendingPathComponent:kJsDirectory];
    }
    
    return _jsPath;
}

- (NSString *)imagesPath
{
    if (_imagesPath == nil)
    {
        _imagesPath = [self.basePath stringByAppendingPathComponent:kImagesDirectory];
    }
    
    return _imagesPath;
}

- (NSString *)templatesPath
{
    if (_templatesPath == nil)
    {
        _templatesPath = [self.basePath stringByAppendingPathComponent:kTemplateDirectory];
    }
    
    return _templatesPath;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create server
    GCDWebServer* webServer = [[GCDWebServer alloc] init];

    [webServer addHandlerForMethod:@"GET" pathRegex:@"/*.mp4"
                      requestClass:[GCDWebServerRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
    
                          NSLog(@"videos path: %@", self.videosPath);
                          
                          NSString *filePath = [self.videosPath stringByAppendingPathComponent:[[request path] lastPathComponent]];
                          
                          GCDWebServerResponse *response = [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
                          
                          [response setValue:@"bytes" forAdditionalHeader:@"Accept-Ranges"];
                         
                          return response;
    
                      }];
    
    [webServer addHandlerForMethod:@"GET" pathRegex:@"/templates/*"
                      requestClass:[GCDWebServerRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                          
                          NSLog(@"templates path: %@", self.templatesPath);
                          
                          NSString *filePath = [self.templatesPath stringByAppendingPathComponent:[[request path] lastPathComponent]];
                          
                          return [GCDWebServerDataResponse responseWithText:[self readFileFromPath:filePath isText:YES]];
                          
                      }];
    
    [webServer addHandlerForMethod:@"GET" pathRegex:@"/js/*"
                      requestClass:[GCDWebServerRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                          
                          NSLog(@"js path: %@", self.jsPath);
                          
                          NSString *filePath = [self.jsPath stringByAppendingPathComponent:[[request path] lastPathComponent]];
                          
                          return [GCDWebServerDataResponse responseWithText:[self readFileFromPath:filePath isText:YES]];
                      }];
    
    [webServer addHandlerForMethod:@"GET" pathRegex:@"/images/*"
                      requestClass:[GCDWebServerRequest class]
                      processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                          
                          NSLog(@"images path: %@", self.imagesPath);
                          
                          NSString *filePath = [self.imagesPath stringByAppendingPathComponent:[[request path] lastPathComponent]];
                          
                          id document = [self readFileFromPath:filePath isText:NO];
                          
                          return [GCDWebServerDataResponse responseWithData:document contentType:@""];
                      }];

    // Use convenience method that runs server on port 8080
    // until SIGINT (Ctrl-C in Terminal) or SIGTERM is received
    [webServer runWithPort:9001 bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", webServer.serverURL);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Private Methods
- (id)readFileFromPath:(NSString *)filePath isText:(BOOL)isText
{
    NSLog(@"filePath: %@", filePath);
    
    NSError *error = nil;
    id document = nil;
    
    if (isText)
    {
        document = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    }
    else
    {
        document = [NSData dataWithContentsOfFile:filePath];
    }
    
    if (error)
    {
        NSLog(@"error reading file: %@", filePath);
    }
    
    return document;
}


@end
