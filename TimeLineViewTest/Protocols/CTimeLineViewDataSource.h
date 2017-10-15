//
//  CTimeLineViewDataSource.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/10/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTimeIntervalScrollViewSectorIntervalEnum.h"

@class CTimeLineView;

@protocol CTimeLineViewDataSource <NSObject>

- (BOOL)timeIntersectWithReservationsForTimeLineView:(CTimeLineView *)timeLineView;
- (CTimeIntervals)stepForTimeLineView:(CTimeLineView *)timeLineView;
- (NSInteger)maxAppliableTimeIntervalInSecsForTimeLineView:(CTimeLineView *)timeLineView;;

@end
