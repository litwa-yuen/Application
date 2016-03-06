//
//  TimeAgo.swift
//  Look LOL
//
//  Created by Lit Wa Yuen on 2/7/16.
//  Copyright © 2016 lit.wa.yuen. All rights reserved.
//


import Foundation



public func timeAgoSince(date: NSDate) -> String {
    
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let unitFlags: NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfYear, .Month, .Year]
    let components = calendar.components(unitFlags, fromDate: date, toDate: now, options: [])
    
    if components.year >= 2 {
        return "\(components.year) years ago"
    }
    
    if components.year >= 1 {
        return "Last year"
    }
    
    if components.month >= 2 {
        return "\(components.month) months ago"
    }
    
    if components.month >= 1 {
        return "Last month"
    }
    
    if components.weekOfYear >= 2 {
        return "\(components.weekOfYear) weeks ago"
    }
    
    if components.weekOfYear >= 1 {
        return "Last week"
    }
    
    if components.day >= 2 {
        return "\(components.day) days ago"
    }
    
    if components.day >= 1 {
        return "Yesterday"
    }
    
    if components.hour >= 2 {
        return "\(components.hour) hours ago"
    }
    
    if components.hour >= 1 {
        return "An hour ago"
    }
    
    if components.minute >= 2 {
        return "\(components.minute) mins ago"
    }
    
    if components.minute >= 1 {
        return "A min ago"
    }
    
    if components.second >= 3 {
        return "\(components.second) seconds ago"
    }
    
    return "Just now"
    
}
