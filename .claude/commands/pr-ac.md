---
description: Testleri çalıştır, STATE.md'yi güncelle, PR aç
argument-hint: [issue numarası, boşsa dal adından çıkar]
---

Mevcut dalın işini PR'a çevir. `$ARGUMENTS` verilmişse issue numarası odur, yoksa dal adından (`feature/<no>-...`) al.

1. Dal `main` ise dur: PR sadece `feature/` veya `fix/` dalından açılır.
2. Çalıştır ve çıktıyı göster:
   - `godot --headless --path . --import`
   - `godot --headless --path . -s tests/run_tests.gd`
   Biri başarısızsa PR açma, hatayı bildir ve dur.
3. `docs/STATE.md` dosyasını güncelle: "Şu an", "Sıradaki", "Açık sorunlar" (tarihi bugüne çek).
4. Değişiklikleri mantıklı commit'lere böl (İngilizce, kısa, emir kipi). Gizli bilgi (token, anahtar) eklenmediğini kontrol et.
5. `git push -u origin <dal>` (yalnızca feature/fix dalı).
6. `gh pr create` ile PR aç. Gövde `.github/pull_request_template.md` biçiminde: ne yapıldı, neden (`Closes #<no>`), nasıl test edildi (komut çıktısı), bilinen eksikler. Başlık kısa ve İngilizce.
7. PR linkini yaz. CI sonucunu `gh pr checks` ile bir kez göster; merge etme.
