# 📱 Google Play Marketga Chiqarish Bo'yicha Mukammal Yo'riqnoma (2026-yil Talablari Asosida) — Zolotoy Tour

Ushbu hujjat **Zolotoy Tour** mobil ilovasini Google Play Store platformasiga eng so'nggi (2026-yilgi) qat'iy qoidalarga to'liq muvofiq holda chiqarish bo'yicha amaliy qo'llanmadir.

---

## 🔍 1. Texnik Ko'rsatkichlar va Tekshiruv Natijalari (Audit)

Loyiha build konfiguratsiyasi tekshirildi va quyidagi parametrlar tasdiqlandi:

| Parametr | Qiymati | Holati |
| :--- | :--- | :--- |
| **Package ID** | `com.zolotoytouruz.app` | ✅ To'g'ri sozlangan |
| **Target SDK** | **Android 16 (API 36)** | ✅ 2026-yilgi eng so'nggi Google Play talabiga to'liq mos |
| **Min SDK** | `API 24` (Android 7.0+) | ✅ Barcha zamonaviy qurilmalarni qamrab oladi |
| **Format** | Android App Bundle (`.aab`) | ✅ Google Play talabi bo'yicha tayyor |
| **Ruxsatnomalar (Permissions)** | Faqat `INTERNET` va `ACCESS_NETWORK_STATE` | ✅ Xavfli/maxfiy tizim ruxsatlari yo'q |
| **Kod himoyasi (R8/ProGuard)** | `isMinifyEnabled = true`, `isShrinkResources = true` | ✅ Kod siqilgan va optimallashtirilgan |

---

## 🗂 2. Loyihadagi Tayyor Materiallar

| Fayl turi | Manzili | Izoh |
| :--- | :--- | :--- |
| **Android App Bundle (.aab)** | [app-release.aab](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/build/app/outputs/bundle/release/app-release.aab) | Play Console'ga yuklanadigan asosiy fayl (~41.5 MB) |
| **De-obfuscation (mapping.txt)** | [mapping.txt](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/build/app/outputs/mapping/release/mapping.txt) | R8 siqish xatolarini o'qish fayli |
| **Do'kon Ikonkasi (512x512 PNG)** | [icon_512x512.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/icon_512x512.png) | Play Store uchun rasmiy o'lchamdagi belgi |
| **Asosiy Banner (1024x500 PNG)** | [feature_graphic_1024x500.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/feature_graphic_1024x500.png) | Play Market qidiruv va do'kon sahifasi banneri |
| **5 ta Skrinshot (1080x2400 PNG)** | [store_assets/](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets) | 9:16 nisbatdagi tayyor reklama skrinshotlari |
| **Domen Huquqi Vakolatnomasi** | [DOMAIN_AUTHORIZATION_LETTER.md](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/DOMAIN_AUTHORIZATION_LETTER.md) | WebView siyosati uchun rasmiy tasdiqnoma hujjati |
| **Maxfiylik Siyosati (HTML)** | [docs/index.html](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/docs/index.html) | Jonli HTTPS sahifasi uchun tayyorlangan hujjat |

---

## ⚠️ 3. 2026-yilgi Muhim Qoidalar va Ehtiyot Choralari

### A. Domen va WebView Siyosati (Webviews and Affiliate Spam)
Google Play o'zganing veb-saytini ruxsatsiz WebView qilib chiqarishni taqiqlaydi. Buni oldini olish uchun:
1. Loyihada tayyorlab qo'yilgan [DOMAIN_AUTHORIZATION_LETTER.md](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/DOMAIN_AUTHORIZATION_LETTER.md) hujjatini kompaniya rahbari imzosi va muhri bilan to'ldirib oling.
2. Google Play Console'da **App content** > **Advance notice to Google Play** bo'limida ushbu xatni va domen boshqaruvi skrinshotini oldindan ilova qilib yuboring. Bu moderatsiyadan 100% muammosiz o'tishni kafolatlaydi.

### B. Akkaunt Turi va 12 Tester Qoidasi:
- **Tashkilot (Organization) akkaunti:** Agar akkaunt kompaniya (yuridik shaxs) nomiga ochilgan bo'lsa (D-U-N-S raqami bilan tasdiqlangan), ilovani darhol **Production (Ochiq reliz)** ga chiqarish mumkin.
- **Shaxsiy (Personal) yangi akkaunt:** 2023-yil 13-noyabrdan keyin ochilgan shaxsiy akkauntlarda Production'dan oldin:
  👉 **Kamida 12 nafar testlovchi (testers)** ilovaga a'zo bo'lib, **kamida 14 kun uzluksiz** Closed Testing'da turishi kerak. Shundan keyin "Apply for production" tugmasi orqali ochiq bozorga ruxsat so'raladi.

### C. Jonli HTTPS Maxfiylik Siyosati (Privacy Policy URL):
Google Play lokal faylni qabul qilmaydi, ochiq ishlaydigan HTTPS URL talab qiladi.
Ikkita qulay yechim mavjud:
- **1-variant (Asosiy saytda):** `store_assets/PRIVACY_POLICY.html` faylini saytingiz serveriga yuklab, havolasini `https://www.zolotoytouruz.uz/privacy` qilib oling.
- **2-variant (GitHub Pages orqali bir zumda):** Repozitoriyangizdagi [`docs/index.html`](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/docs/index.html) faylini GitHub Pages orqali yoqing:
  * GitHub repo sozlamalariga kiring: **Settings** > **Pages** > Branch: **main**, Folder: **/docs** > Save.
  * Sizda bepul, ochiq va doimiy HTTPS havola tayyor bo'ladi: `https://bergamp89-glitch.github.io/ZolotoyTour/`.

