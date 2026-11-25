# Durum

Son güncelleme: 2026-11-25

## Şu an
Repo kuruldu: iskelet, CI, şablonlar ve çalışma kuralları hazır. Memo'nun tasarım notları repoya alındı: oyun tasarımı `docs/GDD.md`, hikâye `docs/LORE.md` (issue #4). Genel teknik yön: `docs/TEKNIK-REHBER.md` ve `docs/decisions/0002-teknik-yon.md`; Godot/oyun skill'leri `.claude/skills/` altında (issue #7).

Oyuncu prototipi (#9), run kaydı ADR taslağı (#12, `docs/decisions/0004-run-kaydi.md`) ve #16 cevapları main'de.

2026-11-24'te iki PR daha açıldı (#11, #10'un üstüne kurulu; önce #10 birleşmeli):
- **Saldırı ve parry (#10):** `scenes/player/player_combat.gd`. Kısa tık hızlı, basılı tut ağır vuruş; dodge saldırıyı iptal eder. Hızlı vuruşla parry: isabetten en çok 0.1 sn önce basmak; ağır vuruşla parry: sadece tam aynı an (~2 kare); saldırana dönük olmak şart; parry yapan vuruş hasar vermez, skill bonus penceresi açar (skill'ler sonra). Parlama ve geçici kod sesi. `scripts/health.gd`. Girdi tamponu (dodge ve saldırı).
- **Hedef düşman (#11):** `scenes/enemies/test_enemy/`. Oyuncuyu navmesh ile kovalar; parry'lenebilen vuruş (silahta parlama), sola/sağa süpürme (bir taraf güvenli), şok dalgası (üstünden zıpla). Yer uyarıları macenta (Memo, karar). Her saldırının run kaydı için kimliği var. Vuruşlar duvardan geçmez (`scripts/line_of_sight.gd`). Test odasında geçici can yazısı.
- Memo ikisini Godot'ta oynadı: iyi. 34 headless test.

Oyun planı tek sayfada: `docs/oyun-plani.html` (genel akış + 9 bölüm), tasarım belgelerinin bilgi grafı `docs/oyun-grafi.html`. Yeni tasarım kararı içermez, mevcut belgelerin görselleştirmesidir.

## Sıradaki
- Yusuf: ADR 0004'ün teknik onayı (dosya düzeni, `RunRecorder` autoload).
- Run kaydı kodu (`RunRecorder`): oyuncunun `dodged`/`parried` ve düşmanın `attack_telegraphed`/`attack_landed` sinyallerini dinleyip ADR 0004'teki sayımları tutar.
- İlk karakter kiti (Q/E/R skill'leri, parry bonus penceresinin kullanımı): önce Memo'nun fikri.
- Gerçek ölüm (hub'da uyanma); şimdilik oyuncunun canı 0'da doluyor.
- Odalar/labirent (elle yapılmış parçalar + hazır navmesh).
- Gamepad desteği (TEKNIK-REHBER madde 11): Input Map'e eklenecek, prototipte henüz yok.
- `docs/ART.md` (palet, ölçek) yazılacak; palet ve silüet Memo'ya sorulacak (#16'da açık kalan).
- Alan sahipleri `CONTRIBUTING.md` ve `.github/CODEOWNERS` içine yazılacak.

## Başlamadan önce (2026-11-23 kararları, 2026-11-24 Memo cevapları)
- Kamera, arayüz (#16): **Memo cevapladı** (yukarıda). Palet ve silüet açık; ADR 0002 "önerildi" kalıyor.
- Run kaydı (#12): **Memo cevapladı**, ADR taslağı yazıldı (yukarıda).
- Vertical slice (#13): run süresi **ortalama 20-40 dk** (Memo). Karakter ve boss seçimi, karakter/boss tasarımları başlayınca yapılacak; Claude o zaman Memo'ya hatırlatacak.
- Ham kaynak dosyalar (#21): **evet** (Memo). `.blend`/`.psd`/`.kra` repoya girmez, ortak sürücüde durur. Hangi sürücü olacağı henüz seçilmedi.
- Plugin listesi (#23): Yusuf'un Memo'nun kurmasını istediği plugin'ler; cevap bekleniyor.
- Çalışma düzeni (CODEOWNERS/CONTRIBUTING doldurma): dosya sayısı artınca Yusuf'a tekrar sorulacak. Şimdilik sahne çatışması kuralı CLAUDE.md'de.
- Lisans: `LICENSE` eklendi (tüm hakları saklıdır, skill'ler Apache-2.0 istisnası).

## Açık sorunlar
- **Git LFS kotası.** GitHub Free 10 GiB depolama + 10 GiB bant, hesap başına. Kurallar `docs/decisions/0003-lfs-ve-buyuk-varliklar.md` (kabul edildi). (Repo public kalır, bilinçli karar.)
- CI şimdilik import + headless test çalıştırıyor, export üretmiyor. Hedef platform belli olunca eklenecek (GDD'de hedef: PC / Steam).
- Test çalıştırıcısı (`tests/run_tests.gd`) fizik karesi ilerletemiyor; görüş hattı ve navmesh elle (tek seferlik script) doğrulandı. Ayrıca bir script hatasında headless çalıştırıcı kapanmak yerine askıda kalıyor (CI 15 dk timeout'a kadar bekler). Yusuf ile bakılmalı.
- `tests/run_tests.gd.uid` ve `tests/test_smoke.gd.uid` repoda yok; Godot her import'ta üretiyor. Commit edilip edilmeyeceği Yusuf'a sorulmalı.
