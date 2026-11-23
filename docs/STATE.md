# Durum

Son güncelleme: 2026-11-23

## Şu an
Repo kuruldu: iskelet, CI, şablonlar ve çalışma kuralları hazır. Memo'nun tasarım notları repoya alındı: oyun tasarımı `docs/GDD.md`, hikâye `docs/LORE.md` (Türkçeye çevrildi, issue #4). Oyunun kodu henüz başlamadı.

## Sıradaki
- Memo'nun ilk prototipini (hareket, zıplama, dodge, MMO kamera) repoya almak: projenin klasör yapısına uyarlanacak (`scenes/player/player.tscn` + `player.gd`) ve Godot'ta test edilecek. Ayrı issue.
- Prototip test edilince: temel saldırı + parry, sinyalli saldırıları olan bir hedef düşman, run kaydı, sonra odalar/labirent.
- Alan sahipleri `CONTRIBUTING.md` ve `.github/CODEOWNERS` içine yazılacak.
- İlk issue'lar ROADMAP "Prototip" aşamasına açılacak.

## Açık sorunlar
- CI şimdilik import + headless test çalıştırıyor, export üretmiyor. Hedef platform belli olunca eklenecek (GDD'de hedef: PC / Steam).
- `CLAUDE.md` repoyu "private" diye tanımlıyor ama repo şu an public. Hangisi doğru, Yusuf'la netleşmeli.
