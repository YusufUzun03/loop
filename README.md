# loop

Godot 4.7 ile geliştirilen oyun. Detaylı tasarım: [docs/GDD.md](docs/GDD.md).

## Kurulum
1. [Godot 4.7](https://godotengine.org/download) indir.
2. Git LFS kur ve etkinleştir: `git lfs install`
3. Repoyu klonla: `git clone https://github.com/YusufUzun03/loop.git`
4. Godot'ta `project.godot` dosyasını içe aktar.

## Test
```
godot --headless --path . --import
godot --headless --path . -s tests/run_tests.gd
```

## Dokümanlar
- [CONTRIBUTING.md](CONTRIBUTING.md): çalışma düzeni
- [docs/ROADMAP.md](docs/ROADMAP.md): aşamalar
- [docs/STATE.md](docs/STATE.md): şu anki durum
- [docs/decisions/](docs/decisions/): tasarım ve teknik kararlar
