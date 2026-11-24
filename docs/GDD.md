# Oyun tasarım dokümanı (GDD): "Again"

Kısa ve güncel tut. Büyük değişikliği `docs/decisions/` altına da kaydet.

Kaynak: Memo ile Claude'un 2026-11-23 tarihli tasarım oturumu. Hikâye ve dünya: [LORE.md](LORE.md).

**İşaretler:** "(Memo'nun fikri)" ve "(Memo, karar)" Memo'nun kararıdır. "(öneri)" Claude'un eklediği, henüz onaylanmamış fikirdir. Oyun içi replikler İngilizce bırakıldı.

**Çalışma kuralı (Memo, karar):** sayılar ve ayarlar (cooldown, parry penceresi, ödüllerin nasıl sunulacağı, adetler) oyun test edilerek belirlenir. Tasarım aşaması çekirdek oynanışa odaklanır. Kodda bu değerler `@export` olarak açılır, Inspector'dan ayarlanır.

## Konsept
> Bir zaman döngüsünün içinde geçen, beceriye dayalı 3D roguelite. Döngüyü yöneten Observer her ölümünü kaydeder, alışkanlıklarını sayar ve final savaşında tam onlara karşı oynar.

- Tür: roguelike / roguelite, zorlayıcı
- Boyut: 3D, stilize; MMO tarzı üçüncü şahıs kamera
- Oyuncu sayısı: önce tek oyunculu, sonra online co-op (lobiyi kuran host olur, sunucu yok)
- Hedef platform: PC (Steam)
- Çalışma adı: **Again** (Memo, karar). Repo kod adı: `loop`

Oyuncu, eski bir dünyayı içine alan dev bir **baloncuğun** dışındaki hub'dan, baloncuktaki bir **yarıktan** içeri girer. Her run'da rastgele oluşturulan, katlı bir labirentte odaları temizler, boss odasının anahtarını bulur ve çekirdeğe ilerler. Ölünce hub'da uyanır. Her ölüm döngü tarafından kaydedilir: geçmiş run'lar **Revenant** olarak geri döner, Observer ise kayıtlardan oyuncunun alışkanlıklarını öğrenir.

**Proje ruhu (Memo):** Steam'deki birçok yapay zekâ ile yapılmış oyun "tek bir prompt'la yapılmış gibi" görünüyor. Sorun yapay zekâ değil, yüzeysel, emeksiz oyunlar. Bu oyun tam tersi olmalı: derin, birbirine bağlı sistemler ve Memo'nun kendisinin de oynayacağı bir hikâye. "I don't want anyone to play a game that I won't play."

### Sütunlar
1. **Şans değil beceri:** zorlayıcı. İyi oynayan, kötü upgrade'lerle bile run'ı bitirebilir.
   - Derin temel kit: dodge, zıplama, **saldırıya saldırarak parry** (yakın dövüş), birkaç skill, hareket
   - Upgrade'ler çoğunlukla ham stat değil, *nasıl* oynadığını değiştirir
   - Okunabilir düşman sinyalleri, kaçınılmaz hasar yok
   - Bosslar öğrenilebilir beceri testleridir
   - RNG kontrolü: 3'ten 1 seç, reroll, dükkân
2. **Tek silah, çok stil:** her karakterin tek, değişmeyen bir silahı var; upgrade'ler oynanışı yeniden şekillendirir.
   - Fikirler: upgrade slotları (saldırı / dodge / özel), build'lerin bağlandığı yönler, evrimler (kombo upgrade'ler)
   - Kararlaşmış örnekler: support'un alanı varsayılan olarak ona bağlı, bir upgrade alanı ayırıp güçlendirir; damage karakterinin zincir bıçağı **fırlatma bıçaklarına** dönüşebilir
3. **Oynamaya değer bir hikâye (Memo):** oyuncular sadece oynanışa değil, hikâyeye de bağlanmalı. Ayrıntılar: [LORE.md](LORE.md).

## Mekanikler
### Çekirdek döngü
Hub → baloncuğa gir → aşama (10 oda + boss odası, en az 1 bakış noktası, odalar arası geçiş) → boss → sonraki aşama → … → çekirdek

#### Baloncuk ve hub (Memo'nun fikri)
- Oyun dünyasının tamamı (döngü) dev bir **baloncuğun** içinde
- **Hub baloncuğun dışında.** Oyuncu hub'da serbestçe dolaşır
- Hazır olunca baloncuktaki bir **yarıktan** içeri girer, run başlar
- Hub **Observer'a ait** (Memo, karar). Observer'ın run'lar arası upgrade sistemi burada
- Görsel not: hub'dan baloncuğun içine kapanmış bütün dünya görünür. Başlık ekranı, Steam sayfası ve fragman için güçlü bir görüntü. Giriş yarığı, run içindeki rupture'larla aynı "döngüdeki çatlak" görselini kullanır
- Özgünlük notu: hub'lar roguelite'larda standart (ör. Hades'teki House of Hades). Hapishanenin dışında durup ona bakan bir hub bizim farkımız
- Açık: hub'da başka neler var (NPC'ler, baloncuğu inceleyen healer, kozmetikler)?

#### Ölüm (Memo, karar)
- Baloncuğun içinde ölünce **hub'da uyanırsın**
- Run'da ne olduğunu **sadece sen ve Observer bilirsiniz**
- **Döngüdeki her ölüm kaydedilir.** Revenant'lar bu kayıtlardan gelir
- Tasarım notu (öneri): tek bir kayıt sistemi birçok özelliği besler: Revenant'lar, Observer'ın alışkanlık sayımı, Lost Relic, Healer's Rest ve hikâyedeki "Do you think this is the first time?". Tek veri sistemi, çok kullanım; kapsam için iyi
- Açık: hub'daki diğer kişiler (varsa) olanları unutuyor mu? Teknolojiyi anlayan healer daha fazlasını hatırlıyor mu?

#### Aşamalar ve odalar (Memo, karar)
- Her aşamada **11 oda** var. **Son oda her zaman boss odası**
- Diğer **10 odadan** biri (her run rastgele) boss odasının **anahtarını** taşır
- Anahtarı bulunca seçersin: **doğrudan boss'a git** ya da güçlenmek için **daha fazla oda temizle**
  - Örnek (Memo): anahtarı ilk odada buldun. Hemen boss'a koşabilir ya da upgrade için keşfe devam edebilirsin
- Oda türleri (mob dövüşleri, mini bosslar vb.) bu odaların içinde yer alır (öneri; onaylanacak)
- 1. sütuna uyar: iyi oyuncular koşabilir, emin olmayanlar önce biraz güç toplar
- Özgünlük notu: anahtar ve keşfedilebilir katlar başka oyunlarda var (ör. The Binding of Isaac, Zelda zindanları). İlginç olan "anahtarı buldum, şimdi ne yapacağım?" kararı ve aşağıdaki bedeller

#### Neden her odayı temizlemiyorsun? (Memo seçti)
1. **Observer daha çok öğrenir:** savaştığın her oda alışkanlıklarının bir kaydı daha. Çok oda temizlemek seni güçlendirir ama Observer'a final için daha çok veri verir
2. **Odalar yıpratır:** her oda can ve hata riski demek. Daha çok upgrade, ama boss'a yaralı varma riski
3. **Döngü, kaldıkça daha kararsız olur:** aşamanın sonraki odaları daha zordur
- (Seçilmeyen: "koşmanın ödülü", ör. daha iyi boss ödülü veya bedava reroll)
- Bunların ne kadar etkili olduğu test edilerek belirlenir
- Not: 1. bedel, Observer'ın sayımına sadece boss dövüşlerinin değil normal odaların da girdiği anlamına gelir

