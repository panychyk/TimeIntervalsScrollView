//
//  CDateInterval.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 6/27/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSCoder.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDateInterval : NSObject <NSCopying>

@property (readonly, copy) NSDate *startDate;
@property (readonly, copy) NSDate *endDate;
@property (readonly) NSTimeInterval duration;

- (instancetype)initWithStartDate:(NSDate *)startDate duration:(NSTimeInterval)duration;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (BOOL)containsDate:(NSDate *)date;

- (nullable NSArray <CDateInterval *> *)compareWithDateInterval:(CDateInterval *)dateInterval;

@end

NS_ASSUME_NONNULL_END
