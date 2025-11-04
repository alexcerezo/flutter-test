# 🐐 CI/CD Configuration - La Cabra (DevOps Expert)

Este directorio contiene los workflows de GitHub Actions para la integración continua y despliegue automatizado de la aplicación Flutter.

## 📋 Workflows Disponibles

### 1. CI - Integración Continua (`ci.yml`)
**Trigger:** Push y Pull Requests a `main` y `develop`

**Responsabilidades:**
- ✅ Verificación de formato del código
- 🔍 Análisis estático con `flutter analyze`
- 🧪 Ejecución de tests unitarios con cobertura
- 🏗️ Verificación de compilación para Android y Web
- 📊 Reporte de cobertura (Codecov)

**Matriz de plataformas:** Android, Web

### 2. Android Release (`android-release.yml`)
**Trigger:** Manual (workflow_dispatch)

**Tipos de release:**
- **Beta:** Genera APK y despliega a Firebase App Distribution
- **Production:** Genera AAB y despliega a Google Play Store (internal track)

**Características:**
- Firma automática de APK/AAB con keystore
- Versionado automático con build number incremental
- Upload a Firebase App Distribution para testing
- Deploy a Google Play Store (internal/beta/production tracks)
- Creación automática de GitHub Releases

### 3. iOS Release (`ios-release.yml`)
**Trigger:** Manual (workflow_dispatch)

**Tipos de release:**
- **Beta:** Genera IPA y despliega a Firebase App Distribution
- **Production:** Genera IPA y despliega a TestFlight

**Características:**
- Configuración automática de certificados y provisioning profiles
- Keychain temporal seguro para firma
- Deploy a Firebase App Distribution para beta testing
- Upload a TestFlight para distribución interna/externa
- Creación automática de GitHub Releases

### 4. Web Deploy (`web-deploy.yml`)
**Trigger:** 
- Push a `main` (automático a producción)
- Manual con selección de entorno (staging/production)

**Características:**
- Build optimizado con CanvasKit renderer
- Compresión gzip de assets
- Deploy a Firebase Hosting (staging y production channels)
- Deploy alternativo a GitHub Pages
- Deploy opcional a AWS S3 + CloudFront
- Invalidación de caché de CDN

## 🔐 GitHub Secrets Requeridos

### Secrets Generales
| Secret | Descripción | Requerido para |
|--------|-------------|----------------|
| `GITHUB_TOKEN` | Token automático de GitHub | Todos los workflows |

### Android Secrets
| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `ANDROID_KEYSTORE_BASE64` | Keystore codificado en Base64 | `base64 -i keystore.jks \| tr -d '\n'` |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del keystore | Generada al crear keystore |
| `ANDROID_KEY_PASSWORD` | Contraseña de la key | Generada al crear keystore |
| `ANDROID_KEY_ALIAS` | Alias de la key | Definido al crear keystore |
| `ANDROID_PACKAGE_NAME` | Package name de la app | Del archivo `build.gradle` |
| `FIREBASE_APP_ID_ANDROID` | ID de la app en Firebase | Firebase Console → Project Settings |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Credenciales de Google Play | Google Play Console → API Access |