#### Harita yapısı: derinliği olan rastgele labirent (Memo, karar)
- The Binding of Isaac gibi düz bir oda ızgarası **değil** (Memo)
- Her aşama **rastgele oluşturulan, derinliği olan labirent benzeri** bir harita: **yeraltı katları, merdivenler** ve odalar arası benzer dikey bağlantılar
- **Elle yapılmış parçalar, rastgele bağlanır (Memo, karar):** elle yapılmış odalar ve elle yapılmış koridor/merdiven/kat parçaları her run yeni bir labirent oluşturacak şekilde birbirine eklenir
- 11 oda bu labirentin içinde durur; geçiş, koridorlar, merdivenler ve katlar arasında dolaşmaktır
- Notlar / öneriler:
  - Dikeylik sırlar fikrine çok uyar (yüksek çıkıntılar, gizli alt katlar)
  - Kamera notu: dar koridorlar ve merdivenler MMO tarzı kamerada iyi kamera çarpışması ister; görüş okunabilir kalsın diye odalar ve koridorlar yeterince geniş olmalı
  - "Döngü kararsızlaşır" bedeli labirente uyar: ne kadar dolaşırsan o kadar kayar (görsel glitch'ler, daha zor odalar)
- Özgünlük notu: katlı, oluşturulan 3D zindanlar var (ör. Diablo zindanları, Deep Rock Galactic mağaraları). Anahtar kararı, bakış noktası haritası ve her odadan öğrenen Observer ile birleşince bize özgü hissettiriyor

#### Minimap yerine bakış noktaları (Memo, karar)
- Keşfettikçe dolan **minimap yok**, **her yerden açılabilen harita yok** (Memo keşfedilebilir minimap'i açıkça reddetti)
- Her aşamada **en az 1 bakış noktası** var: **tüm haritayı, içindeki her şeyi görebildiğin** bir yer
- Haritaya **başka hiçbir yerden erişemezsin.** Oyuncu gördüğünü hatırlayıp yolunu bulmalı
- 1. sütuna uyar: hafıza ve yön bulma menü kontrol etmek değil, beceri olur
- **Nasıl görünür (Memo'nun fikri, 2026-11-24):**
  - Bakış noktası, **duvarda küçük bir ekran** gibi bir şey
  - **Her karakter onunla farklı etkileşime geçer.** Ayrıntılar karakter tasarımında konuşulacak (Memo)
  - Etkileşimden sonra harita, **koridorun ortasına 3D hologram olarak yansır.** Labirentin katları olduğu için düz bir harita yerine 3D görüntü
  - Öneri: hologram camgöbeği olabilir (Observer'ın rengi; bakış noktalarının "Observer'ın gözü" olduğu hikâye bağına uyar). Hikâye bağındaki "antik terminal" fikriyle de örtüşüyor
  - Öneri (tank/damage/support farkı için başlangıç fikri, Memo'nun fikri önce): healer teknolojiyi anladığı için daha çok bilgi görebilir; diğerleri kaba kuvvetle çalıştırır
  - Özgünlük notu: 3D hologram haritalar var (ör. Metroid Prime serisinin 3D haritası, Dead Space'in hologram haritası). Bizimkini farklı kılan: harita sadece o terminalde açılıyor, karaktere göre farklı etkileşim istiyor ve dünyanın içinde, koridorda duruyor
- Öneriler / karar verilecek:
  - **Bakış noktası ne gösterir:** "içindeki her şey" (Memo) odaları, boss odasını, **anahtarın yerini**, sırları, rupture'ları kapsayabilir. Anahtarı göstermek bakış noktasına ulaşmayı çok değerli yapar (gerçek bir seçim: önce bakış noktasını mı bulacaksın, körlemesine mi arayacaksın?)
  - **Yerleri:** her run rastgele, böylece bulmak da işin parçası; ya da biri hep başlangıca yakın, oyuncu ilk saniyeden kaybolmasın
  - **Yer işaretleri:** minimap olmadan labirentin güçlü görsel işaretlere ihtiyacı var (benzersiz heykeller, parlayan makineler, katlara göre farklı zemin renkleri)
  - **Hikâye bağı:** bakış noktaları döngünün eski gözlem noktaları olabilir, Observer'ın izlediği türden yerler. Ya da sadece başında durduğunda haritayı gösteren antik terminaller. Balkon hologramındaki göz sembolünü taşıyabilir
  - **Co-op bağı:** bakış noktasındaki oyuncu diğerlerine yol tarif edebilir
  - **Observer her şeyi her an görür;** oyuncu bu görüşü sadece bakış noktalarında alır. Temaya uyar
- Özgünlük notu: minimap'siz oyunlar var (ör. Dark Souls), "haritayı görmek için kuleye çık" da var (ör. Ubisoft kuleleri), ama orada harita sonradan açık kalır. Rastgele bir labirentte sadece başında dururken görülen tam görüş daha az rastlanan bir şey

#### Odalar arası geçiş (Memo, karar)
- **Geçiş odalar arasında olur** (labirentte bir odadan diğerine hareket)
- **Dövüşle aynı kontroller** (Memo, karar): özel geçiş kuralı yok, dodge cooldown'ı geçişte değişmez
- **Geçişi kolaylaştıran skill'ler:** sonra düşünülecek (Memo)
- **Yol üstünde sırlar (Memo'nun fikri):** sadece beceri veya yaratıcı hareketle ulaşılan gizli yerler
  - Memo'nun örneği: **sadece oradaki uçan bir moba dash (dodge) atarak ulaşılan yüksek bir yer**
  - 1. sütuna uyar (hareket becerisini ödüllendirir) ve dodge'u sadece savunma değil, hareket aracı yapar
  - Sırlarda ne olabilir (öneri): küçük upgrade'ler, kozmetikler, gizli **hikâye kayıtları** (ör. Observer'ın eski oymaları), nadir rupture girişleri
  - Öneri: zıplama, dodge ve düşmanları (onlara dash atmak) kullanan sırlar, hareket kitini dövüş dışında öğretir

#### Run içinde (özet)
- **Mob odaları** (normal düşman grupları), **mini bosslar**, **bosslar** (boss ödülleriyle)
- İsteğe bağlı **rupture'lar** çıkabilir
- Run'ın hedefi (hikâye): baloncuğun **çekirdeğine** ulaşmak

Kit tasarım kuralı (Memo): skill'ler sadece bosslara karşı değil, **hepsinde** işe yaramalı.
- Öneri: her karakterin kiti üç ihtiyacı karşılasın: **kalabalık** için bir şey (mob odaları), **tek büyük hedef** için bir şey (boss, mini boss) ve **hareketi** destekleyen bir şey (geçiş, sırlar, yer değiştirme)
- Açık: hangi oda türleri var; normal upgrade'ler ne zaman veriliyor (ör. her temizlenen odadan sonra)

### Kontroller ve çekirdek dövüş (Memo, karar)
**Aion 2**'nin kontrollerinden esinlenildi (Memo Aion 2 oynuyor).

| Tuş | Eylem |
|---|---|
| WASD | Hareket |
| Shift | Dodge (geçişte hareket aracı da) |
| Space | Zıplama |
| Sol tık | Temel saldırı |
| Q / E / R | Skill'ler (az sayıda) |
| Fare | Kamera |
| Kilitlenme tuşu (ör. Tab veya orta tık, karar verilecek) | Hedefe kilitlen |

- **Her yerde aynı kontroller** (Memo): dövüş ve geçiş aynı tuşları ve kuralları kullanır
- **Harita tuşu yok** (Memo): harita sadece bakış noktalarında görünür
- **Karakter başına az skill (Memo):** 2-3 skill (Q/E/R), büyük bir MMO çubuğu değil ("i dont want too much skills on characters"). Derinlik tuş sayısından değil zamanlamadan gelir. **Skill'ler sonra tasarlanacak** (Memo)
- **Nişan ve kilitlenme (Memo, karar):**
  - Memo'nun mantığı: sadece yakın dövüş karakterleri olsaydı saldırılar baktıkları yere gitmeliydi; menzilli karakterlerde kilitlenip o hedefe saldırmak daha iyi
  - Yakın dövüş saldırıları **karakterin baktığı yöne** gider
  - Menzilli saldırılar (support ve fırlatma bıçaklı damage) **kilitlenme sistemini** kullanır, kilitlenilen hedefe vurur
  - Öneri: kilitlenme herkese açık (yakın dövüşçü boss'a dönük kalmak için kullanabilir) ama yakın dövüş için isteğe bağlı
  - Öneri: **hareket, dodge ve zıplama kilitliyken bile hep WASD'yi izler.** Kilitlenme sadece saldırının nereye gideceğini belirler
  - Kilitlenme menzilli vuruşu kolaylaştırdığı için menzilli zorluk nişan değil; pozisyon, dodge ve güvende kalmaktır
  - Co-op fikri: support bir müttefike kilitlenebilir (ör. iyileştirme için), tank boss'a
- **Dodge (Memo, karar):**
  - **Dokunulmazlık yok (i-frame yok)** ve **mükemmel dodge** bonusu yok. Dodge saf harekettir: sadece seni **gerçekten saldırının dışına taşırsa** kurtarır
  - **Stamina yok, cooldown var** ("since there is no perfect dodge there wont be stamina but a cooldown")
  - **Geçiş sırlarında** da kullanılır (ör. yüksek bir yere ulaşmak için uçan moba dash), aynı cooldown ile
  - Tasarıma etkisi (öneriler):
    - Saldırılar tek dodge ile kaçılabilecek boyutta olmalı ya da net bir cevabı olmalı (zıplama, parry, erken yürüyüp çıkmak). Büyük alan saldırıları içinden dodge atarak değil, **pozisyonla** okunup kaçılır
    - Cooldown her dodge'u bir karar yapar: **boşa harcamak** seni sonraki saldırıya açık bırakır. Zıplama ve parry yedek araçlar olur
    - Bosslar bunu test edebilir: dodge gerektiren bir saldırının hemen ardından gelen hızlı bir devam, panik dodge'u cezalandırır
    - Upgrade fikirleri (2. sütun): daha kısa cooldown, daha uzun dodge, 2 hak, arkasında bir şey bırakan dodge (tuzak, yem)
    - Role göre his: tank dodge'u kısa/ağır, damage dodge'u uzun/hızlı
- **Saldırarak parry (Memo'nun fikri, sadece yakın dövüş):** boss'un saldırısı tam isabet ederken **saldırırsan** onu **parry'lersin**. Parry, 2-3 skill'inin **daha çok hasar verdiği** bir pencere açar. Yani dövüş sol tık spam'i değil: boss'u izler, saldırılarını zamanlarsın
  - **Kural: menzilli = parry yok (Memo, karar).** Menzilli oyuncular çoğu zaman güvenli mesafede durduğu için parry'den vazgeçer. Support ve fırlatma bıçaklı damage için geçerli
  - Açık: support'un **kendi skill bonus penceresini kazanma yolu** olmalı, yoksa skill'leri yakın dövüşün yanında sönük kalır. Fikirler: boss'a hazırlık anında vurmak, turret'ı bir süre hayatta tutmak (karar verilecek, önce Memo'nun fikri). Menzilli damage bunu **çok daha yüksek temel hasarla** telafi eder
- Öneriler / karar verilecek (çoğu test edilerek):
  - **Parry penceresi:** başta cömert mi? (ör. ~0.2 sn). Upgrade'lerle genişleyebilir veya değişebilir (2. sütun)
  - **Hangi saldırılar parry'lenir:** parry'lenebilen saldırılarda net bir sinyal (ör. silahta parlama veya halka) ve parry'lenemeyen bazı saldırılar (dodge veya zıplama gerekir), böylece oyuncu her saldırıyı okumak zorunda kalır
  - **Kaçan parry:** sadece darbeyi yersin (risk/ödül). Yanlış zamanda saldırmak cezadır
  - **Tank ve damage için aynı parry, farklı ödül?** ör. tank parry'si boss'u sersemletir, damage parry'si kritik penceresi verir
  - **Zıplama ayrı bir araç:** dodge yana, zıplama üstünden (şok dalgaları, yer süpürmeleri). Bosslara *dodge* mı *zıplama* mı isteyen saldırılar verir
  - **Observer bağı:** bunları da sayabilir: dodge mu zıplama mı, parry zamanlaması (erken/geç), "bu saldırıyı hep parry'liyor" → parry'yi yemleyen sahte hazırlık
- Özgünlük notu: saldırıya vurarak parry başka oyunlarda var (ör. Hollow Knight'ın nail clash'leri, For Honor'ın parry'leri; Sekiro tarzı deflect'ler ise blok tuşu kullanır). Buradaki fark parry'nin kısa bir **skill penceresi** açması ve Observer'ın parry alışkanlıklarını öğrenmesi

### Karakterler (çıkışta 3, her biri tek başına oynanabilir)
| Rol | Başlangıç canı | Silah | Menzil | Tek başına kimliği | Co-op bonusu |
|---|---|---|---|---|---|
| Tank | **300** | Kalkan-çekiç | Yakın | Blok/karşı saldırı, dayanıklı; **başta düşük hasar** | **Taunt (pasif)**, kalkan müttefikleri korur |
| Damage | **150** | Zincir bıçak (**fırlatma bıçaklarına** dönüşebilir) | Yakın; **bıçak upgrade'iyle menzilli** | Hızlı, kırılgan, yüksek beceri tavanı | Bitirici |
| Support / Kontrol | **200** | Asa | **Menzilli (kilitlenme), parry yok** | **Turret pet** + etrafında alan | Alan müttefikleri iyileştirir/güçlendirir |

- Başlangıç canları Memo'nun kararı. Tank hasarı düşük başlar, upgrade'lerle büyüyebilir
- Zorluk eğrisi: Tank (en kolay) → Support → Damage (en zor). Memo, **tek başına** en zorun Support olacağını düşünüyor (bkz. Revenant ödülleri)
- Support build'leri farklılaşabilir (ör. hasar ağırlıklı support, iyileştirici/çağırıcı support)
- Silah değişmez (Memo): her karakterin tek silahı var, upgrade'ler oyun stilini değiştirir
- Görünüm: Apex tarzı kahramanlar; güçlü silüet ve her birine net bir renk kimliği. Kahraman ana renkleri karar verilecek (öneri: teknoloji ışığıyla karışmasın diye yeşil/turuncu/camgöbeği olmasın)
- Temel kit: herkes aynı kontrollere sahip: temel saldırı, dodge (i-frame yok, cooldown), zıplama, kilitlenme ve **Q/E/R'de 2-3 skill**. Yakın dövüşçüler ayrıca saldırarak parry yapar. **Skill'ler sonra tasarlanacak** (Memo)
- Hikâyedeki yerleri: [LORE.md](LORE.md#karakterler)

#### Tank kiti (sürüyor)
- **Taunt pasif (Memo, karar)**, skill değil. Q/E/R başka skill'lere kalır
  - Esas olarak co-op'ta ve bağlanmış Revenant tank ile önemli: düşman odağını müttefiklerden çeker, Observer'ın hedef önceliğini ezer
  - Açık: pasif tam nasıl çalışır? Fikirler: tankın yakınındaki düşmanlar onu hedefler; tankın son vurduğu düşmanlar ona odaklanır; başarılı parry'den sonra daha güçlü çekim
- Skill'ler (Q/E/R): sonra (önce Memo'nun fikirleri)

#### Damage kiti (sürüyor)
- Varsayılan: **yakın dövüş** zincir bıçak, parry yapabilir
- **Fırlatma bıçakları upgrade'i (Memo'nun fikri, karar):** bir power-up zincir bıçağı **fırlatma bıçaklarına** çevirir, karakter **tamamen menzilli** olur:
  - **Parry yok** (menzilli = parry yok kuralı)
  - Saldırılar **kilitlenme** kullanır
  - **Support'tan çok daha yüksek temel hasar** (Memo); parry'nin skill penceresini kaybetmeyi telafi eder
  - Kırılgan kalır (150 can): rol "menzilde cam top", ikinci bir support değil. Turret, alan ve iyileştirme support'un kimliği olarak kalır
  - **Boss ödülü olarak sunulur (Memo, karar)**, normal upgrade seçimi olarak değil. Bir run en erken 1. boss'tan sonra menzilliye dönebilir
- Hikâye bağı: çöpçü, kurtardığı bıçağı söküp bıçaklara çevirir
- Observer bağı (öneri): menzilliye geçince parry zamanlaması yerine **pozisyon** alışkanlıkları izlenir
- Revenant bağı (öneri): bu upgrade'in alındığı geçmiş bir run, yakın dövüşçüden çok farklı oynayan **bıçak fırlatan bir Revenant** olarak döner
- Açık: run boyunca kalıcı mı, geri dönebilir mi? Diğer upgrade'ler iki formda nasıl çalışır (ör. yakın ve menzilli versiyonu olan upgrade'ler)?
- Özgünlük notu: upgrade'le form değiştiren silahlar var (ör. Hades'in weapon aspect'leri). Bizimki bunu menzilli/parry takasına ve Observer ile Revenant sistemlerine bağlıyor

#### Support kiti (Memo, karar)
- **Menzilli:** asanın saldırıları **kilitlenilen hedefe** vurur
- **Parry yok (Memo, karar):** menzilli oyuncular çoğu zaman güvenli mesafede; parry'nin olmaması takastır
  - Support için zor bosslar mesafeyi kapatarak test edebilir (hücum, içeri çekme, arenayı daraltma)
  - Observer, support'un parry zamanlaması yerine **pozisyon** alışkanlıklarını izler
  - Açık: support kendi skill bonus penceresini nasıl kazanır?
- **Turret'lar pet (Memo):** turret yere konmak yerine **support'u pet gibi takip eder**
  - Hikâye bağı: healer antik teknolojiyi anlıyor, eski bir makineyi yanında çalışır tutabilir
  - Öneriler / açık: kaç turret (1 ile başla)? Support'un kilitlendiği hedefe otomatik saldırır mı? Düşmanlar yok edebilir mi, cooldown sonra geri gelir mi? Observer'ın hedef önceliği onu da kapsar mı?
  - Not: Bind the Revenant ile çağırıcı support'un bir turret pet'i ve en çok 2 Revenant müttefiki olabilir. Ekran okunabilir kalmalı, support sadece müttefikleriyle kazanmamalı
- **Support'a bağlı alan (Memo):** varsayılan olarak alan **karaktere bağlı** ve onunla hareket eder (aura gibi). Co-op'ta müttefikler etkisini almak için support'un yakınında kalır
- **Ayırma upgrade'i (Memo'nun fikri):** bir power-up alanı support'tan **ayırır**. Alan yerinde kalır ama **güçlenir**
  - Net bir 2. sütun seçimi: hareketli ve güvenli (bağlı) mı, güçlü ama sabit (ayrılmış) mı? Dövüşün nerede olacağını planlamayı ödüllendirir
  - Öneriler / açık: ayrılmış alan nereye bırakılır (skill'e basıldığında support'un ayağına mı)? Tekrar alınıp taşınabilir mi? Ayırmak alanın yaptığını değiştirir mi (ör. daha çok iyileştirir veya düşmana hasar verir)? Fırlatma bıçakları gibi boss ödülü mü olmalı?
- Özgünlük notu: auralar ve pet turret'lar RPG/MMO'larda yaygın. Roguelite upgrade'i olarak "güç için ayır" takası güzel bir yorum

### Bosslar
**İlk çıkış (karar): 3 boss + Observer**
- 3 normal boss, **her rolün zayıflığına bir tane**: biri tanklar için, biri damage için, biri support için daha zor
- 4.: Observer (final)
- Sonra: Aşama ?, **antik tanrı** (bkz. [LORE.md](LORE.md#sonlar))
- Her boss aşamasının **11. odasında**, kilitli bir kapının arkasında
- Run'larda mini bosslar da çıkar
- Kamera: bazı boss saldırılarında Observer'ın balkon görüşüne geçilir
- Saldırı türleri (öneri): parry'lenebilen (sinyalli), sadece dodge'lanan ve üstünden zıplanan (şok dalgası, süpürme) saldırılar. Dodge'da dokunulmazlık olmadığı için sadece dodge'lanan her saldırı, kaçılacak gerçek bir boşluk bırakmalı
- Yer uyarıları, teknoloji ışığında kullanılmayan özel bir tehlike rengi kullanır

**Boss ödülleri (Memo):** bosslar, damage'ın fırlatma bıçakları gibi **build değiştiren upgrade'ler** verebilir.
- Öneri: büyük, oyun stilini değiştiren upgrade'lerin (form değişimleri, evrimler) yeri boss ödülleri olsun, normal odalar küçük upgrade'ler versin
- Nasıl sunulacağı: test edilerek karar verilecek (Memo)

**Tam vizyon (sonraki güncellemeler): 6 boss (rol başına 2) + Observer = run başına 7, modifier'lar hariç** (Memo'nun ilk fikri)

Boss kuralları:
- "X için daha zor" = X'in zayıflığını test eder (ör. anti-tank: yerinde durmayı/blok yapmayı cezalandırır, hareket ister; anti-damage: açgözlülüğü cezalandırır, az güvenli açıklık, hem yakın hem bıçak build'ine karşı çalışmalı; anti-support: mesafeyi kapatır, alanları yok eder/onlardan kaçar, turret pet'in peşine düşer)
- Yine de her karakter beceriyle yenebilmeli (1. sütun): daha zor, ama kesin karşı değil
- Co-op'ta rol karışımı, takım için hangi bossların zor olduğunu belirler

#### Observer (final boss): kurala dayalı, yapay zekâ yok
Memo bunu açıkça **yapay zekâsız** istedi: basit sayma kuralları.

- **Görünüm (Memo):** **camgöbeği bir hologram.** Balkon hologramı her aşamada camgöbeği
- **Run boyunca varlığı (Memo'nun fikri):** her boss odasında dövüşü **izleyen bir hologramın** olduğu bir göz / balkon var. Oyuncu bunu 1. boss'tan itibaren görür, final dövüşünün habercisi

**Nasıl öğrenir: basit sayma kuralları**
- Her boss saldırısı, *oyuncunun ondan nasıl kaçtığını* kaydeder (hikâye: Observer'ın kontrol ettiği döngü kaydının parçası)
- **Normal odalar da sayılır:** ne kadar çok oda temizlersen Observer o kadar çok alışkanlık verisi alır. Öneri: boss dövüşleri tam, normal odalar daha az sayılsın, böylece koşan oyuncu Observer'a daha az veri verir
- Memo'nun örneği: 1. boss'un sola veya sağa dodge gerektiren bir saldırısı var. 9 kez kullanıldı, oyuncu 6 kez sağa kaçtı. Şunlardan biri olursa eğilim işaretlenir:
  - aynı seçim **üst üste 3 kez** olursa, ya da
  - bir seçim açık **çoğunluksa** (ör. 9'da 6)
- Final dövüşünde Observer **1. boss'un hologramına dönüşür** ve o saldırıyı tekrar kullanır, ama **sağda güvenli alan yoktur**

**Adalet kuralları**
- Her zaman bir çıkış var: karşılanan taraf kapanır, diğeri açık kalır
- *Sana* karşı oynadığına dair net sinyal (hologram titremesi, kapalı taraf parlar), oyuncu "burada tahmin edilebilirim" diye öğrenir
- Her karşı hamle, mevcut bir saldırının elle yapılmış bir varyantı (ör. "Süpürme: sol güvenli" / "Süpürme: sağ güvenli")

**Aynı yolla izlenebilecek diğer alışkanlıklar (sonra genişletilecek)**
- Mesafe: yakın mı duruyor uzak mı → karşı versiyon o mesafeyi cezalandırır
- Dodge zamanlaması: erken mi geç mi → gecikmeli veya sahte hazırlık
- Her ikisinin de işe yaradığı saldırılarda **dodge mu zıplama mı** → favori kapanır
- **Dodge harcama:** kombonun başında sık dodge → dodge cooldown'dayken gelen devam vuruşu
- **Parry alışkanlıkları (yakın dövüş):** belli bir saldırıyı hep parry'lemeye çalışmak, erken/geç parry → parry'yi yemleyen sahte hazırlık
- **Pozisyon alışkanlıkları (menzilli: support, bıçaklı damage):** favori mesafe, favori köşe → o noktaları kapsayan saldırılar
- **Support alan alışkanlıkları:** alanı hep aynı yere ayırmak (ör. ortaya) → o noktayı kapsayan saldırı
- Ceza penceresi: kombo bitince hep saldırmak → ek devam vuruşu
- Pozisyon: duvarlara/köşelere yapışmak → kenarları kapsayan saldırı
- Favori hareket/upgrade: bir hareketi sürekli kullanmak → Observer direnir veya kopyalar
- Sesin upgrade uyarılarına uyup uymamak (bkz. [LORE.md](LORE.md#parça-3-i-wouldnt-take-that-if-i-were-you))

**Zayıflığı:** sesin uyardığı upgrade'ler Observer'a karşı özellikle etkili.

**Hedef önceliği (Memo'nun fikri):** Observer önce **Support'a, en son Tank'a** odaklanır (Support → Damage → Tank). Bağlanmış Revenant müttefiklere ve co-op oyunculara uygulanır.
- İyileştirici/çağırıcı support yolunu sonda zorlaştırır: support müttefiklerini hayatta tutarken kendisi baskı altında
- Co-op'ta takım support'unu korumalı
- **Tank taunt'u önceliği ezer (karar):** tank (oyuncu veya bağlanmış Revenant) Observer'ın odağını çekebilir. Taunt **pasif** (Memo, karar). Açık: tam kurallar (menzil, odağın süresi)
- Açık: öncelik gösterilmeli mi (ör. odaklanılan oyuncuda hedefleme ışını)?

**Final faz sesi:** glitch'lerdeki manyak ses (bkz. [LORE.md](LORE.md#parça-1-ses-memonun-fikri)).

**Kapsam kazancı:** Observer boss saldırılarını ve modellerini hologram shader'ıyla tekrar kullanır; yeni bir boss kadar sanat değil, çoğunlukla *varyant* gerekir. Hikâye bağı: 3 boss'u sayısız kez dövüştüğü için saldırılarını bilir.

Açık: boss sırası sabit mi rastgele mi? Run süresi: **ortalama 20-40 dk** (Memo, karar). Observer dövüşünde kaç karşı hamle (ör. ilk 3 alışkanlık)?

### Rupture'lar (isteğe bağlı olaylar)
Odalar arasında giderken zaman döngüsünde aniden bir **rupture (yarık)** çıkabilir (Memo'nun fikri). Oyuncu girip girmemeyi seçer (risk/ödül; atlamak her zaman serbest). Hub'dan baloncuğa girerken kullanılan yarıkla aynı görsel.

Rupture türleri (Revenant dövüşü bunlardan biri; Memo sadece Revenant dövüşünden fazlasını istedi):
- **Revenant Fight:** geçmiş kendinle dövüş (aşağıda). Sadece geçmiş **tank ve damage'lar** Revenant olur
- **Healer's Rest** (Memo'nun fikri, çalışma adı): rupture'daki geçmiş benlik bir **support** ise dövüş yok. Eski healer'ınla bedava bir aşama. **2'den 1 seç (karar):**
  1. **Tam iyileşme:** cana tam dön
  2. **+%20 maksimum can:** başlangıç canına göre (tank +60, damage +30, support +40)
  - **Run başına en çok bir kez çıkar** (karar)
- **Lost Relic:** geçmiş run'larından birinde kalmış bir upgrade; al, belki bir bedelle
- **Paradox Room:** garip kurallı bir meydan okuma odası (dodge yok, ters yerçekimi, düşmanlar ölünce geri sarılır); ödül zorlukla artar
- **Glimpse Ahead:** gelecek boss'un desenine karşı kısa bir ön dövüş; sonrası için öğren (beceri odaklı ödül)
- **Fractured Ally:** geçmiş bir Revenant bir aşama boyunca *seninle birlikte* savaşır
- **Loop Merchant:** zamanı (maks can, upgrade'ler) başka upgrade'lerle takas et
- Açık: rupture aşamanın odalarından biri mi sayılır, ekstra mı? "Döngü kararsızlaşır" bedeline eklenir mi? Rupture'lar bakış noktalarında görünür mü?

### İmza özellik: Revenant dövüşleri
_("Echo"dan yeniden adlandırıldı; ECHO (2017) ve geçmiş benlikleri "Echoes" diye adlandıran yakında çıkacak bir Steam oyunuyla karışmasın diye. Not: "Revenant" özellik adı olarak uygun, oyun adı olarak değil; Apex Legends'ta bu isimde bir karakter var ve Code Vein karakterleri için kullanıyor.)_

- **Revenant'lar nereden gelir (Memo, karar):** döngüdeki her ölüm **kaydedilir.** Revenant, o kayıttan **yeniden kurulan** geçmiş benliğindir (Memo: "it also explains the revenants")
- **Hikâye (Memo'nun fikri):** Revenant'lar zaman döngüsü tarafından **bozulmuş (glitch'lenmiş)** kayıtlı geçmiş benliklerdir. Healer'lar antik teknolojiyle etkileşebilen, onu kısmen anlayan kişiler olduğu için döngü **onları bozamaz.** Geçmiş bir healer, Revenant olarak değil, dost bir varlık olarak döner (Healer's Rest)
- **Giriş sahnesi (Memo'nun fikri):** içeri girersin ve geçmiş benliğini ölümün eşiğinde, o geçmiş run'ın bittiği tam anda (kaydedilen an) görürsün. Birden zaman geriye akmayı bırakır ve eski benliğin tam canla odaya yürür. Dövüş başlar
- Run başına kayıt: karakter, son upgrade'ler/build, nasıl/nerede öldüğü ve basit bir davranış profili (tercih edilen mesafe, dodge sıklığı, saldırganlık, favori hareketler)
- Revenant = o build ile o profili kullanan düşman davranışı (birebir girdi tekrarı değil); Observer ile aynı sayım verisi
- Damage Revenant'ı o run'ın build'ine göre yakın dövüşçü ya da bıçak fırlatıcı olabilir
- Görsel fikir: Revenant'lar glitch'li/bozuk görünür; Healer's Rest'teki geçmiş healer temiz ve stabil görünür; Revenant'lar o run'daki özelleştirilmiş görünümü korur
- Hikâye fikri: çok nadiren, Observer'ın oyuncudan önce kandırdığı bir savaşçının kaydından kurulan bir Revenant

**Ödüller (karar)**
- Tank ve Damage: 2'den 1 seç (Memo)
  1. **Ekstra can:** bu run'da ölünce bir kez dirilme
  2. **Eski benliğinin build'inden bir eşya/skill**
- **Sadece Support: 3'ten 1 seç** (Memo'nun fikri; tek başına support daha zor): yukarıdaki ikisi, artı
  3. **Bind the Revenant** (Memo'nun fikri)

#### Bind the Revenant (sadece Support)
- Tamamen bir seçenek: hasar ağırlıklı support eşyayı veya ekstra canı tercih edebilir (Memo)
- Yenilen Revenant **öldürülene kadar seninle savaşır** (Memo'nun kararı). Zamanlayıcı yok; bütün run sürebilir
- Kendiliğinden bağlılık (Memo): onu hayatta tutmak support'un **iyileştirme** upgrade'lerine yönelmesini gerektirir. Doğal bir "healer / çağırıcı" build yolu (2. sütun)
- **Birden fazla bağlı Revenant (Memo'nun kararı):** rol başına bir tane. **Aynı rolden** iki tane (ör. iki damage): birini seç. **Farklı roller** (tank + damage): ikisini de tut. Support'lar Revenant olmadığı için **en çok 2 müttefik** (1 tank + 1 damage)
- **Observer etkileşimi (Memo'nun kararı):** **3. boss'tan sonra** bağlanan bir Revenant hiçbir boss dövüşünde görülmediği için Observer'da hakkında veri yok; bu bir avantaj. Observer'ın hedef önceliği (önce Support) bunu dengeler
- Hikâye bağı: healer antik teknolojiyi, bozuk bir kaydı "onarıp" senin tarafına çevirecek kadar iyi anlıyor
- Fractured Ally teknolojisini tekrar kullanır
- Açık: sadece tek oyunculu mu, co-op'ta da mı? (Öneri: sadece tek oyunculu)
- Açık: run boyunca güçlenir mi, olduğu gibi mi kalır?
- Dikkat: rupture'lar rastgele ve isteğe bağlı olduğu için Support'un **temel kiti** tek başına güçlü olmalı

Tasarım notları:
- Biriktirilen ekstra canları sınırla (öneri: en çok 1), seçim gerçek bir ikilem kalsın
- Revenant'ın hangi eşyalara sahip olduğunu dövüşten *önce/sırasında* göster, oyuncu ne için savaştığını bilsin

#### Yeniden dövme (reforging) (karar: eşyalar silahına uyar)
*Farklı* bir karakterin Revenant'ından eşya aldığında, eşya silahına uyacak şekilde **yeniden dövülür** (Memo "item adapts to your weapon" seçti).
- **Ayrıntılar sonraki bir konu** (Memo)
- Her upgrade, her silahın kendi yoluyla ifade edebileceği bir **çekirdek etki** etrafında tasarlanır (ör. "çekme", "sekme", "tuzak bırakma")
- Örnek: zincir bıçak "Tether" (düşmanları çek) → çeken bir tank kalkan darbesi; düşmanları merkezine sürükleyen bir support alanı (veya çeken bir turret atışı)
- Sonra: fırlatma bıçakları gibi boss ödülü upgrade'lerin yeniden dövmeyle ilişkisi

Yeniden dövme animasyonu: **sadece fikir, sonra tekrar bakılacak** (Memo: "we can talk about the animation at a later time but as an idea i think its good")
- Sanat kapsamı yönetilebilir kalsın diye karakter başına bir animasyon (toplam 3), eşyaya göre renklendirilmiş
  - Tank: eski silahı kırar ve parçaları kalkanının önüne çakar (Memo'nun fikri)
  - Damage: eşyayı eritir ve zincir halkalarına işler
  - Support: eşyayı ışığa çözer ve asaya yeni bir rün olarak kazır
- Açık: zorluk ölçekleme, co-op versiyonu (bütün geçmiş partiyle mi dövüşülür?)

### Diğer mekanikler
#### Çok oyunculu
- Önce tek oyunculu, sonra online co-op
- Host tabanlı (listen server): lobiyi kuran host olur, özel sunucu yok
- GodotSteam ile Steam lobileri/relay
- Kod ilk günden co-op'a hazır: girdi karakterden ayrı, oyun durumu için tek otorite
- Üçüncü şahıs kamera: her oyuncunun kendi kamerası var; diğerleri senin özelleştirilmiş görünümünü görür
- Öneri: hub, co-op oyuncularının baloncuğa birlikte girmeden önce buluştuğu yer
- Öneri: bakış noktalarıyla bir oyuncu bakış noktasında durup diğerlerini labirentte yönlendirebilir
- Açık (co-op): oyuncular labirenti ayrı ayrı keşfetmek için ayrılabilir mi, boss'a ne zaman gidileceğine kim karar verir?
- Not: ağ üzerinden parry zamanlaması ve i-frame'siz dodge'lar dikkat ister (host karar verir; istemciye küçük bir tolerans penceresi)

#### Modifier'lar
- Sonra konuşulacak (olası yeri: hikâye sonrası run'lar)

#### Teknik
- Motor: **Godot 4** (standart sürüm, GDScript), 3D, MMO tarzı üçüncü şahıs kamera, ayrıca senaryolu balkon kamera geçişleri ve bakış noktası harita görünümü
- Kontroller: WASD / Shift / Space / Sol tık / Q E R / kilitlenme. Şimdilik kodda kaydediliyor (`PlayerInput`); sonra oyuncular tuş değiştirebilsin diye Project > Input Map'e taşınacak (gamepad desteği de). **Fiziksel tuş kodları** kullanılıyor, QWERTY olmayan klavyelerde (ör. Türkçe F) de çalışır. Harita tuşu yok
- **Run kaydı (ölüm kaydı fikrinden):** run başına bir kayıt (karakter, build, ölüm sebebi/yeri, odalar ve bosslardan davranış sayıları). Revenant'lar, Observer, Lost Relic, Healer's Rest ve hikâye tetikleyicileri kullanır. Birçok özellik buna bağlı olduğu için erken yapılmaya değer
  - Kaydedilecek alışkanlık parametreleri (Memo, karar): **dodge attığı yönler**, **boss ile ortalama mesafe**, **en çok kullandığı skill'ler** ve benzeri parametreler. Şema ADR olarak yazılacak (#12)
- **Aşama üretimi (Memo, karar): elle yapılmış parçalar, rastgele bağlanır.** Elle yapılmış odalar ile koridor, merdiven ve kat parçaları birkaç katlı bir labirent oluşturacak şekilde birleşir. Aşama başına 10 oda + boss odası, anahtar rastgele bir odada, aşama başına en az 1 bakış noktası. Temel dövüş prototipinden sonra planlanacak, büyük teknik parçalardan biri
- **Bakış noktası haritası:** bakış noktasında dururken oluşturulan labirentin tamamını göster (tüm katlar, odalar ve neyi göstereceğine karar verirsek). Başka hiçbir yerde harita yok
- **Görsel kod (Claude):** hologram, glitch'ler, ölümde geri sarma, baloncuk parıltısı, parlayan devreler (yeşil / turuncu-sarı / camgöbeği), yer tehlike uyarıları için shader ve efektler; alan başına ışık ve sis
- **İlk günden co-op mimarisi:** Player klavyeyi asla okumaz; bir girdi kaynağından "niyet" ister. Yerelde = klavye; sonra uzaktan = ağ. Observer aynı niyetleri/sinyalleri (ör. `Player.dodged`) okuyup alışkanlık öğrenebilir
- Sanat: prototip için asset paketleri (ücretsiz CC0, ör. Kenney, Quaternius), kendi materyal ve shader'larımızla uyarlanır; model düzenleme için **Blender** (ücretsiz); özelleştirme için modüler parçalar (saç, kask, zırh parçaları, renk slotları) ve labirent için modüler seviye parçaları; ileride belki ısmarlanan sanatçılar
- Ses efekti: jsfxr / Bfxr
- **İlk prototip hedefi:** boş bir odada hareket eden, dodge atan ve zıplayan bir karakter, MMO tarzı kamerayla. Kod hazır ama henüz test edilmedi; repoya ayrı bir iş olarak gelecek

## Hedef kitle
- Henüz karar verilmedi. Tasarımdan çıkan: zorlayıcı, beceri odaklı roguelite ve aksiyon oyunlarını seven, hikâyeye de bağlanan oyuncular

## Sanat yönü
### Kamera (Memo, karar): MMO tarzı üçüncü şahıs
- Karakterin arkasında ve üstünde, geride duran kamera (omuz üstü değil: "like in the mmos so you can see everything better and react to dangers faster")
- Geçmiş: Memo önce izometrik seçti (Hades benzeri görüşü sevdi ama özgün olsun istedi), sonra buna geçti
- Tipik MMO düzeni (öneri): kamerayı fareyle döndür, tekerlekle sınırlar içinde yakınlaş/uzaklaş, hafif yüksek açıdan aşağı bak
- Neden uyuyor: okunabilir, sinyalli boss saldırıları (1. sütun); yer uyarıları (MMO tarzı yerdeki tehlike alanları) bu açıdan kolay okunur. Dodge'da dokunulmazlık olmadığı için daha da önemli: oyuncu tehlikenin tam nerede bittiğini görmeli
- Kilitlenmede: kamera hedefi görüş içinde tutar
- Labirentte: koridorlar ve merdivenler için kamera çarpışması gerekir
- **Bakış noktalarında:** oyuncu orada dururken kamera çok geriye çekilebilir (veya yukarıdan "bütün labirent" görünümüne geçebilir) (öneri)
- **Özel: bazı boss saldırıları sırasında kamera Observer'ın balkondan bakışına geçer** (Memo'nun fikri)
  - Risk: oyuncu *dodge atmak zorundayken* görüşü değiştirmek kafa karıştırabilir (yönler ters döner, oyuncu karakterini kaybeder). Adil kalmalı (1. sütun)
  - Seçenekler: yukarıdan görüşün *yardım ettiği* saldırılarda kullan (arena çapında büyük desenler, "sola/sağa kaç" süpürmeleri); hareket kontrollerini kameraya değil karaktere göre tut; geçişten önce kısa uyarı ver; ya da dodge gerektirmeyen anlarda kullan (boss girişleri, faz geçişleri, Observer'ın bir alışkanlığı "öğrendiği" an)
  - Hikâye bağı: oyuncu dövüşü tam Observer'ın izlediği gibi görür; Tyrant sonundan sonra bu oyuncunun kendi balkon görüşüdür
- Sonuçlar: ortamlar izometriğe göre daha yakından görülür (daha çok sanat detayı); co-op iyi çalışır (her oyuncunun kendi kamerası)

### Dövüş temposu: arada (Memo seçti)
- Hareket tepkili, ama saldırıların net hazırlığı ve ağırlığı var
- 1. sütuna uyar: okunabilir sinyaller, adil dodge ve parry'ler
- Observer'a uyar: net hazırlıklar karşı desenlerini okunabilir yapar
- Co-op'a uyar: çok seğirmeli dövüşe göre ağ gecikmesine biraz daha hoşgörülü

### Karakter özelleştirme (karar)
- 3 kahramanın her biri kimliğini korur, ama oyuncular görünümlerini değiştirebilir: **zırh parçaları, renkler, kasklar, silah görünümleri ve saç gibi şeyler** (Memo: "i like to be able to change the characters appearance however i like. i think most people do")
- Güç dışı ilerlemeye uyar: kozmetikler run'larla açılabilir, 1. sütunu bozmadan oynamayı ödüllendirir
- Hikâye bağı (öneri): Revenant'lar o geçmiş run'daki görünümü giyer

### Sanat yönü (Memo, karar)
**Hedef (Memo):** "i dont want graphics that will amaze people but i still want it to look good". Pahalı detayla değil; tutarlılık, renk ve ışıkla.

**Stil karışımı (Memo): Cyberpunk + Apex Legends + Elden Ring**
- **Elden Ring → dünya:** devasa ölçekte antik harabeler, bitki basmış taş, solmuş ve melankolik hava. Şekiller ve atmosfer
- **Cyberpunk → teknoloji ve ışık:** neon parıltı, hologramlar, glitch'ler, taşın altında devreler. Sadece antik teknoloji parlar
- **Apex Legends → karakterler:** stilize ama gerçekçi, güçlü okunabilir silüetler, her kahramanın net bir renk kimliği, zırh ile teknoloji ekipmanı karışık; dövüşler kaosta bile okunabilir
- Karışımı bir arada tutan kural (öneri): **şekiller ve hava Elden Ring'den, ışık ve vurgular cyberpunk'tan, karakterler Apex'ten.** Dünya çoğunlukla soluk ve topraksı; parlayan her şey antik teknoloji; kahramanlar cesur renklerle öne çıkar
- Onların bütçe seviyesindeki detayını değil, **yönünü** alıyoruz; sadece ilham, tasarımlarını asla kopyalamıyoruz
- Diğer temeller: **stilize 3D**, detaylı karakterler, **pixel art yok** (Memo pixel art sevmiyor); her yerde tek tutarlı stil (uyuşmayan asset paketlerini asla karıştırma); önce okunabilirlik

**Derinliğe göre teknoloji ışık renkleri (Memo, karar):**
| Alan | Işık rengi | Not |
|---|---|---|
| Yüzey (bitki basmış harabeler) | **Yeşil** | Binaları kaplayan **yosunla** uyumlu |
| Daha derin (fabrika salonları) | **Turuncu / sarı** | |
| En derin (çekirdek) | **Camgöbeği** | **Observer'ın rengi** (Memo onu hep camgöbeği bir hologram olarak hayal etti) |

- Etki: oyuncular derine indikçe dünya yavaş yavaş Observer'ın rengine döner. Onun alanına yürüyorlar
- **Observer'ın balkon hologramı her aşamada camgöbeği**, yeşil ve turuncu alanlarda göze batar (haberci)
- Öneriler / dikkat:
  - Yeşil ışık ile yeşil yosun: ışık yosundan daha parlak ve doygun olmalı (ya da yosun daha koyu), teknoloji net okunsun
  - **Tehlike rengi:** yerdeki boss saldırı uyarılarının dünyanın teknolojide hiç kullanmadığı kendi rengi olmalı (ör. kırmızı veya beyaz), tehlike süsle asla karışmasın
  - Kahraman ana renkleri: yeşil/turuncu/camgöbeğinden kaçın, kahramanlar her alanda öne çıksın
  - Erken camgöbeği anlar (ses glitch'leri, hologram, rupture'lar?) açıklamadan önce Observer'ı ima edebilir
  - Hub / dış dünya (öneri): gri ve renksiz (geriye bir şey kalmamış), tek güçlü renk baloncuğun camgöbeği parıltısı

**Sanat nasıl yapılacak (Memo):** Memo sanatı sıfırdan yapamıyor, o yüzden:
- Memo **sanat yönünü yönetir;** Claude **konsept fikirleri** verir (yazılı konseptler, silüetler, paletler, basit SVG eskizler)
- Claude **kod olan** her görseli yazar: shader'lar, efektler, ışık, UI (hologram, glitch'ler, ölümde geri sarma, baloncuk parıltısı, parlayan devreler, yer uyarıları)
- Modeller ve animasyonlar: **asset paketleri** (prototip için ücretsiz CC0, ör. Kenney, Quaternius), materyal, renk ve shader'larla bize ait hâle getirilir; ileride belki konseptlerimizden çalışan **ısmarlanan insan sanatçılar**
- Steam notu (2026-11-23 kontrol edildi): Steam, oyuncuların gördüğü veya duyduğu **yapay zekâ ile üretilmiş içeriğin** (sanat, ses, hikâye metni) mağaza sayfasında belirtilmesini istiyor; yapay zekâ kodlama asistanı gibi perde arkası araçlar için gerekmiyor (Valve güncellenmiş formunda bunu netleştirdi). Yani Claude'un yazdığı kod sorun değil; görünen asset'leri (model, doku, ses) insan yapımı tutmak mağaza sayfasındaki yapay zekâ notundan kaçınır

### Görsel kimlik fikirleri (seçilecek / birleştirilecek)
1. **Kamera Observer'ın gözüdür:** balkon kamera geçişi ve bakış noktalarıyla kısmen gerçekleşti; o görüşlerde hafif bir gözetim hissi de eklenebilir
2. **Döngü görsel dili:** ölünce oda görünür şekilde **geri sarılır** (düşmanlar ve mermiler yerlerine uçar), sonra kararır; döngünün dokunduğu her şeyde glitch efektleri (Revenant'lar, rupture'lar). Hub'da uyanmadan önce ölümün "kaydedildiği" de gösterilebilir (bir flaş, donmuş kare). Bir aşamada ne kadar kalırsan döngünün o kadar "kararsız" olması labirentte artan glitch'ler olarak görünebilir
3. **Doğanın altında antik teknoloji** (artık sanat yönünün parçası): bitki basmış taş ve yosun, altında parlayan devreler (derinlikle yeşil → turuncu/sarı → camgöbeği); derin alanlar (ve alt labirent katları) daha çok makine, daha az doğa gösterir, ta ki çekirdek neredeyse saf teknoloji olana kadar
4. **Dünya aşınır:** run'lar boyunca şehir döngünün hasarını gösterir (daha çok çatlak, glitch, çentik işaretleri); oyuncunun ne kadar süredir kapana kısıldığını yansıtır
5. **Dışarıdan görülen baloncuk** (Memo'nun hub fikrinden): harap dış dünyadan görülen, dev bir kubbenin altına kapanmış dünya

## Ses yönü
- Ses efektleri: jsfxr / Bfxr (prototip)
- **Ses (the Voice):** oyun boyunca oyuncuya konuşan ses, hikâyenin merkezinde (bkz. [LORE.md](LORE.md#parça-1-ses-memonun-fikri)). Önce güvenilir, sonra glitch'li ve manyak; ölünce yükleme ekranında **"AGAIN"** diye bağırır
- Müzik: henüz karar verilmedi

## Kapsam dışı
Bilerek yapılmayacaklar (kapsamı korumak için):
- İlk çıkışta 6 boss yok: **3 boss + Observer** (tam vizyon sonraki güncellemelerde)
- Özel sunucu yok (co-op host tabanlı)
- Minimap ve her yerden açılan harita yok
- Pixel art yok
- Büyük skill çubuğu yok (karakter başına 2-3 skill)
- Observer için yapay zekâ yok (basit sayma kuralları)

## Açık sorular
**Çekirdek oynanış (şimdi tasarlanacak):**
- Bakış noktaları: tam olarak ne gösterir (anahtarın yeri? sırlar? rupture'lar? kendi konumun?); rastgele mi yerleşir, biri hep başlangıca yakın mı; dünyada neye benzer
- Odalar: hangi oda türleri var (mob, mini boss, diğerleri: dükkân, dinlenme, meydan okuma?); normal upgrade'ler ne zaman verilir
- Hub: içinde ne var
- Geçiş: sırlarda ne var; geçişi kolaylaştıran skill'ler (sonra)
- Support: kendi skill bonus penceresini nasıl kazanır (parry yok)
- Tank: pasif taunt tam olarak nasıl çalışır
- Damage: fırlatma bıçakları run boyunca kalıcı mı, diğer upgrade'ler her formda nasıl çalışır
- Her karakterin 2-3 skill'i (kalabalık, büyük hedef ve hareketi kapsayan): sonra. Önce Memo'ya sor, ör. "tankın kalkan-çekici Q/E/R'de ne yapar?"
- Kamera: hangi boss saldırıları balkon geçişini alır, nasıl adil tutulur?
- Co-op: labirentte ayrılmak, boss'a ne zaman gidileceğine kim karar verir

**Sanat:**
- Tehlike uyarı rengi (öneri: kırmızı veya beyaz, teknolojide asla kullanılmayan)
- Her kahramanın ana rengi
- Hub / dış dünya paleti (öneri: gri, baloncuğun camgöbeği parıltısıyla)

**Test edilerek karar verilecek (Memo):**
- Dodge cooldown'ı ve mesafesi (önerilen başlangıç ~1-1.5 sn), role göre farklar
- Parry penceresi boyutu, hangi saldırılar parry'lenir, tank ve damage parry pencereleri ne yapar
- Kilitlenme tuşu, yakın dövüş kilitlenme kullanır mı
- Boss ödülleri: nasıl sunulur, hangi upgrade'ler boss ödülü sayılır
- Support: turret pet sayısı, yok edilebilir mi, ayrılmış alan nasıl yerleşir ve taşınır
- "Neden her odayı temizlemiyorsun" bedellerinin her birinin gücü (Observer verisi, yıpranma, kararsızlık)
- Labirent boyutu, aşama başına kat sayısı ve bakış noktası sayısı
- Revenant dövüşü zorluk ölçekleme; rupture'ların ne sıklıkla çıktığı; run süresinin 20-40 dk hedefi içinde kalması

**Hikâye / sonra:** bkz. [LORE.md](LORE.md#açık-sorular)
- Yeniden dövme ayrıntıları
- Meta ilerleme: **güç açılımlarına** yakın (hikâye: Observer'ın sistemi), ölçülü tutulur. Ne kadar güçlü, ne türden? (Kozmetik açılımlar ayrı bir ödül yolu)
- Upgrade yönleri serbestçe karışır mı, bağlılık mı?
- Kullanılacak diğer görsel kimlik fikirleri
- Support tek başına denge
- Oyun adı: **Again** (çalışma adı, büyük ihtimalle son); alt başlık veya stilize yazım karar verilecek

## Fikir geçmişi: değiştirilen ve vazgeçilen fikirler
Kimse Memo'nun zaten reddettiği bir şeyi tekrar önermesin diye tutuluyor.

| Konu | Ne oldu |
|---|---|
| Tür / çalışma şekli | Memo seçti: roguelike/roguelite, birlikte geliştirme (Memo tasarım + sanat, Claude kod + açıklama), motor deneyimi yok. |
| Zorluk | Memo: zorlayıcı; "if you aint lucky with upgrades i want the player to be able to push through with skill alone". |
| Silahlar | Memo: her karakterin sadece 1 silahı var, değiştirilemez, ama upgrade'ler oyun stilini değiştirir. |
| Karakter sayısı | Memo: 3 karakter mükemmel, tamamen farklı türler: tank, damage, support (co-op için). |
| Çok oyunculu | Memo: önce tek oyunculu, sonra co-op; barındırılan sunucu yok, lobiyi kuran host olur. |
| Ortam | Memo: healer'lar modern zamana uymuyor → LOTR benzeri veya bilim kurgu → "unutulmuş teknoloji üzerine kurulmuş antik dünya" seçildi. |
| Sıfırlama mekaniği | Memo: zaman döngüsü, artı geçmiş run'lardaki kendinle dövüştüğün bonus aşamalar. |
| "Echo" → "Revenant" | Geçmiş benlik dövüşünün adı önce "Echo" idi; ECHO (2017) ve yakında çıkacak bir Steam oyunu yüzünden Memo **Revenant** olarak değiştirdi. |
| Echo/Revenant ödülleri | Memo: 2 ödül, birini seç: ekstra can veya eski karakterinden bir eşya/skill. Memo "eşya silahına uyar"ı (yeniden dövme) seçti. Memo'nun tank animasyonu fikri: bıçağı kırar ve parçaları kalkanın önüne ekler. Animasyon ayrıntıları ertelendi. |
| Boss sayısı | Memo önce 7 boss istedi (6 + Observer, rol başına 2-2-2); ilk çıkış için **3 boss + Observer**'a indirildi. Tam vizyon sonraya saklandı. |
| Bind the Revenant | Memo'nun fikri (Claude sormadan önce önerdi; Memo bunun kendi fikri olduğunu ve sorulmayı beklediğini söyledi → "önce sor" kuralı). Sadece Support, zorunlu değil seçenek. |
| Revenant olarak healer | Memo: support'lar Revenant olamaz; geçmiş bir support bedava iyileşme aşaması verir. Ödül: Memo önce run başına bir kez +%20 can dedi, sonra "return to full hp or add 20 percent". |
| Hikâye: healer'lar | Memo: healer'lar teknolojiyi anlıyor, bu yüzden bozulamazlar (glitch'lenemezler). |
| Hikâye denemesi 1 (bırakıldı) | Memo: Observer sevilen eski bir kahraman/maceracı, kibirli, hubris. Claude bunun Darkest Dungeon'ın Ancestor'ına, Hollow Knight'ın Pale King'ine, Fire Emblem: Three Houses'ın Nemesis'ine yakın olduğunu belirtti. Memo bıraktı: bağlayan bir hikâye istiyor. |
| Hikâye denemesi 2 (bırakıldı) | "Observer döngüyü yarattı / savaşçıları lanet olarak içine çekti". Memo: "with your questions i realized this idea wont work". |
| Döngünün kökeni | Memo: döngüyü Observer yaratmadı, ele geçirdi. Sonra: döngü felaketleri geri sarmak için yapıldı ama yanlış ellerde hapishane oldu; Observer "haksız yere hapsedildi". Revize (insanlar isteyerek girdiği için bildikleri bir hapishane olamaz): Observer isteyerek girdi, hapishane olduğunu bilmiyordu, çok sonra öğrendi, 3 boss'u geçmesi gerekiyordu, savaş seven bir manyağa dönüştü. |
| Felaket çelişkisi | Memo çözdü: **felaket yok**; insanları döngüye sokmak için bir yalandı (bir uydurma). Yaratıcı = acı çekmeyi izlemekten zevk alan antik bir tanrı. |
| Sonlar | Memo önce 3 seçilen son önerdi (yeni Observer ol / Observer'ı öldür ve döngüyü bitir / Observer'ı öldür, döngü biter, dünya biter), sonra dünyayı kurtarmak için bir "?" aşaması, sonra son versiyon: yeni Observer ol → tanrı zorla girer → sonuç seçilmez, seçimlere bağlı: Tyrant / Mercy / Erasure (yenilirsen). |
| "Observer savaşçıları içeri çekti" (bırakıldı) | Memo değiştirdi: hub Observer'a ait; savaşçılar isteyerek girer. Gerçek: döngü dünyayı geri getiremez; Observer güçlü rakipler bulmak için insanları buna inandırır. |
| Kamera | Önce izometrik (Hades benzeri ama özgün) → Memo MMO tarzı üçüncü şahsa çevirdi (geride, omuz üstü değil, MMO'lardaki gibi), her şeyi görüp daha hızlı tepki vermek için; bazı boss saldırılarında balkon görüşü geçişi. |
| Harita | Memo Binding of Isaac ızgarasını reddetti → derinliği olan rastgele labirent (yeraltı katları, merdivenler). Memo keşfedilebilir minimap'i reddetti → sadece bakış noktaları. |
| Dodge | Memo: mükemmel dodge yok, dokunulmazlık yok, stamina yok → cooldown. Dodge cooldown'ı geçişte değişmez (Memo). |
| Taunt | Memo: pasif, skill değil. |
| Menzilli parry | Memo: menzilli karakterlerde parry yok (menzilde güvendeler). |
| Fırlatma bıçakları | Memo: tam menzilli geçiş, parry yok, support'tan çok daha yüksek temel hasar; boss ödülü olarak gelir. Hibrit (bıçakları zincirle geri çağırma) önerildi, seçilmedi. |
| Boss ödülleri / yeniden dövme | Memo: ödül sunumuna testle karar verilecek; yeniden dövme sonraki konu. |
| Sanat | Memo sanatı sıfırdan yapamıyor; Memo yönetir, Claude konsept verir. Stil: Cyberpunk, Apex Legends, Elden Ring karışımı. Işık renkleri: yeşil → turuncu/sarı → camgöbeği. Harika grafik değil ama iyi görünmeli. Memo pixel art sevmiyor; detaylı karakterler ve tam görünüm özelleştirmesi (saç dahil) istiyor. |
| Oyun adı | Çalışma adı **Again** (Memo, karar). Steam'de "Again" adlı küçük oyunlar var (Redpix Games LLC'nin basit 3D platform oyunu, ~6 inceleme; "Again?" rahatlatıcı bulmaca, 2018). Steam aynı adlara izin veriyor ama "again" aranması zor; sonra alt başlık veya stilize yazım (ör. "Again: …", "AGAIN."). Çıkıştan önce marka kontrolü (hukuki tavsiye değil). Reddedilenler: "Loop" (çok basit), "Echo" (ECHO 2017 + yakında çıkacak Steam oyunu), "Encore" (Steam'de bu isimde ritim roguelike shooter var), "Observed/Observation/Observe" (Observation, No Code/Devolver 2020; Observe 2025), "Rupture" (kalabalık: RUPTURE taktik bilim kurgu shooter, RUPTURE karanlık fantastik voxel oyunu, Ruptured metroidvania, StarRupture). "Unwatched" sonuç vermedi ama sönük geldi. "Revenant" özellik adı olarak uygun, oyun adı olarak değil (Apex Legends karakteri, Code Vein). |

### Özgünlük kontrolü (2026-11-23)
- Başka yerlerde zaten yapılmış: oyuncuya uyum sağlayan bosslar (Warning Forever, jam oyunları), geçmiş benliğinle/hayaletinle dövüş (küçük roguelike'lar ve jam oyunları), oyuncu davranışını kopyalayan düşmanlar (ECHO, 2017), birçok zaman döngüsü roguelite'ı (Rogue Loops, Clockfall vb.), anahtar ve kat keşfi (The Binding of Isaac), katlı oluşturulan 3D zindanlar (Diablo, Deep Rock Galactic), minimap'siz yön bulma (Dark Souls) ve harita açan kuleler (Ubisoft oyunları)
- Hiçbir yerde bulunamayan: kombinasyon. *Bu run'ın* dövüşlerini hologramla izleyip alışkanlıkları sayma kurallarıyla karşılayan bir final boss (yani labirentin daha çoğunu keşfetmek final boss'u besler); sadece başında dururken bütün haritayı gösteren bakış noktaları; ölüm sahnesi girişli isteğe bağlı rupture'lar; 2 ödül seçimi artı karakterler arası yeniden dövme; hepsini bağlayan rol zayıflığı bossları
- Çıkarım: zaman döngüsü tek başına öne çıkmaz; birbirine bağlı özellikler çıkarır
- Hikâye kontrolü: "sevilen kahraman gizlice kötü, şimdi final boss" düşünüldü ve Memo tarafından bırakıldı (Darkest Dungeon'ın Ancestor'ı, Hollow Knight'ın Pale King'i, Fire Emblem: Three Houses'ın Nemesis'ine çok yakın)
