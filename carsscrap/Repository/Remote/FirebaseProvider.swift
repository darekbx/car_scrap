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

class FirebaseProvider {
    
    func count() async {
        authenticate {
            let db = Firestore.firestore()
            let docRef = db
                .collection("metadata")
                .document("ids")
            docRef.getDocument { [weak self] (snapshot, error) in
                guard let snapshot else { return }
                let ids = snapshot.get("ids")
                print(ids)
            }
        }
    }
    
    private func authenticate(_ authenticated: @escaping () -> Void) {
        let email = ProcessInfo.processInfo.environment["FIREBASE_EMAIL"]
        let password = ProcessInfo.processInfo.environment["FIREBASE_PASSWORD"]
        if let email = email, let password = password {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if result?.user != nil {
                    authenticated()
                } else if let error = error {
                    print("Authentication failed '\(error)'!")
                }
            }
        }
    }
}
