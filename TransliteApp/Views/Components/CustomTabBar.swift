import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var animation
    
    enum TabItem: CaseIterable {
        case home
        case flashcards
        case history
        case settings
        
        var title: String {
            switch self {
            case .home:
                return "home".localized
            case .flashcards:
                return "flashcards".localized
            case .history:
                return "history".localized
            case .settings:
                return "settings".localized
            }
        }
        
        var iconName: String {
            switch self {
            case .home:
                return "house.fill"
            case .flashcards:
                return "rectangle.stack.fill"
            case .history:
                return "clock.arrow.circlepath"
            case .settings:
                return "gear"
            }
        }
    }
    
    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Button(action: {
                    // Prevent rapid tab switching that can cause hangs
                    guard selectedTab != tab else { return }
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: tab == .flashcards ? 28 : 24, weight: .medium))
                            .foregroundColor(selectedTab == tab ? AppColors.appAccent : AppColors.secondaryText)
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? AppColors.appAccent : AppColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.appAccent.opacity(0.1))
                                    .matchedGeometryEffect(id: "tabBackground", in: animation)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.shadow.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    @State var selectedTab = CustomTabBar.TabItem.home
    return CustomTabBar(selectedTab: $selectedTab)
        .background(AppColors.appBackground)
}