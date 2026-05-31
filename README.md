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

```
Hammadde birim fiyatı = alış fiyatı / alış miktarı
Bir hammaddenin üründeki maliyeti = birim fiyat × miktar × (1 + fire oranı / 100)
Ürünün toplam maliyeti = reçetedeki tüm hammadde maliyetlerinin toplamı
Önerilen satış fiyatı = toplam maliyet × (1 + kâr marjı / 100)
```

---

## Teknolojiler

- **Flutter** — çapraz platform mobil uygulama (Android / iOS)
- **Dart** — uygulama dili
- **SQLite** (`sqflite`) — yerel veritabanı, internet gerektirmez

## Mimari

Katmanlı mimari (separation of concerns) ile geliştirilmektedir:

```
lib/
├── models/        → veri sınıfları (RawMaterial, Product, Recipe)
├── database/      → SQLite bağlantısı ve CRUD işlemleri
├── services/      → maliyet hesaplama motoru (UI'dan bağımsız)
└── screens/       → kullanıcı arayüzü
```

Hesaplama motoru arayüzden tamamen ayrıdır; bu sayede bağımsız test edilebilir ve arayüz değişse de etkilenmez.

---

## Yol Haritası

**MVP (mevcut)**
- [x] Veri modelleri
- [x] Veritabanı katmanı (hammadde, ürün, reçete CRUD)
- [ ] Maliyet hesaplama motoru
- [ ] Kullanıcı arayüzü
- [ ] Play Store yayını

**v2 (planlanan)**
- [ ] Hammadde fiyat geçmişi (tarihli kayıt)
- [ ] Ek maliyetler (elektrik, su, kira — aylık üretime bölünür)
- [ ] Geçmiş hesap kayıtları

> Not: MVP'de hesaplanan fiyat yalnızca hammadde maliyetini içerir; genel giderler (elektrik, su, kira) v2'de eklenecektir.

---



**Maliyet Hesabı** (*Cost Calculation*) is a cost and pricing calculator for small-to-medium manufacturers who produce a single product type — a furniture maker, a dairy producer, a soap workshop, and so on.

Given a product's recipe (which raw materials and how much of each, including a waste/loss rate), the app computes the real production cost and suggests a sale price based on a profit margin.

**Built with:** Flutter, Dart, SQLite (`sqflite`)

**Architecture:** Layered (models / database / services / screens), with a UI-independent calculation engine.

**Status:** In development (MVP). Core calculation and data layers are being built.

---

## Kurulum

```bash
flutter pub get
flutter run
```
