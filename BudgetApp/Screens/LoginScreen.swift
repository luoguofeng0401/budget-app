//
//  LoginScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/19.
//

import SwiftUI
import Auth

struct LoginScreen: View {
    
    @Environment(\.authClient) private var authClient
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isRegisterpresented: Bool = false
    
    private var isFormValid: Bool {
        !password.isEmptyOrWhiteSpace && !email.isEmpty
    }
    
    private func login() async {
        do {
            try await authClient.signIn(email: email, password: password)
            print("Login Success!")
        } catch let error as Auth.AuthError {
            switch error {
            case .api(let message, _, _, _):
                self.errorMessage = message
            default:
                self.errorMessage = "Authentication Error \(error)"
            }
        }  catch {
            self.errorMessage = "Authentication failed \(error)"
        }
    }
    var body: some View {
        Form {
            TextField("Enter email", text: $email)
                .textInputAutocapitalization(.never)
            SecureField("Enter password", text: $password)
            HStack {
                Button("Login") {
                    Task {
                        await login()
                    }
                }
                .disabled(!isFormValid)
                
                Spacer()
                
                Button("Register") {
                    isRegisterpresented = true
                }
            }
            .buttonStyle(.borderless)
            
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .navigationTitle("Login")
        .sheet(isPresented: $isRegisterpresented, content: {
            NavigationStack {
                RegisterScreen()
            }
        })
            
    }
}

#Preview {
    LoginScreen()
        .environment(\.authClient, .development)
}
