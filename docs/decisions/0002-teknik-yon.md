# 0002 - Genel teknik yön

- Tarih: 2026-11-23
- Durum: önerildi (Memo'nun görüşü bekleniyor; Yusuf hedef/sanat/skill kararlarını verdi)
- Karar verenler: Yusuf (teknik yön), Memo (tasarımı etkileyen maddeler)

## Bağlam
Oyun kodlamasına başlamadan önce motor ayarları, sanat hattı, performans ve üretim kuralları belirlenmeli. Tasarım (mekanik, lore) Memo'nun; teknik yön Yusuf'un. Ekipte sanatçı yok.

## Karar
Ayrıntılar `docs/TEKNIK-REHBER.md`'de. Özet:
- Windows/Steam hedefi; Steam Deck **bonus** (Yusuf).
- Godot 4.7.2, yalnız GDScript, Forward+ (Mobile renderer'a geçişi imkânsız kılma), Jolt fizik, dövüşte `CharacterBody3D` + `Area3D`, RigidBody yok.
- Üçüncü şahıs yörünge kamera + `SpringArm3D`.
- Sanat: sanatçısız en yüksek kalite = **tek stil, tek palet, tek ölçek**, stilize düşük/orta poligon, ışık/shader ile cyberpunk hissi (Yusuf).
- Varlık hattı: Blender → `.glb` (LFS), Krita, Material Maker, Audacity, jsfxr; CC0 paketler `docs/ASSETS.md`'ye kayıtlı.
- Veri `Resource` + `@export`; girdi "niyet" üzerinden (co-op'a hazır); host otoriter ağ, tek oyunculu önce.
- Önce **vertical slice** (tek karakter, tek boss, bir üretilmiş kat), sonra genişleme.
- Oyun skill'leri repoda `.claude/skills/` (Apache-2.0, `NOTICE.md`) ile paylaşılır (Yusuf).
- Oyunda görünen/duyulan içerikte üretken AI yok; olursa Steam'de bildirilir.

## Alternatifler
- **C# yerine GDScript:** C# daha hızlı ama kurulum ve CI daha ağır; iki kişilik ekip için gereksiz.
- **Mobile renderer:** Deck'te daha hızlı ama cyberpunk ışık dili (glow, sis, çok ışık) sınırlanır. Forward+ seçildi, geçiş kapısı açık bırakıldı.
- **Gerçekçi/detaylı sanat:** sanatçı bütçesi gerektirir; şimdilik elenmedi ama vertical slice sonrası karar.
- **Skill'leri kopyalamak yerine herkesin kendi kurması:** sürüm farkı ve Memo için ek adım; repoya almak daha basit.

## Sonuçlar
- Yeni teknik karar `TEKNIK-REHBER.md`'ye eklenir; büyük olanlar ayrı ADR olur.
- Tasarımı etkileyen maddeler Memo onaylayana kadar öneridir.
- Katlı labirent navmesh'i, Deck performansı ve parry/ağ ilişkisi bilinen teknik risklerdir; vertical slice'ta doğrulanacak.
- Skill'ler her güncellemede elle yenilenir (`NOTICE.md`).
