import SwiftUI
import Combine

@MainActor
final class HistoryViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var historyItems: [TranslationHistoryItem] = []
    @Published var filteredItems: [TranslationHistoryItem] = []
    @Published var searchText = ""
    @Published var showClearAlert = false
    @Published var selectedItem: TranslationHistoryItem?
    @Published var isSelectionMode = false
    @Published var selectedItems = Set<String>()
    
    // MARK: - Services
    private let historyManager = TranslationHistoryManager.shared
    
    // MARK: - Computed Properties
    var hasItems: Bool {
        !filteredItems.isEmpty
    }
    
    var favoriteItems: [TranslationHistoryItem] {
        filteredItems.filter { $0.isFavorite }
    }
    
    override init() {
        super.init()
        loadHistory()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Search filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.filterItems(searchText)
            }
            .store(in: &cancellables)
        
        // Listen for history updates
        NotificationCenter.default.publisher(for: .historyUpdated)
            .sink { [weak self] _ in
                self?.loadHistory()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadHistory() {
        historyItems = historyManager.getHistory()
        filterItems(searchText)
    }
    
    func toggleFavorite(for item: TranslationHistoryItem) {
        historyManager.toggleFavorite(id: item.idString)
        loadHistory()
    }
    
    func deleteItem(_ item: TranslationHistoryItem) {
        historyManager.removeTranslation(id: item.idString)
        loadHistory()
    }
    
    func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        itemsToDelete.forEach { item in
            historyManager.removeTranslation(id: item.idString)
        }
        loadHistory()
    }
    
    func clearHistory() {
        historyManager.clearHistory()
        historyItems = []
        filteredItems = []
        selectedItems.removeAll()
        isSelectionMode = false
    }
    
    func copyTranslation(_ item: TranslationHistoryItem) {
        UIPasteboard.general.string = item.translatedText
        showError("copied_to_clipboard".localized)
    }
    
    func shareTranslation(_ item: TranslationHistoryItem) {
        // This will be handled by the view
        selectedItem = item
    }
    
    func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedItems.removeAll()
        }
    }
    
    func toggleSelection(for item: TranslationHistoryItem) {
        if selectedItems.contains(item.idString) {
            selectedItems.remove(item.idString)
        } else {
            selectedItems.insert(item.idString)
        }
    }
    
    func deleteSelectedItems() {
        selectedItems.forEach { id in
            historyManager.removeTranslation(id: id)
        }
        selectedItems.removeAll()
        isSelectionMode = false
        loadHistory()
    }
    
    func selectAll() {
        selectedItems = Set(filteredItems.map { $0.idString })
    }
    
    func deselectAll() {
        selectedItems.removeAll()
    }
    
    // MARK: - Private Methods
    private func filterItems(_ searchText: String) {
        if searchText.isEmpty {
            filteredItems = historyItems
        } else {
            let lowercasedSearch = searchText.lowercased()
            filteredItems = historyItems.filter { item in
                item.sourceText.lowercased().contains(lowercasedSearch) ||
                item.translatedText.lowercased().contains(lowercasedSearch)
            }
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let historyUpdated = Notification.Name("historyUpdated")
}