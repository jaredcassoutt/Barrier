//
//  ContentView.swift
//  Barrier
//
//  Created by Jared Cassoutt on 10/24/23.
//

import SwiftUI
import ManagedSettings
import DeviceActivity

extension DeviceActivityName {
    static let activity = Self("activity")
}

struct ContentView: View {
    @State private var isDiscouragedPresented: Bool = false
    @EnvironmentObject var model: MyModel
    @EnvironmentObject var store: ManagedSettingsStore
    
    @State private var isLocked: Bool = false
    
    var body: some View {
        ZStack {
            Colors.background1.ignoresSafeArea()
            
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height) * 0.9
                
                VStack (alignment: .center) {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            if isLocked {
                                // unlock app for a 15 minute period
                                try? DeviceActivityCenter().startMonitoring(
                                    .activity,
                                    during: getCurrentTimeActivitySchedule(forMinutes: 15))
                            } else {
                                // Lock the apps indefinitely
                                MySchedule.setSchedule()
                            }
                            isLocked.toggle()
                        }) {
                            VStack {
                                Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: size * 0.3)
                                    .padding(.bottom, 10)
                                
                                Text(isLocked ? "Unlock for 15 Minutes" : "Lock Apps")
                            }
                            .foregroundColor(Colors.text3)
                            .frame(width: size, height: size)
                            .background(.ultraThinMaterial)
                            .cornerRadius(size/20)
                            .font(.title2)
                            .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            isDiscouragedPresented.toggle()
                        }) {
                            VStack {
                                Text(isLocked ? "Re-select Apps to Lock" : "Select Apps to Lock")
                            }
                            .foregroundColor(Colors.text3)
                            .frame(width: size, height: size/4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(size/20)
                            .font(.title2)
                            .shadow(radius: 10)
                        }
                        .familyActivityPicker(isPresented: $isDiscouragedPresented, selection: $model.selectionToDiscourage)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            isLocked = model.selectionToDiscourage.applications.isEmpty == false
        }
        .onChange(of: model.selectionToDiscourage) { _ in
            MyModel.shared.setShieldRestrictions(store: store)
            isLocked = model.selectionToDiscourage.applications.isEmpty == false
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func getCurrentTimeActivitySchedule(forMinutes minutes: Int) -> DeviceActivitySchedule {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        var subZero = currentMinute<10 ? "0" : ""
        print("currentTime - \(currentHour>12 ? currentHour-12 : currentHour):\(subZero)\(currentMinute)")
        
        if let intervalEnd = calendar.date(byAdding: .minute, value: minutes, to: currentDate) {
            let endHour = calendar.component(.hour, from: intervalEnd)
            let endMinute = calendar.component(.minute, from: intervalEnd)
            
            subZero = endMinute<10 ? "0" : ""
            print("intervalEndTime - \(endHour>12 ? endHour-12 : endHour):\(subZero)\(endMinute)")
            
            return DeviceActivitySchedule(
                intervalStart: DateComponents(hour: currentHour, minute: currentMinute),
                intervalEnd: DateComponents(hour: endHour, minute: endMinute),
                repeats: false,
                warningTime: DateComponents(minute: minutes-1)
            )
        } else {
            fatalError("Failed to calculate the end interval")
        }
    }
}

#Preview {
    ContentView()
}
