# Çalışma düzeni

## Temel kurallar
- `main` korumalıdır: doğrudan push yok, her değişiklik PR ile gelir ve CI geçmeden merge edilmez.
- Her iş bir issue'dur. Dal adı `feature/<issue-no>-<kisa-isim>` veya `fix/<issue-no>-<kisa-isim>`.
- PR küçük olsun: tek issue, tek konu. PR açıklamasında `Closes #<no>` kullan.
- Commit mesajı kısa, İngilizce, emir kipinde: `Add player jump`.
- Merge etmeden önce kendi PR'ını bir kez gözden geçir.

## Akış
1. Issue seç veya aç, kendine ata.
2. `git switch main && git pull`, sonra `git switch -c feature/12-player-jump`.
3. Yap, yerelde test et (`godot --headless --path . -s tests/run_tests.gd`).
4. Push et, PR aç, CI'ın geçmesini bekle, merge et, dalı sil.
5. `docs/STATE.md` güncel kalsın.

## Godot'a özel
- `.tscn`, `.tres` ve `project.godot` dosyaları merge'de çatışır. Aynı sahnede aynı anda iki kişi çalışmasın, önce haber ver.
- Sahneyi küçük parçalara böl (bir özellik bir sahne); büyük "world" sahnesine herkes dokunmasın.
- Büyük binary dosyalar Git LFS ile gider (`.gitattributes`). Klonladıktan sonra `git lfs install` çalıştır.
- Etiketler: `mekanik`, `UI`, `level`, `ses`, `grafik`, `bug`, `iyileştirme`, `belgeleme`.

## Kim hangi alandan sorumlu
Alan sahipleri burada ve `.github/CODEOWNERS` içinde tutulur.

| Alan | Sorumlu |
|---|---|
|  |  |
|  |  |
|  |  |
