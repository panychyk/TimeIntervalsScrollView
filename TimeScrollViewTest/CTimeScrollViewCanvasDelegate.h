//
//  CTimeScrollViewCanvasDelegate.h
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CTimeScrollViewCanvasDelegate <NSObject>

- (void)appliedDate:(NSDate *)date forIndex:(NSNumber *)index;

@end
