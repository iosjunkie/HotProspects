//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Jules Lee on 1/31/20.
//  Copyright © 2020 Jules Lee. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}

enum SortType {
    case name, recent
}

struct ProspectsView: View {
    let filter: FilterType
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSort = false
    @State private var sortMode = SortType.name

    var body: some View {
        NavigationView {
            List {
                ForEach(sortMode == .name ? filteredProspects.sorted {
                    $0.name > $1.name
                    } : filteredProspects.sorted {
                    $0.createdAt > $1.createdAt
                }) { prospect in
                    HStack {
                        Image(systemName: prospect.isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle")
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted" ) {
                            self.prospects.add(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
                .navigationBarTitle(title)
            .navigationBarItems(leading: Button(action: {
                    self.isShowingSort = true
                }) {
                Image(systemName: "line.horizontal.3.decrease.circle")
                },
                trailing: Button(action: {
                    self.isShowingScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: self.handleScan)
        }
        .actionSheet(isPresented: $isShowingSort) {
            ActionSheet(title: Text("How do you want to sort it out?"), message: Text("Choose an option"), buttons: [
                .default(Text("By Name"), action: {
                    self.sortMode = .name
                    self.isShowingSort = false
                }), .default(Text("By Most Recent"), action: {
                    self.sortMode = .recent
                    self.isShowingSort = false
                })])

        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
       // more code to come
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]

            self.prospects.add(person)
        case .failure( _):
            print("Scanning failed")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        // more code to come
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)

    }
}
