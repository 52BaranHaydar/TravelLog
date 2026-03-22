//
//  AddTripView.swift
//  TravelLog
//
//  Created by Baran on 22.03.2026.
//
import SwiftUI
import MapKit

struct AddTripView: View {
    @ObservedObject var viewModel: TravelViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var notes = ""
    @State private var status: Trip.Status = .planned
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem?
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gezi Bilgileri") {
                    TextField("Gezi başlığı", text: $title)
                    TextField("Hedef şehir/ülke", text: $destination)
                        .onChange(of: destination) { _, value in
                            searchLocation(value)
                        }
                }
                
                // Konum sonuçları
                if !searchResults.isEmpty {
                    Section("Konum Seç") {
                        ForEach(searchResults, id: \.self) { item in
                            Button {
                                selectedLocation = item
                                destination = item.name ?? destination
                                searchResults = []
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "")
                                        .foregroundStyle(.primary)
                                    Text(item.placemark.title ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section("Tarihler") {
                    DatePicker("Başlangıç", selection: $startDate, displayedComponents: .date)
                    DatePicker("Bitiş", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                
                Section("Durum") {
                    Picker("Durum", selection: $status) {
                        ForEach(Trip.Status.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notlar") {
                    TextField("Gezi notları...", text: $notes, axis: .vertical)
                        .lineLimit(4)
                }
            }
            .navigationTitle("Gezi Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveTrip()
                    }
                    .disabled(title.isEmpty || destination.isEmpty)
                }
            }
        }
    }
    
    func searchLocation(_ query: String) {
        guard query.count > 2 else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        MKLocalSearch(request: request).start { response, _ in
            searchResults = response?.mapItems.prefix(3).map { $0 } ?? []
        }
    }
    
    func saveTrip() {
        let lat = selectedLocation?.placemark.coordinate.latitude ?? 0
        let lon = selectedLocation?.placemark.coordinate.longitude ?? 0
        
        let trip = Trip(
            title: title,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            latitude: lat,
            longitude: lon,
            status: status
        )
        viewModel.addTrip(trip)
        dismiss()
    }
}

#Preview {
    AddTripView(viewModel: TravelViewModel())
}
