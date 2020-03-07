//
//  URLEndpointListenerTest.m
//  CBL ObjC Tests
//
//  Created by Jayahari Vavachan on 3/3/20.
//  Copyright © 2020 Couchbase. All rights reserved.
//

#import "ReplicatorTest.h"

#ifndef COUCHBASE_ENTERPRISE
#error Couchbase Lite EE Only
#endif

@interface URLEndpointListenerTest : ReplicatorTest

@end

@implementation URLEndpointListenerTest

- (CBLURLEndpointListener*) listenTo: (NSString*)network port: (uint16)port {
    CBLURLEndpointListener* listener;
    CBLURLEndpointListenerConfiguration* config;
    if (network) {
        config = [[CBLURLEndpointListenerConfiguration alloc] initWithDatabase: otherDB
                                                                          port: port
                                                              networkInterface: network
                                                                      identity: nil];
    } else {
        config = [[CBLURLEndpointListenerConfiguration alloc] initWithDatabase: otherDB
                                                                          port: 0
                                                                      identity: nil];
    }
    
    listener = [[CBLURLEndpointListener alloc] initWithConfig: config];
    
    NSError* err = nil;
    [listener startWithError: &err];
    return listener;
}

- (void) testStartListenerPort {
    CBLURLEndpointListener* list = [self listenTo: nil port: 0];
    [NSThread sleepForTimeInterval: 1.0];
    
    [list stop];
}

- (void) testStartListenerPortAndNetworkInterface {
    CBLDatabase.log.console.level = kCBLLogLevelInfo;
    NSURL* url = [[NSURL alloc] initWithString: @"ws://127.0.0.1:8080/testdb"];
    CBLURLEndpointListener* list = [self listenTo: url.host port: 8080];

    [self generateDocumentWithID: @"doc-1"];
    CBLURLEndpoint* target = [[CBLURLEndpoint alloc] initWithURL: url];
    id config = [self configWithTarget: target type: kCBLReplicatorTypePush continuous: NO];
    [self run: config errorCode: 0 errorDomain: nil];
    
    AssertEqual(self.db.count, 1);
    AssertEqual(otherDB.count, 1);
    
    [list stop];
}

@end
