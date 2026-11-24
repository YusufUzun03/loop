# Durum

Son güncelleme: 2026-11-24

## Şu an
Repo kuruldu: iskelet, CI, şablonlar ve çalışma kuralları hazır. Memo'nun tasarım notları repoya alındı: oyun tasarımı `docs/GDD.md`, hikâye `docs/LORE.md` (issue #4). Genel teknik yön: `docs/TEKNIK-REHBER.md` ve `docs/decisions/0002-teknik-yon.md`; Godot/oyun skill'leri `.claude/skills/` altında (issue #7).

2026-11-24'te üç PR açıldı (bu STATE güncellemesi üçünü birden anlatır):
- **Oyuncu prototipi (#9):** Memo'nun prototipi `scenes/player/`, `scenes/camera/`, `scenes/test_room/` altına alındı. Hareket, zıplama, i-frame'siz cooldown'lı dodge, MMO kamera. Tuşlar `project.godot` Input Map'te, çarpışma katmanları isimli, ana sahne test odası. 9 yeni headless test. Memo Godot'ta oynadı: temel his iyi.
- **Run kaydı ADR taslağı (#12):** `docs/decisions/0004-run-kaydi.md`. Memo parametreleri, karaktere göre dodge yönünü ve 30 run saklamayı (en yeni 10'u kullanılmaz) onayladı. İlk 10 run'da Observer'ın eski hâlleri çıkacak (LORE).
- **#16 cevapları:** kamera varsayılanları kalıyor; sadece girdi tamponu, zorluk modu yok; HUD az ve sade; bakış noktası duvarda küçük ekran + koridorda 3D hologram harita (GDD).

## Sıradaki
- Yusuf: ADR 0004'ün teknik onayı (dosya düzeni, `RunRecorder` autoload).
- #10 temel saldırı + parry: başlamadan önce Memo'nun saldırı ve parry hissi fikri alınacak. Parry penceresi ve girdi tamponu ayrı `@export` değerleri olacak.
- #11 sinyalli saldırıları olan hedef düşman, sonra run kaydı kodu (`RunRecorder`), sonra odalar/labirent.
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
- `tests/run_tests.gd.uid` ve `tests/test_smoke.gd.uid` repoda yok; Godot her import'ta üretiyor. Commit edilip edilmeyeceği Yusuf'a sorulmalı.
