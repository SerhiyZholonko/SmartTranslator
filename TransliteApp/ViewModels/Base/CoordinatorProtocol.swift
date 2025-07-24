import SwiftUI

protocol CoordinatorProtocol: ObservableObject {
    associatedtype Route
    
    func navigate(to route: Route)
    func dismiss()
}

protocol NavigationRoute {
    associatedtype Destination: View
    
    func destination() -> Destination
}