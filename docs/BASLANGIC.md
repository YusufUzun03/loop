# Başlangıç rehberi (GitHub ve Claude Code'a yeni başlayanlar için)

Bu rehber, projeye sonradan katılan biri içindir. Git ve GitHub bilmen gerekmiyor: kurulumu bir kez yapacaksın, sonrasını Claude Code senin yerine yapar. Sen sadece ne istediğini yazarsın.

## Kısaca nasıl çalışıyoruz
- Kod ve dosyalar GitHub'daki **repoda** durur: <https://github.com/YusufUzun03/loop>
- Kimse `main` dalına doğrudan yazmaz. Her iş için ayrı bir **dal** açılır, iş bitince **PR** (pull request, "şunları ekledim, birleştirelim" isteği) açılır. Testler geçince birleştirilir.
- Her iş bir **issue**'dur (yapılacaklar listesindeki madde). Panoda "Yapılacak / Yapılıyor / İncelemede / Bitti" diye ilerler.
- Bunların hepsini Claude Code yapar. Sen "pushla" dediğinde hepsini kurallara uygun şekilde yapacak.

## 1. Bir kerelik kurulum

| Ne | Nereden | Not |
|---|---|---|
| GitHub hesabı | github.com | Zaten var. Davet e-postasını veya <https://github.com/YusufUzun03/loop/invitations> sayfasını aç, **Accept invitation**'a bas. |
| Git | <https://git-scm.com/download/win> | Kurarken her şeyi varsayılan bırak. Git LFS (büyük dosyalar için) bununla birlikte gelir. |
| GitHub CLI (`gh`) | <https://cli.github.com> | Claude'un issue ve PR açması için gerekli. |
| Godot 4.7.2 | <https://godotengine.org/download> | Standart (.NET olmayan) sürüm. Sürüm numarası 4.7.2 olsun, farklı sürüm proje dosyalarını bozabilir. |
| Claude Code | <https://docs.claude.com/en/docs/claude-code> | En kolayı Claude masaüstü uygulamasındaki **Code** sekmesi. **Ücretli Claude planı gerekir** (Pro veya üstü). |

Windows'ta PowerShell aç ve şunları sırayla yaz:

```powershell
gh auth login
```
Sorulara: GitHub.com, HTTPS, "Login with a web browser" seç. Tarayıcıda çıkan kodu gir, hesabınla onayla.

```powershell
git config --global user.name "Adın Soyadın"
git config --global user.email "GITHUB_NOREPLY_ADRESIN"
git lfs install
```
E-posta için kişisel adresini değil GitHub'ın gizli adresini kullan (GitHub → Settings → Emails → "Keep my email addresses private" açıkken orada yazan `...@users.noreply.github.com` adresi). Böylece e-postan commit'lerde görünmez.

## 2. Projeyi bilgisayara indir

```powershell
cd $HOME\Documents
git clone https://github.com/YusufUzun03/loop.git
cd loop
```

Godot'u aç, **Import** de, `loop` klasöründeki `project.godot` dosyasını seç.

## 3. Claude Code'u projede aç
- **Masaüstü uygulaması:** Code sekmesi → klasör olarak `loop` klasörünü seç.
- **Terminal:** `loop` klasöründeyken `claude` yaz.

Önemli: Claude'u mutlaka `loop` klasöründe aç. Kuralları (`CLAUDE.md`) oradan okur.

İlk mesaj olarak şunu yapıştır:

```text
Merhaba. Ben bu projeye yeni katılıyorum ve Git/GitHub'ı bilmiyorum.
Önce CLAUDE.md, CONTRIBUTING.md, docs/ROADMAP.md ve docs/STATE.md dosyalarını oku.
Sonra kurulumumu kontrol et: git, git lfs, gh (giriş yapılmış mı) ve godot.
Eksik veya hatalı bir şey varsa bana basit bir dille, adım adım söyle.
Bundan sonra Git ve GitHub işlerini (dal, commit, issue, PR) projenin kurallarına göre sen yap,
ben sadece ne istediğimi yazacağım. Yaptığın şeyi kısaca anlat.
```

## 4. Günlük kullanım

**İşe başlarken** (Claude'a söyle):
```text
Güncel hâle getir ve neler olduğunu özetle.
```

**Yeni bir iş için:**
```text
/yeni-gorev oyunun giriş ekranı sahnesini ekle
```
Claude issue açar ve bu iş için ayrı bir dal oluşturur.

**Çalışırken** normal konuş: "şu dosyayı ekle", "şu metni GDD'ye yerleştir" gibi.

**İş bitince** sadece şunu yaz:
```text
pushla
```
Claude şunları yapar: testleri çalıştırır, değişiklikleri düzgün commit'lere böler, kendi dalına gönderir, PR açar, issue'ya bağlar, `docs/STATE.md`'yi günceller. `main`'e hiçbir şey doğrudan gitmez. PR'daki kontrol (CI) yeşil olunca Yusuf'a haber ver, birleştirmeyi ya sen ya o yapar.

**Gün sonu:**
```text
/gunun-ozeti
```

## 5. Örnek: GDD ve lore ekleme
```text
Aşağıdaki metin oyunun tasarımı. docs/GDD.md içindeki başlıklara yerleştir.
Lore uzunsa docs/LORE.md dosyası aç ve GDD'den linkle. Sonra pushla.

<buraya metni yapıştır>
```

## 6. Kurallar ve dikkat
- Şifre, token, API anahtarı hiçbir dosyaya yazma, Claude'a da yazdırma.
- `main`'e doğrudan push yok. Claude yapmak isterse "hayır" de.
- Aynı sahneyi (`.tscn`) aynı anda Yusuf'la düzenlemeyin. Başlamadan önce haber ver.
- Claude bir şey sorarsa (karar, emin olmadığı bir şey) varsayma, cevap ver.
- Bir şey ters giderse sildirmeye çalışma, Claude'a "ne oldu, açıkla, geri almadan önce bana sor" yaz.

## Sözlük
- **Repo:** projenin GitHub'daki ana klasörü.
- **Dal (branch):** ana projeyi bozmadan çalıştığın ayrı kopya.
- **Commit:** kaydedilmiş bir değişiklik paketi.
- **Push:** commit'lerini GitHub'a göndermek.
- **PR:** "bu dalı main ile birleştirelim" isteği. Burada testler çalışır ve değişiklikler gözden geçirilir.
- **Issue:** bir iş veya hata kaydı.
- **CI:** her PR'da otomatik çalışan test. Yeşilse sorun yok.
