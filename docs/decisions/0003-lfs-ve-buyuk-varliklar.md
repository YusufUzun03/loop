# 0003 - Git LFS kotası ve büyük varlıklar

- Tarih: 2026-11-24
- Durum: önerildi (Yusuf onaylayınca kabul; kaynak dosya kuralı Memo ile de konuşulacak)
- Karar verenler: Yusuf (teknik), Memo (kendi dosyalarını etkileyen kısım)

## Bağlam
Repo public ve öyle kalacak. Büyük binary dosyalar Git LFS ile tutuluyor (`.gitattributes`: psd, kra, blend, fbx, glb, wav, mp3, ogg, mp4, webm). Şu an LFS'te dosya yok, `.git` 1,4 MB. Soru: ücretsiz kota yeter mi, neye dikkat etmeliyiz? (issue #14)

GitHub belgesine göre (docs.github.com, "Git LFS billing", 2026-11-24'te okundu):
- GitHub Free hesabı: **10 GiB depolama, 10 GiB bant**. Önceki notlardaki "1 GB" eskiydi, yanlıştı.
- Kota **hesap başınadır**; public/private ayrımı yok, repo private yapmak kotayı artırmaz.
- Bant, LFS dosyasını indiren herkes için **repo sahibinin** hesabından düşer. GitHub Actions indirmesi de dahil; fork/pull de ana reponun bandını yer.
- Push'lanan her LFS sürümü dosyanın tamamı kadar depolama harcar (küçük değişiklik de olsa). Eski sürümler silinmeden depolama geri gelmez.
- Kota dolunca ödeme yöntemi yoksa: depolamada yeni LFS push'u engellenir (klon pointer dosyaları getirir); bantta LFS ertesi aya kadar kapanır. Bütçe $0 ise ay sonuna kadar engellenir.
- Tek dosya boyut sınırı bu sayfada yazmıyor (LFS genel belgesinde ayrıca doğrulanacak).

## Karar
1. **LFS'te kal.** 10 GiB iki kişilik ekibin vertical slice'ı için yeterli görünüyor; alternatif (harici depolama) şimdilik gereksiz karmaşıklık.
2. **CI LFS dosyası indirmez.** `actions/checkout` `lfs: false`; testler `.glb`/ses gerektirmiyor. Gerektiren test çıkarsa önce `lfs: true` yerine yalnız o dosyaları çekmeyi dene. Her PR'da tüm LFS'i çekmek bandı en hızlı eriten şeydir.
3. **Yalnız teslim edilen formatlar LFS'e girer** (`.glb`, `.ogg`, `.wav`, kısa `.mp4/.webm`). Ham kaynaklar (`.blend`, `.psd`, `.kra`) her kaydedildiğinde tam boyut harcar; bunları repoya her sürümde koyma, ortak bir sürücüde tut, repoya yalnız kilometre taşlarında al. (`.gitattributes` şimdilik değişmiyor; kural bu belgede.)
4. **Varlık hazırlama:** `.glb` ve ses sıkıştırılmış/kırpılmış gelsin; denemeler ayrı dalda, merge öncesi temizlenir. Binary dosya tek PR'da bir kez commit edilir, "düzeltme" commit'leriyle tekrar tekrar eklenmez.
5. **Ölç ve alarm kur.** Repo ayarları > Billing'de LFS kullanımı her ay başında STATE.md'ye yazılır. **6 GiB depolama** veya **6 GiB/ay bant** görülürse bu ADR yeniden açılır.
6. **Derleme paketleri repoya girmez.** Oyun build'leri GitHub Releases veya itch.io'da durur.
7. **Kullanım ölçümü:** `git lfs ls-files -s` (dosya boyutları) ve `git count-objects -vH`.

## Alternatifler
- **LFS'siz, düz git:** `.glb` boyutları küçük kalsa bile geçmişe girer, repo şişer ve geri alınamaz. Elendi.
- **Harici depolama (Cloudflare R2, S3, Drive) + indirme scripti:** kotadan bağımsız ama kurulum, kimlik ve senkron derdi. Kota sorun olursa ikinci adım.
- **GitHub veri paketi satın almak** ($5/ay, 50 GiB; fiyat ödeme sayfasında doğrulanacak): bütçe 0 olduğundan şimdilik hayır; "opsiyonel, ücretli".
- **Repoyu private yapmak:** kotayı artırmıyor ve public kararıyla çelişiyor. Elendi.

## Sonuçlar
- CI değişikliği ayrı küçük PR'da yapılır (`lfs: false` + gdlint/gdformat).
- `docs/ASSETS.md` iskeleti açılır: her harici/CC0 varlığın kaynağı, lisansı ve LFS boyutu tek tabloda.
- STATE.md ve issue #14'teki "1 GB" bilgisi düzeltilir.
- Kaynak dosya (`.blend` vb.) kuralı Memo'nun iş akışını etkiler; ilk modelden önce ona haber verilir.
