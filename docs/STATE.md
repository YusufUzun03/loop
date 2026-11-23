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

## Başlamadan önce (2026-11-23 kararları)
- Memo cevaplayacak: TEKNİK-REHBER "Açık sorular" (kamera, run kaydı, arayüz, palet). Bu cevaplar gelmeden ADR 0002 "önerildi" kalır.
- Run kaydı veri şeması: Memo'ya iletildi; kodlamadan önce ayrı ADR olarak yazılacak (Revenant ve Observer buna bağlı).
- Vertical slice bitiş ölçütü (hangi karakter, hangi boss, süre): Memo'ya sorulacak. Memo araştırmadan cevap vermesin; önce Yusuf/Claude'la örnek ve süre araştırması yapılsın.
- Araştırma notları: `docs/ART.md` içeriği (palet, ölçek; #16'ya bağlı). LFS kotası, `docs/ASSETS.md` iskeleti ve CI `gdlint`/`gdformat` yapıldı.
- Çalışma düzeni (CODEOWNERS/CONTRIBUTING doldurma): dosya sayısı artınca Yusuf'a tekrar sorulacak. Şimdilik sahne çatışması kuralı CLAUDE.md'de.
- Lisans: `LICENSE` eklendi (tüm hakları saklıdır, skill'ler Apache-2.0 istisnası).
- Prototip aşaması issue'ları açıldı (milestone "Prototip").

## Açık sorunlar
- **Git LFS kotası.** Araştırıldı: GitHub Free 10 GiB depolama + 10 GiB bant, hesap başına (önceki "1 GB" notu yanlıştı). Öneri ve kurallar `docs/decisions/0003-lfs-ve-buyuk-varliklar.md` (kabul edildi, 2026-11-24). `docs/ASSETS.md` iskeleti açıldı. (Repo public kalır, bilinçli karar.)
- CI şimdilik import + headless test çalıştırıyor, export üretmiyor. Hedef platform belli olunca eklenecek (GDD'de hedef: PC / Steam).
