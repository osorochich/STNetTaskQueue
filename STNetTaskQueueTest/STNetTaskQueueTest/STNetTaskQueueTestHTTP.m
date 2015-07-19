//
//  STNetTaskQueueTestHTTP.m
//  STNetTaskQueueTest
//
//  Created by Kevin Lin on 14/7/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STHTTPNetTaskQueueHandler.h"
#import "STTestRetryNetTask.h"
#import "STTestGetNetTask.h"
#import "STTestPostNetTask.h"
#import "STTestPutNetTask.h"
#import "STTestPatchNetTask.h"
#import "STTestDeleteNetTask.h"

@interface STNetTaskQueueTestHTTP : XCTestCase <STNetTaskDelegate>

@end

@implementation STNetTaskQueueTestHTTP
{
    XCTestExpectation *_expectation;
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
    _expectation = nil;
}

- (void)setUpNetTaskQueueWithBaseURLString:(NSString *)baseURLString
{
    STHTTPNetTaskQueueHandler *httpHandler = [[STHTTPNetTaskQueueHandler alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    [STNetTaskQueue sharedQueue].handler = httpHandler;
}

- (void)testRetryNetTask
{
    [self setUpNetTaskQueueWithBaseURLString:@"http://jsonplaceholder.typicode.com"];
    
    _expectation = [self expectationWithDescription:@"testRetryNetTask"];
    
    STTestRetryNetTask *testRetryTask = [STTestRetryNetTask new];
    [[STNetTaskQueue sharedQueue] addTaskDelegate:self uri:testRetryTask.uri];
    [[STNetTaskQueue sharedQueue] addTask:testRetryTask];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testGetNetTask
{
    [self setUpNetTaskQueueWithBaseURLString:@"http://jsonplaceholder.typicode.com"];
    
    _expectation = [self expectationWithDescription:@"testGetNetTask"];
    
    STTestGetNetTask *testGetTask = [STTestGetNetTask new];
    testGetTask.id = 1;
    [[STNetTaskQueue sharedQueue] addTaskDelegate:self uri:testGetTask.uri];
    [[STNetTaskQueue sharedQueue] addTask:testGetTask];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPostNetTask
{
    [self setUpNetTaskQueueWithBaseURLString:@"http://jsonplaceholder.typicode.com"];
    
    _expectation = [self expectationWithDescription:@"testPostNetTask"];
    
    STTestPostNetTask *testPostTask = [STTestPostNetTask new];
    testPostTask.title = @"Test Post Net Task Title";
    testPostTask.body = @"Test Post Net Task Body";
    testPostTask.userId = 1;
    [[STNetTaskQueue sharedQueue] addTaskDelegate:self uri:testPostTask.uri];
    [[STNetTaskQueue sharedQueue] addTask:testPostTask];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPutNetTask
{
    [self setUpNetTaskQueueWithBaseURLString:@"http://jsonplaceholder.typicode.com"];
    
    _expectation = [self expectationWithDescription:@"testPutNetTask"];
    
    STTestPutNetTask *testPutTask = [STTestPutNetTask new];
    testPutTask.id = 1;
    testPutTask.title = @"Test Put Net Task Title";
    testPutTask.body = @"Test Put Net Task Body";
    testPutTask.userId = 1;
    [[STNetTaskQueue sharedQueue] addTaskDelegate:self uri:testPutTask.uri];
    [[STNetTaskQueue sharedQueue] addTask:testPutTask];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPatchNetTask
{
    [self setUpNetTaskQueueWithBaseURLString:@"http://jsonplaceholder.typicode.com"];
    
    _expectation = [self expectationWithDescription:@"testPatchNetTask"];
    
    STTestPatchNetTask *testPatchTask = [STTestPatchNetTask new];
    testPatchTask.id = 1;
    testPatchTask.title = @"Test Patch Net Task Title";
    [[STNetTaskQueue sharedQueue] addTaskDelegate:self uri:testPatchTask.uri];
    [[STNetTaskQueue sharedQueue] addTask:testPatchTask];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testDeleteNetTask
{
    [self setUpNetTaskQueueWithBaseURLString:@"http://jsonplaceholder.typicode.com"];
    
    _expectation = [self expectationWithDescription:@"testDeleteNetTask"];
    
    STTestDeleteNetTask *testDeleteTask = [STTestDeleteNetTask new];
    testDeleteTask.id = 1;
    [[STNetTaskQueue sharedQueue] addTaskDelegate:self uri:testDeleteTask.uri];
    [[STNetTaskQueue sharedQueue] addTask:testDeleteTask];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)netTaskDidEnd:(STNetTask *)task
{
    if (!_expectation) {
        return;
    }
    if ([task isKindOfClass:[STTestRetryNetTask class]]) {
        [_expectation fulfill];
        if (!task.error || task.retryCount != task.maxRetryCount) {
            XCTFail(@"testRetryNetTask failed");
        }
    }
    else if ([task isKindOfClass:[STTestGetNetTask class]]) {
        [_expectation fulfill];
        STTestGetNetTask *testGetTask = (STTestGetNetTask *)task;
        if (task.error || [testGetTask.post[@"id"] intValue] != testGetTask.id) {
            XCTFail(@"testGetNetTask failed");
        }
    }
    else if ([task isKindOfClass:[STTestPostNetTask class]]) {
        [_expectation fulfill];
        STTestPostNetTask *testPostTask = (STTestPostNetTask *)task;
        if (task.error ||
            ![testPostTask.post[@"title"] isEqualToString:testPostTask.title] ||
            ![testPostTask.post[@"body"] isEqualToString:testPostTask.body] ||
            [testPostTask.post[@"userId"] intValue] != testPostTask.userId) {
            XCTFail(@"testPostNetTask failed");
        }
    }
    else if ([task isKindOfClass:[STTestPutNetTask class]]) {
        [_expectation fulfill];
        STTestPutNetTask *testPutTask = (STTestPutNetTask *)task;
        if (task.error || !testPutTask.post) {
            XCTFail(@"testPutNetTask failed");
        }
    }
    else if ([task isKindOfClass:[STTestPatchNetTask class]]) {
        [_expectation fulfill];
        STTestPatchNetTask *testPatchTask = (STTestPatchNetTask *)task;
        if (task.error || !testPatchTask.post) {
            XCTFail(@"testPatchNetTask failed");
        }
    }
    else if ([task isKindOfClass:[STTestDeleteNetTask class]]) {
        [_expectation fulfill];
        if (task.error) {
            XCTFail(@"testDeleteNetTask failed");
        }
    }
}

@end