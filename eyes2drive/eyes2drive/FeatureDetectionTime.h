//
//  FeatureDetectionTime.h
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM (NSInteger, FeatureDetection) {
    FeatureFaceDetected       = 1,
    FeatureEyesDetected       = 10,
    Feature2EyesDetected       = 20,
    FeatureTrip             = 42
};
extern NSString * const FeatureDetection_toString[];


typedef NS_ENUM (NSInteger, FeatureAlertColor) {
    FeatureAlertGreen     = 0, // used for start trip, too
    FeatureAlertOrange    = 1, // used for pause
    FeatureAlertRed       = 2, // used for stop trip
    FeatureAlertDarkRed   = 3
};
extern NSString * const FeatureAlertColor_toString[];

@interface State : NSObject <NSCopying>

@property (atomic) FeatureDetection feature;
@property (atomic) FeatureAlertColor color;
@property (atomic) CFTimeInterval featureTime;
@property (atomic) CFTimeInterval elapsedTime;
@property (nonatomic, strong) State * lastState;

- (id) initWith: (FeatureDetection) feature;
- (BOOL)push: (FeatureAlertColor) color at: (CFTimeInterval) time  since: (CFTimeInterval) timeInMs;
-(id) copyWithZone: (NSZone *) zone;
-(NSString*) toSendEventString;
@end



@protocol FeatureDetectionDelegate <NSObject>
- (void)feature: (FeatureDetection)feature changedState: (State *) state;
@end


@interface FeatureDetectionTime : NSObject 

@property (nonatomic) FeatureDetection feature;
@property (nonatomic, strong) State * state;
@property (nonatomic, weak) id<FeatureDetectionDelegate> delegate;

+ (CFTimeInterval) now;
- (id) initWith: (FeatureDetection)feature;

- (void)start;
- (void)stop;
- (void)setThreshold: (BOOL)on orange: (CFTimeInterval)orangeThresholdInMs red: (CFTimeInterval)redThresholdInMs darkred: (CFTimeInterval) darkRedThresholdInMs;
- (FeatureAlertColor)getThresholdColor;

- (void)featureDetected;
- (void)featureNotDetected;

- (void)featureDetected: (BOOL) found;


@end