### D. Data Safety (Ma'lumotlar xavfsizligi) — To'g'ri to'ldirish tartibi:
Saytdagi tur bron qilish formasi orqali foydalanuvchilar ism va telefon kiritishi sababli, Google talabi bo'yicha Data Safety bo'limida quyidagicha to'ldiriladi:
- **Does your app collect or share any user data?** -> **Yes**
- **Is all of the user data collected by your app encrypted in transit?** -> **Yes** (HTTPS)
- **Do you provide a way for users to request that their data be deleted?** -> **Yes** (Email: `zolotoytouruz@gmail.com`)
- **Qaysi ma'lumotlar to'planadi?**
  * **Personal info -> Name (Ism):** Collected (To'planadi), Purpose: **App functionality** (Buyurtmalarni qayta ishlash), Ephemeral emas.
  * **Personal info -> Phone number (Telefon raqam):** Collected, Purpose: **App functionality / Account management** (Mijoz bilan aloqa).
  * Uchinchi shaxslarga berilmaydi (Not shared with 3rd parties).

---

## 📝 4. Qadam-baqadam Google Play Console Yo'riqnomasi

### 1-QADAM: Yangi ilova yaratish
1. [Google Play Console](https://play.google.com/console) saytiga kiring.
2. **"Create app"** tugmasini bosing:
   - **App name:** `Zolotoy Tour`
   - **Default language:** `Russian` yoki `Uzbek`
   - **App or game:** `App`
   - **Free or paid:** `Free`

---

### 2-QADAM: Do'kon Sahifasini To'ldirish (Main store listing)
**"Grow"** > **"Store presence"** > **"Main store listing"** bo'limida:

#### Matnlar:
- **App name:** `Zolotoy Tour`
- **Short description (80 belgigacha):**
  * Ruscha: `Бронируйте туры, находите горящие предложения и путешествуйте с Zolotoy Tour.`
  * O'zbekcha: `Zolotoy Tour bilan turlarni toping, sayohatni tanlang va buyurtma qiling.`
- **Full description (To'liq tavsif):**
```text
Zolotoy Tour — sizning ishonchli sayohat hamkoringiz!

Rasmiy Zolotoy Tour mobil ilovasi orqali dunyoning eng maftunkor burchaklariga unutilmas sayohatlarni osongina qidiring, tanlang va bron qiling.

Ilovaning asosiy imkoniyatlari:
✨ Qaynoq turlar (Горящие туры) — har kuni yangilanadigan eng manfaatli takliflar;
🌍 Keng yo'nalishlar — Turkiya, BAA (Dubay), Misr, Tailand, Yevropa, Malayziya, Gruziya va boshqa mashhur davlatlar;
🏨 Mehmonxonalarni qulay tanlash — narxlar, yulduzlar darajasi va qulayliklar bo'yicha to'liq ma'lumot;
✈️ Aviachiptalar va viza xizmati — viza rasmiylashtirish bo'yicha professional maslahat va yordam;
📞 24/7 aloqa — mutaxassislar bilan bir zumda bog'lanish va buyurtmani rasmiylashtirish.

Zolotoy Tour bilan orzuingizdagi sayohatni bugunoq boshlang!

Ofis manzili: O'zbekiston, Namangan sh., Hamroh ko'chasi, 5-uy.
Telefon: +998 77 043 44 44
Telegram: @zolotoy_tour
Veb-sayt: https://www.zolotoytouruz.uz/
```

#### Grafik fayllarni yuklash:
- **App icon:** [`store_assets/icon_512x512.png`](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/icon_512x512.png)
- **Feature graphic:** [`store_assets/feature_graphic_1024x500.png`](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/feature_graphic_1024x500.png)
- **Phone screenshots:** [`store_assets/`](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets) papkasidagi 5 ta skrinshot.

---

### 3-QADAM: Ilova Tarkibi (App content)
- **Privacy Policy:** Jonli HTTPS URL (saytingizdagi yoki GitHub Pages'dagi havola).
- **App access:** *"All functionality is available without special access"*.
- **Ads:** *"No, my app does not contain ads"*.
- **Content rating:** IARC so'rovnomasi (yosh chegarasi 3+ / Everyone).
- **Target audience:** 18+ (yoki 13+).
- **Data safety:** Yuqoridagi 3-bo'lim D-bandida ko'rsatilganidek (Ism va telefon raqami).
- **Financial / Health / Government apps:** Barchasiga "No".

---

### 4-QADAM: Reliz Yuklash va Tarqatish

1. Akkauntingiz turiga qarab:
   - Agar tashkilot bo'lsa: **Production** > **Create new release**.
   - Agar shaxsiy bo'lsa: **Closed testing** > **Create new release** (12 tester bilan 14 kunlik test).
2. **App bundle** joyiga yuklang:
   👉 [`build/app/outputs/bundle/release/app-release.aab`](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/build/app/outputs/bundle/release/app-release.aab)
3. **Release notes:**
   ```text
   Первый официальный релиз мобильного приложения Zolotoy Tour.
   - Поиск и бронирование туров
   - Горящие предложения
   - Визовая поддержка и связь с агентством
   ```
4. **Save** va **Start rollout** tugmasini bosing.
5. Google moderatsiyasi odatda **24 soatdan 3 ish kunigacha** davom etadi.
