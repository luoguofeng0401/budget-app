//
//  AddExpenseScreen.swift
//  BudgetApp
//
//  Created by Guofeng Luo on 2026/8/18.
//

import SwiftUI
import PhotosUI
import Supabase

struct AddExpenseScreen: View {
    
    let budget: Budget
    
    @State private var name: String = ""
    @State private var amount: Double?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var uiImage: UIImage?
    @State private var isCameraSelected: Bool = false
    @State private var saving: Bool = false
     
    @Environment(\.dismiss) private var dismiss
    @Environment(\.storageClient) private var storageClient
    @Environment(ExpenseTrackerStore.self) private var store
    
    private func saveExpense() async {
        
        var receiptPath: String?
        
        if let uiImage {
            
            guard let resizedImage = uiImage.resizeTo(to: CGSize(width: 300, height: 300)),
                  let imageData = resizedImage.pngData()
                    else { return }
            
            let uniqueFileName = UUID().uuidString
            
            do {
                let response = try await storageClient
                    .from("receipts")
                    .upload(
                        path: "private/\(uniqueFileName)",
                        file: imageData,
                        options: FileOptions(
                            cacheControl: "3600",
                            contentType: "image/png",
                            upsert: false
                        )
                    )
                receiptPath = response.path
            } catch {
                print(error)
            }
            
        }
        
        
        guard let amount = amount,
              let budgetID = budget.id
                else{ return }
        
        let expense = Expense(name: name, amount: amount, budgetId: budgetID, receiptPath: receiptPath)
        
        do {
            try await store.addExpense(expense)
            dismiss()
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        Form {
            TextField("Enter name", text: $name)
            TextField("Enter limit", value: $amount, format: .number)
            
            HStack {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text("Select a Photo")
                }
                
                Button("Camera") {
                    isCameraSelected = true
                }
                .buttonStyle(.bordered)
            }
            
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            }
        }
        .onChange(of: selectedPhotoItem, {
            
            selectedPhotoItem?.loadTransferable(type: Data.self, completionHandler: { result in
                switch result {
                case .success(let data):
                    if let data {
                        guard let img = UIImage(data: data) else { return }
                        uiImage = img
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            })
        })
        .task(id: saving, {
            if saving {
                await saveExpense()
                saving = false
            }
        })
        .sheet(isPresented: $isCameraSelected, content: {
            ImagePicker(image: $uiImage, sourceType: .camera)
            
        })
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saving = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        AddExpenseScreen(budget: Budget(id: 9, name: "Hiiiii", limit: 350, userID: UUID()))
            .environment(ExpenseTrackerStore(supabaseClient: .development )) 
    }
}
