//
//  MotionService.swift
//  TravelLog
//
//  Created by Baran on 21.03.2026.
//

import Foundation
import CoreMotion
import Combine

class MotionService: ObservableObject{
    
    static let shared = MotionService()
    private let pedometer = CMPedometer()
    
    @Published var todaySteps: Int = 0
    @Published var totalSteps : Int = 0
    @Published var isAvailable = CMPedometer.isStepCountingAvailable()
    
    init(){
        fetchTodaySteps()
    }
    
    
    // Bugünkü adımları getir
    func fetchTodaySteps(){
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        pedometer.queryPedometerData(from: startOfDay, to: Date()){ [weak self] data, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async{
                self?.todaySteps = data.numberOfSteps.intValue
            }
            
        }
    }
    
    // Belirli tarih aralıgındaki adımları getir
    func fetchSteps(from: Date, to: Date, completion: @escaping (Int) -> Void){
        guard CMPedometer.isStepCountingAvailable() else {
            completion(0)
            return
        }
        
        pedometer.queryPedometerData(from: from, to: to){ data, error in
            guard let data = data, error == nil else{
                completion(0)
                return
            }
            DispatchQueue.main.async{
                completion(data.numberOfSteps.intValue)
            }
            
        }
        
    }
    
    // Canlı adım sayımı başlat
    func startLiveTracking(){
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let data = data, error == nil else{return}
            DispatchQueue.main.async{
                self?.todaySteps = data.numberOfSteps.intValue
            }
            
        }
    }
    
    // Canlı takibi durdur
    func stopLiveTracking(){
        pedometer.stopUpdates()
    }
    
    // Adımları formatı göster
    func formatSteps(_ steps: Int) -> String{
        if steps >= 1000{
            return String(format: "%.1K", Double(steps) / 1000)
        }
        return "\(steps)"
    }
    
    
    
    
    
    
}
