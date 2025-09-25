import SwiftUI
import UIKit
import Combine
#if canImport(Supabase)
import Supabase
#endif

// MARK: - Models
struct Recipe: Codable, Identifiable {
    var id = UUID()
    let title: String
    let ingredients: [String]
    let instructions: [String]
    
    // Custom initializer to handle missing id in JSON
    init(title: String, ingredients: [String], instructions: [String]) {
        self.id = UUID()
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
    }
    
    // Custom CodingKeys to exclude id from encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case title
        case ingredients
        case instructions
    }
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    
    var identifer: String {
        return id
    }
}

struct AuthCredentials: Codable {
    let email: String
    let password: String
}

struct Profile: Codable {
    let id: String // Corresponds to user.id
    var extractionCount: Int
    let subscriptionStatus: String // 'free' or 'active'
}

// MARK: - Recipe Export Format
enum RecipeFormat: String, CaseIterable {
    case text = "Text"
    case markdown = "Markdown"
    case html = "HTML"
    case json = "JSON"

    var displayName: String {
        return self.rawValue
    }

    var fileExtension: String {
        switch self {
        case .text: return "txt"
        case .markdown: return "md"
        case .html: return "html"
        case .json: return "json"
        }
    }
}

// MARK: - Utils
class ImageUtils {
    static func convertToBase64(image: UIImage) -> (base64: String, mimeType: String)? {
        // Try JPEG first
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            let base64String = jpegData.base64EncodedString()
            return (base64String, "image/jpeg")
        }

        // Try PNG if JPEG failed
        if let pngData = image.pngData() {
            let base64String = pngData.base64EncodedString()
            return (base64String, "image/png")
        }

        return nil
    }
}

class RecipeFormatter {
    static func formatRecipe(_ recipe: Recipe, as format: RecipeFormat) -> String {
        switch format {
        case .text:
            return formatAsText(recipe)
        case .markdown:
            return formatAsMarkdown(recipe)
        case .html:
            return formatAsHTML(recipe)
        case .json:
            return formatAsJSON(recipe)
        }
    }

    private static func formatAsText(_ recipe: Recipe) -> String {
        var output = "\(recipe.title)\n\n"

        output += "INGREDIENTS:\n"
        for (index, ingredient) in recipe.ingredients.enumerated() {
            output += "\(index + 1). \(ingredient)\n"
        }

        output += "\nINSTRUCTIONS:\n"
        for (index, instruction) in recipe.instructions.enumerated() {
            output += "\(index + 1). \(instruction)\n"
        }

        return output
    }

    private static func formatAsMarkdown(_ recipe: Recipe) -> String {
        var output = "# \(recipe.title)\n\n"

        output += "## Ingredients\n\n"
        for (index, ingredient) in recipe.ingredients.enumerated() {
            output += "\(index + 1). \(ingredient)\n"
        }

        output += "\n## Instructions\n\n"
        for (index, instruction) in recipe.instructions.enumerated() {
            output += "\(index + 1). \(instruction)\n"
        }

        return output
    }

