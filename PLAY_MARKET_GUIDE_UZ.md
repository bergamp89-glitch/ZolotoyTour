# 📱 Google Play Marketga Chiqarish Bo'yicha Mukammal Yo'riqnoma — Zolotoy Tour

Ushbu qo'llanma **Zolotoy Tour** mobil ilovasini Google Play Console orqali Google Play Marketga muvaffaqiyatli yuklash va moderatsiyadan o'tkazish uchun barcha tayyor fayllar, qadam-baqadam ko'rsatmalar va zarur matnlarni o'z ichiga oladi.

---

## 🗂 1. Loyihada To'liq Tayyorlab Qo'yilgan Fayllar

Barcha texnik va vizual materiallar to'liq tayyorlangan va loyihada joylashgan:

| Fayl turi | Fayl joylashuvi | Maqsadi |
| :--- | :--- | :--- |
| **Android App Bundle (.aab)** | [app-release.aab](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/build/app/outputs/bundle/release/app-release.aab) | Play Console'ga yuklanadigan asosiy imzolangan reliz fayli (~41.5 MB) |
| **De-obfuscation (mapping.txt)** | [mapping.txt](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/build/app/outputs/mapping/release/mapping.txt) | R8 siqishdan keyingi koddagi xatolarni o'qish fayli |
| **Do'kon Ikonkasi (512x512 PNG)** | [icon_512x512.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/icon_512x512.png) | Google Play Store listing uchun rasmiy belgilangan o'lchamdagi belgi |
| **Asosiy Banner (1024x500 PNG)** | [feature_graphic_1024x500.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/feature_graphic_1024x500.png) | Play Market qidiruv va do'kon sahifasi tepasidagi majburiy banner |
| **Skrinshot 1 (Bosh sahifa)** | [screenshot_1_home.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/screenshot_1_home.png) | 1080x2400 (9:16) yuqori sifatli vizual taqdimot |
| **Skrinshot 2 (Turlar qidiruvi)** | [screenshot_2_tours.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/screenshot_2_tours.png) | 1080x2400 (9:16) tur tanlash sahifasi |
| **Skrinshot 3 (Qaynoq turlar)** | [screenshot_3_hot_tours.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/screenshot_3_hot_tours.png) | 1080x2400 (9:16) qaynoq turlar taqdimoti |
| **Skrinshot 4 (Xizmatlarimiz)** | [screenshot_4_services.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/screenshot_4_services.png) | 1080x2400 (9:16) viza va aviachiptalar xizmati |
| **Skrinshot 5 (Aloqa va manzil)** | [screenshot_5_contacts.png](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/screenshot_5_contacts.png) | 1080x2400 (9:16) mijozlar xizmati va ofis manzili |
| **Maxfiylik Siyosati (HTML)** | [PRIVACY_POLICY.html](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/PRIVACY_POLICY.html) | Ikki tilli (O'zbek / Rus) rasmiy maxfiylik hujjati |
| **Imzo Kaliti (Keystore)** | [zolotoytour-release.jks](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/android/keystore/zolotoytour-release.jks) | Parol: `ZolotoyTour2026!SecureKey` (Alias: `zolotoytour`) |

---

## ⚠️ 2. Google Play Siyosati: Akkaunt Turini Tekshirish (Muhim!)

Google Play 2023-yil 13-noyabrdan boshlab yangi qoida joriy qilgan:
- **Tashkilot (Organization) akkaunti bo'lsa:** Ilovani to'g'ridan-to'g'ri **Production (Ochiq reliz)** ga chiqarish mumkin.
- **Jismoniy shaxs (Personal) yangi akkaunti bo'lsa:** Ilovani asosiy bozorga chiqarishdan oldin **Closed Testing (Yopiq test)** bo'limida kamida **20 nafar testlovchi (testers)** ilovaga 14 kun davomida a'zo bo'lib turishi talab qilinadi. Shundan so'ng "Apply for production" tugmasi ochiladi.

---

## 📝 3. Qadam-baqadam Google Play Console Yo'riqnomasi

### 1-QADAM: Yangi ilova yaratish
1. [Google Play Console](https://play.google.com/console) saytiga kiring.
2. O'ng yuqoridagi **"Create app"** (Ilova yaratish) tugmasini bosing:
   - **App name:** `Zolotoy Tour`
   - **Default language:** `Russian` yoki `Uzbek`
   - **App or game:** `App`
   - **Free or paid:** `Free` (Bepul)
   - Qoidalarga rozilik belgilarini qo'yib, **"Create app"** ni bosing.

---

### 2-QADAM: Ilova Tarkibi va Xavfsizlik So'rovnomasi (App content)
Chap menyudan **"App content"** bo'limiga kiring va quyidagi vazifalarni bajaring:

1. **Privacy Policy (Maxfiylik siyosati):**
   - Veb-saytdagi havolani ko'rsating: masalan `https://www.zolotoytouruz.uz/kontakty` yoki yuqoridagi [PRIVACY_POLICY.html](file:///c:/Users/Asia%20Electronics/Desktop/projects/zolotoytour/store_assets/PRIVACY_POLICY.html) faylini saytingizga `https://www.zolotoytouruz.uz/privacy` qilib joylashtiring va shu havolani yozing.
2. **App access (Ilovaga kirish huquqi):**
   - *"All functionality is available without special access"* (Barcha funksiyalar cheklovlarsiz va parolsiz ochiq).
3. **Ads (Reklama):**
   - *"No, my app does not contain ads"* (Ilovada reklama yo'q).
4. **Content rating (Yosh chegarasi so'rovnomasi):**
   - Emailingizni kiriting (`zolotoytouruz@gmail.com`).
   - Kategoriya: **Utility, Productivity, Communication or Other** (yoki Travel).
   - Zo'ravonlik, qimor, nomaqbul so'zlar: barchasiga **"No"**.
   - Natija: **Everyone (3+) / PEGI 3** chiqadi. Tasdiqlang.
5. **Target audience (Maqsadli auditoriya):**
   - Yosh: **18 and over** (yoki 13-17, 18+).
   - Bolalar uchun maxsus mo'ljallanganmi: **"No"**.
6. **News apps (Yangiliklar):**
   - *"No"* (Ilova yangiliklar nashri emas).
7. **COVID-19 contact tracing:**
   - *"No"*.
8. **Data safety (Ma'lumotlar xavfsizligi):**
   - *"Does your app collect or share any user data?"* -> **No** (Ilovada shaxsiy ma'lumotlarni o'g'irlovchi SDK yoki tahliliy trekerlar mavjud emas. Sayt formasi orqali kiritilgan ma'lumotlar faqat mijoz bilan bog'lanish uchun ishlatiladi).
   - *"Is all user data collected by your app encrypted in transit?"* -> **Yes** (HTTPS orqali to'liq shifrlangan).
9. **Financial features:**
   - Ilova bank yoki kredit ilovasi emas (*"My app doesn't provide any financial features"*).
10. **Government apps:**
    - Davlat organi ilovasi emas (*"No"*).

---

### 3-QADAM: Do'kon Sahifasini To'ldirish (Main store listing)

Chap menyudan **"Grow"** > **"Store presence"** > **"Main store listing"** bo'limiga o'ting:

#### Matnlar:
- **App name:** `Zolotoy Tour`
- **Short description (Qisqa tavsif — 80 belgigacha):**
  * Ruscha: `Бронирование туров, горящие путевки и путешествия по миру с Zolotoy Tour.`
  * O'zbekcha: `Zolotoy Tour bilan dunyo bo'ylab unutilmas sayohatlar va qaynoq turlar.`
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
1. **App icon:** `store_assets/icon_512x512.png` faylini yuklang.
2. **Feature graphic:** `store_assets/feature_graphic_1024x500.png` faylini yuklang.
3. **Phone screenshots:** Quyidagi 5 ta skrinshotni ketma-ket yuklang:
   - `store_assets/screenshot_1_home.png`
   - `store_assets/screenshot_2_tours.png`
   - `store_assets/screenshot_3_hot_tours.png`
   - `store_assets/screenshot_4_services.png`
   - `store_assets/screenshot_5_contacts.png`

---

### 4-QADAM: App Bundle (.aab) Faylini Yuklash va Chiqarish

1. Chap menyudan **"Release"** > **"Production"** bo'limiga kiring (yoki shaxsiy akkaunt bo'lsa **"Closed testing"** ga).
2. O'ng yuqoridagi **"Create new release"** (Yangi reliz yaratish) tugmasini bosing.
3. **App bundles** bo'limidagi **"Upload"** tugmasini bosing va quyidagi faylni tanlang:
   👉 `build/app/outputs/bundle/release/app-release.aab`
4. **Release name:** Avtomatik `1.0.0 (1)` deb aniqlanadi.
5. **Release notes (Reliz yangiliklari):**
   ```text
   Первый официальный релиз мобильного приложения Zolotoy Tour.
   - Удобный поиск туров
   - Горящие предложения
   - Визовая поддержка и связь с агентством
   ```
6. Pastdagi **"Save"** va so'ngra **"Next"** (Keyingisi) tugmasini bosing.
7. Xatolar yo'qligini tekshiring va **"Save and publish"** (yoki **"Start rollout to Production"**) tugmasini bosing.

---

## ⏱ 4. Moderatsiya va Natija

- Google tekshiruv guruhi ilovani odatda **24 soatdan 3 ish kunigacha** bo'lgan muddatda tekshirib chiqadi.
- Moderatsiyadan muvaffaqiyatli o'tgach, ilovangiz Google Play Marketda barcha foydalanuvchilar uchun ochiq bo'ladi va o'rnatish uchun havola paydo bo'ladi.
