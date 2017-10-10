//
//  CTimeIntervalScrollViewDataSource.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/10/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTimeIntervalScrollViewSectorIntervalEnum.h"

@protocol CTimeIntervalScrollViewDataSource <NSObject>

- (BOOL)timeIntervalScrollViewAllowIntersectWithReservations;
- (CTimeIntervals)stepForTimeIntervalScrollView;
- (NSInteger)maxAppliableTimeIntervalInSecs;
@end
