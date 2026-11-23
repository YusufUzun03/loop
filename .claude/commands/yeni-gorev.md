---
description: Issue aç ve onun için dal oluştur
argument-hint: <görev başlığı veya kısa açıklama>
---

Görev: "$ARGUMENTS" için GitHub issue aç ve çalışma dalını hazırla.

1. `git status` temiz değilse dur ve durumu bildir.
2. `git switch main && git pull` ile main'i güncelle.
3. Başlık ve açıklama net değilse tek soru sor. Netse issue gövdesini `.github/ISSUE_TEMPLATE/gorev.yml` alanlarına göre yaz: ne yapılacak, bitti ölçütü, dokunulacak sahne/asset.
4. Uygun etiketi seç (mekanik, UI, level, ses, grafik, bug, iyileştirme, belgeleme) ve `docs/ROADMAP.md` ile uyumlu milestone'u seç (Prototip, Çekirdek mekanik, İçerik, Cila, Çıkış). Emin değilsen sor.
5. `gh issue create --title ... --body ... --label ... --milestone ...` çalıştır, issue numarasını al.
6. Dal adı: `fix/<no>-<kisa-isim>` (etiket bug ise) yoksa `feature/<no>-<kisa-isim>`. `kisa-isim` küçük harf, ASCII, tire ile. `git switch -c <dal>` ile main'den aç.
7. Issue linkini ve dal adını yaz. İşe başlama; büyük işse önce plan yazıp onay iste.
