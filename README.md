# SIGEJ Flutter

Base de migracion del proyecto SIGEJ a Flutter para Windows escritorio y Web.

## Ejecutar

```powershell
flutter pub get
flutter run -d windows
```

Para web:

```powershell
flutter run -d chrome
```

## Estructura

- `lib/core`: tema, constantes, utilidades y widgets compartidos.
- `lib/data`: almacenamiento local y repositorios.
- `lib/models`: modelos principales.
- `lib/features`: pantallas y controladores por modulo.
- `lib/routes`: rutas de navegacion.
