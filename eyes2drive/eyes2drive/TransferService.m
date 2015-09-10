//
//  TransferService.m
//  BTLE Transfer
//
//  Created by Lorenz Hänggi on 12/08/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@implementation TransferService : NSObject 

static int value = 0;
static NSString *valueString = @"0";


+ (int) value {
    @synchronized(self) { return value; }
}
+ (void) setValue:(int)val {
    @synchronized(self) {
        value = val;
        valueString = [NSString stringWithFormat:@"%d",val];
    }
}

+(NSDictionary*) dictionary {
    static NSDictionary* TRANSFER_SERVICE_UUIDs = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        TRANSFER_SERVICE_UUIDs = @{
                                   @"0" : @"08590F7E-DB05-467E-8757-72F6FAEB13D4",
                                   @"1" : @"75B26B22-7812-4E9A-AB6D-D8385E8400A7",
                                   @"2" : @"77B71D7D-E2B7-41AF-BE92-59B560B9BCCC",
                                   @"3" : @"99AE1A86-945F-4887-B927-BB4678E4359F",
                                   @"4" : @"2FC9AD59-E58B-42B2-ABB6-0758800ADDE1",
                                   @"5" : @"E7BE1ADA-A5E2-4D7E-B123-E14B928AEF31",
                                   @"6" : @"75991EF3-5889-43E4-A375-12B17B028637",
                                   @"7" : @"FD67372D-3D5F-4C7A-A010-74DD812C8F61"
                                  };
    });
    
    return TRANSFER_SERVICE_UUIDs;
}

/* TRANSFER_SERVICE_UUID */
+(NSString*) getTRANSFER_SERVICE_UUID {
    NSString * uuid = self.dictionary[valueString];
    if (!uuid) {
        /* generate random */
        uuid = [[NSUUID UUID] UUIDString];
    }
    return uuid;
}

+(CBUUID*) getTRANSFER_SERVICE_CBUUID {
    return [CBUUID UUIDWithString: [self getTRANSFER_SERVICE_UUID]];
}



@end