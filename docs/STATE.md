# Durum

Son güncelleme: 2026-11-23

## Şu an
Repo kuruldu: iskelet, CI, şablonlar ve çalışma kuralları hazır. Memo'nun tasarım notları repoya alındı: oyun tasarımı `docs/GDD.md`, hikâye `docs/LORE.md` (Türkçeye çevrildi, issue #4). Genel teknik yön yazıldı: `docs/TEKNIK-REHBER.md` (kararlar, hedef donanım, sanat hattı, performans bütçesi) ve `docs/decisions/0002-teknik-yon.md`; Godot/oyun skill'leri `.claude/skills/` altında (issue #7). Oyunun kodu henüz başlamadı.

## Sıradaki
- Memo'nun TEKNİK-REHBER içindeki "Açık sorular" bölümüne cevabı (kamera hissi, run kaydı, arayüz, palet); sonra 0002'nin durumu "kabul edildi" olur.
- `docs/ASSETS.md` (varlık/lisans kaydı) ve `docs/ART.md` (palet, ölçek) yazılacak; CI'ya `gdlint`/`gdformat` eklenecek.
- Memo'nun ilk prototipini (hareket, zıplama, dodge, MMO kamera) repoya almak: projenin klasör yapısına uyarlanacak (`scenes/player/player.tscn` + `player.gd`) ve Godot'ta test edilecek. Ayrı issue.
- Prototip test edilince: temel saldırı + parry, sinyalli saldırıları olan bir hedef düşman, run kaydı, sonra odalar/labirent.
- Alan sahipleri `CONTRIBUTING.md` ve `.github/CODEOWNERS` içine yazılacak.
- İlk issue'lar ROADMAP "Prototip" aşamasına açılacak.

## Açık sorunlar
- CI şimdilik import + headless test çalıştırıyor, export üretmiyor. Hedef platform belli olunca eklenecek (GDD'de hedef: PC / Steam).
- `CLAUDE.md` repoyu "private" diye tanımlıyor ama repo şu an public. Hangisi doğru, Yusuf'la netleşmeli.
