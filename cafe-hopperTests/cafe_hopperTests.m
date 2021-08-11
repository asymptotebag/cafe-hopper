//
//  cafe_hopperTests.m
//  cafe-hopperTests
//
//  Created by Emily Jiang on 7/12/21.
//

#import <XCTest/XCTest.h>
#import "NSString+EmailValidation.h"

@interface cafe_hopperTests : XCTestCase

@end

@implementation cafe_hopperTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testEmailVerification {
    NSString *validEmail = @"emily.s.jiang@gmail.com";
    NSString *invalidEmail1 = @"@.";
    NSString *invalidEmail2 = @"email";
    NSString *invalidEmail3 = @".com";
    NSString *invalidEmail4 = @"@e.com";
    NSString *invalidEmail5 = @"a@b";
    
    XCTAssertTrue([validEmail isValidEmail]);
    XCTAssertFalse([invalidEmail1 isValidEmail]);
    XCTAssertFalse([invalidEmail2 isValidEmail]);
    XCTAssertFalse([invalidEmail3 isValidEmail]);
    XCTAssertFalse([invalidEmail4 isValidEmail]);
    XCTAssertFalse([invalidEmail5 isValidEmail]);
}

@end
