# 0001 - Motor olarak Godot 4

- Tarih: 2026-11-23
- Durum: kabul edildi
- Karar verenler: Yusuf

## Bağlam
İki kişi aynı projede çalışacak. Motor belirlenmemişti (Godot veya Unity).

## Karar
Godot 4.7 (GDScript) kullanılacak.

## Alternatifler
Unity: sahne/prefab YAML dosyaları iki kişide sık merge çatışması üretir, CI için lisans secret'ı gerekir. Ağır 3D veya konsol hedefi çıkarsa yeniden değerlendirilir.

## Sonuçlar
Sahne ve kaynak dosyaları düz metin, diff ve merge dostu. CI ücretsiz kurulur. 3D ihtiyacı büyürse Godot'un sınırları tekrar gözden geçirilmeli.
