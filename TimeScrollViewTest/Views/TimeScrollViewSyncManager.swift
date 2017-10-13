//
//  TimeScrollViewSyncManager.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/13/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

protocol TimeScrollViewSyncManagerDelegate: NSObjectProtocol {
    
    func onChangeThumbLocation(minX: CGFloat,
                               maxX: CGFloat,
                               thumbView: CThumbView,
                               timeInterval: CDateInterval)
    
}

class TimeScrollViewSyncManager {
    
    var listeners: [TimeScrollViewSyncManagerDelegate?] = [TimeScrollViewSyncManagerDelegate?]()
    
    static let shared = TimeScrollViewSyncManager()
    
    public func notifyListeners(minX: CGFloat,
                                maxX: CGFloat,
                                thumbView: CThumbView,
                                timeInterval: CDateInterval) {
        for listener in listeners {
            guard let listener = listener else { continue }
            listener.onChangeThumbLocation(minX: minX,
                                           maxX: maxX,
                                           thumbView: thumbView,
                                           timeInterval: timeInterval)
        }
    }
}
