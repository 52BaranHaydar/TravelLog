//
//  Trip.swift
//  TravelLog
//
//  Created by Baran on 21.03.2026.
//
import Foundation
import MapKit

struct Trip: Identifiable {
    let id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var notes: String
    var latitude: Double
    var longitude: Double
    var photos: [String]
    var status: Status
    var steps: Int
    
    enum Status: String, CaseIterable {
        case planned = "Planlandı"
        case ongoing = "Devam Ediyor"
        case completed = "Tamamlandı"
        
        var color: String {
            switch self {
            case .planned: return "blue"
            case .ongoing: return "orange"
            case .completed: return "green"
            }
        }
        
        var icon: String {
            switch self {
            case .planned: return "calendar"
            case .ongoing: return "airplane"
            case .completed: return "checkmark.seal.fill"
            }
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(86400 * 7),
        notes: String = "",
        latitude: Double = 0,
        longitude: Double = 0,
        photos: [String] = [],
        status: Status = .planned,
        steps: Int = 0
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
        self.photos = photos
        self.status = status
        self.steps = steps
    }
    
    static let samples: [Trip] = [
        Trip(title: "İstanbul Turu", destination: "İstanbul", startDate: Date().addingTimeInterval(-86400 * 30), endDate: Date().addingTimeInterval(-86400 * 25), latitude: 41.0082, longitude: 28.9784, status: .completed, steps: 45230),
        Trip(title: "Kapadokya Macerası", destination: "Nevşehir", startDate: Date().addingTimeInterval(86400 * 10), endDate: Date().addingTimeInterval(86400 * 15), latitude: 38.6431, longitude: 34.8289, status: .planned, steps: 0),
        Trip(title: "Ege Turu", destination: "İzmir", startDate: Date().addingTimeInterval(-86400 * 2), endDate: Date().addingTimeInterval(86400 * 5), latitude: 38.4189, longitude: 27.1287, status: .ongoing, steps: 12450),
    ]
}
