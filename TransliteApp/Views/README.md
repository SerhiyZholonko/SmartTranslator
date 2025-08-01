# Views Structure

Нова організація Views у проекті TransliteApp для кращої структури коду та навігації.

## 📁 Структура папок

### 🎯 Screens/
Основні екрани додатку, згруповані за функціональністю:

#### 📱 Main/
- **SideMenuView.swift** - Бічне меню з навігацією та налаштуваннями

#### 🌍 Translation/
Всі View пов'язані з перекладом:
- **TextTranslatorView.swift** - Переклад тексту (основна функція)
- **VoiceChatView.swift** - Голосовий переклад
- **CameraTranslatorView.swift** - Переклад через камеру (Premium)
- **FileTranslatorView.swift** - Переклад файлів (Premium)
- **OfflineTranslationView.swift** - Офлайн переклад

#### 🎓 Flashcards/
- **FlashcardsView.swift** - Система флешкарток для вивчення мов
  - Містить: FlashcardsView, DeckCardWrapper, DeckCard, StatItem, AddCardView, CreateDeckView, StudyView, FlashcardView, StudyCompleteView

#### 💎 Premium/
- **PremiumView.swift** - Екран преміум підписки

#### ⚙️ Settings/
Налаштування та допоміжні екрани:
- **SettingsView.swift** - Налаштування додатку
- **HistoryView.swift** - Історія перекладів

### 🧩 Components/
Багаторазові UI компоненти:
- **FeatureCard.swift** - Картка функції на головному екрані
- **GlobeView.swift** - Анімований глобус
- **HeaderView.swift** - Заголовок з кнопками меню та преміум

## 🔄 Переваги нової структури

### ✅ Організація
- **Логічне групування** - файли згруповані за функціональністю
- **Легка навігація** - швидко знайти потрібний екран
- **Масштабованість** - легко додавати нові екрани

### 🎯 Розділення відповідальностей
- **Screens/** - повноцінні екрани з бізнес-логікою  
- **Components/** - перевикористовувані UI елементи
- **Ясна архітектура** - зрозуміла ієрархія залежностей

### 👥 Командна робота
- **Менше конфліктів** - файли в різних папках
- **Спрощений код-рев'ю** - зрозуміла структура
- **Легший онбординг** - нові розробники швидше розберуться

## 🔍 Як знайти потрібний файл

```
Потрібен переклад тексту? → Screens/Translation/TextTranslatorView.swift
Потрібна історія? → Screens/Settings/HistoryView.swift  
Потрібне бічне меню? → Screens/Main/SideMenuView.swift
Потрібен UI компонент? → Components/
```

## 📋 Чекліст для нових екранів

При додаванні нового екрану:

1. **Визначити категорію** (Translation, Settings, Premium, тощо)
2. **Додати у відповідну папку** Screens/
3. **Перевикористати компоненти** з Components/
4. **Документувати** у цьому README

## 🚀 Майбутні покращення

- [ ] Додати більше багаторазових компонентів
- [ ] Створити окремі папки для великих екранів (наприклад Flashcards/Components/)
- [ ] Додати ViewModels у відповідну структуру
- [ ] Створити стилі та теми в окремій папці

---

**Створено:** 2025-07-19  
**Версія:** 1.0  
**Автор:** Claude Code Assistant