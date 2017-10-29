//
//  TimeLineReservation.h
//  Cadence
//
//  Created by Dimitry Panychyk on 10/17/17.
//  Copyright © 2017 Cadence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TimeLineReservation <NSObject>

@property (nonatomic, strong, nullable, readonly) NSString *imagePath;
@property (nonatomic, strong, nullable, readonly) UIImage *image;
@property (nonatomic, strong, nonnull, readonly) NSDate *startDate;
@property (nonatomic, strong, nonnull, readonly) NSDate *endDate;

@end
