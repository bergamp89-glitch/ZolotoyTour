# 🚀 Zolotoy Tour — App Store va Google Play Marketga Chiqarish Bo'yicha To'liq Qo'llanma

Ushbu hujjat **Zolotoy Tour** mobil ilovasini Google Play Store va Apple App Store platformalariga muvaffaqiyatli chiqarish (publish) uchun barcha texnik sozlamalar, talablar va qadam-baqadam yo'riqnomani o'z ichiga oladi.

---

## 📋 1. Loyihada Bajarilgan Texnik Tayyorgarliklar

Loyiha ikkala do'konning eng so'nggi (2024–2026) qat'iy talablariga to'liq moslashtirildi:

| Parametr | Android (Google Play) | iOS (App Store) | Holati |
| :--- | :--- | :--- | :--- |
| **Ilova ID (Package / Bundle ID)** | `com.zolotoytouruz.app` | `com.zolotoytouruz.app` | ✅ To'liq sozlangan |
| **Ilova nomi** | `Zolotoy Tour` | `Zolotoy Tour` | ✅ To'liq sozlangan |
| **Versiya** | `1.0.0` (Build `1`) | `1.0.0` (Build `1`) | ✅ `pubspec.yaml` da belgilangan |
| **SDK talabi** | `minSdk: 21`, `targetSdk: 34+`, `compileSdk: 34+` | `iOS 13.0+` | ✅ Play Store & Apple talabiga mos |
| **Ikonkalar** | Adaptive Icon + Mipmaplar | AppIcon (1024x1024 gacha barcha o'lchamlar) | ✅ Generatsiya qilingan |
| **Splash Screen** | Brend quyuq rang (`#1E1E1E`) bilan integratsiya qilingan | Qora-oltin fon (`#1E1E1E`) bilan launch storyboard | ✅ Oq miltillash (white flash) yo'q |
| **R8 / ProGuard** | `isMinifyEnabled = true`, `isShrinkResources = true` | Dead code stripping yoqilgan | ✅ Kod siqilgan va himoyalangan |
| **Maxfiylik (Privacy Manifest)** | Internet ruxsatnomalari to'g'ri ko'rsatilgan | `PrivacyInfo.xcprivacy` (Apple 2024 talabi) | ✅ Tayyor |
| **Xavfsizlik (ATS)** | HTTPS traffic prioriteti | `NSAllowsArbitraryLoads: false`, `InWebContent: true` | ✅ App Store qoidalariga mos |
| **Avtomatlashtirilgan testlar** | 22/22 test muvaffaqiyatli o'tgan | 0 ta linter/analizator xatosi | ✅ 100% toza |

---

## 🤖 2. Google Play Marketga Chiqarish (Android)

### 1-qadam: Release Keystore (Imzo kaliti) yaratish

Google Play ilovaning haqiqiyligini tekshirish uchun uni maxsus raqamli kalit (`keystore`) bilan imzolashni talab qiladi.

Terminalda (PowerShell yoki Git Bash) loyiha papkasida quyidagi buyruqni ishga tushiring:

```bash
keytool -genkey -v -keystore android/keystore/zolotoytour-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zolotoytour
```

Sizdan quyidagi ma'lumotlar so'raladi:
1. **Parol kiriting**: Masalan, kuchli parol tanlang (parolni albatta saqlab qo'ying!).
2. Ism, tashkilot nomi, shahar va davlat kodi (`UZ`).
3. Yakunida `yes` deb tasdiqlang.

### 2-qadam: `android/key.properties` faylini to'ldirish

`android/key.properties` faylini oching va belgilagan parollaringizni yozing:

```properties
storePassword=SIZ_TANLAGAN_PAROL
keyPassword=SIZ_TANLAGAN_PAROL
keyAlias=zolotoytour
storeFile=../keystore/zolotoytour-release.jks
```

*(Eslatma: `key.properties` va `.jks` fayli `.gitignore` ga kiritilgan, ular ochiq tarmoqqa chiqib ketmaydi).*

### 3-qadam: Android App Bundle (.aab) faylini yig'ish

Google Play faqat `.aab` (Android App Bundle) formatini qabul qiladi. Terminalda:

```bash
flutter build appbundle --release
```

Yig'ilgan fayl quyidagi manzilda tayyor bo'ladi:
👉 `build/app/outputs/bundle/release/app-release.aab`

*(Agar o'zingiz telefoningizga o'rnatib ko'rish uchun APK kerak bo'lsa: `flutter build apk --release` buyrug'ini ishlatishingiz mumkin).*

---

### 4-qadam: Google Play Console'da sozlash

1. [Google Play Console](https://play.google.com/console) ga kiring (Dasturchi hisobi mavjud bo'lishi kerak - bir martalik to'lovi $25).
2. **Create app** (Ilova yaratish) tugmasini bosing:
   - App name: **Zolotoy Tour**
   - Default language: **Russian (ru-RU)** yoki **Uzbek (uz)**
   - App or game: **App**
   - Free or paid: **Free** (Bepul)
3. **App content** (Ilova tarkibi) bo'limida quyidagilarni to'ldiring:
   - **Privacy Policy**: Veb-saytdagi havola (masalan, `https://www.zolotoytouruz.uz/` yoki alohida maxfiylik sahifasi).
   - **App access**: Barcha funksiyalar cheklovlarsiz ochiq (*All functionality is available without special access*).
   - **Ads**: Ilovada reklama yo'q (*No, my app does not contain ads*).
   - **Content rating**: So'rovnomani to'ldiring (Ijtimoiy tarmoq emas, qimor emas, turizm ma'lumotlari). Barcha yoshdagilar uchun mos (*Everyone 3+*).
   - **Target audience**: 18 yoshdan katta yoki 13+.
   - **News apps**: Ilova yangiliklar agentligi emas (*No*).
   - **COVID-19 / Government apps**: Hukumat ilovasi emas (*No*).
   - **Data safety (Ma'lumotlar xavfsizligi)**:
     - Ilova o'zida shaxsiy ma'lumotlarni to'plamaydi yoki uchinchi tomonga sotmaydi (*No user data collected by the native app wrapper*). Sayt orqali bron qilinganda ma'lumotlar to'g'ridan-to'g'ri himoyalangan HTTPS orqali sayt serveriga yuboriladi.
4. **Main store listing (Asosiy do'kon sahifasi)**:
   - **App name**: `Zolotoy Tour`
   - **Short description (Qisqa tavsif)**:
     * `Бронирование туров и путешествий по всему миру с Zolotoy Tour.`
   - **Full description (To'liq tavsif)**:
     * Rasmiy Zolotoy Tour mobil ilovasi orqali qaynoq turlar, dunyo bo'ylab sayohatlar, aviachiptalar va viza xizmatlarini qulay qidirish va bron qilish imkoniyati.
   - **App Icon**: 512x512 PNG formatdagi logotip (loyihadagi `assets/images/app_icon.png` dan olinadi).
   - **Feature Graphic**: 1024x500 PNG banner (Zolotoy Tour brend banneri).
   - **Phone Screenshots**: Telefon ekranidagi ilovadan olingan kamida 2-4 ta skrinshot.
5. **Production Release (Ishchi reliz)**:
   - **Releases** > **Create new release** bo'limiga kiring.
   - `build/app/outputs/bundle/release/app-release.aab` faylini yuklang.
   - Release name: `1.0.0 (1)`.
   - **Review and roll out to production** tugmasini bosing.
   - Google tekshiruvi 1–3 kun davom etadi.

---

## 🍏 3. Apple App Store ga Chiqarish (iOS)

> *Eslatma: iOS uchun yig'ish va yuklash macOS operatsion tizimi (MacBook / Mac mini / iMac) hamda yillik Apple Developer akkaunti ($99/yil) talab qiladi.*

### 1-qadam: Loyihani Xcode'da ochish

Mac kompyuterida terminal orqali:

```bash
open ios/Runner.xcworkspace
```

### 2-qadam: Signing & Team sozlamasi

1. Xcode oynasida chap tomondan **Runner** loyihasini tanlang.
2. **Targets** ostidan **Runner** ni tanlang va **Signing & Capabilities** tabiga o'ting.
3. **Team** bo'limida o'zingizning Apple Developer profilingizni tanlang.
4. **Bundle Identifier** avtomatik `com.zolotoytouruz.app` ekanligiga ishonch hosil qiling.

### 3-qadam: Ilova arxivini (Archive / IPA) yaratish

Terminal orqali:

```bash
flutter build ipa --release
```

yoki to'g'ridan-to'g'ri Xcode menyusidan:
1. Yuqori menyudan nishon qurilmani **Any iOS Device (arm64)** qilib tanlang.
2. **Product** > **Archive** buyrug'ini bosing.
3. Jarayon tugagach, **Organizer** oynasi ochiladi.
4. **Distribute App** > **App Store Connect** > **Upload** tugmasini bosib, to'g'ridan-to'g'ri App Store ga jo'nating.

---

### 4-qadam: App Store Connect'da sahifani to'ldirish

1. [App Store Connect](https://appstoreconnect.apple.com/) saytiga kiring.
2. **Apps** > **+ (New App)**:
   - Platform: **iOS**
   - Name: **Zolotoy Tour**
   - Primary Language: **Russian** yoki **Uzbek**
   - Bundle ID: `com.zolotoytouruz.app`
   - SKU: `zolotoytour001`
   - User Access: **Full Access**
3. **App Information**:
   - Privacy Policy URL: Masalan `https://www.zolotoytouruz.uz/kontakty`
   - Category: **Travel** (Путешествия)
4. **Pricing and Availability**:
   - Bepul (Free).
5. **App Privacy (Maxfiylik so'rovnomasi)**:
   - "Do you collect data?" degan joyga: Agar tahliliy ma'lumotlar olinmasa, "Data Not Collected" deb belgilashingiz mumkin.
6. **Version Information (1.0.0)**:
   - **Screenshots**:
     * iPhone 6.7" (iPhone 15/16 Pro Max o'lchami: 1290 x 2796)
     * iPhone 6.5" (iPhone 11 Pro Max / XS Max o'lchami: 1242 x 2688)
   - **Keywords**: `туризм, туры, zolotoy tour, горящие туры, путешествия, наманган, узбекистан, авиабилеты`
   - **Support URL**: `https://www.zolotoytouruz.uz/kontakty`
   - **Marketing URL**: `https://www.zolotoytouruz.uz/`
   - **Description**:
     * Ilovaning to'liq imkoniyatlari (qaynoq turlarni tanlash, mehmonxonalarni bron qilish, vizalar bo'yicha ma'lumot olish).
7. **Build tanlash**:
   - Xcode orqali yuklangan `1.0.0 (1)` relizini tanlang.
   - *Export Compliance*: Savol berganda "No" (chunki `ITSAppUsesNonExemptEncryption = false` qilib sozlangan).
8. **Submit for Review** (Tekshiruvga yuborish) tugmasini bosing.
   - Apple tekshiruvi odatda 24–48 soat ichida yakunlanadi.

---

## 🔄 4. Kelajakda Yangilanishlar Chiqarish

### Sayt o'zgarganda ilovani yangilash shartmi?
❌ **Yo'q!** Saytda yangi turlar, narxlar, fotosuratlar, yangi sahifalar yoki aksiyalar qo'shilganda, ilova bularni **avtomatik tarzda real vaqtda** ko'rsatadi. Ilovani qayta do'konga yuklash talab etilmaydi.

### Qachon ilovani yangilash kerak bo'ladi?
Faqatgina Flutter versiyasini ko'targanda, yangi native funksiyalar qo'shilganda yoki ilova ikonkasini almashtirmoqchi bo'lganingizda.

**Ilovani yangilash tartibi:**
1. `pubspec.yaml` faylida versiya raqamini 1 taga oshiring:
   ```yaml
   version: 1.0.1+2
   ```
2. Yangi bundle yig'ing:
   - Android: `flutter build appbundle --release`
   - iOS: `flutter build ipa --release`
3. Do'konlarga yangi versiya sifatida yuklang.

---

## 📞 Yordam va Texnik Aloqa
- **Veb-sayt**: https://www.zolotoytouruz.uz/
- **Aloqa**: +998 77 043 44 44
- **Telegram**: [@zolotoy_tour](https://t.me/zolotoy_tour)
