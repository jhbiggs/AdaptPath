//
//  ContentView.swift
//  AdaptPath
//
//  Created by Justin Biggs on 5/17/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var api = AccommodationAPI()
    
    @State private var grade = 3
    @State private var diagnosis = "ADHD"
    @State private var reading = 2
    @State private var math = 2
    @State private var attention = 1
    @State private var social = 2
    @State private var motor = 3
    @State private var showRecommendations = false
    
    let diagnoses = ["ADHD", "Dyslexia", "Dyscalculia", "Autism"]
    let grades = [1, 2, 3, 4, 5]
    let skillLevels = [1,2,3]
    
    var body: some View {
        NavigationStack {
            Group {
                if showRecommendations && !api.recommendations.isEmpty {
                    RecommendationsView(recommendations: api.recommendations, showRecommendations: $showRecommendations)
                } else {
                    Form {
                        Section("Student Information") {
                            Picker("Grade", selection: $grade) {
                                ForEach(grades, id: \.self) { g in
                                    Text("Grade \(g)").tag(g)
                                }
                            }
                            
                            Picker("Primary Diagnosis", selection: $diagnosis) {
                                ForEach(diagnoses, id: \.self) { d in
                                    Text(d).tag(d)
                                }
                            }
                        }
                        
                        Section("Academic Skills") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Reading Fluency")
                                    Spacer()
                                    Picker("", selection: $reading) {
                                        Text("Low").tag(1)
                                        Text("Average").tag(2)
                                        Text("Above Average").tag(3)
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                HStack {
                                    Text("Math Skill")
                                    Spacer()
                                    Picker("", selection: $math){
                                        Text("Low").tag(1)
                                        Text("Average").tag(2)
                                        Text("Above Average").tag(3)
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                        
                        Section("Behavioral & Physical") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Attention Level")
                                    Spacer()
                                    Picker("", selection: $attention) {
                                        Text("Low").tag(1)
                                        Text("Average").tag(2)
                                        Text("Above Average").tag(3)
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                HStack {
                                    Text("Social Skills")
                                    Spacer()
                                    Picker("", selection: $social) {
                                        Text("Low").tag(1)
                                        Text("Average").tag(2)
                                        Text("Above Average").tag(3)
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                HStack {
                                    Text("Motor Skills")
                                    Spacer()
                                    Picker("", selection: $motor) {
                                        Text("Low").tag(1)
                                        Text("Average").tag(2)
                                        Text("Above Average").tag(3)
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                        
                        Section {
                            Button(action: {
                                api.predictAccommodations(grade: grade, diagnosis: diagnosis, reading: reading, math: math, attention: attention, social: social, motor: motor)
                            }) {
                                if api.isLoading {
                                    HStack {
                                        ProgressView()
                                        Text("Predicting...")
                                    }
                                } else {
                                    Text("Get Recommendations")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .disabled(api.isLoading)
                        }
                    }
                }
            }
            .onChange(of: api.recommendations.count) { oldValue, newValue in
                if newValue > 0 {
                    showRecommendations = true
                }
            }
            .navigationTitle("AdaptPath")
        }
    }
}

struct RecommendationsView: View {
    let recommendations: [AccommodationAPI.Accommodation]
    @Binding var showRecommendations: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    showRecommendations = false
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Recommended Accommodations")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(recommendations) { accommodation in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(accommodation.name)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text("Confidence: \(accommodation.confidencePercent)")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                
                                Text(accommodation.confidencePercent)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            }
                            .frame(width: 50, height: 50)
                        }
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
}


#Preview {
    ContentView()
}
