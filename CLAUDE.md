# loop

Godot 4.7 ile geliştirilen, iki kişilik ekibin büyük çaplı oyunu. Repo bilinçli olarak herkese açıktır (public); lore dahil her şey görünür.

## Oyun tanımı
**Again** (çalışma adı): 3D, beceriye dayalı bir roguelite. Önce tek oyunculu, sonra host tabanlı online co-op. Oyuncu, dev bir baloncuğa kapanmış antik-teknolojili bir dünyada, rastgele oluşturulan katlı labirentlerde dövüşür; ölünce hub'da uyanır. Her ölüm kaydedilir: geçmiş run'lar Revenant olarak geri döner, final boss Observer ise oyuncunun alışkanlıklarını sayıp final savaşında onlara karşı oynar. 3 karakter (tank, damage, support), her birinin tek silahı var; MMO tarzı üçüncü şahıs kamera, i-frame'siz cooldown'lı dodge, saldırarak parry. Ayrıntılar: `docs/GDD.md`, hikâye: `docs/LORE.md`.

Tasarım lideri Memo'dur. Tasarım kararlarında önce Memo'nun fikrini sor, sonra öneri ekle. Belgelerde kararları "(Memo'nun fikri)" / "(Memo, karar)", Claude eklemelerini "(öneri)" diye işaretle. Sayılar ve ayarlar oyun test edilerek belirlenir: makul bir başlangıç değeri ver ve `@export` ile aç.

## Motor ve araçlar
- Motor: Godot 4.7 (GDScript). Sürüm CI'da `.github/workflows/ci.yml` içindeki `GODOT_VERSION` ile sabitlenir. Motoru yükseltmek bir karardır: `docs/decisions/` altına kayıt yaz ve CI sürümünü aynı PR'da değiştir.
- Büyük binary dosyalar Git LFS ile tutulur (`.gitattributes`). Klonladıktan sonra bir kez `git lfs install` çalıştır.

Teknik kararlar (render, fizik, kamera, sanat hattı, performans bütçesi, kayıt, yerelleştirme): `docs/TEKNIK-REHBER.md`. Oyun skill'leri `.claude/skills/` altındadır (Godot, kamera, AI, prosedürel üretim vb.); ilgili işte kullan.

## Klasör yapısı
```
assets/        ham ve içe aktarılan varlıklar
  art/         sprite, doku, model
  audio/       müzik ve ses efekti
  fonts/
scenes/        .tscn sahneler (özellik başına alt klasör)
scripts/       sahneye bağlı olmayan ortak GDScript (autoload, yardımcılar)
tests/         headless testler (test_*.gd) ve run_tests.gd
docs/          GDD, ROADMAP, STATE, decisions/
.github/       CI, issue ve PR şablonları
.claude/       Claude Code ayarları ve komutları
```
Bir özelliğin sahnesi ve scripti yan yana durur: `scenes/player/player.tscn` + `scenes/player/player.gd`.

## İsimlendirme ve kod stili
- Dosya ve klasör: `snake_case` (`player_controller.gd`, `main_menu.tscn`).
- Sınıf (`class_name`) ve node adı: `PascalCase`. Değişken ve fonksiyon: `snake_case`. Sabit: `UPPER_SNAKE_CASE`. Sinyal: geçmiş zaman (`health_changed`).
- Statik tipleme kullan (`var speed: float = 200.0`, `func hit(damage: int) -> void`).
- Girinti tab, `.editorconfig` geçerlidir. Kod, yorum, değişken adı ve commit mesajı İngilizce; dokümanlar Türkçe.
- Sihirli sayı yok: ayarlanabilir değerler `@export` veya sabit olsun.

## Build ve test komutları
`godot` komutunun PATH'te olduğunu varsay (yoksa editörün tam yolunu kullan).
```
godot --headless --path . --import                 # varlıkları içe aktar (CI'daki build adımı)
godot --headless --path . -s tests/run_tests.gd    # testleri çalıştır, hata varsa çıkış kodu 1
```
CI (`build-and-test`) her PR'da ve `main`'e push'ta bu iki komutu çalıştırır. Not: CI şimdilik export (derleme paketi) üretmez; export şablonları ve platform kararı sonra eklenecek.

## İş akışı
- Her iş için ayrı dal: `feature/...` veya `fix/...`. `main`'e doğrudan push yok.
- İş PR ile biter. PR açıklamasına ne yaptığını yaz, issue'ya `Closes #<no>` ile bağla.
- Commit mesajları kısa ve net, İngilizce, emir kipinde ("Add player jump", "Fix camera clipping").
- Merge çatışması çıkarması kolay dosyalar (`.tscn`, `.tres`, `project.godot`): aynı dosyada aynı anda iki kişi çalışmasın, önce haber ver.

## Claude için çalışma kuralları
- Her oturumun başında: `git pull`, `docs/ROADMAP.md` ve `docs/STATE.md` oku, açık issue'lara bak.
- Bir issue üzerinde çalışırken dal adı: `feature/<issue-no>-<kisa-isim>` veya `fix/<issue-no>-<kisa-isim>`. Önce main'den güncel dal aç.
- Asla `main`'e doğrudan push yapma, force push yapma, geçmişi yeniden yazma.
- Büyük işe başlamadan önce kısa bir plan yaz, onayımı bekle. Küçük ve net işlerde direkt başla.
- PR'lar küçük olsun: tek issue, tek konu. Büyük işi parçalara böl.
- Commit atmadan önce build/test çalıştır. Geçmiyorsa PR açma, durumu bildir.
- PR açıklaması: ne yapıldı, neden, nasıl test edildi, bilinen eksikler. Issue'ya `Closes #<no>` ile bağla.
- İş bitince `docs/STATE.md`'yi güncelle (ne yapıldı, sıradaki adım, açık sorunlar).
- Sahne/prefab/asset gibi birleştirmesi zor dosyaları, issue'da açıkça istenmedikçe değiştirme. Değiştireceksen önce kimin üzerinde çalıştığını sor.
- Emin olmadığın tasarım kararını varsayma, sor. Büyük kararları `docs/decisions/` altına kısa bir kayıt olarak yaz.
- Şifre, token, API anahtarı asla repoya yazma.
- Bittiğinde "Tamam" için ölçüt: build geçiyor, test geçiyor, PR açık, STATE.md güncel.

### Kısayol: "pushla"
Kullanıcı "pushla", "gönder" veya "yükle" derse (Git bilmeyen ekip arkadaşı için), şunları sırayla ve sormadan yap: `main` üzerindeysen veya bağlı issue yoksa önce issue aç ve `feature/<no>-...` dalı oluştur. Sonra `/pr-ac` akışını uygula (test, STATE.md, commit, push, PR, `Closes #<no>`). `main`'e asla doğrudan push etme. Yaptığın her adımı kullanıcıya düz Türkçeyle kısaca anlat; Git terimlerini ilk geçtiğinde açıkla.

Slash komutları (`.claude/commands/`): `/yeni-gorev`, `/pr-ac`, `/gunun-ozeti`. Yeni başlayanlar için rehber: `docs/BASLANGIC.md`.