    private static func formatAsHTML(_ recipe: Recipe) -> String {
        var output = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(recipe.title)</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
                h1 { color: #8B4513; border-bottom: 2px solid #8B4513; padding-bottom: 10px; }
                h2 { color: #CD853F; margin-top: 30px; }
                ol { padding-left: 20px; }
                li { margin-bottom: 8px; line-height: 1.5; }
            </style>
        </head>
        <body>
            <h1>\(recipe.title)</h1>

            <h2>Ingredients</h2>
            <ol>
        """

        for ingredient in recipe.ingredients {
            output += "        <li>\(ingredient)</li>\n"
        }

        output += """
            </ol>

            <h2>Instructions</h2>
            <ol>
        """

        for instruction in recipe.instructions {
            output += "        <li>\(instruction)</li>\n"
        }

        output += """
            </ol>
        </body>
        </html>
        """

        return output
    }

    private static func formatAsJSON(_ recipe: Recipe) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let jsonData = try encoder.encode(recipe)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding recipe to JSON: \(error)")
        }

        return "{\"error\": \"Failed to encode recipe as JSON\"}"
    }
}

class ClipboardUtils {
    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    static func showCopyFeedback() {
        // Generate haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Services
class GeminiService {
    static let shared = GeminiService()
    
    private init() {}
    
    func extractRecipeFromImage(base64Image: String, mimeType: String) async throws -> Recipe {
        guard let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
            throw RecipeExtractionError.missingAPIKey
        }
        
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!
        
        let requestBody: [String: Any] = [
            "contents": [
                "parts": [
                    [
                        "text": "Analyze this image of a handwritten recipe. Extract the title, a complete list of ingredients, and all preparation instructions. Ensure the output is well-structured and follows the provided JSON schema. If the handwriting is unclear, make your best guess."
                    ],
                    [
                        "inlineData": [
                            "mimeType": mimeType,
                            "data": base64Image
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "responseSchema": [
                    "type": "OBJECT",
                    "properties": [
                        "title": [
                            "type": "STRING",
                            "description": "The title of the recipe. If no title is found, create a suitable one."
                        ],
                        "ingredients": [
                            "type": "ARRAY",
                            "items": ["type": "STRING"],
                            "description": "A list of all ingredients, including quantities and preparation notes (e.g., '1 cup flour, sifted')."
                        ],
                        "instructions": [
                            "type": "ARRAY",
                            "items": ["type": "STRING"],
                            "description": "The step-by-step instructions for preparing the recipe."
                        ]
                    ],
                    "required": ["title", "ingredients", "instructions"]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Print the raw response for debugging
        print("Response status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw response: \(responseString)")
        }
        
        do {
            // Parse the JSON response
            let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Extract the text from the response
            if let candidates = responseDict?["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                
                print("Extracted text: \(text)")
                
                // Try to parse the recipe JSON from the text
                let cleanedText = self.extractJSON(from: text)
                print("Cleaned text: \(cleanedText)")
                
                if let recipeData = cleanedText.data(using: .utf8) {
                    do {
                        // Decode the recipe using our custom decoder
                        let decoder = JSONDecoder()
                        let recipeDict = try decoder.decode([String: AnyCodable].self, from: recipeData)
                        
                        // Extract the values
                        guard let title = recipeDict["title"]?.value as? String,
                              let ingredients = recipeDict["ingredients"]?.value as? [String],
                              let instructions = recipeDict["instructions"]?.value as? [String] else {
                            throw RecipeExtractionError.parsingFailed
                        }
                        
                        // Create the recipe with our custom initializer
                        let recipe = Recipe(title: title, ingredients: ingredients, instructions: instructions)
                        return recipe
                    } catch let jsonError {
                        print("JSON decoding error: \(jsonError)")
                        throw RecipeExtractionError.parsingFailed
                    }
                } else {
                    print("Failed to convert cleaned text to data")
                    throw RecipeExtractionError.parsingFailed
                }
            } else {
                print("Failed to extract text from response")
                throw RecipeExtractionError.invalidResponse
            }
        } catch let error as RecipeExtractionError {
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw RecipeExtractionError.parsingFailed
        }
    }
    
    // Helper function to extract JSON from markdown code blocks
    private func extractJSON(from text: String) -> String {
        // Remove markdown code block markers if present
        var cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedText.hasPrefix("```json") {
            cleanedText = String(cleanedText.dropFirst(7)) // Remove ```json
        } else if cleanedText.hasPrefix("```") {
            cleanedText = String(cleanedText.dropFirst(3)) // Remove ```
        }
        
        if cleanedText.hasSuffix("```") {
            cleanedText = String(cleanedText.dropLast(3)) // Remove ```
        }
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - AnyCodable
struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value could not be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value could not be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
    }
}

enum RecipeExtractionError: Error, LocalizedError {
    case missingAPIKey
    case invalidResponse
    case invalidResponseStructure(String)
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is not set."
        case .invalidResponse:
            return "Invalid response from AI service."
        case .invalidResponseStructure(let response):
            return "Unexpected response structure from AI service: \(response)"
        case .parsingFailed:
            return "Failed to parse recipe from response."
        }
    }
}

// MARK: - ViewModels
class RecipeGenieViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var recipe: Recipe? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isAuthModalPresented = false
    @Published var isPaywallPresented = false
    @Published var currentView: AppView = .home
    
    // Updated limits based on the provided information
    private let FREE_LIMIT_AUTH = 3
    private let FREE_LIMIT_ANON = 1
    
    @ObservedObject var authService = RealAuthService.shared
    let profileService = RealProfileService.shared
    
    func handleImageSelection(_ image: UIImage) {
        self.image = image
        self.recipe = nil
        self.errorMessage = nil
    }
    
    func extractRecipe() async {
        guard let image = self.image else {
            DispatchQueue.main.async {
                self.errorMessage = "Please select an image first."
            }
            return
        }
        
        // Check usage limits based on auth state
        let isAnonymous = !authService.isAuthenticated
        let anonymousUsageCount = UserDefaults.standard.integer(forKey: "anonymousUsageCount")
        
        // Check usage limits
        if isAnonymous && anonymousUsageCount >= FREE_LIMIT_ANON {
            DispatchQueue.main.async {
                self.isAuthModalPresented = true
            }
            return
        } else if authService.isAuthenticated {
            if let userId = authService.user?.id,
               let profile = try? await profileService.getProfile(for: userId),
               profile.subscriptionStatus == "free" && profile.extractionCount >= FREE_LIMIT_AUTH {
                DispatchQueue.main.async {
                    self.isPaywallPresented = true
                }
                return
            }
        }
        
        guard let (base64, mimeType) = ImageUtils.convertToBase64(image: image) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to process image."
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let extractedRecipe = try await GeminiService.shared.extractRecipeFromImage(base64Image: base64, mimeType: mimeType)
            
            DispatchQueue.main.async {
                self.recipe = extractedRecipe
                self.isLoading = false
                self.currentView = .recipe
                
                // Update usage count
                if isAnonymous {
                    let newCount = anonymousUsageCount + 1
                    UserDefaults.standard.set(newCount, forKey: "anonymousUsageCount")
                } else if let userId = self.authService.user?.id {
                    Task {
                        _ = try await self.profileService.incrementExtractionCount(for: userId)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func resetState() {
        image = nil
        recipe = nil
        errorMessage = nil
        isLoading = false
        currentView = .home
    }
    
    func showUploader() {
        currentView = .uploader
    }
}

enum AppView {
    case home
    case uploader
    case recipe
}

// MARK: - Views
struct ContentView: View {
    @StateObject private var viewModel = RecipeGenieViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView(viewModel: viewModel)
            
            // Main content
            ScrollView {
                VStack {
                    switch viewModel.currentView {
                    case .home:
                        HomeView(viewModel: viewModel)
                    case .uploader:
                        ImageUploaderView(viewModel: viewModel)
                    case .recipe:
                        if let recipe = viewModel.recipe {
                            RecipeDisplayView(recipe: recipe, viewModel: viewModel)
                        }
                    }
                    
                    if viewModel.isLoading {
                        LoadingView()
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage, onTryAgain: {
                            viewModel.resetState()
                        })
                    }
                }
                .padding()
            }
        }
        .background(Color("cream"))
        .sheet(isPresented: $viewModel.isAuthModalPresented) {
            AuthModalView()
        }
        .sheet(isPresented: $viewModel.isPaywallPresented) {
            PaywallModalView()
        }
    }
}

struct HeaderView: View {
    @ObservedObject var viewModel: RecipeGenieViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recipe Genie")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                Text("Your kitchen's magical assistant for handwritten recipes")
                    .font(.caption)
                    .foregroundColor(Color("brand-gray"))
            }
            
            Spacer()
            
            if viewModel.authService.isAuthenticated && viewModel.authService.user != nil {
                VStack(alignment: .trailing) {
                    Text("Welcome, \(viewModel.authService.user?.email ?? "")")
                        .font(.caption)
                        .foregroundColor(Color("brand-gray"))
                    Button(action: {
                        Task {
                            await viewModel.authService.logout()
                        }
                    }) {
                        Text("Logout")
                            .foregroundColor(Color("brand-orange"))
                            .underline()
                    }
                }
            } else {
                Button(action: {
                    viewModel.isAuthModalPresented = true
                }) {
                    Text("Login / Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("brand-green"))
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: RecipeGenieViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            // Hero Section
            VStack(spacing: 16) {
                Text("Magically Digitize Your Handwritten Recipes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                    .multilineTextAlignment(.center)
                
                Text("Preserve your family's culinary legacy forever. Just snap a photo of any handwritten recipe, and let our AI assistant turn it into a beautiful, digital format you can save and share.")
                    .font(.body)
                    .foregroundColor(Color("brand-gray"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    viewModel.showUploader()
                }) {
                    Text("Upload Your First Recipe")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("brand-orange"))
                        .cornerRadius(30)
                }
                .padding(.top)
            }
            
            // How It Works Section
            VStack(spacing: 24) {
                Text("How It Works in 3 Easy Steps")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                
                HStack(spacing: 20) {
                    FeatureCard(
                        icon: "camera",
                        title: "1. Snap a Photo",
                        description: "Upload a clear picture of your handwritten recipe card or note."
                    )
                    
                    FeatureCard(
                        icon: "sparkles",
                        title: "2. AI Magic",
                        description: "Our smart AI analyzes the image, identifies the handwriting, and extracts the text."
                    )
                    
                    FeatureCard(
                        icon: "doc.text",
                        title: "3. Get Your Recipe",
                        description: "Receive a perfectly formatted digital recipe, ready to be copied, saved, or shared."
                    )
                }
            }
            
            // Pricing Section
            VStack(spacing: 24) {
                Text("Simple, Transparent Pricing")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                
                HStack(spacing: 20) {
                    PricingCard(
                        title: "Try It Out",
                        price: "1",
                        description: "As an anonymous guest",
                        features: ["Free Recipe Extraction", "No account needed"]
                    )
                    
                    PricingCard(
                        title: "Free Account",
                        price: "3",
                        description: "Create an account to get more",
                        features: ["3 free recipe extractions", "Save your history (coming soon)"],
                        isFeatured: true
                    )
                    
                    PricingCard(
                        title: "Go Pro",
                        price: "$3.99",
                        description: "For the master chef",
                        features: ["Unlimited Extractions", "Priority Support", "Help preserve family recipes"]
                    )
                }
            }
            
            // Contact Support
            VStack(spacing: 8) {
                Text("Need assistance?")
                    .font(.subheadline)
                    .foregroundColor(Color("brand-gray"))
                ContactLinkView()
                    .font(.subheadline)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

struct ContactLinkView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Button(action: openEmail) {
            Text("contact-us@dinner-brain.com")
                .foregroundColor(Color("brand-orange"))
        }
        .alert("Email client not available", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func openEmail() {
        if let url = URL(string: "mailto:contact-us@dinner-brain.com") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                alertMessage = "No default email client is configured. Please set up an email account in Settings."
                showAlert = true
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(Color("brand-orange"))
                .frame(width: 48, height: 48)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("brand-brown"))
            
            Text(description)
                .font(.caption)
                .foregroundColor(Color("brand-gray"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let description: String
    let features: [String]
    var isFeatured: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color("brand-gray"))
                    .multilineTextAlignment(.center)
                
                VStack {
                    Text(price)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("brand-brown"))
                    
                    if title == "Go Pro" {
                        Text("/month")
                            .font(.caption)
                            .foregroundColor(Color("brand-gray"))
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(features, id: \.self) { feature in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("brand-green"))
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(Color("brand-gray"))
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFeatured ? Color("brand-orange") : Color.clear, lineWidth: isFeatured ? 4 : 0)
            )
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isFeatured ? 1.05 : 1.0)
        .shadow(radius: isFeatured ? 8 : 4)
    }
}

struct ImageUploaderView: View {
    @ObservedObject var viewModel: RecipeGenieViewModel
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 4)
                    )
            } else {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(Color("brand-gray"))
                        
                        Text("Click to upload a recipe photo")
                            .font(.headline)
                            .foregroundColor(Color("brand-gray"))
                        
                        Text("PNG, JPG, or WEBP")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("brand-gray"), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                }
            }
            
            if viewModel.image != nil {
                Button(action: {
                    Task {
                        await viewModel.extractRecipe()
                    }
                }) {
                    Text("Extract Recipe")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("brand-orange"))
                        .cornerRadius(30)
                }
                .disabled(viewModel.isLoading)
            }
            
            Button(action: {
                viewModel.currentView = .home
            }) {
                Text("Cancel")
                    .font(.caption)
                    .foregroundColor(Color("brand-gray"))
                    .underline()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let image = newValue {
                viewModel.handleImageSelection(image)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct RecipeDisplayView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: RecipeGenieViewModel
    @State private var selectedFormat: RecipeFormat = .text
    @State private var showCopySuccess = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe title
                Text(recipe.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)

                // Copy controls section
                RecipeCopyControlsView(
                    recipe: recipe,
                    selectedFormat: $selectedFormat,
                    showCopySuccess: $showCopySuccess
                )

                // Ingredients section
                SectionView(title: "Ingredients") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(recipe.ingredients.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("brand-brown"))
                                Text(recipe.ingredients[index])
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(Color("brand-gray"))
                                Spacer()
                            }
                        }
                    }
                }

                // Instructions section
                SectionView(title: "Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(recipe.instructions.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("brand-brown"))
                                Text(recipe.instructions[index])
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(Color("brand-gray"))
                                Spacer()
                            }
                        }
                    }
                }

                // Preview section
                RecipePreviewView(recipe: recipe, format: selectedFormat)

                // Start New Recipe button section
                StartNewRecipeButtonView(viewModel: viewModel)
            }
            .padding()
        }
        .overlay(
            // Copy success feedback
            VStack {
                if showCopySuccess {
                    CopySuccessBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .animation(.easeInOut(duration: 0.3), value: showCopySuccess)
        )
    }
}

struct RecipeCopyControlsView: View {
    let recipe: Recipe
    @Binding var selectedFormat: RecipeFormat
    @Binding var showCopySuccess: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Format selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Copy Format")
                    .font(.headline)
                    .foregroundColor(Color("brand-brown"))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(RecipeFormat.allCases, id: \.self) { format in
                            Button(action: {
                                selectedFormat = format
                            }) {
                                Text(format.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedFormat == format ? .white : Color("brand-brown"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedFormat == format
                                            ? Color("brand-orange")
                                            : Color("brand-gray").opacity(0.1)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }

            // Copy button
            Button(action: {
                copyRecipe()
            }) {
                HStack {
                    Image(systemName: "doc.on.clipboard")
                        .font(.headline)
                    Text("Copy Recipe as \(selectedFormat.displayName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("brand-green"))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func copyRecipe() {
        let formattedRecipe = RecipeFormatter.formatRecipe(recipe, as: selectedFormat)
        ClipboardUtils.copyToClipboard(formattedRecipe)
        ClipboardUtils.showCopyFeedback()

        // Show success banner
        showCopySuccess = true

        // Hide success banner after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCopySuccess = false
        }
    }
}

struct RecipePreviewView: View {
    let recipe: Recipe
    let format: RecipeFormat
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Preview (\(format.displayName))")
                    .font(.headline)
                    .foregroundColor(Color("brand-brown"))

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.headline)
                        .foregroundColor(Color("brand-orange"))
                }
            }

            if isExpanded {
                ScrollView {
                    Text(RecipeFormatter.formatRecipe(recipe, as: format))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Color("brand-gray"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color("cream").opacity(0.5))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 300)
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CopySuccessBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.title2)

            Text("Recipe copied to clipboard!")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(Color("brand-green"))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct StartNewRecipeButtonView: View {
    @ObservedObject var viewModel: RecipeGenieViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Divider
            HStack {
                VStack {
                    Divider()
                        .background(Color("brand-gray").opacity(0.3))
                }

                Text("Ready for another?")
                    .font(.caption)
                    .foregroundColor(Color("brand-gray"))
                    .padding(.horizontal, 12)

                VStack {
                    Divider()
                        .background(Color("brand-gray").opacity(0.3))
                }
            }
            .padding(.vertical, 8)

            // Start New Recipe button
            Button(action: {
                startNewRecipe()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Start New Recipe")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("brand-orange"), Color("brand-orange").opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(radius: 4)
            }
            .buttonStyle(PlainButtonStyle())

            // Helper text
            Text("Upload another handwritten recipe to digitize")
                .font(.caption)
                .foregroundColor(Color("brand-gray"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func startNewRecipe() {
        // Reset the current recipe and navigate to uploader
        viewModel.resetState()
        viewModel.showUploader()
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("brand-brown"))
                .padding(.bottom, 5)
            
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Extracting your recipe...")
                .font(.headline)
                .foregroundColor(Color("brand-gray"))
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color("cream"))
        .cornerRadius(10)
    }
}

struct ErrorView: View {
    let message: String
    let onTryAgain: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            Text("Oops!")
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("brand-gray"))
            
            Button(action: onTryAgain) {
                Text("Try Again")
                    .font(.caption)
                    .foregroundColor(Color("brand-gray"))
                    .underline()
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 1.0, green: 0.8, blue: 0.8))
        .cornerRadius(10)
    }
}

struct AuthModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            if authViewModel.signupCompletedSuccessfully {
                // Email verification modal
                VStack(spacing: 24) {
                    // Success icon and title
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color("brand-orange"))

                        Text("Account Created!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("brand-brown"))
                    }

                    // Email verification instructions
                    VStack(spacing: 16) {
                        Text("Please check your email to verify your account")
                            .font(.headline)
                            .foregroundColor(Color("brand-brown"))
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Check your email inbox")
                            Text("2. Click the verification link")
                            Text("3. You'll be automatically logged in")
                        }
                        .foregroundColor(Color("brand-gray"))
                        .padding()
                        .background(Color("cream"))
                        .cornerRadius(10)
                    }

                    // Support email
                    VStack(spacing: 8) {
                        Text("Need help?")
                            .font(.footnote)
                            .foregroundColor(Color("brand-gray"))

                        Text("contact-us@dinner-brain.com")
                            .font(.footnote)
                            .foregroundColor(Color("brand-orange"))
                            .underline()
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        // Done button
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("brand-orange"))
                        .cornerRadius(10)

                        // Create new account button
                        Button("Create New Account") {
                            // Reset the signup completion state
                            authViewModel.resetSignupState()
                            // Clear any existing form data
                            authViewModel.email = ""
                            authViewModel.password = ""
                            authViewModel.confirmPassword = ""
                            // Switch to signup mode
                            authViewModel.isSignupMode = true
                        }
                        .font(.subheadline)
                        .foregroundColor(Color("brand-orange"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("brand-orange"), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            } else {
                // Normal login/signup form
                VStack(spacing: 20) {
                    Text("Login / Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("brand-brown"))
                
                Text("To continue extracting recipes, please log in or create an account. As a registered user, you get 3 free recipe extractions.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("brand-gray"))
                
                VStack {
                    TextField("Email", text: $authViewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $authViewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                if authViewModel.isSignupMode {
                    SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await authViewModel.performAction()
                    }
                }) {
                    Text(authViewModel.isSignupMode ? "Sign Up" : "Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("brand-orange"))
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isActionDisabled)
                .padding(.horizontal)
                
                Button(action: {
                    authViewModel.isSignupMode.toggle()
                    authViewModel.clearError()
                }) {
                    Text(authViewModel.isSignupMode ? "Already have an account? Login" : "Don't have an account? Sign Up")
                        .font(.caption)
                        .foregroundColor(Color("brand-orange"))
                }
                .padding(.top)
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("brand-gray"))
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            } // End else block
        }
        .onChange(of: authViewModel.didCompleteAction) { oldValue, completed in
            if completed && !authViewModel.signupCompletedSuccessfully {
                // Only dismiss for login success, not signup success
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isSignupMode = true
    @Published var isActionDisabled = false
    @Published var didCompleteAction = false
    @Published var signupCompletedSuccessfully = false

    private let authService = RealAuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe changes in RealAuthService's signupCompletedSuccessfully property
        authService.$signupCompletedSuccessfully
            .assign(to: \.signupCompletedSuccessfully, on: self)
            .store(in: &cancellables)
    }

    func performAction() async {
        isActionDisabled = true
        clearError()
        
        let credentials = AuthCredentials(email: email, password: password)
        
        if isSignupMode {
            // Validate passwords match
            guard password == confirmPassword else {
                await MainActor.run {
                    self.errorMessage = "Passwords do not match"
                    self.isActionDisabled = false
                }
                return
            }
            
            // Validate password strength
            guard password.count >= 6 else {
                await MainActor.run {
                    self.errorMessage = "Password must be at least 6 characters long"
                    self.isActionDisabled = false
                }
                return
            }
            
            do {
                try await authService.signup(with: credentials)
                await MainActor.run {
                    self.didCompleteAction = true
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isActionDisabled = false
                }
                return
            }
        } else {
            await authService.login(with: credentials)

            if let error = authService.authError {
                await MainActor.run {
                    self.errorMessage = error
                    self.isActionDisabled = false
                }
            } else {
                await MainActor.run {
                    self.didCompleteAction = true
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = ""
        authService.authError = nil
    }

    func resetSignupState() {
        authService.resetSignupState()
        signupCompletedSuccessfully = false
    }
}

struct PaywallModalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 50))
                    .foregroundColor(Color("brand-orange"))
                
                Text("Upgrade to Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("brand-brown"))
                
                Text("You've used your free extractions. Upgrade to Pro to extract unlimited recipes!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("brand-gray"))
                
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(text: "Unlimited recipe extractions")
                    FeatureRow(text: "Save your favorite recipes to your account")
                    FeatureRow(text: "Export recipes to PDF")
                    FeatureRow(text: "Priority customer support")
                    FeatureRow(text: "Help preserve family recipes forever")
                }
                .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pro Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("brand-brown"))
                    
                    Text("$3.99/month")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("brand-orange"))
                    
                    Text("Billed monthly. Cancel anytime.")
                        .font(.caption)
                        .foregroundColor(Color("brand-gray"))
                }
                .padding()
                .background(Color("brand-orange").opacity(0.1))
                .cornerRadius(10)
                
                Button("Upgrade Now") {
                    // Handle upgrade
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("brand-orange"))
                .cornerRadius(10)
                
                Button("Maybe Later") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("brand-gray"))
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color("brand-green"))
            Text(text)
                .foregroundColor(Color("brand-gray"))
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}