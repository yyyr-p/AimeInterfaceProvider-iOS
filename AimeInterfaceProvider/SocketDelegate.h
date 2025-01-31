//
//  SocketDelegate.h
//  Brokenithm-iOS
//
//  Created by ester on 2020/2/29.
//  Copyright © 2020 esterTion. All rights reserved.
//

#ifndef SocketDelegate_h
#define SocketDelegate_h

@class ViewController;

#import <UIKit/UIKit.h>
#import <GCDAsyncSocket.h>

@interface SocketDelegate : NSObject {
    GCDAsyncSocket *server;
    NSMutableArray<GCDAsyncSocket*> *connectedSockets;
}
@property ViewController *viewController;

- (void)BroadcastFeliCaData:(NSData*)data;
- (void)BroadcastData:(NSData*)data;

@end

#endif /* SocketDelegate_h */
