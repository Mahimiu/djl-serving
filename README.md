# 🧠 DJL Serving (Sidecar)

Docker-Image mit [DJL Serving](https://github.com/deepjavalibrary/djl-serving) und einem vortrainierten **TorchScript-ResNet18-Modell** (ImageNet-1k). Wird als **Sidecar** vom [DJL Serving Consumer](https://github.com/Mahimiu/djl-serving-consumer) angesprochen.

Das Projekt entstand im Rahmen des Moduls **MDM (Model Deployment & Maintenance)** an der ZHAW (FS2026).

## 🏗️ Rolle in der Architektur
[Consumer Service]  --HTTP-->  [DJL Serving Sidecar]
(galmmax1/                     (galmmax1/djl-serving:latest)
djl-serving-consumer:latest)        ▲
|
traced_resnet18.zip

Der Sidecar exponiert auf Port `8080` den Endpoint `/predictions/traced_resnet18`, der ein Bild als `multipart/form-data` entgegennimmt und Top-5-Klassifikationen zurückliefert.

## 🎁 Bonus-Themen Projekt 2

Dieses Projekt deckt zwei auf Moodle angemeldete Bonus-Themen ab:

| Bonus-Thema | Umsetzung |
|---|---|
| **UI / Backend** | Vorgefertigter DJL-Serving-Endpoint `/predictions/traced_resnet18` mit TorchScript-Modell, integriert über Docker Compose und Azure-Sidecar-Pattern |
| **Dependency Management & Project Setup in VS Code** | Multi-Stage Dockerfile mit separater Model-Prep-Stage (sauberes Runtime-Image ohne `unzip`-Tool), VS Code Workspace Config (`tasks.json`, `settings.json`, `extensions.json`), `.editorconfig` |

### Multi-Stage Dockerfile

Im Gegensatz zu Footwear/Consumer ist hier kein Maven-Build nötig — der Trick liegt in der **Modell-Extraktion**:

- **Stage 1 (Model-Prep)**: kleines Alpine-Image installiert `unzip`, entpackt das Modell-ZIP, löscht das ZIP
- **Stage 2 (Runtime)**: offizielles `deepjavalibrary/djl-serving`-Image bekommt nur das **entpackte Modell** aus Stage 1 kopiert

Damit bleiben das `unzip`-Tool und das ZIP-Original ausserhalb des finalen Images. Das Runtime-Image enthält nur, was zur Laufzeit gebraucht wird.

### VS Code Workspace

Beim Öffnen des Repos in VS Code werden Docker- und YAML-Extensions vorgeschlagen. Über die Tasks (`Ctrl+Shift+P` → „Run Task") können `docker build`, `docker run`, `docker push` und `docker compose up/down` direkt ausgeführt werden, ohne Befehle zu tippen. `.editorconfig` sorgt für konsistente Formatierung in Dockerfile, YAML und Markdown.

## 📦 Inhalt

| Datei | Zweck |
|---|---|
| `Dockerfile` | Multi-Stage Image-Definition (Model-Prep + Runtime) |
| `traced_resnet18.zip` | Vortrainiertes TorchScript-Modell (ImageNet-1k) |
| `docker-compose.yml` | Startet Sidecar + Consumer zusammen |
| `.vscode/` | Workspace-Konfig mit Docker-Tasks |
| `.editorconfig` | IDE-übergreifende Format-Regeln |

## 🚀 Lokal starten

### Variante A: Beides via Docker Compose (empfohlen)

```bash
docker-compose up
```

Anschliessend ist der Consumer unter [http://localhost](http://localhost) erreichbar; der Sidecar ist intern unter `model-service:8080`.

In VS Code: `Ctrl+Shift+P` → „Run Task" → „docker compose: up".

### Variante B: Nur den Sidecar starten

```bash
docker run -p 8080:8080 galmmax1/djl-serving:latest
```

Test:

```bash
curl -X POST http://localhost:8080/predictions/traced_resnet18 \
     -F "image=@kitten.jpg"
```

## 🚢 Deployment

### Docker Hub

Image-URL: [hub.docker.com/r/galmmax1/djl-serving](https://hub.docker.com/r/galmmax1/djl-serving)

### CI/CD via GitHub Actions

Bei jedem Push auf `main` läuft automatisch der Workflow [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml):

1. Code-Checkout
2. Docker Buildx Setup
3. Login bei Docker Hub (Secret `DOCKERHUB_TOKEN`)
4. Build und Push mit Tag `:latest`

Status: [Actions-Tab](https://github.com/Mahimiu/djl-serving/actions)

### Verwendung als Azure-Sidecar

Auf Azure App Service wird dieses Image als Sidecar zum Consumer-Service hinzugefügt; der Consumer-Container erreicht den Sidecar dann über den Service-Namen `model-service` auf Port `8080`.

## 📁 Projektstruktur
djl-serving/
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions Workflow
├── .vscode/                        # Workspace-Konfig (Bonus)
│   ├── tasks.json                  # Docker Build/Run/Push/Compose Tasks
│   ├── settings.json               # Editor-Einstellungen
│   └── extensions.json             # Empfohlene Extensions
├── .editorconfig                   # IDE-übergreifende Format-Regeln (Bonus)
├── .gitignore
├── docker-compose.yml              # Sidecar + Consumer zusammen
├── Dockerfile                      # Multi-Stage Build (Bonus)
├── README.md                       # Diese Datei
└── traced_resnet18.zip             # TorchScript-Modell (ImageNet-1k)

## 🔗 Verwandte Repositories

- **Consumer-Service**: [Mahimiu/djl-serving-consumer](https://github.com/Mahimiu/djl-serving-consumer)
- **Footwear-Klassifikator (eingebettete Variante)**: [Mahimiu/djl-footwear-classification](https://github.com/Mahimiu/djl-footwear-classification)

## 📜 Lizenz

Dieses Projekt basiert auf dem offiziellen [DJL Serving](https://github.com/deepjavalibrary/djl-serving) (Apache 2.0). Das verwendete TorchScript-Modell stammt aus dem DJL-Beispielcode.

## 👤 Autor

**Maximillian Galm** — ZHAW, Wirtschaftsinformatik, FS2026
