# Приклад використання нових функцій (Ліміт 20 + Вибір режиму)

## Нові функції:

### 1. **Збільшений денний ліміт до 20 перекладів**
```swift
// UserUsageTracker автоматично відстежує використання
let manager = TranslationManager.shared

// Перевірка доступності
if manager.canTranslateToday {
    print("✅ Доступно \(manager.remainingTranslations) з 20 перекладів")
} else {
    print("❌ Денний ліміт вичерпано")
}
```

### 2. **Вибір між звичайним та AI перекладом**
```swift
// Встановлення режиму
manager.setTranslationMode(.regular)  // Звичайний Google Translate
manager.setTranslationMode(.ai)       // AI з множинними варіантами

// Переклад з вибраним режимом
let options = try await manager.translateWithMode(
    text: "duck",
    from: "en",
    to: "uk"
)

// Regular mode -> 1 варіант: "качка"
// AI mode -> 4+ варіанти: "качка (птах)", "пригнутися (дія)", тощо
```

## Логування з новими лімітами:

### Користувацький ліміт:
```
👤 User Usage: 3/20 translations (15.0%), Remaining: 17
👤 User Usage: 4/20 translations (20.0%), Remaining: 16
👤 User Usage: 20/20 translations (100.0%), Remaining: 0
❌ Денний ліміт вичерпано (20/20)
```

### API ліміти (незалежно від користувацького):
```
📊 Groq Usage - Global: 45/14400 (0.3%), Tokens: 2800/25000 (11.2%)
🔑 Key Usage (gsk_MqKo): 1600/12500 tokens (12.8%)
⏰ Rate: 12/600 requests/hour, Remaining today: 14355 requests, 22200 tokens
```

## Переваги подвійної системи:

### 🧑‍🤝‍🧑 **Користувацький ліміт (20/день)**
- **Призначення**: Контроль використання додатку користувачем
- **Мета**: Запобігання зловживанням та справедливе використання
- **Скидання**: Щодня о півночі
- **Відображення**: В UI Settings як "User Daily Limit"

### 🤖 **API ліміти (14,400 запитів, 25,000 токенів)**
- **Призначення**: Технічні обмеження API провайдерів
- **Мета**: Уникнення перевищення API квот
- **Скидання**: За API правилами (зазвичай щодня)
- **Відображення**: В AI Settings як "Usage Statistics"

## Приклади використання в UI:

### Settings Screen:
```
📊 Статистика використання:
┌─────────────────────────────┐
│ 👤 Користувач: 8/20 (40%)   │
│ 🤖 API Запити: 45/14400     │
│ 🪙 API Токени: 2800/25000   │
│ ⏰ Швидкість: 12/600 год     │
└─────────────────────────────┘

🔧 Режим перекладу:
○ Звичайний переклад (швидко)
● ШІ переклад (детально)
```

### Translation Screen:
```
[Введіть текст: "bank"]

🔄 Режим: ШІ переклад
📊 Залишилось: 12/20 перекладів

Результати:
1. 🏦 банк (фінанси) - 95%
2. 🏞️ берег (річки) - 90%  
3. 💰 банк (гроші) - 85%
4. 📊 банк (дані) - 80%
```

## Код інтеграції:

### TextTranslatorView:
```swift
@StateObject private var translationManager = TranslationManager.shared

// Перевірка перед перекладом
private func translateText() {
    guard translationManager.canTranslateToday else {
        showError("Денний ліміт вичерпано. Спробуйте завтра.")
        return
    }
    
    Task {
        do {
            // Використання нового методу з режимом
            let options = try await translationManager.translateWithMode(
                text: sourceText,
                from: sourceLanguage,
                to: targetLanguage
            )
            
            await MainActor.run {
                translationOptions = options
                translatedText = options.first?.text ?? ""
            }
        } catch TranslationError.dailyLimitExceeded {
            showError("Денний ліміт перекладів вичерпано")
        } catch {
            showError(error.localizedDescription)
        }
    }
}
```

## Налаштування режиму:
```swift
// Settings для вибору режиму
Section("translation_mode".localized) {
    Picker("Режим", selection: $translationManager.selectedMode) {
        ForEach(TranslationMode.allCases, id: \.self) { mode in
            HStack {
                Image(systemName: mode.icon)
                Text(mode.displayName)
            }
            .tag(mode)
        }
    }
    .pickerStyle(SegmentedPickerStyle())
}
```

Тепер користувачі мають 20 перекладів на день та можуть обирати між швидким Google Translate та детальним AI перекладом з множинними варіантами!