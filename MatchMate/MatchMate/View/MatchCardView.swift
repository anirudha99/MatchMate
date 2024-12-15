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
    let profile: UserProfile
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                WebImage(url: URL(string: profile.imageURL))
                    .resizable()
//                    .placeholder(Image(systemName: "person.fill"))
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(profile.name)
                        .font(.headline)
                    Text("Age: \(profile.age)")
                    Text(profile.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            HStack {
                Button(action: onAccept) {
                    Text("Accept")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: onDecline) {
                    Text("Decline")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 10)

            if profile.status != .pending {
                Text("Status: \(profile.status.rawValue)")
                    .font(.footnote)
                    .foregroundColor(profile.status == .accepted ? .green : .red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
        .padding(.horizontal)
    }
}
