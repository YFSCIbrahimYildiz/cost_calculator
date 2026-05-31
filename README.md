# Maliyet Hesabı

Bir ürün üreten küçük ve orta ölçekli imalatçılar için **hammadde maliyeti** ve **önerilen satış fiyatı** hesaplama uygulaması.

Masa üreten bir marangoz, süt işleyen bir mandıra ya da sabun yapan bir atölye — reçetesi belli (hangi hammaddeden ne kadar kullanıldığı bilinen) bir ürünü olan herkes, ürününün gerçek maliyetini ve kâr marjına göre satış fiyatını hesaplayabilir.

> **Durum:** Geliştirme aşamasında (MVP). Çekirdek hesaplama ve veri katmanı geliştiriliyor.

---

## Ne işe yarar?

- **Hammadde tanımlama:** Alış fiyatı ve miktarından birim maliyet otomatik hesaplanır.
- **Reçete oluşturma:** Bir ürünün hangi hammaddeden ne kadar kullandığı, fire (kayıp) oranıyla birlikte tanımlanır.
- **Maliyet hesabı:** Reçetedeki tüm hammaddelerin maliyeti, fire dahil toplanır.
- **Satış fiyatı önerisi:** Toplam maliyete kâr marjı eklenerek önerilen satış fiyatı çıkar.

### Hesaplama mantığı

\`\`\`
Hammadde birim fiyatı = alış fiyatı / alış miktarı
Bir hammaddenin üründeki maliyeti = birim fiyat × miktar × (1 + fire oranı / 100)
Ürünün toplam maliyeti = reçetedeki tüm hammadde maliyetlerinin toplamı
Önerilen satış fiyatı = toplam maliyet × (1 + kâr marjı / 100)
\`\`\`

---

## Teknolojiler

- **Flutter** — çapraz platform mobil uygulama (Android / iOS)
- **Dart** — uygulama dili
- **SQLite** (\`sqflite\`) — yerel veritabanı, internet gerektirmez

## Mimari

Katmanlı mimari (separation of concerns) ile geliştirilmektedir:

\`\`\`
lib/
├── models/        → veri sınıfları (RawMaterial, Product, Recipe)
├── database/      → SQLite bağlantısı ve CRUD işlemleri
├── services/      → maliyet hesaplama motoru (UI'dan bağımsız)
└── screens/       → kullanıcı arayüzü
\`\`\`

Hesaplama motoru arayüzden tamamen ayrıdır; bu sayede bağımsız test edilebilir ve arayüz değişse de etkilenmez.

---

## Yol Haritası

**MVP (mevcut)**
- [x] Veri modelleri
- [x] Veritabanı katmanı (hammadde, ürün, reçete CRUD)
- [x] Maliyet hesaplama motoru
- [ ] Kullanıcı arayüzü
- [ ] Play Store yayını

**v2 (planlanan)**
- [ ] Hammadde fiyat geçmişi (tarihli kayıt)
- [ ] Ek maliyetler (elektrik, su, kira — aylık üretime bölünür)
- [ ] Geçmiş hesap kayıtları

> Not: MVP'de hesaplanan fiyat yalnızca hammadde maliyetini içerir; genel giderler (elektrik, su, kira) v2'de eklenecektir.

---

## Kurulum

\`\`\`bash
flutter pub get
flutter run
\`\`\`

---
---

# Cost Calculation

A cost and sale-price calculation application for small and medium-sized manufacturers who produce a single product.

A carpenter making tables, a dairy processing milk, or a workshop making soap — anyone with a product that has a defined recipe (knowing which raw materials are used and how much) can calculate their product's real cost and its sale price based on a profit margin.

> **Status:** In development (MVP). The core calculation and data layers are being built.

---

## What does it do?

- **Raw material definition:** Unit cost is calculated automatically from the purchase price and quantity.
- **Recipe creation:** Defines how much of which raw material a product uses, together with a waste (loss) rate.
- **Cost calculation:** The cost of all raw materials in the recipe is summed, including waste.
- **Sale price suggestion:** A profit margin is added to the total cost to produce the suggested sale price.

### Calculation logic

\`\`\`
Raw material unit price = purchase price / purchase quantity
Cost of a raw material in a product = unit price × quantity × (1 + loss rate / 100)
Total product cost = sum of all raw material costs in the recipe
Suggested sale price = total cost × (1 + profit margin / 100)
\`\`\`

---

## Technologies

- **Flutter** — cross-platform mobile application (Android / iOS)
- **Dart** — application language
- **SQLite** (\`sqflite\`) — local database, no internet required

## Architecture

Built with a layered architecture (separation of concerns):

\`\`\`
lib/
├── models/        → data classes (RawMaterial, Product, Recipe)
├── database/      → SQLite connection and CRUD operations
├── services/      → cost calculation engine (UI-independent)
└── screens/       → user interface
\`\`\`

The calculation engine is completely separate from the UI; this makes it independently testable and unaffected by interface changes.

---

## Roadmap

**MVP (current)**
- [x] Data models
- [x] Database layer (raw material, product, recipe CRUD)
- [x] Cost calculation engine
- [ ] User interface
- [ ] Play Store release

**v2 (planned)**
- [ ] Raw material price history (dated records)
- [ ] Additional costs (electricity, water, rent — divided by monthly production)
- [ ] Past calculation records

> Note: In the MVP, the calculated price includes only raw material cost; general expenses (electricity, water, rent) will be added in v2.

---

## Setup

\`\`\`bash
flutter pub get
flutter run
\`\`\`
