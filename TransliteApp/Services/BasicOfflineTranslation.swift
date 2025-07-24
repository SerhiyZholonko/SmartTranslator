import Foundation

// Basic offline translation for common words when Apple Translation is not available
class BasicOfflineTranslation {
    static let shared = BasicOfflineTranslation()
    
    // Basic dictionary for common words (expandable)
    private let translations: [String: [String: String]] = [
        // English to Ukrainian
        "en-uk": [
            "hello": "привіт",
            "goodbye": "до побачення",
            "yes": "так",
            "no": "ні",
            "please": "будь ласка",
            "thank you": "дякую",
            "sorry": "вибачте",
            "good": "добре",
            "bad": "погано",
            "water": "вода",
            "food": "їжа",
            "help": "допомога",
            "love": "любов",
            "friend": "друг",
            "family": "сім'я",
            "home": "дім",
            "work": "робота",
            "school": "школа",
            "time": "час",
            "day": "день",
            "night": "ніч",
            "morning": "ранок",
            "evening": "вечір",
            "today": "сьогодні",
            "tomorrow": "завтра",
            "yesterday": "вчора",
            "i": "я",
            "you": "ти",
            "he": "він",
            "she": "вона",
            "we": "ми",
            "they": "вони",
            "what": "що",
            "where": "де",
            "when": "коли",
            "why": "чому",
            "how": "як",
            "name": "ім'я",
            "translate": "перекласти",
            "language": "мова",
            "understand": "розуміти",
            "speak": "говорити",
            "write": "писати",
            "read": "читати"
        ],
        // Ukrainian to English
        "uk-en": [
            "привіт": "hello",
            "до побачення": "goodbye",
            "так": "yes",
            "ні": "no",
            "будь ласка": "please",
            "дякую": "thank you",
            "вибачте": "sorry",
            "добре": "good",
            "погано": "bad",
            "вода": "water",
            "їжа": "food",
            "допомога": "help",
            "любов": "love",
            "друг": "friend",
            "сім'я": "family",
            "дім": "home",
            "робота": "work",
            "школа": "school",
            "час": "time",
            "день": "day",
            "ніч": "night",
            "ранок": "morning",
            "вечір": "evening",
            "сьогодні": "today",
            "завтра": "tomorrow",
            "вчора": "yesterday",
            "я": "i",
            "ти": "you",
            "він": "he",
            "вона": "she",
            "ми": "we",
            "вони": "they",
            "що": "what",
            "де": "where",
            "коли": "when",
            "чому": "why",
            "як": "how",
            "ім'я": "name",
            "перекласти": "translate",
            "мова": "language",
            "розуміти": "understand",
            "говорити": "speak",
            "писати": "write",
            "читати": "read"
        ],
        // English to Russian
        "en-ru": [
            "hello": "привет",
            "goodbye": "до свидания",
            "yes": "да",
            "no": "нет",
            "please": "пожалуйста",
            "thank you": "спасибо",
            "sorry": "извините",
            "good": "хорошо",
            "bad": "плохо",
            "water": "вода",
            "food": "еда",
            "help": "помощь",
            "love": "любовь",
            "friend": "друг",
            "family": "семья",
            "home": "дом",
            "work": "работа",
            "school": "школа",
            "time": "время",
            "day": "день",
            "night": "ночь",
            "morning": "утро",
            "evening": "вечер",
            "today": "сегодня",
            "tomorrow": "завтра",
            "yesterday": "вчера"
        ],
        // Russian to English
        "ru-en": [
            "привет": "hello",
            "до свидания": "goodbye",
            "да": "yes",
            "нет": "no",
            "пожалуйста": "please",
            "спасибо": "thank you",
            "извините": "sorry",
            "хорошо": "good",
            "плохо": "bad",
            "вода": "water",
            "еда": "food",
            "помощь": "help",
            "любовь": "love",
            "друг": "friend",
            "семья": "family",
            "дом": "home",
            "работа": "work",
            "школа": "school",
            "время": "time",
            "день": "day",
            "ночь": "night",
            "утро": "morning",
            "вечер": "evening",
            "сегодня": "today",
            "завтра": "tomorrow",
            "вчера": "yesterday"
        ],
        // English to Spanish
        "en-es": [
            "hello": "hola",
            "goodbye": "adiós",
            "yes": "sí",
            "no": "no",
            "please": "por favor",
            "thank you": "gracias",
            "sorry": "lo siento",
            "good": "bueno",
            "bad": "malo",
            "water": "agua",
            "food": "comida",
            "help": "ayuda",
            "love": "amor",
            "friend": "amigo",
            "family": "familia",
            "home": "casa",
            "work": "trabajo",
            "school": "escuela",
            "time": "tiempo",
            "day": "día",
            "night": "noche",
            "morning": "mañana",
            "evening": "tarde",
            "today": "hoy",
            "tomorrow": "mañana",
            "yesterday": "ayer"
        ],
        // Spanish to English
        "es-en": [
            "hola": "hello",
            "adiós": "goodbye",
            "sí": "yes",
            "no": "no",
            "por favor": "please",
            "gracias": "thank you",
            "lo siento": "sorry",
            "bueno": "good",
            "malo": "bad",
            "agua": "water",
            "comida": "food",
            "ayuda": "help",
            "amor": "love",
            "amigo": "friend",
            "familia": "family",
            "casa": "home",
            "trabajo": "work",
            "escuela": "school",
            "tiempo": "time",
            "día": "day",
            "noche": "night",
            "mañana": "morning",
            "tarde": "evening",
            "hoy": "today",
            "ayer": "yesterday"
        ]
    ]
    
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String) -> String? {
        let key = "\(sourceLanguage)-\(targetLanguage)"
        let lowercasedText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try exact match first
        if let dictionary = translations[key], let translation = dictionary[lowercasedText] {
            return translation
        }
        
        // Try to translate word by word for simple phrases
        let words = lowercasedText.split(separator: " ")
        if words.count > 1, let dictionary = translations[key] {
            let translatedWords = words.compactMap { word -> String? in
                let cleanWord = String(word).trimmingCharacters(in: CharacterSet.punctuationCharacters)
                return dictionary[cleanWord]
            }
            
            // If we translated at least some words, return partial translation
            if !translatedWords.isEmpty {
                if translatedWords.count == words.count {
                    return translatedWords.joined(separator: " ")
                } else {
                    // Partial translation - mix translated and original words
                    var result: [String] = []
                    for (_, word) in words.enumerated() {
                        let cleanWord = String(word).trimmingCharacters(in: CharacterSet.punctuationCharacters)
                        if let translation = dictionary[cleanWord] {
                            result.append(translation)
                        } else {
                            result.append(String(word))
                        }
                    }
                    return result.joined(separator: " ")
                }
            }
        }
        
        return nil
    }
    
    func isLanguagePairSupported(from sourceLanguage: String, to targetLanguage: String) -> Bool {
        let key = "\(sourceLanguage)-\(targetLanguage)"
        return translations[key] != nil
    }
    
    func getDictionarySize() -> Int {
        return translations.values.reduce(0) { $0 + $1.count }
    }
    
    func getSupportedLanguagePairs() -> [String] {
        return Array(translations.keys)
    }
}