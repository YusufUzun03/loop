# Teknik rehber

Bu belge oyunun **nasıl yapılacağını** (araçlar, motor ayarları, üretim hattı) kaydeder. **Ne yapılacağı** (mekanik, hikâye) `GDD.md` ve `LORE.md`'dedir ve Memo'nundur. Çakışırsa GDD kazanır.

İşaretler: **(Yusuf, karar)** verilmiş karar, **(öneri)** Claude önerisi, henüz onaylanmamış, **(Memo'ya sor)** tasarımı etkilediği için Memo'nun sözü gerekir, **(prototipte doğrula)** deneyerek karar verilecek.

Kısa karar kaydı: `docs/decisions/0002-teknik-yon.md`.

---

## Bölüm A: Her oyunun vermesi gereken kararlar

Pre-production kaynaklarının ortak noktası: motor/araç seçimi en pahalı karardır, sanat üretimin en büyük maliyet ve risk kalemidir (bazı kaynaklara göre bütçenin ağır kısmı), performans bütçesi en zayıf hedef cihaza göre **kod yazılmadan önce** konur, ve pre-production bir teknik tasarım belgesi ile bu kararları kanıtlayan bir prototiple (vertical slice) biter. Aşağıdaki liste bunlardan ve oyun yapım pratiğinden derlenmiş kontrol listesidir. Hangi maddeye karar verdiğimiz Bölüm B'de.

| # | Alan | Sorulması gereken |
|---|---|---|
| 1 | Hedef | Platform, çözünürlük, minimum donanım, FPS hedefi, hangi giriş aygıtları |
| 2 | Motor ve dil | Motor, sürüm kilidi, dil, yükseltme politikası |
| 3 | Render | Renderer, ışık yaklaşımı, gölge, post-process, görsel stil sınırı |
| 4 | Fizik | Motor, hangi nesne fizik objesi, çarpışma katmanları |
| 5 | Kamera ve görünüm | Perspektif, kontrol şeması, kamera çarpışması, FOV |
| 6 | Sanat yönü | Stil, palet, poligon/doku bütçesi, ölçek birimi, kim üretir |
| 7 | Varlık hattı | Modelleme, doku, rig, animasyon, ses araçları; dosya formatları; içe aktarma kuralları |
| 8 | Animasyon | Durum makinesi, vuruş zamanlaması, retarget, root motion |
| 9 | Oyun mimarisi | Sahne/node düzeni, autoload'lar, olay (sinyal) kuralları, durum yönetimi |
| 10 | Veri | Oyun sayıları nerede durur, kayıt dosyası, mod/konfigürasyon |
| 11 | Girdi | Eylem haritası, gamepad, yeniden atama, buffer kuralları |
| 12 | Yapay zekâ | Düşman karar yapısı, yol bulma, algılama |
| 13 | Dünya/seviye | Elle mi üretilmiş mi, kod ile üretim, tohum (seed), yükleme |
| 14 | Ağ | Tek/çok oyunculu, otorite modeli, senkron stratejisi, hile politikası |
| 15 | Ses | Bus düzeni, müzik sistemi, ses kaynakları ve lisansları |
| 16 | Arayüz | HUD ve menü sistemi, ölçekleme, tema, gamepad odağı |
| 17 | Kayıt ve ilerleme | Ne kaydedilir, format, sürüm uyumu, bulut |
| 18 | Yerelleştirme | Hangi diller, metin altyapısı, font kapsamı |
| 19 | Erişilebilirlik | Altyazı, renk körlüğü, yeniden atama, zorluk seçenekleri |
| 20 | Performans | Bütçe (kare süresi, draw call), profilleme yöntemi, LOD/culling |
| 21 | Test ve kalite | Birim/headless testler, CI, elle test planı, hata raporu akışı |
| 22 | Kod standardı | İsimlendirme, tipleme, lint/format, inceleme kuralı |
| 23 | Sürüm ve dağıtım | Export, sürüm numarası, Steam, otomatik build, imzalama |
| 24 | Hukuk ve lisans | Varlık lisansları, AI içerik bildirimi, kredi listesi, public repo |
| 25 | Üretim | Kapsam, vertical slice, milestone, kim neyin sahibi |
| 26 | Analitik ve çökme raporu | Oyuncu verisi toplanacak mı (gizlilik), çökme kaydı |

---

## Bölüm B: Bizim kararlarımız

### 1. Hedef (Yusuf, karar)
- Platform: **Windows PC, Steam.** Steam Deck **bonus**: ayrı bir mod yazmıyoruz ama çözünürlük/arayüz/denetleyici kararları Deck'i dışlamayacak şekilde alınır.
- Hedef donanım (öneri): 1080p, 60 FPS, GTX 1060 sınıfı ekran kartı, 8 GB RAM. Deck için ek hedef: 1280x800, 30–40 FPS, **varsayılan ayarlarda** oynanabilir. (prototipte doğrula)
- Giriş: klavye+fare ve gamepad **eşit** desteklenir (Deck ve Steam Input buna bağlı).
- Steam Deck Verified için Valve'in belgelediği şartlar: varsayılan denetleyici ayarıyla tüm işlevlere erişim, ekranda denetleyici simgeleri, 1280x800 desteği, okunabilir metin (Valve alt sınır olarak 1280x800'de 9 px, mümkünse 12 px önerir). Bunlar arayüz kararlarımızı belirler (madde 16).

