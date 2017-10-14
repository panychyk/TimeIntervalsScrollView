//
//  TimeLineViewSyncManager.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/13/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

protocol TimeLineViewSyncManagerDelegate: NSObjectProtocol {
    
    func onChangeThumbLocation(_ thumbView: CThumbView,
                               minX: CGFloat,
                               maxX: CGFloat,
                               timeInterval: CDateInterval)
    
}

class TimeLineViewSyncManager {
    
    // Insert only weak references to prevent memory leaking
    var listeners: [TimeLineViewSyncManagerDelegate?] = [TimeLineViewSyncManagerDelegate?]()
    
    static let shared = TimeLineViewSyncManager()
    
    public func notifyListenersChangeThumbViewLocation(_ thumbView: CThumbView, minX: CGFloat, maxX: CGFloat, timeInterval: CDateInterval) {
        
        for listener in listeners {
            guard let listener = listener else { continue }
            listener.onChangeThumbLocation(thumbView, minX: minX, maxX: maxX, timeInterval: timeInterval)
        }
    }
}
