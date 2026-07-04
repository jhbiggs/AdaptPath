//
//  AccommodationAPI.swift
//  AdaptPath
//
//  Created by Justin Biggs on 6/20/26.
//

import Foundation
internal import Combine

class AccommodationAPI: ObservableObject {
    @Published var recommendations: [Accommodation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var errorResetTimer: Timer?
    
    struct Accommodation: Identifiable {
        let id = UUID()
        let name: String
        let confidence: Double
        
        var confidencePercent: String{
            String(format: "%.0f%%", confidence * 100)
        }
    }
    
    func predictAccommodations(
        grade: Int,
        diagnosis: String,
        reading: Int,
        math: Int,
        attention: Int,
        social: Int,
        motor: Int
    ) {
        isLoading = true
        errorMessage = nil
        recommendations = []
        errorResetTimer?.invalidate() // Clear any existent timer
        
        let url = URL(string: "http://192.168.1.109:5001/predict")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "grade": grade,
            "diagnosis": diagnosis,
            "reading": reading,
            "math": math,
            "attention": attention,
            "social": social,
            "motor": motor
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    self?.scheduleErrorReset()
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    self?.scheduleErrorReset()
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AccommodationResponse.self, from:data)
                    
                    if response.success {
                        self?.recommendations = response.accommodations.map { acc in
                            let name: String
                            if case .string(let str) = acc[0] {
                                name = str
                            } else {
                                name = ""
                            }
                            
                            let confidence: Double
                            if case .double(let dbl) = acc[1] {
                                confidence = dbl
                            } else {
                                confidence = 0.0
                            }
                            
                            return Accommodation(name: name, confidence: confidence)
                        }
                    } else {
                        self?.errorMessage = response.error ?? "API error"
                        self?.scheduleErrorReset()
                    }
                } catch {
                    self?.errorMessage  = "Decoding error: \(error.localizedDescription)."
                    self?.scheduleErrorReset()
                }
            }
        }.resume()
    }
    
    private func scheduleErrorReset() {
        errorResetTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.errorMessage = nil
        }
    }
}
