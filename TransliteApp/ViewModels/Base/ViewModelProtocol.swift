import Foundation
import Combine

protocol ViewModelProtocol: ObservableObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

protocol LoadableProtocol {
    var isLoading: Bool { get }
    var error: Error? { get }
}

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    var value: T? {
        switch self {
        case .loaded(let value):
            return value
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}