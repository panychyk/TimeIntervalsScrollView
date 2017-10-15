//
//  TimeLineViewDataSource.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/10/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeIntervalScrollViewSectorIntervalEnum.h"

@class TimeLineView;

@protocol TimeLineViewDataSource <NSObject>

- (BOOL)timeIntersectWithReservationsForTimeLineView:(TimeLineView *)timeLineView;
- (CTimeIntervals)stepForTimeLineView:(TimeLineView *)timeLineView;
- (NSInteger)maxAppliableTimeIntervalInSecsForTimeLineView:(TimeLineView *)timeLineView;;

@end
