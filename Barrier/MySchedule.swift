//
//  MySchedule.swift
//  Barrier
//
//  Created by Jared Cassoutt on 10/24/23.
//

import Foundation
import DeviceActivity

extension DeviceActivityName {
    static let daily = Self("daily")
}

extension DeviceActivityEvent.Name {
    static let discourage = Self("discourage")
}

let dailySchedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 0, minute: 0),
    intervalEnd: DateComponents(hour: 23, minute: 59),
    repeats: true)

class MySchedule {
    
    static let center = DeviceActivityCenter()
    
    static func setSchedule(timeLimitMinutes: Int? = 0) {
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .discourage:
                DeviceActivityEvent(
                    applications: MyModel.shared.selectionToDiscourage.applicationTokens,
                    categories: MyModel.shared.selectionToDiscourage.categoryTokens,
                    webDomains: MyModel.shared.selectionToDiscourage.webDomainTokens,
                    threshold: DateComponents(minute: timeLimitMinutes)
                )
        ]
        
        do {
            try center.startMonitoring(.daily, during: dailySchedule, events: events)
        } catch {
            print("Error monitoring schedule: ", error)
        }
    }
}
