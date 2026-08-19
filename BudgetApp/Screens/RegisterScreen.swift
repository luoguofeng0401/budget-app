//
//  RegisterScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI
import Auth

struct RegisterScreen: View {
    
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var errorMessage: String?
    @State private var isSignedUP: Bool = false
    
    @Environment(\.authClient) private var authClient
    @Environment(\.dismiss) private var dismiss
    
    private func register() async {
        do {
            let _ = try await authClient.signUp(email: email, password: password)
            isSignedUP = true
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
    
    private var isFormValid: Bool {
        !password.isEmptyOrWhiteSpace && email.isEmail
    }
    
    var body: some View {
        Form {
            TextField("Enter email", text: $email)
            SecureField("Enter password", text: $password)
            Button("Register") {
                Task {
                    await register()
                }
            }
            .disabled(!isFormValid)
            
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .alert("Your account has been created successfully", isPresented: $isSignedUP) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
        .navigationTitle("Register")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterScreen()
    }
    .environment(\.authClient, .development)
}
