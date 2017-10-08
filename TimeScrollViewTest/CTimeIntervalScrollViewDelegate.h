//
//  CTimeIntervalScrollViewDelegate.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDateInterval;

@protocol CTimeIntervalScrollViewDelegate <NSObject>

- (void)onApplyDateInterval:(CDateInterval *)dateInterval forIndex:(NSNumber *)index;

@end
