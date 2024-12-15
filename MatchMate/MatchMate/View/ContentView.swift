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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.6), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) { // Add spacing between cards
                        ForEach(viewModel.profiles) { profile in
                            VStack {
                                MatchCardView(
                                    profile: $viewModel.profiles[viewModel.profiles.firstIndex(where: { $0.id == profile.id })!],
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MatchMate")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
            }
            .onAppear {
                viewModel.fetchProfiles()
            }
        }
    }
}


#Preview {
    ContentView()
}
