# Roadmap de Desarrollo

## Fase 1: Setup y Foundation (1 día)

**Objetivo**: Establecer la base del proyecto Flutter y Supabase.

### Tareas:
- [ ] Crear nuevo proyecto en Supabase
- [ ] Desconectar MCP del proyecto anterior
- [ ] Conectar MCP al nuevo proyecto Supabase
- [ ] Crear proyecto Flutter: `flutter create conversa_ai`
- [ ] Habilitar soporte web: `flutter config --enable-web`
- [ ] Agregar dependencias: supabase_flutter, flutter_riverpod, go_router, dio
- [ ] Crear estructura de carpetas (features, core, shared)
- [ ] Configurar Supabase en main.dart

### Criterios de éxito:
- Proyecto Flutter corre en web y mobile
- Conexión exitosa con Supabase
- Estructura de carpetas definida

---

## Fase 2: Autenticación OAuth (1-2 días)

**Objetivo**: Sistema de login con Google/GitHub funcional.

### Tareas:
- [ ] Configurar OAuth providers en Supabase Dashboard
- [ ] Crear pantalla de Login
- [ ] Implementar signInWithOAuth
- [ ] Crear AuthProvider con Riverpod
- [ ] Configurar go_router con redirect para rutas protegidas
- [ ] Crear tabla users y trigger para insertar al primer login
- [ ] Pantalla de perfil básica

### Criterios de éxito:
- Usuario puede iniciar sesión con OAuth
- Rutas protegidas redirigen a login
- Perfil de usuario visible

---

## Fase 3: Base de Datos (1 día)

**Objetivo**: Esquema de BD listo y operaciones desde Flutter.

### Tareas:
- [ ] Crear migraciones (conversations, messages)
- [ ] Configurar RLS policies
- [ ] Crear trigger update_conversation_timestamp
- [ ] Implementar ConversationRepository
- [ ] Implementar MessageRepository
- [ ] Probar CRUD desde Flutter

### Criterios de éxito:
- Tablas creadas en Supabase
- Flutter puede insertar y leer datos
- RLS funciona correctamente

---

## Fase 4: Interfaz de Chat Básica (2 días)

**Objetivo**: UI de chat funcional sin IA (mensajes locales).

### Tareas:
- [ ] Layout principal con AppBar + ListView + Input
- [ ] Widget MessageBubble (user vs assistant)
- [ ] Widget MessageInput
- [ ] Scroll automático
- [ ] Drawer/sidebar con lista de conversaciones
- [ ] Crear nueva conversación
- [ ] Seleccionar conversación activa
- [ ] Responsive: web vs mobile

### Criterios de éxito:
- Usuario puede escribir y ver mensajes en UI
- Puede crear y cambiar entre conversaciones
- Interfaz usable en web y mobile

---

## Fase 5: Integración OpenAI (2 días)

**Objetivo**: Respuestas de IA en tiempo real.

### Tareas:
- [ ] Crear Edge Function chat-completion
- [ ] Configurar OpenAI API key en Supabase secrets
- [ ] Implementar llamada a OpenAI con historial
- [ ] Guardar mensajes en BD desde Edge Function
- [ ] Servicio Flutter para llamar Edge Function
- [ ] Provider para enviar mensaje y recibir respuesta
- [ ] Indicador de carga durante respuesta

### Criterios de éxito:
- IA responde a mensajes del usuario
- Mensajes se guardan en BD
- Respuestas aparecen en la UI

---

## Fase 6: Historial y Guardado Automático (1 día)

**Objetivo**: Persistencia completa y carga de historial.

### Tareas:
- [ ] Cargar mensajes al seleccionar conversación
- [ ] Guardado automático al enviar (ya integrado en Fase 5)
- [ ] Manejar conversación vacía
- [ ] Estados de loading y error

### Criterios de éxito:
- Historial se carga al abrir conversación
- Mensajes persisten entre sesiones

---

## Fase 7: Interfaz Mejorada (1-2 días)

**Objetivo**: UX pulida y funcionalidades extra.

### Tareas:
- [ ] Tema oscuro/claro
- [ ] Markdown en mensajes de IA
- [ ] Copiar mensaje
- [ ] Eliminar conversación
- [ ] Renombrar conversación
- [ ] Títulos automáticos

### Criterios de éxito:
- App se siente completa y profesional
- Todas las features principales funcionando

---

## Fase 8: Real-time y Deployment (opcional)

**Objetivo**: Sincronización en vivo y publicación.

### Tareas:
- [ ] Suscripción Realtime a messages
- [ ] Build web para producción
- [ ] Deploy en Firebase Hosting / Vercel / Netlify
- [ ] Build Android APK/AAB
- [ ] Build iOS (requiere Mac)

### Criterios de éxito:
- App desplegada y accesible
- Funciona en web y mobile

---

## Resumen de Tiempo Estimado

| Fase | Días |
|------|------|
| 1. Setup | 1 |
| 2. Auth OAuth | 1-2 |
| 3. Base de Datos | 1 |
| 4. Chat UI | 2 |
| 5. OpenAI | 2 |
| 6. Historial | 1 |
| 7. UI Mejorada | 1-2 |
| 8. Deploy | 1 |
| **Total** | **10-12 días** |
