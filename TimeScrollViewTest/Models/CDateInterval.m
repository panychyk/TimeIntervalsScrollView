//
//  CDateInterval.m
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 6/27/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import "CDateInterval.h"
#import <Foundation/NSException.h>

@implementation CDateInterval

- (instancetype)initWithStartDate:(NSDate *)startDate duration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        _startDate = startDate;
        _duration = duration;
        if (duration < 0) {
            NSAssert(false, @"[CDateInterval initWithStartDate:duration:] - Duration must be grather then 0");
            const NSTimeInterval oneHour = 60*60;
            _duration = oneHour;
        }
        _endDate = [NSDate dateWithTimeInterval:_duration sinceDate:_startDate];
    }
    return self;
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    self = [super init];
    if (self) {
        _startDate = startDate;
        _endDate = endDate;
        if (startDate.timeIntervalSince1970 > endDate.timeIntervalSince1970) {
            NSAssert(false, @"[CDateInterval initWithStartDate:endDate:] - End date must be grather then start date");
            const NSTimeInterval oneHour = 60*60;
            _endDate = [NSDate dateWithTimeInterval:oneHour sinceDate:_startDate];
        }
        _duration = [_endDate timeIntervalSinceDate:startDate];
    }
    return self;
}

- (BOOL)containsDate:(NSDate *)date {
    if (([_startDate compare:date] != NSOrderedDescending) &&
        [_endDate compare:date] != NSOrderedAscending) {
        return true;
    } else {
        return false;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    CDateInterval *copy = [[CDateInterval alloc] initWithStartDate:[_startDate copy] endDate:[_endDate copy]];
    return copy;
}

- (BOOL)isEqual:(CDateInterval *)object {
    if (object == nil) {
        return false;
    }
    if ([object isKindOfClass:[CDateInterval class]]) {
        if (self.startDate.timeIntervalSince1970 == object.startDate.timeIntervalSince1970 &&
            self.endDate.timeIntervalSince1970 == object.endDate.timeIntervalSince1970) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

- (NSArray <CDateInterval *> *)compareWithDateInterval:(CDateInterval *)dateInterval {
    if ([self isEqual:dateInterval]) {
        //dates the same
        return @[self];
    }
    
    CDateInterval *earlierDateInterval = nil;
    CDateInterval *laterDateInterval = nil;
    if ([_startDate compare:dateInterval.startDate] == NSOrderedAscending) {
        earlierDateInterval = self;
        laterDateInterval = dateInterval;
    } else {
        earlierDateInterval = dateInterval;
        laterDateInterval = self;
    }
    
    if ([earlierDateInterval.endDate compare:laterDateInterval.endDate] == NSOrderedDescending) {
        //earlierDateInterval absorb laterDateInterval
        return @[earlierDateInterval];
    }
    
    if ([earlierDateInterval containsDate:laterDateInterval.startDate]) {
        //earlierDateInterval is smooth flow into laterDateInterval
        return @[[[CDateInterval alloc] initWithStartDate:earlierDateInterval.startDate endDate:laterDateInterval.endDate]];
    }
    
    // return both dates
    return @[self, dateInterval];
}

@end
