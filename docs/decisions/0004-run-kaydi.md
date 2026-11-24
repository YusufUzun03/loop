# 0004 - Run kaydı veri şeması

- Tarih: 2026-11-24
- Durum: önerildi (Memo parametreleri onayladı, 2026-11-24; açık kalan soru ve Yusuf'un teknik onayı bekleniyor, issue #12)
- Karar verenler: Memo (ne kaydedilecek), Yusuf (teknik biçim)

## Bağlam
GDD'ye göre döngü her ölümü kaydeder ve bu tek kayıt birçok özelliği besler:

| Kullanan | Kayıttan ne ister |
|---|---|
| **Observer** (final boss) | Bu run'da her boss saldırısından oyuncunun nasıl kaçtığı; "üst üste 3 kez" ve "açık çoğunluk" kuralları için sıra ve sayılar |
| **Revenant** | Geçmiş run'ın karakteri, build'i, görünümü, nerede/nasıl öldüğü ve davranış profili (birebir girdi tekrarı değil) |
| **Healer's Rest** | Geçmiş run'ın karakteri support muydu? |
| **Lost Relic** | Geçmiş run'ın upgrade'leri |
| **Ses / hikâye** | 2. boss kaç kez yenildi (glitch ihtimali), sesin uyarılarına uyuldu mu |

Memo'nun cevabı (2026-11-24, #12): kayıtta oyuncunun alışkanlıklarını gösteren parametreler tutulsun: **dodge attığı yönler, boss ile ortalama mesafe, en çok kullandığı skill'ler** ve benzerleri.

Kısıtlar: TEKNİK-REHBER madde 17 (sürüm numaralı JSON, `user://` altında, Steam Cloud uyumlu, küçük dosya, bozuk dosya oyunu çökertmez).

## Karar
### 1. İki ayrı kayıt
- **Run kaydı:** her run için bir dosya. O run'da ne olduğunu anlatır (aşağıdaki şema).
- **Run'lar arası sayaçlar:** "2. boss kaç kez yenildi", "kaç run oynandı" gibi birikimli sayılar. Bunlar meta ilerleme dosyasında durur, run kaydında değil (öneri). Her run bitince run kaydından güncellenir.

### 2. Alışkanlıklar saldırıya göre tutulur
Observer "1. boss'un süpürme saldırısında hep sağa kaçıyor" diye düşünür. Bu yüzden alışkanlıklar **saldırı kimliğine** (`attack_id`) göre gruplanır.

- **Dodge yönü karaktere göre kaydedilir (Memo, karar):** karakterin baktığı yöne göre `left` / `right` / `back` / `forward` / `none` (dodge atmadı). Memo: "karaktere göre kaydedersek farklı saldırılar tasarlamak daha kolay olur".
  - Not (öneri): oyuncu boss'a dönükken (ör. kilitlenmede) karakterin sağı saldırının da sağıdır. Boss saldırısının "güvenli tarafı" tasarlanırken karakter yönüyle eşleşecek şekilde düşünülür.
- Her saldırı için hem **son seçimlerin sırası** (en fazla son 10, "üst üste 3" kuralı için) hem **toplam sayılar** ("9'da 6" kuralı için) tutulur.
- Kayıt sadece veriyi tutar. "Bu bir eğilim mi?" kararını Observer okurken verir. Böylece eşikler kayıt formatı değişmeden test edilerek ayarlanır.

### 3. Kaydedilecek parametreler
Memo'nun üç parametresi ve GDD'den gelen ekler. Eklerin hepsini de Memo onayladı (2026-11-24):

| Parametre | Nasıl tutulur | Kim kullanır | Kaynak |
|---|---|---|---|
| Dodge yönü | saldırı başına sıra + sayım | Observer, Revenant | Memo |
| Boss ile mesafe | dövüş başına ortalama + yakın/orta/uzak sayımı | Observer, Revenant | Memo |
| Skill kullanımı | skill başına kullanım sayısı | Observer, Revenant | Memo |
| Dodge mu zıplama mı | saldırı başına sayım | Observer | GDD, Memo onayladı |
| Dodge zamanlaması | saldırı başına erken/geç sayımı | Observer | GDD, Memo onayladı |
| Parry denemeleri | saldırı başına deneme/başarı, erken/geç | Observer | GDD, Memo onayladı |
| Arena konumu | duvar/köşe/orta süre oranı | Observer (menzilliler) | GDD, Memo onayladı |
| Sesin upgrade uyarısı | uyuldu/uyulmadı sayımı | Observer, ses | GDD, Memo onayladı |

- **Olayın nerede olduğu da yazılır** (`boss`, `mini_boss`, `room`). GDD'ye göre boss dövüşleri tam, normal odalar daha az sayılmalı. Ağırlığı Observer okurken uygular, böylece oran testle ayarlanır.

### 4. Run kaydının şeması (ilk sürüm)
```json
{
  "schema_version": 1,
  "run_id": "2026-11-24T20-15-03_a1b2",
  "game_version": "0.1.0",
  "started_at": "2026-11-24T20:15:03Z",
  "duration_s": 1834,
  "character": "tank",
  "look": { "preset": "default" },
  "build": { "upgrades": ["tether", "shield_bash_plus"], "boss_rewards": [] },
  "outcome": {
    "result": "death",
    "stage": 2,
    "room": "boss",
    "killed_by": "boss_2.sweep"
  },
  "rooms_cleared": 7,
  "key_found_in_room": 3,
  "habits": {
    "attacks": {
      "boss_1.sweep": {
        "source": "boss",
        "seen": 9,
        "dodge": { "left": 3, "right": 6, "back": 0, "forward": 0, "none": 0 },
        "recent": ["right", "right", "left", "right"],
        "jump": 0,
        "timing": { "early": 2, "late": 1 },
        "parry": { "tried": 0, "success": 0 }
      }
    },
    "distance": {
      "boss_1": { "avg_m": 4.2, "near": 120, "mid": 340, "far": 40 }
    },
    "skills": { "skill_1": 14, "skill_2": 31, "skill_3": 6 },
    "arena_position": { "wall": 0.2, "corner": 0.1, "center": 0.7 },
    "voice_warnings": { "obeyed": 1, "ignored": 2 }
  }
}
```
Değerler ve isimler örnektir. Saldırı ve upgrade kimlikleri, içerik eklendikçe belirlenir.

### 5. Dosya ve güvenlik kuralları
- Yer: `user://runs/` altında run başına bir JSON dosyası (öneri). Tek dosya büyüyüp bozulursa her şey gider; ayrı dosyalarda tek run kaybolur.
- **Saklama (Memo, karar):** en fazla son **30** run tutulur, eskiler silinir. **En yeni 10 run kullanılmaz, sadece kaydedilir.** Revenant, Lost Relic ve Healer's Rest, 11. ile 30. run arasındaki havuzdan seçilir. O anki run'ın kendi verisi Observer için her zaman kullanılır.
- **Güvenli yazma:** önce geçici dosyaya yaz, sonra adını değiştir. Oyun yazma sırasında kapanırsa eski dosya sağlam kalır.
- **Sürüm:** her dosya `schema_version` taşır. Yeni alan eklenince eski dosya, sürümü yükselten bir göç (migration) fonksiyonundan geçer. Eksik alan varsayılan değerle okunur, bilinmeyen alan yok sayılır.
- **Bozuk dosya:** okunamayan run kaydı atlanır ve loga yazılır; oyun çökmez.
- **Kayıt ne zaman yazılır:** run bitince (ölüm veya zafer). Oyun run ortasında kapanırsa (öneri) o run "yarım" olarak yazılır ve Revenant havuzuna girmez.

### 6. Koddaki yeri (öneri)
- `RunRecorder` adında bir autoload. Oyuncunun sinyallerini (`Player.dodged`, `jumped`, ileride `parried`, `skill_used`) ve boss'un saldırı sinyallerini dinler, sayıları günceller.
- Player klavye okumaz, "niyet" alır (GDD, co-op mimarisi). Co-op'ta her oyuncu için ayrı alışkanlık kaydı tutulur; kaydı host yazar (sonra ayrıntılandırılacak).

## Alternatifler
- **Girdilerin birebir kaydı (replay):** her karedeki tuş basışlarını kaydetmek. Elendi: dosya çok büyür, oyun sürümü değişince bozulur ve GDD Revenant'ın "birebir tekrar değil, profil" olmasını istiyor.
- **Sadece toplam sayılar:** sıra tutmadan yalnız sayım. Elendi: "üst üste 3 kez" kuralı sıra ister.
- **Dodge yönünü dünyaya göre kaydetmek** (kuzey/güney). Elendi: boss ve kamera döndüğü için aynı kaçış farklı yönlere düşer.
- **Dodge yönünü saldırıya göre kaydetmek** (Claude'un önerisi). Memo karaktere göre olanı seçti: farklı saldırılar tasarlamayı kolaylaştırıyor.
- **Son 50 run saklamak** (Claude'un önerisi). Memo 30 seçti.
- **Tüm run'lar tek dosyada.** Elendi: tek hatada bütün geçmiş kaybolur, Steam Cloud her seferinde büyük dosya yükler.

## Sonuçlar
- Her boss saldırısının bir `attack_id`'si ve "güvenli yön" bilgisi olmalı; boss tasarlanırken bu baştan düşünülür.
- Oyuncu tarafında yeni sinyaller gerekir (`parried`, `skill_used`); prototip işleri (#9, #10) bunları ekler.
- Observer'ın eşikleri (3 kez, çoğunluk oranı, oda ağırlığı) kayıtta değil kodda durur ve `@export` ile ayarlanır.
- Dosyalar küçük kalır (run başına birkaç KB), Steam Cloud'a uygun.

## Memo'nun onayı (2026-11-24)
- Dodge yönü: karaktere göre.
- Ek parametrelerin hepsi kaydedilecek: dodge mu zıplama mı, zamanlama ve parry, arena konumu, ses uyarıları.
- Saklama: son 30 run; en yeni 10'u kullanılmaz, sadece kaydedilir.

- **İlk 10 run (Memo'nun fikri):** oyuncunun kullanılabilir kaydı henüz yokken Revenant dövüşlerinde **Observer'ın eski hâlleri** çıkar ve hikâye hakkında ipuçları bırakır. Bunlar elle hazırlanmış kayıtlardır, oyuncunun dosyalarından gelmez. Ayrıntılar sonra (bkz. [LORE.md](../LORE.md#parça-4-do-you-think-this-is-the-first-time)).

## Açık kalan
- Observer'ın eski hâllerinin ayrıntıları (kaç tane, hangi karakter tipleri, nasıl ipucu bırakırlar): sonra, Memo ile.
- Yusuf'un teknik onayı (dosya düzeni, `RunRecorder` autoload).
