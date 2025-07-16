import Foundation
import GoogleGenerativeAI
import UIKit
import Combine

class AIAssistant: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var chatResponse: String = ""
    @Published var priceAnalysis: PriceAnalysis?
    @Published var marketInsights: MarketInsights?
    
    private let model: GenerativeModel?
    private let chatModel: GenerativeModel?
    private let isAIEnabled: Bool
    
    struct PriceAnalysis {
        let suggestedPrice: Double
        let confidence: Double
        let reasoning: String
        let comparableItems: [String]
        let marketTrend: String
    }
    
    struct MarketInsights {
        let averagePrice: Double
        let priceRange: (min: Double, max: Double)
        let demandLevel: String
        let seasonalTrends: String
        let recommendations: [String]
    }
    
    init() {
        // Try to get API key from Info.plist or environment
        let apiKey = Self.getAPIKey()
        
        if !apiKey.isEmpty {
            self.model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
            self.chatModel = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
            self.isAIEnabled = true
        } else {
            self.model = nil
            self.chatModel = nil
            self.isAIEnabled = false
            print("⚠️ AI Assistant: Gemini API key not found. AI features will use fallback responses.")
        }
    }
    
    private static func getAPIKey() -> String {
        // Try to get from Info.plist first
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" {
            return apiKey
        }
        
        // Try to get from environment variables (for development)
        if let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !apiKey.isEmpty {
            return apiKey
        }
        
        return ""
    }
    
    // MARK: - Price Analysis
    func analyzePriceForItem(title: String, description: String, condition: ItemCondition, category: ItemCategory, images: [UIImage]? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard isAIEnabled, let model = model else {
            await handleFallbackPriceAnalysis(title: title, description: description, condition: condition, category: category)
            return
        }
        
        let prompt = createPriceAnalysisPrompt(title: title, description: description, condition: condition, category: category)
        
        do {
            let response = try await withTimeout(AppConstants.AIAssistant.priceAnalysisTimeout) {
                try await model.generateContent(prompt)
            }
            
            if let text = response.text {
                let analysis = parsePriceAnalysisResponse(text, fallback: (title, description, condition, category))
                
                await MainActor.run {
                    priceAnalysis = analysis
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to analyze price: \(error.localizedDescription)"
                isLoading = false
            }
            
            // Provide fallback analysis
            await handleFallbackPriceAnalysis(title: title, description: description, condition: condition, category: category)
        }
    }
    
    private func handleFallbackPriceAnalysis(title: String, description: String, condition: ItemCondition, category: ItemCategory) async {
        let fallbackAnalysis = createFallbackPriceAnalysis(title: title, description: description, condition: condition, category: category)
        
        await MainActor.run {
            priceAnalysis = fallbackAnalysis
            isLoading = false
        }
    }
    
    private func createFallbackPriceAnalysis(title: String, description: String, condition: ItemCondition, category: ItemCategory) -> PriceAnalysis {
        // Simple rule-based pricing for common categories
        let basePrices: [ItemCategory: Double] = [
            .textbooks: 50.0,
            .electronics: 200.0,
            .clothing: 25.0,
            .furniture: 150.0,
            .sports: 75.0,
            .tickets: 30.0,
            .dorm: 40.0,
            .techGear: 100.0,
            .other: 50.0
        ]
        
        let conditionMultipliers: [ItemCondition: Double] = [
            .new: 1.0,
            .likeNew: 0.85,
            .good: 0.70,
            .fair: 0.55,
            .poor: 0.40
        ]
        
        let basePrice = basePrices[category] ?? 50.0
        let conditionMultiplier = conditionMultipliers[condition] ?? 0.70
        let suggestedPrice = basePrice * conditionMultiplier
        
        return PriceAnalysis(
            suggestedPrice: suggestedPrice,
            confidence: 0.6, // Lower confidence for fallback
            reasoning: "Suggested price based on category (\(category.rawValue)) and condition (\(condition.rawValue)). This is a basic estimate - consider researching similar items for more accurate pricing.",
            comparableItems: ["Similar \(category.rawValue) items", "Other \(condition.rawValue) condition items"],
            marketTrend: "stable"
        )
    }
    
    private func createPriceAnalysisPrompt(title: String, description: String, condition: ItemCondition, category: ItemCategory) -> String {
        return """
        As a marketplace pricing expert for college students at Texas Tech University, analyze this item and suggest an optimal price:
        
        Item Details:
        - Title: \(title)
        - Description: \(description)
        - Condition: \(condition.rawValue)
        - Category: \(category.rawValue)
        - Target Market: Texas Tech University students (ages 18-25)
        
        Please provide a JSON response with:
        1. Suggested price (as a number)
        2. Confidence level (1-10 as a number)
        3. Reasoning for the price
        4. Comparable items or market data
        5. Current market trend for this category
        
        Format your response as JSON:
        {
            "suggestedPrice": 0.00,
            "confidence": 8,
            "reasoning": "explanation here",
            "comparableItems": ["item1", "item2"],
            "marketTrend": "stable"
        }
        """
    }
    
    private func parsePriceAnalysisResponse(_ response: String, fallback: (String, String, ItemCondition, ItemCategory)) -> PriceAnalysis {
        // Try to parse JSON response
        guard let data = response.data(using: .utf8) else {
            return createFallbackPriceAnalysis(title: fallback.0, description: fallback.1, condition: fallback.2, category: fallback.3)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            return PriceAnalysis(
                suggestedPrice: json?["suggestedPrice"] as? Double ?? 0,
                confidence: json?["confidence"] as? Double ?? 0,
                reasoning: json?["reasoning"] as? String ?? "No reasoning provided",
                comparableItems: json?["comparableItems"] as? [String] ?? [],
                marketTrend: json?["marketTrend"] as? String ?? "unknown"
            )
        } catch {
            // If JSON parsing fails, try to extract price from text
            let priceRegex = try! NSRegularExpression(pattern: "\\$?([0-9]+\\.?[0-9]*)", options: [])
            let range = NSRange(location: 0, length: response.count)
            
            if let match = priceRegex.firstMatch(in: response, options: [], range: range) {
                let priceString = String(response[Range(match.range(at: 1), in: response)!])
                if let price = Double(priceString) {
                    return PriceAnalysis(
                        suggestedPrice: price,
                        confidence: 0.5,
                        reasoning: "Extracted price from AI response. Full analysis may not be available.",
                        comparableItems: [],
                        marketTrend: "unknown"
                    )
                }
            }
            
            return createFallbackPriceAnalysis(title: fallback.0, description: fallback.1, condition: fallback.2, category: fallback.3)
        }
    }
    
    // MARK: - Market Research
    func performMarketResearch(for category: ItemCategory, priceRange: (min: Double, max: Double)? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard isAIEnabled, let model = model else {
            await handleFallbackMarketResearch(for: category, priceRange: priceRange)
            return
        }
        
        let prompt = createMarketResearchPrompt(category: category, priceRange: priceRange)
        
        do {
            let response = try await withTimeout(AppConstants.AIAssistant.marketResearchTimeout) {
                try await model.generateContent(prompt)
            }
            
            if let text = response.text {
                let insights = parseMarketInsightsResponse(text, fallback: category)
                
                await MainActor.run {
                    marketInsights = insights
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to perform market research: \(error.localizedDescription)"
                isLoading = false
            }
            
            await handleFallbackMarketResearch(for: category, priceRange: priceRange)
        }
    }
    
    private func handleFallbackMarketResearch(for category: ItemCategory, priceRange: (min: Double, max: Double)?) async {
        let fallbackInsights = createFallbackMarketInsights(for: category, priceRange: priceRange)
        
        await MainActor.run {
            marketInsights = fallbackInsights
            isLoading = false
        }
    }
    
    private func createFallbackMarketInsights(for category: ItemCategory, priceRange: (min: Double, max: Double)?) -> MarketInsights {
        let averagePrices: [ItemCategory: Double] = [
            .textbooks: 45.0,
            .electronics: 180.0,
            .clothing: 20.0,
            .furniture: 120.0,
            .sports: 60.0,
            .tickets: 25.0,
            .dorm: 35.0,
            .techGear: 85.0,
            .other: 40.0
        ]
        
        let avgPrice = averagePrices[category] ?? 40.0
        let minPrice = avgPrice * 0.5
        let maxPrice = avgPrice * 1.8
        
        let recommendations = [
            "Price competitively within the suggested range",
            "Include clear photos to attract buyers",
            "List detailed condition information",
            "Consider timing - end of semester may have higher demand",
            "Be responsive to messages and offers"
        ]
        
        return MarketInsights(
            averagePrice: avgPrice,
            priceRange: (min: minPrice, max: maxPrice),
            demandLevel: "medium",
            seasonalTrends: "Demand typically increases during semester transitions and exam periods",
            recommendations: recommendations
        )
    }
    
    private func createMarketResearchPrompt(category: ItemCategory, priceRange: (min: Double, max: Double)?) -> String {
        var prompt = """
        Provide market research analysis for \(category.rawValue) items on a Texas Tech University student marketplace:
        
        Target Demographics:
        - Texas Tech University students
        - Ages 18-25
        - College budget constraints
        - Campus-specific needs
        
        """
        
        if let range = priceRange {
            prompt += "Price Range of Interest: $\(range.min) - $\(range.max)\n"
        }
        
        prompt += """
        
        Please analyze and return JSON format:
        {
            "averagePrice": 0.00,
            "priceRange": {"min": 0.00, "max": 0.00},
            "demandLevel": "high/medium/low",
            "seasonalTrends": "description",
            "recommendations": ["tip1", "tip2", "tip3"]
        }
        """
        
        return prompt
    }
    
    private func parseMarketInsightsResponse(_ response: String, fallback category: ItemCategory) -> MarketInsights {
        guard let data = response.data(using: .utf8) else {
            return createFallbackMarketInsights(for: category, priceRange: nil)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let priceRangeDict = json?["priceRange"] as? [String: Double] ?? [:]
            
            return MarketInsights(
                averagePrice: json?["averagePrice"] as? Double ?? 0,
                priceRange: (min: priceRangeDict["min"] ?? 0, max: priceRangeDict["max"] ?? 0),
                demandLevel: json?["demandLevel"] as? String ?? "unknown",
                seasonalTrends: json?["seasonalTrends"] as? String ?? "",
                recommendations: json?["recommendations"] as? [String] ?? []
            )
        } catch {
            return createFallbackMarketInsights(for: category, priceRange: nil)
        }
    }
    
    // MARK: - Chatbot Functionality
    func processUserQuery(_ query: String, context: ChatContext? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard isAIEnabled, let chatModel = chatModel else {
            await handleFallbackChatResponse(query: query, context: context)
            return
        }
        
        let prompt = createChatbotPrompt(query: query, context: context)
        
        do {
            let response = try await withTimeout(AppConstants.AIAssistant.chatResponseTimeout) {
                try await chatModel.generateContent(prompt)
            }
            
            if let text = response.text {
                await MainActor.run {
                    chatResponse = text
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to process query: \(error.localizedDescription)"
                isLoading = false
            }
            
            await handleFallbackChatResponse(query: query, context: context)
        }
    }
    
    private func handleFallbackChatResponse(query: String, context: ChatContext?) async {
        let fallbackResponse = createFallbackChatResponse(query: query, context: context)
        
        await MainActor.run {
            chatResponse = fallbackResponse
            isLoading = false
        }
    }
    
    private func createFallbackChatResponse(query: String, context: ChatContext?) -> String {
        let lowerQuery = query.lowercased()
        
        if lowerQuery.contains("price") || lowerQuery.contains("cost") || lowerQuery.contains("how much") {
            return """
            For pricing help, consider these factors:
            • Check similar items already listed
            • Consider the item's condition honestly
            • Research original retail prices
            • Factor in demand for your category
            • Be competitive but fair
            
            Different categories have different price ranges - electronics tend to hold value better than textbooks, for example.
            """
        }
        
        if lowerQuery.contains("sell") || lowerQuery.contains("listing") {
            return """
            Here are some selling tips:
            • Take clear, well-lit photos from multiple angles
            • Write detailed, honest descriptions
            • Include all relevant details (model, size, condition)
            • Respond quickly to messages
            • Be flexible with meeting times and locations
            • Consider offers - negotiation is common
            """
        }
        
        if lowerQuery.contains("buy") || lowerQuery.contains("purchase") {
            return """
            When buying items:
            • Meet in safe, public campus locations
            • Inspect items carefully before paying
            • Ask questions about condition and history
            • Verify the seller's student status
            • Use secure payment methods
            • Trust your instincts
            """
        }
        
        if lowerQuery.contains("safety") || lowerQuery.contains("safe") {
            return """
            Safety tips for Texas Tech students:
            • Always meet in public campus locations
            • Consider meeting at the Student Union or Library
            • Bring a friend for high-value transactions
            • Verify the other person's student status
            • Use campus resources when possible
            • Trust your instincts - if something feels wrong, walk away
            """
        }
        
        return """
        I'm here to help with your Raider ReSell questions! I can assist with:
        • Pricing guidance and market insights
        • Selling and buying tips
        • Safety recommendations
        • General marketplace advice
        
        What specific aspect would you like help with?
        
        (Note: AI features are currently limited. For full AI assistance, please configure the Gemini API key.)
        """
    }
    
    enum ChatContext {
        case priceHelp
        case sellingTips
        case buyingAdvice
        case generalMarketplace
        case techSupport
    }
    
    private func createChatbotPrompt(query: String, context: ChatContext?) -> String {
        var systemPrompt = """
        You are an AI assistant for "Raider ReSell", a marketplace app exclusive to Texas Tech University students. You help with:
        
        - Price recommendations and market analysis
        - Selling and buying tips
        - Marketplace best practices
        - Texas Tech student-specific advice
        - Safety guidelines for student transactions
        
        Keep responses helpful, concise, and relevant to college students. Be friendly and use appropriate Texas Tech spirit when relevant.
        
        """
        
        if let context = context {
            switch context {
            case .priceHelp:
                systemPrompt += "Focus on pricing strategies and market value analysis.\n"
            case .sellingTips:
                systemPrompt += "Provide selling optimization and listing improvement tips.\n"
            case .buyingAdvice:
                systemPrompt += "Give buying advice and safety tips for students.\n"
            case .generalMarketplace:
                systemPrompt += "Discuss general marketplace functionality and features.\n"
            case .techSupport:
                systemPrompt += "Help with app technical issues and how-to questions.\n"
            }
        }
        
        systemPrompt += "\nUser Query: \(query)\n\nResponse:"
        
        return systemPrompt
    }
    
    // MARK: - Item Search and Recommendations
    func findSimilarItems(to searchItem: String, in category: ItemCategory) async -> [String] {
        guard isAIEnabled, let model = model else {
            return createFallbackSimilarItems(to: searchItem, in: category)
        }
        
        let prompt = """
        Given this item: "\(searchItem)" in the \(category.rawValue) category, suggest 5-7 similar items that Texas Tech students might be interested in buying or selling.
        
        Focus on:
        - Items commonly needed by college students
        - Campus-relevant variations
        - Different conditions or models
        - Complementary items
        
        Return only a simple list of item names, one per line.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                return text.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to find similar items"
            }
        }
        
        return createFallbackSimilarItems(to: searchItem, in: category)
    }
    
    private func createFallbackSimilarItems(to searchItem: String, in category: ItemCategory) -> [String] {
        let similarItemsByCategory: [ItemCategory: [String]] = [
            .textbooks: ["Course textbooks", "Study guides", "Lab manuals", "Reference books"],
            .electronics: ["Laptops", "Tablets", "Headphones", "Chargers", "Phone accessories"],
            .clothing: ["T-shirts", "Hoodies", "Jeans", "Sneakers", "Jackets"],
            .furniture: ["Desk chairs", "Study desks", "Lamps", "Storage bins", "Bed frames"],
            .sports: ["Gym equipment", "Sports gear", "Athletic wear", "Fitness accessories"],
            .tickets: ["Game tickets", "Concert tickets", "Event passes"],
            .dorm: ["Bedding", "Kitchen supplies", "Storage solutions", "Decorations"],
            .techGear: ["Computer accessories", "Software", "Gaming gear", "Tech gadgets"],
            .other: ["Miscellaneous items", "School supplies", "Personal items"]
        ]
        
        return similarItemsByCategory[category] ?? ["Similar items in \(category.rawValue)"]
    }
    
    // MARK: - Safety and Guidelines
    func generateSafetyTips(for transactionType: TransactionType) -> [String] {
        switch transactionType {
        case .selling:
            return [
                "Meet in public campus locations like the SUB or library",
                "Verify buyer's Texas Tech student status",
                "Use secure payment methods (Venmo, Zelle with verification)",
                "Take photos of the item condition before meeting",
                "Bring a friend to high-value transactions",
                "Trust your instincts - if something feels wrong, don't proceed"
            ]
        case .buying:
            return [
                "Inspect items thoroughly before payment",
                "Meet in well-lit, populated campus areas",
                "Verify seller's student status and reviews",
                "Test electronics before purchasing",
                "Ask about item history and any issues",
                "Trust your instincts - if something feels wrong, walk away"
            ]
        }
    }
    
    enum TransactionType {
        case selling, buying
    }
    
    // MARK: - Listing Optimization
    func optimizeItemDescription(_ originalDescription: String, title: String, category: ItemCategory) async -> String {
        guard isAIEnabled, let model = model else {
            return optimizeDescriptionFallback(originalDescription, title: title, category: category)
        }
        
        let prompt = """
        Optimize this item description for a Texas Tech student marketplace:
        
        Title: \(title)
        Category: \(category.rawValue)
        Original Description: \(originalDescription)
        
        Make it more appealing to college students by:
        - Adding relevant details they care about
        - Using engaging language
        - Highlighting value propositions
        - Including Texas Tech context when relevant
        - Keeping it concise but informative
        
        Return only the optimized description:
        """
        
        do {
            let response = try await model.generateContent(prompt)
            return response.text ?? originalDescription
        } catch {
            return optimizeDescriptionFallback(originalDescription, title: title, category: category)
        }
    }
    
    private func optimizeDescriptionFallback(_ originalDescription: String, title: String, category: ItemCategory) -> String {
        if originalDescription.count < 20 {
            return "\(originalDescription)\n\nPerfect for Texas Tech students! Great condition and ready for campus use."
        }
        
        return originalDescription
    }
    
    // MARK: - Trend Analysis
    func analyzeTrends(for items: [Item]) -> String {
        // Analyze current marketplace trends
        let categoryCount = Dictionary(grouping: items, by: { $0.category })
            .mapValues { $0.count }
        
        let avgPrices = Dictionary(grouping: items, by: { $0.category })
            .mapValues { items in
                items.reduce(0.0) { $0 + $1.price } / Double(items.count)
            }
        
        var trends = "📊 Current Marketplace Trends:\n\n"
        
        // Most popular categories
        let sortedCategories = categoryCount.sorted { $0.value > $1.value }
        trends += "🔥 Most Active Categories:\n"
        for (category, count) in sortedCategories.prefix(3) {
            trends += "• \(category.rawValue): \(count) items\n"
        }
        
        trends += "\n💰 Average Prices by Category:\n"
        for (category, avgPrice) in avgPrices.sorted(by: { $0.value > $1.value }).prefix(5) {
            trends += "• \(category.rawValue): $\(String(format: "%.2f", avgPrice))\n"
        }
        
        return trends
    }
    
    // MARK: - Utility Functions
    private func withTimeout<T>(_ timeout: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
    
    private struct TimeoutError: Error {}
} 