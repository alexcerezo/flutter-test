# 🐐 Guía de Configuración CI/CD - La Cabra

Esta guía te ayudará a configurar completamente los pipelines de CI/CD para tu aplicación Flutter.

## 📋 Prerequisitos

- Cuenta de GitHub con permisos de administrador en el repositorio
- Proyecto Flutter inicializado
- (Opcional) Cuenta de Firebase para distribución y hosting
- (Opcional) Cuenta de Google Play Developer para Android
- (Opcional) Cuenta de Apple Developer para iOS
- (Opcional) Cuenta de AWS para hosting web

## 🚀 Paso 1: Configuración del Proyecto Flutter

### 1.1 Crear proyecto Flutter (si aún no existe)

```bash
flutter create my_app
cd my_app
```

### 1.2 Verificar que el proyecto compila

```bash
flutter pub get
flutter test
flutter analyze
flutter build apk --debug  # Para Android
flutter build web          # Para Web
```

## 🔐 Paso 2: Configuración de Secrets en GitHub

Ve a: **Repository → Settings → Secrets and variables → Actions → New repository secret**

### Secrets mínimos requeridos (para CI básico)

Ninguno - el workflow de CI básico funciona sin secrets.

### Secrets para Android Release

#### 2.1 Crear Keystore

```bash
keytool -genkey -v -keystore ~/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Responde las preguntas y guarda la información:
# - Keystore password: [TU_PASSWORD]
# - Key password: [TU_PASSWORD] (puede ser la misma)
# - Alias: upload
```

#### 2.2 Convertir Keystore a Base64

```bash
base64 -i ~/keystore.jks | tr -d '\n' > keystore.base64.txt
```

#### 2.3 Agregar Secrets de Android

| Secret Name | Valor | Dónde obtenerlo |
|-------------|-------|-----------------|
| `ANDROID_KEYSTORE_BASE64` | Contenido de `keystore.base64.txt` | Del paso 2.2 |
| `ANDROID_KEYSTORE_PASSWORD` | Password del keystore | Del paso 2.1 |
| `ANDROID_KEY_PASSWORD` | Password de la key | Del paso 2.1 |
| `ANDROID_KEY_ALIAS` | `upload` | Del paso 2.1 |
| `ANDROID_PACKAGE_NAME` | `com.ejemplo.app` | De `android/app/build.gradle` |

#### 2.4 Configurar build.gradle para firma

Edita `android/app/build.gradle`:

```gradle
// Después de 'apply from: ...'
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... configuración existente ...
    
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
            // ... resto de configuración ...
        }
    }
}
```

### Secrets para iOS Release

#### 2.5 Exportar Certificado de Firma

1. Abre **Keychain Access** en Mac
2. Encuentra tu certificado de distribución
3. Click derecho → Export
4. Guarda como `certificate.p12`
5. Ingresa una password y guárdala

#### 2.6 Descargar Provisioning Profile

