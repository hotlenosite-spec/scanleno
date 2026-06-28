# Android release signing

Release builds must never fall back to the debug signing key.

1. Copy the example file:

```powershell
Copy-Item android/key.properties.example android/key.properties
```

2. Create or place your upload keystore outside Git tracking, then update:

```properties
storeFile=upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_KEY_PASSWORD
```

`storeFile` is resolved from the Android project root. For example,
`upload-keystore.jks` points to `android/upload-keystore.jks`.

3. Build release:

```powershell
flutter build appbundle --release `
  --dart-define=SCANLENO_ENV=production `
  --dart-define=SCANLENO_BACKEND_URL=https://api.scanleno.com
```

If `android/key.properties` or any required signing value is missing, the
release build fails with:

```text
Release signing is not configured. Create android/key.properties.
```

Do not commit `android/key.properties`, `.jks`, or `.keystore` files.
