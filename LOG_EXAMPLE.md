# Приклад логування з оновленими лімітами Groq Free Tier

## Оновлені ліміти (2024):
- **Запити**: 14,400/день (~600/годину, 8/хвилину)
- **Токени**: 25,000/день загально
- **Per-key ліміт**: 12,500 токенів/день на ключ

## Раніше (старі ліміти):
```
📊 Groq Usage - Requests: 3/10 (30.0%), Tokens: 450/6000 (7.5%)
✅ GroqTranslationService: Generated 4 enhanced translations using 150 tokens
```

## Тепер (з реальними лімітами та per-key tracking):
```
📊 Groq Usage - Global: 45/14400 (0.3%), Tokens: 2800/25000 (11.2%)
🔑 Key Usage (gsk_MqKo): 1600/12500 tokens (12.8%)
⏰ Rate: 12/600 requests/hour, Remaining today: 14355 requests, 22200 tokens
✅ GroqTranslationService: Generated 4 enhanced translations using 156 tokens

📊 Groq Usage - Global: 46/14400 (0.3%), Tokens: 2956/25000 (11.8%)
🔑 Key Usage (gsk_Esoe): 1200/12500 tokens (9.6%)
⏰ Rate: 11/600 requests/hour, Remaining today: 14354 requests, 22044 tokens
✅ GroqTranslationService: Generated 3 enhanced translations using 156 tokens
```

## В UI Settings відображається:
- **Запити за день**: 46 / 14,400 (0.3%)
- **Токени за день**: 2,956 / 25,000 (11.8%)
- **Швидкість (на годину)**: 11 / 600 (1.8%)

## Що покращено:
- **Реалістичні ліміти**: 14,400 запитів замість 10
- **Більший токен-ліміт**: 25,000 замість 6,000
- **Per-key balance**: 12,500 токенів на ключ
- **Hourly rate tracking**: поточна швидкість запитів
- **Remaining counters**: скільки залишилось на сьогодні
- **Smart rotation**: вибір ключа з найменшим використанням

## Рекомендації для оптимізації:
- **Чат-бот**: llama-3.1-8b-instant (швидкий)
- **Голосовий помічник**: whisper-large-v3-turbo + llama-3.1-8b-instant
- **Кешування**: часті запити зберігати локально
- **Короткі промпти**: зменшити споживання токенів