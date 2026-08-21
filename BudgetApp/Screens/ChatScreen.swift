//
//  ChatScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/20.
//

import SwiftUI
import Supabase

struct UserStatus: Identifiable, Codable {
    
    let id: UUID
    let userId: UUID
    let username: String
    var online: Bool
    
    init(id: UUID = UUID(), userId: UUID, username: String, online: Bool) {
        self.id = id
        self.userId = userId
        self.username = username
        self.online = online
    }
}

struct ChatScreen: View {
    @Environment(\.supabaseClient) private var supabaseClient
    @State private var chatMessages: [ChatMessage] = []
    @State private var chatMessageText: String = ""
    @State private var userStatusus: [UserStatus] = []
    @State private var channel: RealtimeChannelV2?
    

    
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
    
    private func handlePresenceChange(isJoining: Bool, presenceValue: PresenceV2) {
        
        guard let userIdString = presenceValue.state["userId"]?.stringValue,
              let userId = UUID(uuidString: userIdString) else { return }
        
                
                
        let username = presenceValue.state["username"]?.stringValue ?? "Anonymous"
        
        if isJoining {
            if !userStatusus.contains(where: { $0.username == username }) {
                userStatusus.append(UserStatus(userId: userId, username: username, online: true))
            } else {
                if let index = userStatusus.firstIndex(where: { $0.userId == userId }) {
                    userStatusus[index].online = true
                }
            }
        } else {
            if let index = userStatusus.firstIndex(where: { $0.username == username }) {
                userStatusus[index].online = false
            }
//            userStatusus.removeAll() { $0.username == username }
        }
    }
    
    private func handlePresenceStream(_ presenceStream: AsyncStream<any PresenceAction>) async {
        
        for await presence in presenceStream {
            if let presenceValue = presence.joins.values.first {
                handlePresenceChange(isJoining: true, presenceValue: presenceValue)
            }

            if let presenceValue = presence.leaves.values.first {
                handlePresenceChange(isJoining: false, presenceValue: presenceValue)
            }
        }
    }
    
    
    private func handleChatChanges(_ changeStream: AsyncStream<AnyAction>) async {
        for await change in changeStream {
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
    
    private func configureSubscriptions() async throws {
        
        let channel = supabaseClient.channel("general")
        self.channel = channel
        let presenceScreen = channel.presenceChange()
        
        let changeStream = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "chats"
        )
        
        let user = try await supabaseClient.auth.user()
        guard let email = user.email else { return }
        
        let  userStatus = UserStatus(userId: user.id, username: email.username, online: true)
        
        await channel.subscribe()
        
        try await channel.track(userStatus)
        
        async let presenceTask: Void = handlePresenceStream(presenceScreen)
        async let changeTask: Void = handleChatChanges(changeStream)
        
        _ = await(presenceTask, changeTask)
    }
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                UserStatusListView(userStatuses: userStatusus)
                ChatMessageListView(chatMessages: chatMessages)
                    .onChange(of: chatMessages) {
                        if !chatMessages.isEmpty {
                            let lastChatMessage = chatMessages[chatMessages.endIndex - 1]
                            withAnimation {
                                proxy.scrollTo(lastChatMessage.id, anchor: .bottom)
                            }
                        }
                    }
                
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
                try await configureSubscriptions()
            } catch {
                print(error)
            }
        }.onDisappear(perform: {
            Task {
                await channel?.untrack()
                await channel?.unsubscribe()
            }
        })
    }
}

#Preview {
    NavigationStack {
        ChatScreen()
    }
    .environment(\.supabaseClient, .development)
}
