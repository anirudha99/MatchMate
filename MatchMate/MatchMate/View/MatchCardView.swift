//
//  MatchCardView.swift
//  MatchMate
//
//  Created by Anirudha SM on 15/12/24.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage

struct MatchCardView: View {
    @State var profile: UserProfile
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack {
            // Profile Image
            WebImage(url: URL(string: profile.imageURL))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.bottom, 10)

            // Name, Age, and Location
            VStack(spacing: 5) {
                Text(profile.name)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Age: \(profile.age) • \(profile.location)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)

            // Accept and Decline Buttons
            HStack(spacing: 40) {
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(Circle())
                }

                Button(action: onDecline) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 10)

            // Display Status if not Pending
            if profile.status != .pending {
                Text("Status: \(profile.status.rawValue)")
                    .font(.headline)
                    .foregroundColor(profile.status == .accepted ? .green : .red)
                    .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}


#Preview {
    MatchCardView(profile: UserProfile(name: "Sam", age: 35, location: "Bengaluru, Karnataka", imageURL: "https://picsum.photos/200/300", status: .pending), onAccept: {}, onDecline: {})
}
