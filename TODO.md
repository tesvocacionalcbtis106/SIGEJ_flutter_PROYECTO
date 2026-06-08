# Migración completa LocalDatabase -> Firestore (TODO)

## Plan aprobado

### Fase 0: Mapa/Verificación
- [ ] Revisar TODOS los imports/referencias a `LocalDatabase` en `lib/`.
- [ ] Confirmar todos los métodos públicos usados por UI/controladores.
- [ ] Revisar modelos existentes y métodos faltantes.

### Fase 1: Models
- [ ] Agregar `fromMap()` / `toMap()` / `copyWith()` a todos los modelos que falten.
- [ ] Asegurar compatibilidad de tipos con Firestore (incl. enums roles).

### Fase 2: FirestoreDatabaseAdapter
- [ ] Crear `lib/data/firebase/firestore_database_adapter.dart`.
- [ ] Implementar clase `FirestoreDatabaseAdapter` que extienda `ChangeNotifier` y tenga API pública equivalente a `LocalDatabase`.
- [ ] Migrar mutaciones/consultas: usuarios, grupos, estudiantes, maestros, justificaciones.
- [ ] Convertir lecturas a Firestore (sin memoria persistente como fuente de verdad).
- [ ] Mantener compatibilidad temporal: permitir inicializarse y cachear solo lo estrictamente necesario (si aplica) pero con invalidación/refresh desde Firestore.

### Fase 3: Repos (sin fallback a LocalDatabase)
- [ ] Migrar `AuthRepository` a `FirebaseAuth`.
- [ ] `UsersRepository` a Firestore puro.
- [ ] `RecordsRepository` a derivación desde `justifications`.

### Fase 4: main.dart y Provider
- [ ] Cambiar `main.dart` para inyectar `FirestoreDatabaseAdapter` y eliminar `LocalDatabase`.
- [ ] Ajustar providers de repos si dependían de `LocalDatabase`.

### Fase 5: Eliminar LocalDatabase
- [ ] Ejecutar búsqueda para confirmar que no quedan referencias a `LocalDatabase`.
- [ ] Eliminar `lib/data/local/local_database.dart` y cualquier provider/import asociado.
- [ ] Eliminar dependencias restantes (storage_service si ya no se usa).

### Fase 6: Validación
- [ ] Ejecutar `flutter analyze`.
- [ ] Ejecutar tests si existen.
- [ ] Corregir errores de tipos/null safety/provider/streams.

