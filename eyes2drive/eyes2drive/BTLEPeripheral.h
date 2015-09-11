
//
//  BTLEPeripheral.h
//  BTLE Transfer
//
//  Created by Lorenz Hänggi on 10/09/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//



@protocol SenderDelegate <NSObject>

@required
- (NSData *)dataToSend;
@end


@interface BTLEPeripheral : NSObject 

- (id) initWith: (id<SenderDelegate>)delegate;
- (void) startBluetooth;
- (void) stopBluetooth;

@end