### 2. Motor ve dil (Yusuf, karar; kayıt: `0001-godot-engine.md`)
- Godot 4.7.2, **yalnız GDScript**. C# yok (kurulum ve CI sade kalsın, iki kişilik ekip).
- Sürüm CI'da `GODOT_VERSION` ile kilitli. Yükseltme bir karardır, ADR gerekir.
- Performans gereken küçük bir kısım olursa o noktada GDExtension (C++/Rust) düşünülür, şimdi değil.

### 3. Render (öneri)
- **Forward+** (Vulkan). Gerekçe: cyberpunk ışık dili (glow, sis, çok sayıda ışıklı yüzey) ve gölge kalitesi. Godot belgesine göre Forward+ masaüstü içindir, Mobile renderer ise daha az özellikle basit sahneleri daha hızlı çizer ve Deck gibi düşük güçlü donanım için makul seçenektir.
- Bu yüzden **kural:** Forward+ kullanırken Mobile renderer'a geçişi imkânsız kılan özellik kullanmayız ("sadece Forward+'ta çalışan" efektleri tek bir yerde, ayarlanabilir tutarız). Deck'te yetmezse Mobile'a geçmek kalite ayarı olarak kalır. (prototipte doğrula)
- Anti-aliasing: MSAA 3D (stilize, keskin kenarlı görüntüde işe yarar) + gerekirse FXAA. TAA ve DLSS/FSR sonra.
- Işık: az sayıda dinamik ışık, çoğu iş **emissive malzeme + glow + sis**. Odaya düşen dinamik ışık sayısı bütçelenir (madde 20). Labirent her run yeniden kurulduğu için baked ışık yok; gerekirse SDFGI/VoxelGI **sadece prototipte denenip** maliyeti ölçülür.
- Post-process: tonemap, glow, hafif renk düzeltme, sis. Ağır efektler (SSR, SSAO yüksek) kalite ayarıdır, varsayılan değil.

### 4. Fizik (öneri)
- **Jolt** (4.6+ ile 3D varsayılanı).
- Oyuncu ve düşman: `CharacterBody3D`. Vuruş/hasar alanları: `Area3D` (hitbox/hurtbox). Dövüşün çekirdeğinde `RigidBody` **yok**; hareket kodla yönetilir. Gerekçe: i-frame'siz dodge ve saldırıyla parry'de öngörülebilir, tekrarlanabilir hareket gerekir. Ağ senkronu da kolaylaşır.
- RigidBody sadece süs (devrilen sandık, parçalar). Oynanışı etkilemez.
- Çarpışma katmanları baştan **isimlendirilir** (`project.godot` `[layer_names]`): world, player, enemy, player_hitbox, enemy_hitbox, pickup, trigger, ... Yeni katman eklemek bir PR kararıdır.
- Ince duvar/hızlı hareket için CCD ve ray/shape cast kullanılır, tünelleme testi yazılır.

