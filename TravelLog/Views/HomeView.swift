//
//  HomeView.swift
//  TravelLog
//
//  Created by Baran on 21.03.2026.
//
import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = TravelViewModel()
    @State private var showAddTrip = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // İstatistik kartları
                    StatsCard(viewModel: viewModel)
                    
                    // Adım sayacı
                    StepCountCard(motionService: viewModel.motionService)
                    
                    // Durum filtresi
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterButton(title: "Tümü", isSelected: viewModel.selectedStatus == nil) {
                                viewModel.filterByStatus(nil)
                            }
                            ForEach(Trip.Status.allCases, id: \.self) { status in
                                FilterButton(
                                    title: status.rawValue,
                                    isSelected: viewModel.selectedStatus == status
                                ) {
                                    viewModel.filterByStatus(status)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Gezi listesi
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredTrips) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip, viewModel: viewModel)) {
                                TripCard(trip: trip)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .searchable(text: $viewModel.searchText, prompt: "Gezi ara...")
            .navigationTitle("TravelLog ✈️")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTrip = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddTrip) {
                AddTripView(viewModel: viewModel)
            }
        }
    }
}

// İstatistik kartı
struct StatsCard: View {
    @ObservedObject var viewModel: TravelViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            StatItem(value: "\(viewModel.totalTrips)", title: "Gezi", icon: "airplane", color: .blue)
            StatItem(value: "\(viewModel.completedTrips)", title: "Tamamlanan", icon: "checkmark.seal", color: .green)
            StatItem(value: "\(viewModel.totalDays)", title: "Gün", icon: "calendar", color: .orange)
            StatItem(value: viewModel.motionService.formatSteps(viewModel.totalSteps), title: "Adım", icon: "figure.walk", color: .purple)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Adım sayacı kartı
struct StepCountCard: View {
    @ObservedObject var motionService: MotionService
    
    var body: some View {
        HStack {
            Image(systemName: "figure.walk.circle.fill")
                .font(.title)
                .foregroundStyle(.purple)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bugünkü Adımlar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(motionService.formatSteps(motionService.todaySteps))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Hedef ilerleme
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(Double(motionService.todaySteps) / 10000, 1))
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("%\(Int(min(Double(motionService.todaySteps) / 100, 100)))")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(width: 50, height: 50)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6)
        .padding(.horizontal)
    }
}

// Filtre butonu
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// Gezi kartı
struct TripCard: View {
    let trip: Trip
    
    var body: some View {
        HStack(spacing: 16) {
            // Durum ikonu
            Image(systemName: trip.status.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(.headline)
                Text(trip.destination)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(trip.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                
                Text("\(trip.duration) gün")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6)
    }
}

#Preview {
    HomeView()
}
