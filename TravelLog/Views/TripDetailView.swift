//
//  TripDetailView.swift
//  TravelLog
//
//  Created by Baran on 22.03.2026.
//

import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: Trip
    @ObservedObject var viewModel: TravelViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    init(trip: Trip, viewModel: TravelViewModel) {
        self.trip = trip
        self.viewModel = viewModel
        _region = State(initialValue: MKCoordinateRegion(
            center: trip.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Harita
                if trip.latitude != 0 && trip.longitude != 0 {
                    Map(coordinateRegion: $region, annotationItems: [trip]) { t in
                        MapAnnotation(coordinate: t.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
                // Gezi detayları
                VStack(spacing: 16) {
                    // Durum
                    HStack {
                        Label(trip.status.rawValue, systemImage: trip.status.icon)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                        Spacer()
                        Text("\(trip.duration) gün")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Tarihler
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Başlangıç")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Bitiş")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.06), radius: 6)
                    
                    // Adım sayısı
                    if trip.steps > 0 {
                        HStack {
                            Image(systemName: "figure.walk.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Toplam Adım")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.motionService.formatSteps(trip.steps))
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.06), radius: 6)
                    }
                    
                    // Notlar
                    if !trip.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notlar")
                                .font(.headline)
                            Text(trip.notes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.06), radius: 6)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    viewModel.deleteTrip(trip)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TripDetailView(trip: Trip.samples[0], viewModel: TravelViewModel())
    }
}
