import SwiftUI
import PhotosUI

struct CreateItemView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var aiAssistant: AIAssistant
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var originalPrice = ""
    @State private var selectedCategory: ItemCategory = .other
    @State private var selectedCondition: ItemCondition = .good
    @State private var location = ""
    @State private var isNegotiable = true
    @State private var tags: [String] = []
    @State private var newTag = ""
    
    // Image handling
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    
    // AI assistance
    @State private var showingAIAnalysis = false
    @State private var gettingAIPrice = false
    
    // Navigation
    @State private var showingPreview = false
    @State private var isCreating = false
    
    var isFormValid: Bool {
        return !title.isEmpty &&
               !description.isEmpty &&
               !price.isEmpty &&
               Double(price) != nil &&
               !location.isEmpty &&
               !selectedImages.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Photo Section
                    photoSection
                    
                    // Basic Info Section
                    basicInfoSection
                    
                    // Pricing Section
                    pricingSection
                    
                    // Details Section
                    detailsSection
                    
                    // Tags Section
                    tagsSection
                    
                    // AI Analysis Section
                    if let analysis = aiAssistant.priceAnalysis {
                        aiAnalysisSection(analysis)
                    }
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .navigationBarHidden(true)
            .background(TexasTechTheme.lightGray.opacity(0.3))
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItems, matching: .images)
        .onChange(of: selectedPhotoItems) { _ in
            loadSelectedPhotos()
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                selectedImages.append(image)
            }
        }
        .actionSheet(isPresented: $showingImagePicker) {
            ActionSheet(
                title: Text("Add Photos"),
                buttons: [
                    .default(Text("Camera")) { showingCamera = true },
                    .default(Text("Photo Library")) { showingPhotoPicker = true },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingPreview) {
            ItemPreviewView(
                title: title,
                description: description,
                price: Double(price) ?? 0,
                category: selectedCategory,
                condition: selectedCondition,
                location: location,
                images: selectedImages,
                onPublish: createItem
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sell an Item")
                        .font(TexasTechTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Text("List your item for Texas Tech students")
                        .font(TexasTechTypography.caption1)
                        .foregroundColor(TexasTechTheme.mediumGray)
                }
                
                Spacer()
                
                Button("Clear") {
                    clearForm()
                }
                .textButton()
            }
        }
        .padding(.vertical, 16)
        .background(TexasTechTheme.white)
        .cornerRadius(12)
        .shadow(color: TexasTechTheme.cardShadow, radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photos")
                .font(TexasTechTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(TexasTechTheme.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Add photo button
                    Button(action: { showingImagePicker = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundColor(TexasTechTheme.primaryRed)
                            
                            Text("Add Photos")
                                .font(TexasTechTypography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(TexasTechTheme.primaryRed)
                        }
                        .frame(width: 120, height: 120)
                        .background(TexasTechTheme.primaryRed.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(TexasTechTheme.primaryRed, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        )
                    }
                    
                    // Selected images
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(12)
                            
                            Button(action: {
                                selectedImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(TexasTechTheme.white)
                                    .background(TexasTechTheme.primaryRed)
                                    .clipShape(Circle())
                            }
                            .padding(8)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            
            Text("Add up to 10 photos. First photo will be the cover image.")
                .font(TexasTechTypography.caption1)
                .foregroundColor(TexasTechTheme.mediumGray)
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(TexasTechTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(TexasTechTheme.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(TexasTechTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(TexasTechTheme.black)
                
                TextField("What are you selling?", text: $title)
                    .texasTechTextField()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(TexasTechTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(TexasTechTheme.black)
                
                TextField("Describe your item...", text: $description, axis: .vertical)
                    .lineLimit(4...8)
                    .texasTechTextField()
                
                Button("✨ Optimize with AI") {
                    optimizeDescription()
                }
                .textButton()
                .font(TexasTechTypography.caption1)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(TexasTechTheme.lightGray)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Condition")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(TexasTechTheme.lightGray)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pricing")
                    .font(TexasTechTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TexasTechTheme.black)
                
                Spacer()
                
                Button("🤖 Get AI Price") {
                    getAIPrice()
                }
                .textButton()
                .font(TexasTechTypography.caption1)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selling Price")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    TextField("$0.00", text: $price)
                        .keyboardType(.decimalPad)
                        .texasTechTextField()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original Price (Optional)")
                        .font(TexasTechTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TexasTechTheme.black)
                    
                    TextField("$0.00", text: $originalPrice)
                        .keyboardType(.decimalPad)
                        .texasTechTextField()
                }
            }
            
            Toggle("Price is negotiable", isOn: $isNegotiable)
                .font(TexasTechTypography.subheadline)
                .foregroundColor(TexasTechTheme.black)
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(TexasTechTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(TexasTechTheme.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Location (Dorm/Building)")
                    .font(TexasTechTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(TexasTechTheme.black)
                
                TextField("e.g., Wall/Gates Hall, Chitwood", text: $location)
                    .texasTechTextField()
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tags (Optional)")
                .font(TexasTechTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(TexasTechTheme.black)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Add a tag...", text: $newTag)
                        .texasTechTextField()
                    
                    Button("Add") {
                        addTag()
                    }
                    .primaryButton()
                }
                
                if !tags.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                    .font(TexasTechTypography.caption1)
                                
                                Button(action: {
                                    tags.removeAll { $0 == tag }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(TexasTechTheme.primaryRed.opacity(0.1))
                            .foregroundColor(TexasTechTheme.primaryRed)
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - AI Analysis Section
    private func aiAnalysisSection(_ analysis: AIAssistant.PriceAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(TexasTechTheme.primaryRed)
                Text("AI Price Analysis")
                    .font(TexasTechTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(TexasTechTheme.black)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Suggested Price:")
                        .font(TexasTechTypography.subheadline)
                        .foregroundColor(TexasTechTheme.mediumGray)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", analysis.suggestedPrice))")
                        .font(TexasTechTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TexasTechTheme.primaryRed)
                }
                
                Button("Use This Price") {
                    price = String(format: "%.2f", analysis.suggestedPrice)
                }
                .secondaryButton()
                
                Text(analysis.reasoning)
                    .font(TexasTechTypography.caption1)
                    .foregroundColor(TexasTechTheme.mediumGray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .texasTechCard()
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button("Preview Listing") {
                showingPreview = true
            }
            .secondaryButton()
            .disabled(!isFormValid)
            
            Button("Publish Item") {
                createItem()
            }
            .primaryButton()
            .disabled(!isFormValid || isCreating)
            
            if isCreating {
                ProgressView("Creating listing...")
                    .progressViewStyle(CircularProgressViewStyle(tint: TexasTechTheme.primaryRed))
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Helper Functions
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        originalPrice = ""
        selectedCategory = .other
        selectedCondition = .good
        location = ""
        isNegotiable = true
        tags = []
        selectedImages = []
    }
    
    private func addTag() {
        guard !newTag.isEmpty, !tags.contains(newTag) else { return }
        tags.append(newTag)
        newTag = ""
    }
    
    private func getAIPrice() {
        guard !title.isEmpty || !description.isEmpty else { return }
        
        Task {
            await aiAssistant.analyzePriceForItem(
                title: title,
                description: description,
                condition: selectedCondition,
                category: selectedCategory
            )
        }
    }
    
    private func optimizeDescription() {
        Task {
            let optimized = await aiAssistant.optimizeItemDescription(
                description,
                title: title,
                category: selectedCategory
            )
            
            await MainActor.run {
                description = optimized
            }
        }
    }
    
    private func loadSelectedPhotos() {
        Task {
            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        selectedImages.append(image)
                    }
                }
            }
            await MainActor.run {
                selectedPhotoItems.removeAll()
            }
        }
    }
    
    private func createItem() {
        guard let currentUser = authManager.currentUser,
              let priceValue = Double(price) else { return }
        
        isCreating = true
        
        let newItem = Item(
            title: title,
            description: description,
            price: priceValue,
            category: selectedCategory,
            condition: selectedCondition,
            sellerID: currentUser.id ?? "",
            sellerName: currentUser.fullName,
            location: location,
            imageURLs: []
        )
        
        Task {
            let success = await itemStore.createItem(newItem, images: selectedImages)
            
            await MainActor.run {
                isCreating = false
                if success {
                    clearForm()
                    // Show success message or navigate
                }
            }
        }
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Item Preview View

struct ItemPreviewView: View {
    let title: String
    let description: String
    let price: Double
    let category: ItemCategory
    let condition: ItemCondition
    let location: String
    let images: [UIImage]
    let onPublish: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Preview header
                    Text("Preview your listing as others will see it")
                        .font(TexasTechTypography.body)
                        .foregroundColor(TexasTechTheme.mediumGray)
                        .padding(.horizontal, 20)
                    
                    // Item preview (similar to ItemCard)
                    VStack(alignment: .leading, spacing: 16) {
                        if let firstImage = images.first {
                            Image(uiImage: firstImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title)
                                .font(TexasTechTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TexasTechTheme.black)
                            
                            Text("$\(String(format: "%.2f", price))")
                                .font(TexasTechTypography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(TexasTechTheme.primaryRed)
                            
                            HStack {
                                Text(condition.rawValue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(condition.color).opacity(0.1))
                                    .foregroundColor(Color(condition.color))
                                    .cornerRadius(6)
                                
                                Text(category.rawValue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(TexasTechTheme.primaryRed.opacity(0.1))
                                    .foregroundColor(TexasTechTheme.primaryRed)
                                    .cornerRadius(6)
                            }
                            .font(TexasTechTypography.caption1)
                            
                            Text(description)
                                .font(TexasTechTypography.body)
                                .foregroundColor(TexasTechTheme.black)
                                .lineSpacing(4)
                            
                            Text("📍 \(location)")
                                .font(TexasTechTypography.caption1)
                                .foregroundColor(TexasTechTheme.mediumGray)
                        }
                        .padding(.horizontal, 16)
                    }
                    .texasTechCard()
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Publish") {
                    onPublish()
                    presentationMode.wrappedValue.dismiss()
                }
                .primaryButton()
            )
        }
    }
}

#Preview {
    CreateItemView()
        .environmentObject(ItemStore())
        .environmentObject(AuthenticationManager())
        .environmentObject(AIAssistant())
} 