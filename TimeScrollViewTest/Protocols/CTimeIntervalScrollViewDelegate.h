//
//  CTimeIntervalScrollViewDelegate.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/10/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@class CDateInterval;

@protocol CTimeIntervalScrollViewDelegate <NSObject>

- (void)onSelectedTimeIntervalChangeDateInterval:(CDateInterval *)dateInterval;
- (void)onThumbViewChangeSelectedIntervalRect:(CGRect)newRect;

@end
