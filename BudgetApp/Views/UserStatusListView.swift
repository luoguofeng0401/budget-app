//
//  UserStatusListView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/21.
//

import SwiftUI

struct UserStatusListView: View {
    
    let userStatuses: [UserStatus]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(userStatuses) { userStatus in
                    Text(userStatus.username)
                        .font(.caption2)
                        .padding(5)
                        .background(userStatus.online ? .green: .red)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    UserStatusListView(userStatuses: [UserStatus(userId: UUID(), username: "Leo", online: true), UserStatus(userId: UUID(), username: "Rex", online: false)])
}
