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
    Feature2EyesDetected       = 20
};
extern NSString * const FeatureDetection_toString[];


typedef NS_ENUM (NSInteger, FeatureAlertColor) {
    FeatureAlertGreen     = 0,
    FeatureAlertOrange    = 1,
    FeatureAlertRed       = 2,
    FeatureAlertDarkRed   = 3,
};
extern NSString * const FeatureAlertColor_toString[];



@interface State : NSObject

@property (atomic) FeatureAlertColor color;
@property (atomic) CFTimeInterval elapsedTime;
@property (nonatomic, strong) State * lastState;

- (id) init;
- (BOOL)push: (FeatureAlertColor) color since: (CFTimeInterval) timeInMs;

@end



@protocol FeatureDetectionDelegate <NSObject>
- (void)feature: (FeatureDetection)feature changedState: (State *) state;
@end


@interface FeatureDetectionTime : NSObject

@property (nonatomic) FeatureDetection feature;
@property (nonatomic, strong) State * state;


@property (nonatomic, weak) id<FeatureDetectionDelegate> delegate;

- (id) initWith: (FeatureDetection)feature;

- (void)start;
- (void)stop;
- (void)setThreshold: (BOOL)on orange: (CFTimeInterval)orangeThresholdInMs red: (CFTimeInterval)redThresholdInMs darkred: (CFTimeInterval) darkRedThresholdInMs;
- (FeatureAlertColor)getThresholdColor;

- (void)featureDetected;
- (void)featureNotDetected;

@end
