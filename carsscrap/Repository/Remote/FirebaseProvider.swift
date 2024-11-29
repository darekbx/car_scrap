//
//  FirebaseProvider.swift
//  carsscrap
//
//  Created by Dariusz Baranczuk on 28/11/2024.
//

import Foundation

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class FirebaseProvider: ObservableObject {
    
    func fetch() async throws -> [CarModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if await authenticate() == false {
            print("Failed to authenticate!")
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let db = Firestore.firestore()
            let docRef = db.collection("cars")//.limit(to: 2)
            docRef.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Fetch error: \(error)")
                    return
                }
                let documents = snapshot?.documents
                print("Firebase documents count: \(documents?.count ?? -1)")
                let data = snapshot?.documents.compactMap { document in
                    return CarModel(from: document, formatter: formatter)
                } ?? []
                print("Firebase fetched count: \(data.count)")
                continuation.resume(returning: data)
            }
        }
    }
    
    private func authenticate() async -> Bool {
        guard
            let email = ProcessInfo.processInfo.environment["FIREBASE_EMAIL"],
            let password = ProcessInfo.processInfo.environment["FIREBASE_PASSWORD"]
        else {
            return false
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return true
        } catch {
            return false
        }
    }
}
