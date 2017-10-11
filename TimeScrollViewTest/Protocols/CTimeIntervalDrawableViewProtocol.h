//
//  CTimeIntervalDrawableViewProtocol.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@protocol CTimeIntervalDrawableViewProtocol <NSObject>

- (void)onSelectionEventWithIndex:(NSInteger)index andPoint:(CGPoint)point;

@end
