//
//  Prospect.swift
//  HotProspects
//
//  Created by Jules Lee on 1/31/20.
//  Copyright © 2020 Jules Lee. All rights reserved.
//

import SwiftUI



class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var createdAt = Date()
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    static let saveKey = "SavedData"

    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filename = paths[0].appendingPathComponent(Self.saveKey)
        do {
            let data = try Data(contentsOf: filename)
            people = try JSONDecoder().decode([Prospect].self, from: data)
            print(people)
        } catch {
            print("Unable to load saved data.")
        }
        
//        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                self.people = decoded
//                return
//            }
//        }

        self.people = []
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        do {
            let filename = paths[0].appendingPathComponent(Self.saveKey)
            let data = try JSONEncoder().encode(people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data")
        }
//        if let encoded = try? JSONEncoder().encode(people) {
//            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
//        }
    }
}
