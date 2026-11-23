---
description: Günün işini özetle ve docs/STATE.md'yi güncelle
---

Bugünkü ilerlemeyi `docs/STATE.md` dosyasına işle.

1. `git pull` yap. `git log --since=midnight --oneline`, `gh pr list --state all --limit 10` ve `gh issue list --limit 20` ile bugün olanları topla.
2. `docs/STATE.md` dosyasını güncelle (tarihi bugüne çek):
   - **Şu an**: şu anda ne durumda, hangi PR/issue üzerinde çalışılıyor
   - **Sıradaki**: yapılacak ilk 3 adım
   - **Açık sorunlar**: bilinen hatalar, bekleyen kararlar, bloklayan şeyler
3. Yeni büyük karar varsa `docs/decisions/` altına kısa kayıt yaz (`0000-template.md` biçimi).
4. Değişikliği şöyle işle: `main` üzerindeysen `feature/state-<yyyy-mm-dd>` dalı aç, yoksa mevcut dalda kal. Commit mesajı "Update project state". Push yalnızca feature/fix dalına, ardından küçük bir PR aç.
5. Üç satırlık bir özet yaz: bugün ne bitti, ne bekliyor, yarın ilk iş.
