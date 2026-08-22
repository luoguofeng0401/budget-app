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
    @Environment(\.authClient) private var authClient
    @Environment(ExpenseTrackerStore.self) private var store

    @State private var selectedTags: Set<Tag> = []
    @State private var errorMessage: String?

    private func uploadReceipt() async throws -> String? {

        guard let uiImage = uiImage,
              let resizedImage = uiImage.resizeTo(to: CGSize(width: 300, height: 300)),
              let imageData = resizedImage.pngData()
                else {
            return nil
        }

        guard let userID = authClient.currentUser?.id else { return nil }

        // Store receipts in a per-user folder so uploads satisfy the
        // storage RLS policy: (storage.foldername(name))[1] = auth.uid()
        let path = "\(userID.uuidString.lowercased())/\(UUID().uuidString)"

        let options = FileOptions(
            cacheControl: "3600",
            contentType: "image/png",
            upsert: false
        )

        return try await storageClient.upload(data: imageData, path: path, options: options)

    }

    private func saveExpense() async {


        do {
            let receiptPath = try await uploadReceipt()

            guard let amount = amount,
                  let budgetID = budget.id
                    else{ return }

            let expense = Expense(name: name, amount: amount, budgetId: budgetID, receiptPath: receiptPath)


            try await store.addExpense(expense: expense, tags: Array(selectedTags))
            dismiss()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }

    }
    
    var body: some View {
        Form {
            TextField("Enter name", text: $name)
            TextField("Enter limit", value: $amount, format: .number)
            
            AddTagsView(tags: store.tags, selectedTags: $selectedTags, onTagAdded: store.createTag)
            
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
        .task {
            do {
                try await store.loadTags()
            } catch {
                print(error)
            }
        }
        .task(id: saving, {
            if saving {
                await saveExpense()
                saving = false
            }
        })
        .sheet(isPresented: $isCameraSelected, content: {
            ImagePicker(image: $uiImage, sourceType: .camera)

        })
        .alert("Unable to Save", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if saving {
                    ProgressView()
                } else {
                    Button("Save") {
                        saving = true
                    }
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
