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
    
    private let model: GenerativeModel
    private let chatModel: GenerativeModel
    
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
        // Initialize Gemini API - You'll need to add your API key
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !apiKey.isEmpty else {
            // Use empty models as fallback - features will be disabled
            self.model = GenerativeModel(name: "gemini-pro", apiKey: "")
            self.chatModel = GenerativeModel(name: "gemini-pro", apiKey: "")
            self.errorMessage = "Gemini API key not configured. AI features are disabled."
            return
        }
        
        self.model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
        self.chatModel = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
    }
    
    // MARK: - Price Analysis
    func analyzePriceForItem(title: String, description: String, condition: ItemCondition, category: ItemCategory, images: [UIImage]? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let prompt = createPriceAnalysisPrompt(title: title, description: description, condition: condition, category: category)
        
        do {
            let response = try await model.generateContent(prompt)
            
            if let text = response.text {
                let analysis = parsePriceAnalysisResponse(text)
                
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
        }
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
        
        Please provide:
        1. Suggested price range (minimum and maximum)
        2. Optimal selling price
        3. Confidence level (1-10)
        4. Reasoning for the price
        5. Comparable items or market data
        6. Current market trend for this category
        
        Format your response as JSON:
        {
            "suggestedPrice": 0.00,
            "priceRange": {"min": 0.00, "max": 0.00},
            "confidence": 8,
            "reasoning": "explanation here",
            "comparableItems": ["item1", "item2"],
            "marketTrend": "stable/increasing/decreasing"
        }
        """
    }
    
    private func parsePriceAnalysisResponse(_ response: String) -> PriceAnalysis {
        // Parse JSON response and create PriceAnalysis object
        // This is a simplified implementation
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return PriceAnalysis(
                suggestedPrice: 0,
                confidence: 0,
                reasoning: "Could not parse AI response",
                comparableItems: [],
                marketTrend: "unknown"
            )
        }
        
        return PriceAnalysis(
            suggestedPrice: json["suggestedPrice"] as? Double ?? 0,
            confidence: json["confidence"] as? Double ?? 0,
            reasoning: json["reasoning"] as? String ?? "",
            comparableItems: json["comparableItems"] as? [String] ?? [],
            marketTrend: json["marketTrend"] as? String ?? "unknown"
        )
    }
    
    // MARK: - Market Research
    func performMarketResearch(for category: ItemCategory, priceRange: (min: Double, max: Double)? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let prompt = createMarketResearchPrompt(category: category, priceRange: priceRange)
        
        do {
            let response = try await model.generateContent(prompt)
            
            if let text = response.text {
                let insights = parseMarketInsightsResponse(text)
                
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
        }
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
        
        Please analyze:
        1. Average market price for this category
        2. Typical price range (min-max)
        3. Current demand level (high/medium/low)
        4. Seasonal trends and timing recommendations
        5. Specific recommendations for Texas Tech students
        6. Popular items in this category
        
        Format response as JSON:
        {
            "averagePrice": 0.00,
            "priceRange": {"min": 0.00, "max": 0.00},
            "demandLevel": "high/medium/low",
            "seasonalTrends": "description",
            "recommendations": ["tip1", "tip2", "tip3"],
            "popularItems": ["item1", "item2"]
        }
        """
        
        return prompt
    }
    
    private func parseMarketInsightsResponse(_ response: String) -> MarketInsights {
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return MarketInsights(
                averagePrice: 0,
                priceRange: (min: 0, max: 0),
                demandLevel: "unknown",
                seasonalTrends: "Could not parse response",
                recommendations: []
            )
        }
        
        let priceRangeDict = json["priceRange"] as? [String: Double] ?? [:]
        
        return MarketInsights(
            averagePrice: json["averagePrice"] as? Double ?? 0,
            priceRange: (min: priceRangeDict["min"] ?? 0, max: priceRangeDict["max"] ?? 0),
            demandLevel: json["demandLevel"] as? String ?? "unknown",
            seasonalTrends: json["seasonalTrends"] as? String ?? "",
            recommendations: json["recommendations"] as? [String] ?? []
        )
    }
    
    // MARK: - Chatbot Functionality
    func processUserQuery(_ query: String, context: ChatContext? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let prompt = createChatbotPrompt(query: query, context: context)
        
        do {
            let response = try await chatModel.generateContent(prompt)
            
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
        }
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
        
        return []
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
                "Bring a friend to high-value transactions"
            ]
        case .buying:
            return [
                "Inspect items thoroughly before payment",
                "Meet in well-lit, populated campus areas",
                "Verify seller's student status and reviews",
                "Test electronics before purchasing",
                "Trust your instincts - if something feels wrong, walk away"
            ]
        }
    }
    
    enum TransactionType {
        case selling, buying
    }
    
    // MARK: - Listing Optimization
    func optimizeItemDescription(_ originalDescription: String, title: String, category: ItemCategory) async -> String {
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
            return originalDescription
        }
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
} 