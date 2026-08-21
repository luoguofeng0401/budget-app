//
//  ChatScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/20.
//

import SwiftUI
import Supabase



struct ChatScreen: View {
    @Environment(\.supabaseClient) private var supabaseClient
    @State private var chatMessages: [ChatMessage] = []
    @State private var chatMessageText: String = ""
    
    private func saveChatMessage() async {
        
        do {
            let user =  try await supabaseClient.auth.user()
            guard let email = user.email else { return }
            
            let chatMessage = ChatMessage(text: chatMessageText, userId: user.id, email: email)
            
            try await supabaseClient
                .from("chats")
                .insert(chatMessage)
                .execute()
            
            chatMessageText = ""
            
        } catch {
            print(error)
        }
    }
    
    private func loadChatMessages() async throws {
        
        chatMessages = try await supabaseClient
            .from("chats")
            .select()
            .execute()
            .value
        
        print(chatMessages)
    }
    
    private func handleInsertChatMessage(_ record: [String: AnyJSON]) async {
        
        guard let id = record["id"]?.intValue,
              let text = record["text"]?.stringValue,
              let userIdString = record["user_id"]?.stringValue,
              let email = record["email"]?.stringValue,
              let userId = UUID(uuidString: userIdString)
        else {
            print("Error: Missing required fields or incorrect types in inserted record")
            return
        }
        
        let chatMessage = ChatMessage(id: id, text: text, userId: userId, email: email)
        await MainActor.run {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                chatMessages.append(chatMessage)
            }
        }
    }
    
    private func configureChannelSubscription() async {
        
        let channel = await supabaseClient.channel("general")
        
        let channelStream = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "chats"
        )
        
        await channel.subscribe()
        
        for await change in channelStream {
            switch change {
            case .delete(let action):
                print("Deleted: \(action.oldRecord)")
            case .insert(let action):
                await handleInsertChatMessage(action.record)
                print("Inserted: \(action.record)")
//            case .select(let action):
//                print("Selected: \(action.record)")
            case .update(let action):
                print("Updated: \(action.record)")
            }
        }
    }
    var body: some View {
        VStack {
            if chatMessages.isEmpty {
                ContentUnavailableView("No messages yet", systemImage: "bubble.left.and.bubble.right")
            } else {
                ChatMessageListView(chatMessages: chatMessages)
            }
        }
        .padding()
        .navigationTitle("General")
        .safeAreaInset(edge: .bottom) {
            TextField("Enter chat message", text: $chatMessageText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    Task {
                        await saveChatMessage()
                    }
                }
                .padding()
                .background(.bar)
        }
        .task {
            do {
                try await loadChatMessages()
                await configureChannelSubscription()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatScreen()
    }
    .environment(\.supabaseClient, .development)
}
