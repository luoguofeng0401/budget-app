//
//  ChatMessageView.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/20.
//

import SwiftUI

enum ChatMessageDirection {
    case left
    case right
}

struct ChatMessageView: View {
    
    let chatMessage: ChatMessage
    let direction: ChatMessageDirection
    let color: Color
    
    private func username8y(email: String) -> String {
        
        let components = email.split(separator: "@")
        
        guard let username = components.first else {
            return ""
        }
        
        return String(username)
        
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5){
                
                Text(username8y(email: chatMessage.email))
                    .opacity(0.8)
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text(chatMessage.text)
                Text(chatMessage.createdAt, format: .dateTime)
                    .font(.caption)
                    .opacity(0.4)
                    .frame(maxWidth: 200, alignment: .trailing)
            }
            .padding(8)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
        }
        .listRowSeparator(.hidden)
        .overlay(alignment: direction == .left ? .bottomLeading: .bottomTrailing) {
            Image(systemName: "arrowtriangle.down.fill")
                .font(.title)
                .rotationEffect(.degrees(direction == .left ? 45 : -45))
                .offset(x: direction == .left ? 30: -30, y: 10)
                .foregroundColor(color)
        }
    }
}

#Preview {
    ChatMessageView(chatMessage: ChatMessage(id: nil, text: "Hello Wprld!", userId: UUID(), email: "luoguofeng0401@gmail.com"), direction: .left, color: .blue)
}
