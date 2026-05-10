# 🧠 DJL Serving (Sidecar)

Docker-Image mit [DJL Serving](https://github.com/deepjavalibrary/djl-serving) und einem vortrainierten **TorchScript-ResNet18-Modell** (ImageNet-1k). Wird als **Sidecar** vom [DJL Serving Consumer](https://github.com/Mahimiu/djl-serving-consumer) angesprochen.

Das Projekt entstand im Rahmen des Moduls **MDM (Model Deployment & Maintenance)** an der ZHAW (FS2026).

## 🏗️ Rolle in der Architektur

```
[Consumer Service]  ──HTTP──►  [DJL Serving Sidecar]
 (galmmax1/                     (galmmax1/djl-serving:latest)
  djl-serving-consumer:latest)        ▲
                                      │
                            traced_resnet18.zip
```

Der Sidecar exponiert auf Port `8080` den Endpoint `/predictions/traced_resnet18`, der ein Bild als `multipart/form-data` entgegennimmt und Top-5-Klassifikationen zurückliefert.

## 📦 Inhalt

| Datei | Zweck |
|---|---|
| `Dockerfile` | Image-Definition (basiert auf `deepjavalibrary/djl-serving`) |
| `traced_resnet18.zip` | Vortrainiertes TorchScript-Modell (ImageNet-1k) |
| `docker-compose.yml` | Startet Sidecar + Consumer zusammen |

## 🚀 Lokal starten

### Variante A: Beides via Docker Compose (empfohlen)

```bash
docker-compose up
```

Anschliessend ist der Consumer unter [http://localhost](http://localhost) erreichbar; der Sidecar ist intern unter `model-service:8080`.

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

## 🔗 Verwandte Repositories

- **Consumer-Service**: [Mahimiu/djl-serving-consumer](https://github.com/Mahimiu/djl-serving-consumer)
- **Footwear-Klassifikator (eingebettete Variante)**: [Mahimiu/djl-footwear-classification](https://github.com/Mahimiu/djl-footwear-classification)

## 📜 Lizenz

Dieses Projekt basiert auf dem offiziellen [DJL Serving](https://github.com/deepjavalibrary/djl-serving) (Apache 2.0). Das verwendete TorchScript-Modell stammt aus dem DJL-Beispielcode.

## 👤 Autor

**Maximillian Galm** — ZHAW, Wirtschaftsinformatik, FS2026
