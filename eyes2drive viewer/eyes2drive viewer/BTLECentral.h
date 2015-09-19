//
//  BTLECentral.h
//  BTLE Transfer
//
//  Created by Lorenz Hänggi on 10/09/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//



@protocol ReceiverDelegate <NSObject>

@required
- (void) dataReceived: (NSString *) data;
- (void) strengthRSSI: (int) RSSI;
- (BOOL) isRSSIAllowed: (int) RSSI;
- (void) isConnected;
- (void) isDisconnected;

@end


@interface BTLECentral : NSObject
- (id) initWith: (id<ReceiverDelegate>)delegate;
- (void) assignDataDelegate:(id<ReceiverDelegate>)dataDelegate;
- (void) startBluetooth;
- (void) stopBluetooth;

@end
