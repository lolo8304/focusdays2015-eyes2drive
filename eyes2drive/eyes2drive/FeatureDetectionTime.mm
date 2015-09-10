//
//  FeatureDetectionTime.m
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FeatureDetectionTime.h"

@implementation State

- (id)initWith: (FeatureDetection) feature {
    self = [super init];
    if (self) {
        self.feature = feature;
        self.lastState = [State alloc];
        self.color = FeatureAlertDarkRed;
        self.elapsedTime = 0;
        self.featureTime = 0;
        return self;
    }
    return nil;
}

- (BOOL)push: (FeatureAlertColor) color at: (CFTimeInterval) time  since: (CFTimeInterval) timeInMs {
    if (self.color == color) {
        self.elapsedTime = timeInMs;
        self.featureTime = time;
        return false;
    } else {
        self.lastState.color = self.color;
        self.lastState.elapsedTime = self.elapsedTime;
        self.lastState.featureTime = self.featureTime;
        self.color = color;
        self.elapsedTime = timeInMs;
        self.featureTime = time;
        return true;
    }
}

-(id) copyWithZone: (NSZone *) zone {
    State *stateCopy = [State allocWithZone: zone];
    stateCopy.feature = self.feature;
    stateCopy.color = self.color;
    stateCopy.elapsedTime = self.elapsedTime;
    stateCopy.featureTime = self.featureTime;
    if (self.lastState) {
        stateCopy.lastState = self.lastState.copy;
    }
    return stateCopy;
}

@end



@implementation FeatureDetectionTime

NSString * const FeatureAlertColor_toString[] = {
    [FeatureAlertGreen] = @"Green",
    [FeatureAlertOrange] = @"Orange",
    [FeatureAlertRed] = @"Red",
    [FeatureAlertDarkRed] = @"Dark-Red"
};
NSString * const FeatureDetection_toString[] = {
    [FeatureEyesDetected] = @"FeatureEyesDetected",
    [Feature2EyesDetected] = @"Feature2EyesDetected",
    [FeatureFaceDetected] = @"FeatureFaceDetected",
    [FeatureTrip] = @"FeatureTrip"
};


BOOL started = false;

BOOL featureOn = false;
CFTimeInterval startTime = 0;
CFTimeInterval elapsedTime = 0;

CFTimeInterval darkRedThresholdOn = 0;
CFTimeInterval redThresholdOn = 0;
CFTimeInterval orangeThresholdOn = 0;

CFTimeInterval darkRedThresholdOff = 0;
CFTimeInterval redThresholdOff = 0;
CFTimeInterval orangeThresholdOff = 0;

+ (CFTimeInterval) now {
    return CACurrentMediaTime() * 1000;
}

- (id)initWith:(FeatureDetection)feature {
    self = [self init];
    if (self) {
        self.feature = feature;
        self.delegate = nil;
        self.state = [[State alloc] initWith: feature];
        return self;
    }
    return nil;
}

- (void)setThreshold: (BOOL)on orange: (CFTimeInterval)orangeThresholdInMs red: (CFTimeInterval)redThresholdInMs  darkred: (CFTimeInterval)darkRedThresholdInMs{
    if (on) {
        orangeThresholdOn = orangeThresholdInMs;
        redThresholdOn = redThresholdInMs;
        darkRedThresholdOn = darkRedThresholdInMs;
    } else {
        orangeThresholdOff = orangeThresholdInMs;
        redThresholdOff = redThresholdInMs;
        darkRedThresholdOff = darkRedThresholdInMs;
    }
}

- (FeatureAlertColor)getThresholdColor {
    if (featureOn) {
        if (orangeThresholdOn > 0 && redThresholdOn > 0) {
            if (elapsedTime < orangeThresholdOn) return FeatureAlertGreen;
            if (elapsedTime < redThresholdOn) return FeatureAlertOrange;
            if (elapsedTime < darkRedThresholdOn) return FeatureAlertRed;
            return FeatureAlertDarkRed;
        } else {
            return FeatureAlertGreen;
        }
    } else {
        if (orangeThresholdOff > 0 && redThresholdOff > 0) {
            if (elapsedTime < orangeThresholdOff) return FeatureAlertGreen;
            if (elapsedTime < redThresholdOff) return FeatureAlertOrange;
            if (elapsedTime < darkRedThresholdOff) return FeatureAlertRed;
            return FeatureAlertDarkRed;
        } else {
            return FeatureAlertGreen;
        }
    }
}


- (BOOL)isValidElapsedTimeToSwitchMode {
    return elapsedTime > 100;
}

- (void)start; {
    started = true;
}
- (void)stop {
    started = false;
}

- (void)triggerChangedEvent {
    if (self.delegate) {
        [self.delegate feature: self.feature changedState: [self.state copy]];
    }
}

- (void)featureDetected {
    [self featureDetected: true];
}

- (void)featureNotDetected {
    [self featureDetected: false];
}

- (void)featureDetected: (BOOL) found {
    if (startTime == 0) {
        featureOn = found;
        startTime = [FeatureDetectionTime now];
        return;
    }
    
    CFTimeInterval now = [FeatureDetectionTime now];
    elapsedTime = now - startTime;
    FeatureAlertColor color = [self getThresholdColor];
//    printf("time = %f / detected: %d / feature = %d / color = %s\n", elapsedTime, found, featureOn, [(FeatureAlertColor_toString[color]) UTF8String]);
    
    if ([self.state push: color at: now  since: elapsedTime]) {
        [self triggerChangedEvent ];
    }
    if (featureOn != found && [self isValidElapsedTimeToSwitchMode]) {
        featureOn = found;
        startTime = [FeatureDetectionTime now];
        elapsedTime = 0;
    } else {
        //keep feature or switch feature was too fast
    }
    
}



@end