#### Crear keystore para Android:
```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### iOS Secrets
| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `IOS_CERTIFICATE_BASE64` | Certificado P12 en Base64 | `base64 -i certificate.p12 \| tr -d '\n'` |
| `IOS_PROVISION_PROFILE_BASE64` | Provisioning profile en Base64 | `base64 -i profile.mobileprovision \| tr -d '\n'` |
| `IOS_CERTIFICATE_PASSWORD` | Contraseña del certificado | Definida al exportar certificado |
| `FIREBASE_APP_ID_IOS` | ID de la app en Firebase | Firebase Console → Project Settings |
| `APPSTORE_ISSUER_ID` | Issuer ID de App Store Connect | App Store Connect → Users and Access → Keys |
| `APPSTORE_API_KEY_ID` | API Key ID | App Store Connect → Users and Access → Keys |
| `APPSTORE_API_PRIVATE_KEY` | Private key de la API | Descargada al crear API Key |

### Firebase Secrets
| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Credenciales de Service Account | Firebase Console → Project Settings → Service Accounts |
| `FIREBASE_PROJECT_ID` | ID del proyecto Firebase | Firebase Console → Project Settings |

### Web/AWS Secrets (Opcionales)
| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `AWS_ACCESS_KEY_ID` | Access Key de AWS | AWS Console → IAM |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de AWS | AWS Console → IAM |
| `AWS_REGION` | Región de AWS | Ej: `us-east-1` |
| `AWS_S3_BUCKET` | Nombre del bucket S3 | AWS Console → S3 |
| `AWS_CLOUDFRONT_DISTRIBUTION_ID` | ID de distribución CloudFront | AWS Console → CloudFront |
| `CUSTOM_DOMAIN` | Dominio personalizado | Tu dominio web |

## 🚀 Cómo usar los Workflows

### Para Pull Requests
El workflow de CI se ejecuta automáticamente al crear o actualizar un PR:
1. Se ejecutan los tests y análisis
2. Se verifica la compilación para Android y Web
3. Los checks deben estar en verde para hacer merge

### Para Releases de Android
1. Ve a Actions → Android Release
2. Click en "Run workflow"
3. Selecciona el tipo de release (beta/production)
4. Ingresa la versión (ej: 1.0.0)
5. Click en "Run workflow"

### Para Releases de iOS
1. Ve a Actions → iOS Release
2. Click en "Run workflow"
3. Selecciona el tipo de release (beta/production)
4. Ingresa la versión (ej: 1.0.0)
5. Click en "Run workflow"

### Para Deploy Web
- **Automático:** Push a `main` despliega automáticamente a producción
- **Manual:** 
  1. Ve a Actions → Web Deploy
  2. Click en "Run workflow"
  3. Selecciona el entorno (staging/production)
  4. Click en "Run workflow"

## 🔧 Configuración del Proyecto Flutter

### Android - key.properties
Crear archivo `android/key.properties` (ignorado por git):
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=<alias>
storeFile=<path-to-keystore>
```

### Android - build.gradle
Configurar firma en `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS - ExportOptions.plist
Crear archivo `ios/ExportOptions.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

## 📊 Optimizaciones Implementadas

### Cache de Dependencias
- Cache de `pub-cache` para dependencias de Dart/Flutter
- Cache de `.dart_tool` para análisis incrementales
- Cache de Flutter SDK (via `subosito/flutter-action`)
- Reduce tiempo de build en ~60%

### Paralelización
- Jobs independientes ejecutados en paralelo
- Matriz de plataformas para builds simultáneos
- Timeout configurado por job para prevenir bloqueos

### Seguridad
- Keychain temporal para certificados iOS
- Limpieza automática de archivos sensibles
- Secrets nunca expuestos en logs
- Certificados decodificados on-the-fly

## 🐛 Troubleshooting

### Error: "Flutter command not found"
- Verificar versión de Flutter en workflow
- Confirmar que `subosito/flutter-action` está configurado

### Error: "Tests failed"
- Revisar logs del job `test-and-analyze`
- Ejecutar tests localmente: `flutter test`
- Contactar a **@El-Bicho** para fixes de tests

### Error: "Analyze failed"
- Revisar logs del análisis estático
- Ejecutar localmente: `flutter analyze`
- Contactar a **@Dash** para fixes de arquitectura

### Error: "Build failed"
- Verificar configuración de firma (Android/iOS)
- Confirmar que todos los secrets están configurados
- Revisar logs específicos de la plataforma

### Error: "Firebase deployment failed"
- Verificar que `FIREBASE_SERVICE_ACCOUNT_JSON` sea válido
- Confirmar permisos del Service Account
- Verificar que el proyecto Firebase existe

## 📈 Métricas y Monitoreo

### Codecov
El workflow de CI genera reportes de cobertura y los sube a Codecov automáticamente (requiere configuración en Codecov.io).

### Artifacts
Los builds generan artifacts que se almacenan por:
- Debug builds: 5 días
- Beta builds: 30 días
- Production builds: 90 días

### GitHub Releases
Los builds de producción crean releases en GitHub automáticamente con:
- Tag versionado (v1.0.0-android, v1.0.0-ios)
- Binarios adjuntos (AAB, IPA)
- Notas de release automáticas

## 🎯 Siguientes Pasos

1. ✅ Configurar todos los secrets en GitHub
2. ✅ Crear proyecto en Firebase (si se usa)
3. ✅ Configurar Google Play Console API (para Android)
4. ✅ Configurar App Store Connect API (para iOS)
5. ✅ Verificar permisos de Service Accounts
6. ✅ Probar workflow de CI con un PR de prueba
7. ✅ Realizar primer release de prueba en beta

## 📞 Contacto y Responsabilidades

- **CI/CD Issues:** @La-Cabra (DevOps Expert)
- **Test Failures:** @El-Bicho (Testing Expert)
- **Code Architecture:** @Dash (Flutter Expert)
- **UI/Accessibility:** @Semanti-Dash (UI/UX Expert)

---

**La Cabra** 🐐 - *Greatest Of All Time in DevOps*
