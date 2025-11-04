# 🐐 Referencia Rápida CI/CD

## 🚦 Estados de Workflows

| Estado | Significado | Acción |
|--------|-------------|--------|
| ✅ Green | Todo funciona | Proceder con merge |
| 🟡 Yellow | En ejecución | Esperar |
| ❌ Red | Fallo detectado | Revisar logs |

## 📋 Comandos Locales Pre-CI

Ejecuta estos comandos antes de hacer push para evitar fallos en CI:

```bash
# 1. Formato
dart format .

# 2. Análisis
flutter analyze

# 3. Tests
flutter test

# 4. Build Android
flutter build apk --debug

# 5. Build Web
flutter build web

# Todo en uno (validación completa)
dart format . && flutter analyze && flutter test && flutter build apk --debug
```

## 🎯 Workflows Disponibles

### CI - Integración Continua
- **Trigger:** Push/PR a main o develop
- **Duración:** ~10-15 minutos
- **Incluye:** Format check, análisis, tests, builds

### Android Release
- **Trigger:** Manual
- **Duración:** ~20-30 minutos
- **Output:** APK (beta) o AAB (production)

### iOS Release
- **Trigger:** Manual
- **Duración:** ~30-45 minutos
- **Output:** IPA

### Web Deploy
- **Trigger:** Auto en push a main, o manual
- **Duración:** ~10-15 minutos
- **Output:** Build web deployado

### Dependencies Check
- **Trigger:** Semanal (lunes 9am) o manual
- **Duración:** ~5 minutos
- **Output:** Reporte de dependencias

## 🔄 Proceso de Release

### Android Beta
```bash
1. Actions → Android Release
2. Run workflow
3. Tipo: beta
4. Versión: 1.0.0
5. Wait ~20 min
6. Download APK from artifacts
```

### Android Production
```bash
1. Actions → Android Release
2. Run workflow
3. Tipo: production
4. Versión: 1.0.0
5. Wait ~30 min
6. AAB subido a Play Store (internal track)
```

### iOS Beta
```bash
1. Actions → iOS Release
2. Run workflow
3. Tipo: beta
4. Versión: 1.0.0
5. Wait ~30 min
6. IPA disponible en Firebase
```

### iOS Production
```bash
1. Actions → iOS Release
2. Run workflow
3. Tipo: production
4. Versión: 1.0.0
5. Wait ~45 min
6. IPA subido a TestFlight
```

### Web Staging
```bash
1. Actions → Web Deploy
2. Run workflow
3. Entorno: staging
4. Wait ~10 min
5. URL de staging disponible
```

### Web Production
```bash
# Automático al hacer push a main
git push origin main

# O manual:
1. Actions → Web Deploy
2. Run workflow
3. Entorno: production
4. Wait ~15 min
```

## 🔍 Debug de Failures

### Test Failure
```bash
# Ver logs del workflow
Actions → CI → Failed job → Tests step

# Reproducir localmente
flutter test

# Si es un test específico
flutter test test/widget_test.dart

# Contactar: @El-Bicho
```

### Analyze Failure
```bash
# Ver logs
Actions → CI → Failed job → Analyze step

# Reproducir localmente
flutter analyze

# Fix común
dart format .
flutter analyze --fix

# Contactar: @Dash
```

### Build Failure (Android)
```bash
# Verificar gradle
cd android && ./gradlew clean

# Verificar dependencias
flutter pub get
flutter pub upgrade

# Verificar signing (release builds)
# - Confirmar que secrets estén configurados
# - Verificar build.gradle

# Contactar: @La-Cabra
```

### Build Failure (iOS)
```bash
# Verificar pods
cd ios && pod install

# Limpiar build
flutter clean
flutter pub get

# Verificar certificados
# - Confirmar que no estén expirados
# - Verificar provisioning profile

# Contactar: @La-Cabra
```

### Deploy Failure
```bash
# Firebase
# - Verificar service account JSON
# - Verificar permisos
# - Verificar project ID

# Play Store
# - Verificar service account
# - Verificar permisos en Play Console
# - Verificar package name

# App Store
# - Verificar API key
# - Verificar issuer ID
# - Verificar bundle ID

# Contactar: @La-Cabra
```

## ⚡ Optimizaciones

### Reducir tiempo de CI
```yaml
# Ya implementado:
- Cache de Flutter SDK
- Cache de pub dependencies
- Cache de .dart_tool
- Paralelización de builds
```

### Reducir uso de minutos
```yaml
# Tips:
- Usar workflow_dispatch en lugar de push triggers
- Limitar branches que activan CI
- Usar conditions en steps
```

## 🔐 Secrets Checker

Antes de un release, verifica:

### Android
- [ ] ANDROID_KEYSTORE_BASE64
- [ ] ANDROID_KEYSTORE_PASSWORD
- [ ] ANDROID_KEY_PASSWORD
- [ ] ANDROID_KEY_ALIAS
- [ ] ANDROID_PACKAGE_NAME

### iOS
- [ ] IOS_CERTIFICATE_BASE64
- [ ] IOS_PROVISION_PROFILE_BASE64
- [ ] IOS_CERTIFICATE_PASSWORD

### Firebase
- [ ] FIREBASE_SERVICE_ACCOUNT_JSON
- [ ] FIREBASE_PROJECT_ID
- [ ] FIREBASE_APP_ID_ANDROID
- [ ] FIREBASE_APP_ID_IOS

### Play Store
- [ ] GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

### App Store
- [ ] APPSTORE_ISSUER_ID
- [ ] APPSTORE_API_KEY_ID
- [ ] APPSTORE_API_PRIVATE_KEY

## 📊 Métricas Típicas

| Métrica | Valor Esperado |
|---------|----------------|
| CI Duration | 10-15 min |
| Android Release | 20-30 min |
| iOS Release | 30-45 min |
| Web Deploy | 10-15 min |
| Test Coverage | >80% |
| Analyze Warnings | 0 |

## 🎨 Branch Strategy

```
main (protected)
  ├── develop
  │   ├── feature/nueva-funcionalidad
  │   ├── bugfix/arreglar-algo
  │   └── hotfix/urgente
  └── release/v1.0.0
```

### Reglas
1. CI debe pasar antes de merge a main
2. Al menos 1 approval requerido
3. No push directo a main
4. Squash commits al hacer merge

## 📱 Distribución

### Android Beta
- Firebase App Distribution
- Grupo: testers
- Auto-notificación

### Android Production
- Google Play Console
- Track: internal → beta → production
- Release manual

### iOS Beta
- Firebase App Distribution
- TestFlight (opcional)
- Grupo: testers

### iOS Production
- TestFlight
- App Store (manual)

### Web
- Firebase Hosting (main)
- GitHub Pages (backup)
- AWS S3/CloudFront (opcional)

## 🚨 Alertas

### Configurar notificaciones
```bash
# GitHub
Settings → Notifications → Actions
- Enable workflow notifications
- Email on failure

# Slack (requiere setup adicional)
- Instalar GitHub app en Slack
- Subscribirse: /github subscribe owner/repo workflows
```

## 📞 Contactos Rápidos

| Issue | Agente | Tag |
|-------|--------|-----|
| CI/CD | La Cabra | @La-Cabra |
| Tests | El Bicho | @El-Bicho |
| Code | Dash | @Dash |
| UI | Semanti-Dash | @Semanti-Dash |

---

**La Cabra** 🐐 - Siempre a tu servicio
