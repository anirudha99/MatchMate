//
//  ContentView.swift
//  MatchMate
//
//  Created by Anirudha SM on 15/12/24.
//

import SwiftUI
import CoreData

// MARK: - Main View
struct ContentView: View {
    @StateObject private var viewModel = MatchViewModel(context: PersistenceController.shared.container.viewContext)

    var body: some View {
        NavigationView {
            List(viewModel.profiles) { profile in
                MatchCardView(profile: profile, onAccept: {
                    viewModel.updateProfileStatus(profile, status: .accepted)
                }, onDecline: {
                    viewModel.updateProfileStatus(profile, status: .declined)
                })
            }
            .navigationTitle("MatchMate")
            .onAppear {
                viewModel.fetchProfiles()
            }
        }
    }
}


#Preview {
    ContentView()
}
