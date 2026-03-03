# Features Detallados

Cada feature está dividido en pasos concretos para implementarlos uno por uno.

---

## 1. Autenticación OAuth

**Descripción**: Login con Google, GitHub u otros proveedores OAuth mediante Supabase Auth.

### Pasos:
1. Configurar Supabase Auth en el proyecto Flutter
2. Configurar OAuth providers en el dashboard de Supabase (Google, GitHub)
3. Crear pantalla de Login con botones OAuth
4. Implementar `signInWithOAuth()` y manejo de sesión
5. Crear pantalla de perfil de usuario
6. Implementar logout
7. Crear guard para rutas protegidas (redirect si no autenticado)

### Archivos a crear:
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/profile_screen.dart`
- `lib/features/auth/providers/auth_provider.dart`
- `lib/features/auth/services/auth_service.dart`
- `lib/core/router/app_router.dart` (con guards)

---

## 2. Interfaz de Chat Básica

**Descripción**: Pantalla principal con área de mensajes e input para escribir.

### Pasos:
1. Crear layout principal: AppBar + área de mensajes + input fijo abajo
2. Crear widget `MessageBubble` para mostrar mensajes (user vs assistant)
3. Crear widget `MessageInput` con TextField y botón enviar
4. Implementar scroll automático al nuevo mensaje
5. Mostrar indicador de carga cuando la IA está respondiendo
6. Adaptar layout para web (sidebar) vs mobile (pantalla completa)

### Archivos a crear:
- `lib/features/chat/presentation/screens/chat_screen.dart`
- `lib/features/chat/presentation/widgets/message_bubble.dart`
- `lib/features/chat/presentation/widgets/message_input.dart`
- `lib/features/chat/presentation/widgets/chat_app_bar.dart`

---

## 3. Gestión de Conversaciones

**Descripción**: Crear, listar y cambiar entre múltiples chats.

### Pasos:
1. Crear drawer/sidebar con lista de conversaciones
2. Botón "Nueva conversación" que crea chat vacío
3. Provider Riverpod para lista de conversaciones
4. Al seleccionar conversación, cargar sus mensajes
5. Mostrar título de conversación (primeros caracteres del primer mensaje o "Nueva conversación")
6. En mobile: drawer lateral; en web: sidebar fija

### Archivos a crear:
- `lib/features/chat/presentation/widgets/chat_list_drawer.dart`
- `lib/features/chat/presentation/widgets/conversation_item.dart`
- `lib/features/chat/providers/conversations_provider.dart`
- `lib/features/chat/providers/active_conversation_provider.dart`

---

## 4. Base de Datos y Supabase

**Descripción**: Esquema de BD, migraciones y operaciones CRUD desde Flutter.

### Pasos:
1. Crear proyecto en Supabase
2. Ejecutar migraciones (tablas users, conversations, messages)
3. Configurar RLS policies
4. Crear trigger para actualizar `last_message_at`
5. Inicializar `Supabase.initialize()` en main.dart
6. Crear repositorios: `ConversationRepository`, `MessageRepository`
7. Crear función para insertar usuario en `users` al primer login (trigger o Edge Function)

### Archivos a crear:
- `supabase/migrations/001_initial_schema.sql`
- `lib/core/database/supabase_client.dart`
- `lib/features/chat/data/repositories/conversation_repository.dart`
- `lib/features/chat/data/repositories/message_repository.dart`

---

## 5. Integración con OpenAI

**Descripción**: Edge Function que recibe mensajes y devuelve respuestas de la IA.

### Pasos:
1. Crear Edge Function `chat-completion` en Supabase
2. Recibir `message`, `conversation_id` desde el cliente
3. Obtener historial de mensajes de la conversación
4. Llamar a OpenAI API (Chat Completions) con historial
5. Guardar mensaje del usuario en `messages`
6. Guardar respuesta del assistant en `messages`
7. Retornar respuesta (streaming o no) al cliente
8. En Flutter: servicio que llama a la Edge Function con Dio
9. Provider que envía mensaje y actualiza estado con la respuesta

### Archivos a crear:
- `supabase/functions/chat-completion/index.ts`
- `lib/features/chat/data/services/chat_api_service.dart`
- `lib/features/chat/providers/chat_completion_provider.dart`

---

## 6. Historial de Mensajes

**Descripción**: Cargar y mostrar el historial completo al abrir una conversación.

### Pasos:
1. Al seleccionar conversación, hacer query a `messages` ordenado por `created_at`
2. Provider que expone `AsyncValue<List<Message>>`
3. Mostrar estados: loading, error, data
4. Paginación opcional si hay muchos mensajes (limit/offset)
5. Manejar conversación vacía (mensaje de bienvenida)

### Archivos a crear:
- `lib/features/chat/providers/messages_provider.dart`
- `lib/features/chat/data/models/message_model.dart`

---

## 7. Guardado Automático

**Descripción**: Los mensajes se guardan automáticamente al enviar.

### Pasos:
1. Al enviar mensaje: insertar en `messages` inmediatamente (optimistic)
2. Llamar a Edge Function para respuesta de IA
3. Al recibir respuesta: insertar mensaje del assistant en `messages`
4. Actualizar `last_message_at` de la conversación (vía trigger)
5. Manejar errores: retry o mostrar mensaje al usuario
6. No permitir enviar mensaje duplicado si falla la primera vez

### Archivos a crear:
- Integrar en `conversation_repository.dart` y `message_repository.dart`
- `lib/features/chat/providers/send_message_provider.dart`

---

## 8. Real-time Updates (opcional)

**Descripción**: Sincronización en tiempo real si el usuario tiene la app abierta en varios dispositivos.

### Pasos:
1. Suscribirse a cambios en `messages` donde `conversation_id` = activa
2. Usar `Supabase.realtime` channel
3. Al recibir INSERT en `messages`, actualizar provider
4. Mostrar nuevos mensajes sin recargar

### Archivos a crear:
- `lib/features/chat/services/realtime_subscription_service.dart`
- Integrar en `messages_provider.dart`

---

## 9. Interfaz Mejorada

**Descripción**: Mejoras de UX y funcionalidades adicionales.

### Pasos:
1. Tema oscuro/claro (ThemeMode en MaterialApp)
2. Soporte para markdown en mensajes de la IA (flutter_markdown)
3. Copiar mensaje al portapapeles
4. Eliminar conversación con confirmación
5. Renombrar título de conversación
6. Indicador "escribiendo..." mientras la IA responde

### Archivos a crear:
- `lib/core/theme/app_theme.dart`
- `lib/features/chat/presentation/widgets/message_actions.dart`
- `lib/features/settings/providers/theme_provider.dart`

---

## Orden de Implementación Sugerido

1. Autenticación OAuth  
2. Base de Datos y Supabase  
3. Interfaz de Chat Básica  
4. Gestión de Conversaciones  
5. Integración con OpenAI  
6. Historial de Mensajes  
7. Guardado Automático  
8. Interfaz Mejorada  
9. Real-time Updates (opcional)