### 5. Kamera ve görünüm (GDD'ye uygun; ayrıntı Memo'ya sorulur)
- MMO tarzı üçüncü şahıs: oyuncu etrafında yörünge kamera + `SpringArm3D` (duvara girmesin). Kilitlenmede (lock-on) hedef ve oyuncu aynı karede kalır.
- Dar koridor ve merdivenlerde kameranın durumu GDD'de risk olarak belirtilmiş: kamera çarpışması, otomatik yaklaşma ve duvar saydamlığı prototipin ilk testlerinden biridir. (prototipte doğrula)
- FOV, kamera mesafesi, omuz kaydırma, hassasiyet: `@export` ile açık, ayarlar menüsünde oyuncuya da açık (FOV, sallantı, hassasiyet). (Memo'ya sor: his)
- Sallantı (screen shake) ve vuruş durması (hit-stop) tek bir "game feel" servisinde toplanır; oyuncu ayarı ile kısılabilir.

### 6. Sanat yönü (Yusuf, karar: sanatçı olmadan elimizden gelen en kaliteli iş)
Sanatçı yok, bu yüzden **kalite işçilikten değil tutarlılıktan** gelecek. Kurallar:
1. **Tek stil:** stilize, düşük/orta poligon, el boyası veya düz renk dokular, gerçekçi PBR yok. Işık, renk ve shader işi taşır. Hedef his: Elden Ring'in kasvetli büyüklüğü + cyberpunk neon vurgu (GDD referansı); gerçekçi karakter modeli hedeflenmez.
2. **Tek palet:** ana palet 6–8 renk + vurgu rengi. Renkler belge olarak tutulur (`docs/ART.md`, yazılacak). Her yeni varlık palete uyar.
3. **Tek ölçek ve grid:** 1 Godot birimi = 1 metre. Modüler parçalar 4 m grid üzerinde (öneri). Karakter yüksekliği sabit.
4. **Karıştırma yasağı:** bir paketten varlık alınacaksa o paketin stiliyle uyumlu olmalı. Uyumsuz paket yok. (GDD'deki kural)
5. **Vurgu şu üçte:** silüet (okunaklı karakter şekli), ışık (neon/emissive kontrast), efekt (parçacık, glow). Detay doku aramayız.
6. **Opsiyonel, ücretli:** karakter/boss için dışarıdan sanatçı. Şimdilik yok; vertical slice sonrası bütçe varsa ve çıta yetmiyorsa karar verilir.
7. **Poligon/doku bütçesi (öneri, prototipte doğrula):** oyuncu karakteri ≤ 30k üçgen, düşman ≤ 15k, boss ≤ 50k, oda/prop parçası başına ≤ 5k; doku en fazla 1024² (boss/oyuncu 2048²), arka plan ortak atlas.

### 7. Varlık hattı (öneri)
| Ne | Araç | Format | Not |
|---|---|---|---|
| 3D model | Blender (ücretsiz) | `.glb` (glTF 2.0) | Git LFS. `.blend` kaynakları `assets/_source/` altında, LFS |
| Hazır model | Kenney, Quaternius, (lisansı CC0/uygun olanlar) | `.glb` | Her paket `docs/ASSETS.md`'ye kaydedilir |
| Doku/malzeme | Krita, Material Maker (ücretsiz) | `.png` | Boyutlar bütçeye uyar, `sRGB`/`linear` doğru işaretlenir |
| Shader | Godot shader dili + `VisualShader` | `.gdshader` | Ortak hologram/glitch/dissolve shader'ları tek klasörde |
| Rig/animasyon | Blender veya Mixamo benzeri (lisansı kontrol) + Godot retarget | `.glb` | Tek ortak iskelet, retarget ile paylaşım |
| Ses efekti | jsfxr, Audacity, CC0 paketleri (Kenney, freesound CC0) | `.ogg` (SFX), `.ogg` müzik | Lisanslar `ASSETS.md`'de |
| Müzik | CC0 veya lisanslı; üretken araç kullanılırsa Steam bildirimi (madde 24) | `.ogg` | |
| Font | Açık lisanslı (SIL OFL), Türkçe karakter destekli | `.ttf` | Türkçe/İngilizce dil desteği zorunlu (madde 18) |

İçe aktarma kuralları: modeller Blender'da uygulanmış ölçek/rotasyonla (apply transforms), Z ileri/Y yukarı (glTF), isimlendirme `snake_case`. Her `.glb` için tek bir `.tscn` sarmalayıcı yazılır, oyun doğrudan `.glb`'yi değil sarmalayıcıyı kullanır (sonradan değişiklik kolay olur).

### 8. Animasyon (öneri)
- `AnimationPlayer` + `AnimationTree` durum makinesi (hareket, saldırı, dodge, parry, hasar, ölüm).
- Vuruş zamanlaması animasyon izinden (method/signal track) gelir: hitbox'ı açıp kapatan, parry penceresini başlatan olaylar animasyona bağlı. Böylece "animasyon neyse hasar odur" ve ayar tek yerde olur.
- Tek iskelet, retarget ile üç karakter ve ortak insansı düşmanlar paylaşır. Root motion kullanmıyoruz, hareket kodla yönetilir (ağ ve parry için öngörülebilirlik). (prototipte doğrula)
- Procedural dokunuşlar (eğilme, bakış, lock-on yönelimi) `LookAtModifier3D`/IK ile.

### 9. Oyun mimarisi (öneri)
- Sahne = bir sorumluluk. Kompozisyon tercih edilir (miras değil): `Health`, `Hurtbox`, `Hitbox`, `Stats`, `StateMachine` küçük, yeniden kullanılır node'lar.
- Sinyaller yukarı, çağrılar aşağı. Kardeş node'lar birbirini doğrudan çağırmaz. Genel olaylar küçük bir `EventBus` autoload'unda (az sayıda, belgeli).
- Autoload'lar kısa tutulur: `EventBus`, `GameState` (run durumu), `Settings`, `SaveManager`, `Audio`. Autoload eklemek PR'da gerekçe ister.
- **Co-op'a hazır kural** (GDD'de var): oyuncu klavyeyi doğrudan okumaz, bir **niyet** (`PlayerIntent`: yön, saldırı, dodge...) üretilir; karakter sadece niyeti tüketir. Aynı oyun durumu tek bir otoritede yaşar.
- Oyun mantığı sabit adımda (`_physics_process`), görsel enterpolasyon ayrıdır.

### 10. Veri (öneri)
- Ayarlanabilir sayılar `Resource` (`.tres`) + `@export` ile: silah, saldırı, düşman, yükseltme, kat/oda ağırlıkları. Kodda sihirli sayı yok (CLAUDE.md kuralı).
- Resource'lar paylaşılan referanstır: örnek başına değişecekse `duplicate()` kullanılır.
- GDD'deki "sayılar oyun test edilerek belirlenir" kuralı için ayar dosyaları tek klasörde (`data/`) ve oyunda hızlı yeniden yükleme bir debug komutuyla.

### 11. Girdi (öneri)
- `InputMap` eylemleri, ham tuş okuma yok. Hepsi yeniden atanabilir (madde 19).
- Gamepad birinci sınıf: ölü bölge ayarı, tetik/analog, titreşim opsiyonu.
- Dodge/parry için kısa **girdi tamponu** (buffer) süreleri `@export`; sayıyı test belirler.
- Girdi kaynağı soyutlaması (niyet) co-op, replay ve ileride AI test botu için de kullanılır.

### 12. Yapay zekâ (öneri; GDD'ye uygun)
- Düşman karar yapısı: **hiyerarşik durum makinesi** (devriye, algıla, kovala, saldır, geri çekil). Boss'lar aşamalı durum makinesi. Daha karmaşık gereken olursa davranış ağacına geçilir.
- Observer'ın alışkanlık sayımı **kural tabanlı sayaçlardır** (GDD böyle istiyor), makine öğrenmesi yok. Bu aynı zamanda Steam AI bildirimini etkilemez (oyun içinde üretken AI yok).
- Algılama: görüş konisi + ray cast + ses/yakınlık. Düşmanların aynı anda saldırabilme sınırı ("saldırı jetonu") mücadelenin okunur kalması için.
- Yol bulma: `NavigationServer3D`. **Labirent her run üretildiği için** parçalar önceden pişirilmiş navmesh ile gelir, çalışma zamanında bağlanır. Bu en belirsiz kısımlardan biri, **ilk prototipte** doğrulanır. (prototipte doğrula)

### 13. Dünya ve labirent (GDD'ye uygun, öneri)
- Elle yapılmış parçalar (oda, koridor, merdiven, çıkmaz, özel odalar) + `Marker3D` bağlantı noktaları + **tohumlu** (seeded) birleştirici. Aynı tohum aynı labirenti verir: hata ayıklama, co-op eşleşmesi ve "bu run'ı tekrar oyna" için şart.
- Üretici saf mantık olarak yazılır (sahne yüklemeden), böylece headless testle "her tohumda başlangıçtan çıkışa yol var" gibi kurallar test edilir.
- Yükleme: parçalar arka planda (`ResourceLoader.load_threaded_request`), kat geçişinde kısa yükleme ekranı. Streaming/oda culling ölçülünce eklenir.
- **Dürüst uyarı:** katlı, dik/dar ve birleştirilmiş navmesh'li labirent projenin en büyük teknik riskidir. Vertical slice'ın ana sorusu budur.

### 14. Ağ (GDD'ye uygun, öneri)
- Önce **tek oyunculu**. Co-op sonra: Godot high-level multiplayer + GodotSteam, **host otoriter**.
- Bugünden kurallar: oyun durumu tek otoritede (host), oyuncu niyeti ağdan gelebilir, rastgelelik tohumlu, zaman `_physics_process` adımında, UI ve görsel mantık ayrı.
- i-frame'siz dodge ve zamanlı parry gecikmeye hassas: istemci tarafı tahmin (prediction) gerekebilir. Bu iş co-op aşamasında ayrı karar/ADR olur. Şimdi sadece mimariyi bozmayacak kurallar.
- Hile: tek oyunculu ve arkadaş co-op'ta anti-cheat kapsam dışı.

### 15. Ses (öneri)
- Bus düzeni: `Master` > `Music`, `SFX`, `UI`, `Voice`(rezerv), `Ambient`. Ses sürgüleri **dB** ile (lineer değil).
- SFX çeşitliliği: aynı ses tekrar etmesin (havuz + hafif pitch/volume rastgeleliği). Müzik uyarlanır (keşif / savaş / boss katmanları, geçişte çapraz solma).
- 3D ses: `AudioStreamPlayer3D`, mesafe sönümü, oda yankısı için bus efekti.
- FMOD/Wwise yok. Godot'un sesi yeter, bütçe 0.

### 16. Arayüz (öneri)
- Godot `Control` düğümleri + **tek Tema** (`theme.tres`): renk, font, boyutlar tek yerde. Hologram/glitch hissi shader ile.
- Ölçekleme: temel çözünürlük 1920x1080, `canvas_items` stretch, `expand`. Ultrawide ve 1280x800'de bozulmaz. Metin Deck'te okunur (alt sınır madde 1).
- HUD olay (sinyal) ile güncellenir, her karede yoklama yok. Gamepad odağı (focus) bütün menülerde çalışır; ekranda gösterilen tuş simgeleri girişe göre (klavye/gamepad) değişir.
- Minimap yok (GDD): bakış noktaları (lookout) arayüzü ayrıca tasarlanır. (Memo'ya sor)

### 17. Kayıt ve ilerleme (öneri)
- Üç ayrı şey: **ayarlar** (`ConfigFile`), **meta ilerleme** (hub, açılanlar), **run kaydı** (Revenant ve Observer'ı besleyen ölüm kayıtları). Her biri sürüm numaralı JSON.
- Kayıt dosyası sürüm alanı taşır, eski sürüm göç (migration) fonksiyonuyla yükselir. Bozuk dosya oyunu çökertmez, yedek tutulur.
- Steam Cloud ile uyumlu: kayıt `user://` altında tek klasörde. Dosya boyutu küçük tutulur.
- Run kaydının biçimi (ne kaydedilecek) Revenant/Observer tasarımına bağlıdır. (Memo'ya sor)

### 18. Yerelleştirme (öneri)
- Diller: **Türkçe ve İngilizce** (ikisi de ekipte konuşuluyor). Başka dil sonra.
- Tüm oyuncuya görünen metin `tr()` ile ve çeviri tablosundan (CSV → `.translation`). Metin koda gömülmez. Anahtarlar `snake_case` ve bağlam taşır.
- Font Türkçe karakterleri (ı, İ, ğ, ş, ç, ö, ü) içerir. Metin genişlemesi için arayüz esnek.
- Lore metinleri çok olduğu için çeviri tek seferde değil, sürüm sonuna doğru toplanır; ama **anahtar sistemi baştan** kurulur.

### 19. Erişilebilirlik (öneri)
- Altyazı ve boyut ayarı, renk körü için **renkten başka ipucu** (şekil/simge), parlama/sallantı/hit-stop kısma, tuş yeniden atama, dodge/parry zamanlama yardımı ya da zorluk ayarı (Memo'ya sor: tasarımı etkiler).
- Steam Deck ve genel okunabilirlik için arayüz ölçeği ayarı.

### 20. Performans (öneri; ölçerek karar)
- Bütçe (başlangıç değeri, prototipte ölçülüp güncellenir): kare süresi 16,6 ms (60 FPS), aynı karede **draw call < 2000** masaüstü / **< 1000** Deck, dinamik gölgeli ışık sayısı odada ≤ 4, aktif düşman ≤ 12 aynı anda, parçacık sayısı efekt başına sınırlı.
- Yöntem: önce **ölç** (Godot profiler, görsel profiler, Monitors, `--print-fps`), CPU mu GPU mu belirle, sonra en büyük kalemi düzelt. Tahminle optimizasyon yok.
- Standart araçlar: `MultiMeshInstance3D` (tekrar eden süsler), `VisibleOnScreenNotifier`/culling, `LOD`, `OccluderInstance3D`, nesne havuzlama (mermi, efekt), gölge mesafesi sınırı, doku sıkıştırma (VRAM).
- Hedef kontrol: her milestone sonunda hedef donanımda (veya benzeri) kare süresi ölçüsü `STATE.md`'ye yazılır.

### 21. Test ve kalite (mevcut + öneri)
- Headless testler (`tests/`), CI'da her PR'da (mevcut).
- Eklenecek: `gdlint`/`gdformat` CI'da, labirent üretici için tohum testleri, kayıt göç testleri, saldırı/hasar hesabı testleri.
- Elle test planı: her milestone için kısa kontrol listesi, iki kişi birbirinin PR'ını oynar.
- Hata raporu: GitHub issue şablonu var (`bug` etiketi). Debug ekranı: FPS, çarpışma görünümü, god mode, run tohumu gösterimi (oyuna yerleşik debug menüsü).

### 22. Kod standardı (mevcut; `CLAUDE.md`)
Statik tipleme, `snake_case`/`PascalCase`, sihirli sayı yok, sinyaller geçmiş zaman, kod ve commit İngilizce, belgeler Türkçe. `.editorconfig` tab.

### 23. Sürüm ve dağıtım (öneri)
- Hedef: Windows x86_64 export, Steam (Steamworks SDK + GodotSteam). Export şablonları ve `export_presets.cfg` vertical slice sırasında eklenir; CI'da export üretimi ayrı bir iş.
- Sürüm numarası `MAJOR.MINOR.PATCH`, `project.godot` içinde `config/version`. Release notu `CHANGELOG.md`.
- Steam sayfası, satın alma, fiyat: kapsam dışı, oyun oynanabilir olunca ayrı karar.

### 24. Hukuk ve lisans (öneri)
- Her harici varlık `docs/ASSETS.md`'ye: ad, kaynak URL, lisans, tarih. Lisansı belirsiz varlık repoya girmez. **Repo public**, yani varlık lisansı yeniden dağıtıma izin vermeli (CC0 en güvenlisi; CC-BY ise kredi gerekir).
- Steam üretken AI bildirimi: Valve, **oyunun ürettiği ve oyuncunun gördüğü** AI içeriğini (önceden üretilmiş sanat/ses/metin, ya da oyun sırasında üretilen) bildirmeyi ister; Ocak 2026 güncellemesiyle geliştirme sırasındaki verimlilik araçları (kod yardımı vb.) bildirim kapsamı dışı sayıldı. Pratik kural: **oyunda görünen/duyulan hiçbir şeyi üretken AI ile yapmayız** ya da yaparsak bildiririz. Kod için Claude kullanımı normal. Bildirim metni Steamworks'te çıkış öncesi yeniden kontrol edilir.
- Telif: oyun adı "Again" çalışma adı; Steam'e çıkmadan önce ad ve marka kontrolü yapılır.
- Kredi ekranı: ASSETS.md'den otomatik üretilebilir.

### 25. Üretim (öneri)
- **Vertical slice** önce: tek karakter (tank), tek silah, 1 kat ürettirilmiş labirent (4–6 oda tipi), 2–3 düşman tipi, 1 boss, dodge+parry+lock-on, run biter → hub. Co-op, Observer, Revenant, diğer iki karakter **sonra**.
- Slice'ın cevaplaması gereken sorular: dövüş hissi (parry/dodge) eğlenceli mi, kamera dar yerlerde çalışıyor mu, üretilen labirent oynanabilir mi, sanat çıtası yeterli mi, performans hedefte mi.
- Sahiplik: tasarım Memo (GDD/lore/ayarlar), teknik yön ve araçlar Yusuf, ikisi birbirinin PR'ını inceler. Sahne/`project.godot` aynı anda iki kişi düzenlemez.
- Kapsam kuralı: yeni özellik önce issue, sonra GDD'de kayıt, sonra kod.

### 26. Analitik ve çökme raporu (öneri)
- Şimdilik **yok**. Oyuncu verisi toplamıyoruz (gizlilik, KVKK/GDPR sade kalsın). Çökme kaydı yerel log dosyası, oyuncu isterse paylaşır. Sonra ihtiyaç olursa ayrı karar.

---

## Skill'ler

Claude Code'un oyun skill'leri `.claude/skills/` altında repoyla gelir; böylece Memo'nun Claude'u da aynı bilgiyi kullanır. Kaynak: <https://github.com/gamedev-skills/awesome-gamedev-agent-skills> (Apache-2.0, `NOTICE-skills.md`). Yalnız Godot ve ilgili genel disiplin skill'leri alındı, başka motorlarınkiler değil.

## Açık sorular (Memo'ya)
- Kamera hissi, dodge/parry zamanlama yardımları ve zorluk ayarları (madde 5, 19).
- Run kaydının ne içereceği (madde 17).
- Arayüz fikri: bakış noktaları ve HUD (madde 16).
- Sanat yönü ana paleti ve karakter silüetleri (madde 6).
