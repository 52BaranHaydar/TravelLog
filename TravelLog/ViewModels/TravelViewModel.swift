//
//  TravelViewModel.swift
//  TravelLog
//
//  Created by Baran on 21.03.2026.
//

import Foundation
import Combine
import MapKit

class TravelViewModel: ObservableObject{
    
    @Published var trips: [Trip] = Trip.samples
    @Published var selectedTrip: Trip?
    @Published var searchText = ""
    @Published var selectedStatus: Trip.Status? = nil
    
    let motionService = MotionService.shared
    
    // Filtrelenmiş Geziler
    var filteredTrips: [Trip] {
        var result = trips
        
        if let status = selectedStatus{
            result = result.filter{ $0.status == status }
        }
        
        if !searchText.isEmpty{
            result = result.filter{
                $0.title.localizedCaseInsensitiveContains(searchText) || $0.destination.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted{ $0.startDate > $1.startDate }
        
    }
    
    // İstatistikler
    var totalTrips: Int{ trips.count }
    var completedTrips: Int { trips.filter{ $0.status == .completed }.count }
    var totalSteps: Int { trips.reduce(0) {$0 + $1.duration} }
    var totalDays : Int { trips.reduce(0) {$0 + $1.duration} }
    
    // Gezi Ekle
    func addTrip(_ trip: Trip){
        trips.append(trip)
    }
    
    // Gezi Sil
    func deleteTrip(_ trip: Trip){
        trips.removeAll{ $0.id == trip.id}
    }
    
    func updateTrip(_ trip: Trip){
        if let index = trips.firstIndex(where: { $0.id == trip.id }){
            trips[index] = trip
        }
    }
    
    // Durum filtrele
    func filterByStatus(_ status: Trip.Status?){
        selectedStatus = status
    }
    
    // Harita Bölgesi
    func region(for trip: Trip) -> MKCoordinateRegion{
        MKCoordinateRegion(
            center: trip.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }
    
    
}
