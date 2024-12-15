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
            ScrollView {
                VStack(spacing: 16) { // Add spacing between cards
                    ForEach(viewModel.profiles) { profile in
                        VStack {
                            MatchCardView(
                                profile: profile,
                                onAccept: {
                                    viewModel.updateProfileStatus(profile, status: .accepted)
                                },
                                onDecline: {
                                    viewModel.updateProfileStatus(profile, status: .declined)
                                }
                            )
                            Spacer(minLength: 16)
                            
                            // Custom Divider
                            if profile.id != viewModel.profiles.last?.id {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding()
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