1. Ve a [Apple Developer Portal](https://developer.apple.com)
2. Certificates, Identifiers & Profiles → Profiles
3. Descarga tu provisioning profile de distribución
4. Guárdalo como `profile.mobileprovision`

#### 2.7 Convertir a Base64

```bash
base64 -i certificate.p12 | tr -d '\n' > certificate.base64.txt
base64 -i profile.mobileprovision | tr -d '\n' > profile.base64.txt
```

#### 2.8 Crear ExportOptions.plist

Copia el template y configúralo:

```bash
cp ios-config-templates/ExportOptions.plist.template ios/ExportOptions.plist
```

Edita `ios/ExportOptions.plist`:
- Reemplaza `YOUR_TEAM_ID` con tu Team ID
- Reemplaza `YOUR.BUNDLE.IDENTIFIER` con tu Bundle ID
- Reemplaza `YOUR_PROVISIONING_PROFILE_NAME` con el nombre de tu perfil

#### 2.9 Agregar Secrets de iOS

| Secret Name | Valor | Dónde obtenerlo |
|-------------|-------|-----------------|
| `IOS_CERTIFICATE_BASE64` | Contenido de `certificate.base64.txt` | Del paso 2.7 |
| `IOS_PROVISION_PROFILE_BASE64` | Contenido de `profile.base64.txt` | Del paso 2.7 |
| `IOS_CERTIFICATE_PASSWORD` | Password del certificado | Del paso 2.5 |

### Secrets para Firebase (Android/iOS Beta + Web Hosting)

#### 2.10 Crear proyecto Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto o selecciona uno existente
3. Agrega apps de Android y/o iOS según necesites

#### 2.11 Obtener Service Account

1. Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Guarda el archivo JSON

#### 2.12 Agregar Secrets de Firebase

| Secret Name | Valor | Dónde obtenerlo |
|-------------|-------|-----------------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Contenido completo del JSON | Del paso 2.11 |
| `FIREBASE_PROJECT_ID` | ID del proyecto | Firebase Console → Project Settings |
| `FIREBASE_APP_ID_ANDROID` | App ID de Android | Firebase Console → Android app settings |
| `FIREBASE_APP_ID_IOS` | App ID de iOS | Firebase Console → iOS app settings |

### Secrets para Google Play Store

#### 2.13 Configurar Google Play API

1. Google Play Console → Setup → API Access
2. Crea o vincula un proyecto de Google Cloud
3. Crea una Service Account
4. Descarga la clave JSON
5. Dale permisos en Google Play Console

#### 2.14 Agregar Secret

| Secret Name | Valor |
|-------------|-------|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Contenido del JSON de service account |

### Secrets para App Store Connect

#### 2.15 Crear API Key

1. App Store Connect → Users and Access → Keys
2. Click "+" para crear nueva key
3. Selecciona "App Manager" role
4. Descarga la key (.p8)
5. Guarda el Key ID e Issuer ID

#### 2.16 Agregar Secrets

| Secret Name | Valor |
|-------------|-------|
| `APPSTORE_ISSUER_ID` | Issuer ID de la página de keys |
| `APPSTORE_API_KEY_ID` | Key ID de la key creada |
| `APPSTORE_API_PRIVATE_KEY` | Contenido completo del archivo .p8 |

### Secrets para AWS (Web Hosting Opcional)

#### 2.17 Crear usuario IAM

1. AWS Console → IAM → Users → Add user
2. Tipo: Programmatic access
3. Permisos: `AmazonS3FullAccess`, `CloudFrontFullAccess`
4. Guarda Access Key ID y Secret Access Key

#### 2.18 Crear bucket S3

```bash
aws s3 mb s3://my-flutter-app --region us-east-1
aws s3 website s3://my-flutter-app --index-document index.html
```

#### 2.19 Agregar Secrets de AWS

| Secret Name | Valor |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | Access Key del usuario IAM |
| `AWS_SECRET_ACCESS_KEY` | Secret Key del usuario IAM |
| `AWS_REGION` | Región del bucket (ej: `us-east-1`) |
| `AWS_S3_BUCKET` | Nombre del bucket |
| `AWS_CLOUDFRONT_DISTRIBUTION_ID` | (Opcional) ID de distribución |
| `CUSTOM_DOMAIN` | (Opcional) Tu dominio personalizado |

## ✅ Paso 3: Verificar Configuración

### 3.1 Probar CI Pipeline

1. Crea una branch de prueba
2. Haz un cambio mínimo (ej: README)
3. Crea un Pull Request
4. Verifica que el workflow de CI se ejecute correctamente

### 3.2 Probar Android Release

1. Ve a Actions → Android Release
2. Run workflow con tipo "beta"
3. Ingresa versión "0.1.0"
4. Verifica que se genere el APK

### 3.3 Probar iOS Release (requiere Mac runner)

1. Ve a Actions → iOS Release
2. Run workflow con tipo "beta"
3. Ingresa versión "0.1.0"
4. Verifica que se genere el IPA

### 3.4 Probar Web Deploy

1. Haz push a `main`
2. Verifica que se despliegue automáticamente
3. O usa workflow_dispatch para deploy manual

## 📊 Paso 4: Configuración de Badges (Opcional)

Agrega badges a tu README.md:

```markdown
[![CI](https://github.com/USUARIO/REPO/workflows/CI%20-%20Integración%20Continua/badge.svg)](https://github.com/USUARIO/REPO/actions)
[![Android Release](https://github.com/USUARIO/REPO/workflows/CD%20-%20Android%20Release/badge.svg)](https://github.com/USUARIO/REPO/actions)
[![iOS Release](https://github.com/USUARIO/REPO/workflows/CD%20-%20iOS%20Release/badge.svg)](https://github.com/USUARIO/REPO/actions)
```

## 🔒 Seguridad

### Checklist de Seguridad

- [ ] Todos los secrets están en GitHub Secrets (no en código)
- [ ] `.gitignore` incluye archivos sensibles
- [ ] `key.properties` está en `.gitignore`
- [ ] `ExportOptions.plist` está en `.gitignore` (si tiene info sensible)
- [ ] Certificados y keystores NO están en el repositorio
- [ ] Service account keys NO están en el repositorio
- [ ] Los workflows limpian archivos sensibles después de usarlos

### Archivos que NUNCA deben comitearse

```
android/key.properties
android/app/keystore.jks
android/app/*.keystore
ios/ExportOptions.plist (si tiene credenciales)
ios/**/*.p12
ios/**/*.mobileprovision
*.env
.env.*
secrets/
credentials/
*-service-account.json
*.base64.txt
```

## 🐛 Troubleshooting Común

### CI falla con "No tests found"

**Solución:** Crea al menos un test básico:

```dart
// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('basic test', () {
    expect(1 + 1, 2);
  });
}
```

### Android build falla con "Keystore not found"

**Solución:** Verifica que todos los secrets de Android estén configurados correctamente.

### iOS build falla con "Certificate not valid"

**Solución:** 
1. Verifica que el certificado no esté expirado
2. Confirma que el provisioning profile coincida con el certificado
3. Verifica el Team ID

### Firebase deploy falla

**Solución:**
1. Verifica permisos del Service Account
2. Confirma que el proyecto Firebase existe
3. Verifica que las apps estén configuradas en Firebase

### Web deploy a S3 falla

**Solución:**
1. Verifica permisos del usuario IAM
2. Confirma que el bucket existe
3. Verifica la región del bucket

## 📞 Soporte

Para problemas específicos:

- **CI/CD Issues:** @La-Cabra
- **Test Failures:** @El-Bicho
- **Code Issues:** @Dash
- **UI Issues:** @Semanti-Dash

## 🎯 Próximos Pasos

Una vez configurado todo:

1. ✅ Ejecuta el workflow de CI regularmente
2. ✅ Configura branch protection rules (require CI pass)
3. ✅ Establece un proceso de release regular
4. ✅ Documenta el proceso para tu equipo
5. ✅ Configura notificaciones de Slack/Email para failures

---

**La Cabra** 🐐 - Configuración completada exitosamente
