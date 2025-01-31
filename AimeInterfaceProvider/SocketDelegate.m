//
//  SocketDelegate.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/2/29.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import "SocketDelegate.h"
#import "AimeInterfaceProvider-Swift.h"

@interface SocketDelegate ()
@end

@implementation SocketDelegate

- (id)init {
    server = [[GCDAsyncSocket alloc] initWithDelegate:(id)self delegateQueue:dispatch_get_main_queue()];
    server.IPv4Enabled = YES;
    server.IPv6Enabled = YES;
    [self acceptConnection];
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(becomeInactive) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    return [super init];
}
- (void)acceptConnection {
    NSError *error = nil;
    if (![server acceptOnPort:24865 error:&error]) {
        NSLog(@"error creating server: %@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    @synchronized(connectedSockets)
    {
        [connectedSockets addObject:newSocket];
    }
    NSLog(@"got connection");
    // Welcome
    NSString *initResponse = @"W";
    NSData *initResp = [initResponse dataUsingEncoding:NSASCIIStringEncoding];
    [newSocket writeData:initResp withTimeout:-1 tag:0];
    [newSocket readDataToLength:1 withTimeout:5 tag:0];
    [self.viewController connected];
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}
- (void)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    switch (tag) {
        case 0:
            [sock readDataToLength:1 withTimeout:5 tag:0];
            break;
        default:
            [sock disconnect];
            break;
    }
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    switch (tag) {
        case 0: {
            switch (((uint8_t*)data.bytes)[0])
            {
                // Heartbeat Hello
                case 'H':
                    [sock writeData:[@"H" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];
                    break;
                // Polling
                case 'P':
                    [sock readDataToLength:1 withTimeout:1 tag:'P'];
                    return;
                // LED
                case 'L':
                    [sock readDataToLength:3 withTimeout:1 tag:'L'];
                    return;
                // Unknown
                default:
                    [sock disconnect];
                    return;
            }
            break;
        }
        // Polling
        case 'P': {
            bool enabled = ((uint8_t*)data.bytes)[0];
            if (enabled) [self.viewController startPolling];
            else [self.viewController stopPolling];
            break;
        }
        // LED
        case 'L': {
            short r, g, b;
            
            r = ((uint8_t*)data.bytes)[0];
            g = ((uint8_t*)data.bytes)[1];
            b = ((uint8_t*)data.bytes)[2];
            
            [self.viewController updateLed:r :g :b];
            break;
        }
    }
    [sock readDataToLength:1 withTimeout:5 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (sock != server)
    {
        NSLog(@"connection ended");
        @synchronized(connectedSockets)
        {
            [connectedSockets removeObject:sock];
            if (connectedSockets.count == 0) {
                [self.viewController disconnected];
            }
        }
    }
}

-(void)BroadcastFeliCaData:(NSData*)data {
    NSString *header = [NSString stringWithFormat:@"CF%c", (char)(data.length)];
    NSMutableData *resp = [NSMutableData dataWithData:[header dataUsingEncoding:NSASCIIStringEncoding]];
    [resp appendData:data];
    [self BroadcastData:resp];
}

- (void)BroadcastData:(NSData*)data {
    for (GCDAsyncSocket* sock in connectedSockets) {
        [sock writeData:data withTimeout:-1 tag:0];
    }
}

- (void)becomeInactive {
    /*
    server.IPv4Enabled = NO;
    server.IPv6Enabled = NO;
    for (GCDAsyncSocket* sock in connectedSockets) {
        [sock disconnect];
        [connectedSockets removeObject:sock];
    }
    [server disconnect];
    */
}
- (void)becomeActive {
    /*
    server.IPv4Enabled = YES;
    server.IPv6Enabled = YES;
    [self acceptConnection];
    */
}

@end
