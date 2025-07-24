import Foundation
import Combine

@MainActor
class BaseViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    init() {}
    
    func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func showError(_ error: Error) {
        showError(error.localizedDescription)
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func handleError(_ error: Error) {
        isLoading = false
        showError(error)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}