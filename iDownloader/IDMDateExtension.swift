//
//  IDMDateExtension.swift
//  iDownloader
//
//  Created by Abhishek Pandey on 29/04/17.
//  Copyright © 2017 Abhishek Pandey. All rights reserved.
//

import Foundation


extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func add(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func add(hrs: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .hour, value: hrs, to: self)!
    }
    
    func addDay(day: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: day, to: self)!
    }
    
    func changeHrsAndMins(hrs:Int, mins:Int) -> Date{
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = hrs
        components.minute = mins
        components.second = 0
        let date = gregorian.date(from: components)!
        return date
    }
    
    func getHrs() -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        return hour
    }
    
    func getMinutes() -> Int {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        return minutes
        
    }
    
    func getDateForDayAfterCurrentDate(_ dayNumber:Int) -> Date
    {
        let forCalender:Calendar = Calendar.current
        let currentDate = self
        var nextWeekDayComponent = DateComponents()
        nextWeekDayComponent.weekday = dayNumber
        let componentsForCurrentDate = (forCalender as NSCalendar).components([.hour, .minute, .second, .day, .month, .year], from: currentDate)
        let nextWeekDayDate = (forCalender as NSCalendar).nextDate(after: currentDate, matching: nextWeekDayComponent, options: [.matchNextTime, .matchStrictly])
        var componentForNextDay = (forCalender as NSCalendar).components([.hour, .minute, .second, .day, .month, .year], from: nextWeekDayDate!)
        componentForNextDay.hour = componentsForCurrentDate.hour
        componentForNextDay.minute = componentsForCurrentDate.minute
        componentForNextDay.second = componentsForCurrentDate.second
        let nextDateWithSameTime = forCalender.date(from: componentForNextDay)
        return nextDateWithSameTime!
    }
}
