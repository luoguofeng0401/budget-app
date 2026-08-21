//
//  ChatMessageListView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/20.
//

import SwiftUI
import Supabase

struct ChatMessageListView: View {
    
    let chatMessages: [ChatMessage]
    @Environment(\.supabaseClient) private var supabaseClient
    
    private func isChatMessageFromCurrentUser(_ chatMessage: ChatMessage) -> Bool {
        
        guard let currentUser = supabaseClient.auth.currentUser else {
            return false
        }
        
        return currentUser.id == chatMessage.userId
    }
        
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(chatMessages) { chatMessage in
                    VStack {
                        if isChatMessageFromCurrentUser(chatMessage) {
                            HStack {
                                Spacer()
                                ChatMessageView(chatMessage: chatMessage, direction: .right, color: .blue)
                            }
                            
                        } else {
                            HStack {
                                ChatMessageView(chatMessage: chatMessage, direction: .left, color: .gray)
                                Spacer()
                            }
                        }
                        Spacer().frame(height: 40)
                    }
                    .id(chatMessage.id)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.bottom)
    }
}

#Preview {
    ChatMessageListView(chatMessages: [ChatMessage(text: "Hello World", userId: UUID(uuidString: "9d152e03-4b67-44d3-beaf-c9ad5927dbf8")!, email: "luoguofeng0401@gmail.com.tw")])
        .environment(\.supabaseClient, .development)
}
