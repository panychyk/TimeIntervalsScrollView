//
//  TimeLineViewDataSource.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/10/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeIntervalScrollViewSectorIntervalEnum.h"

@class TimeLineView, CTimeLineViewModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TimeLineViewDataSource <NSObject>

- (BOOL)timeIntersectWithReservationsForTimeLineView:(TimeLineView *)timeLineView;
- (CTimeIntervals)stepForTimeLineView:(TimeLineView *)timeLineView;
- (NSInteger)maxAppliableTimeIntervalInSecsForTimeLineView:(TimeLineView *)timeLineView;;
- (CTimeLineViewModel *)timeLineViewModelFroView:(TimeLineView *)timeLineView;

@end

NS_ASSUME_NONNULL_END

