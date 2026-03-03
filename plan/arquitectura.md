# Arquitectura de la Aplicación ChatGPT-like

## Arquitectura General

```
┌─────────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App       │    │   Supabase      │    │   OpenAI API    │
│   (Web + Mobile)    │◄──►│   Backend       │◄──►│   (GPT-4)       │
│   Riverpod + UI     │    │   Database      │    │                 │
└─────────────────────┘    └─────────────────┘    └─────────────────┘
```

## Componentes Principales

### 1. Frontend (Flutter)
- **Chat Screen**: Pantalla principal de conversación
- **Chat List**: Lista de conversaciones en drawer/sidebar
- **Message Widgets**: Widgets para mensajes del usuario y AI
- **Auth Screens**: Login con OAuth (Google, GitHub, etc.)

### 2. Backend (Supabase)
- **Database**: PostgreSQL con tablas para:
  - `conversations`: Conversaciones del usuario
  - `messages`: Mensajes individuales
  - `users`: Perfiles de usuario
- **Edge Functions**: Para llamadas a OpenAI API (evitar exponer API key)
- **Real-time**: Suscripción a cambios en conversaciones
- **Auth**: OAuth con proveedores externos

### 3. Servicios Externos
- **OpenAI API**: Para generación de respuestas de IA
- **Supabase MCP**: Conexión vía Model Context Protocol

## Flujo de Datos

1. **Autenticación**: Usuario inicia sesión con OAuth → Supabase Auth
2. **Nueva Conversación**: Usuario crea chat → Se guarda en DB
3. **Mensaje**: Usuario envía mensaje → Se guarda + se envía a Edge Function
4. **Respuesta IA**: Edge Function llama OpenAI → Guarda en DB + retorna streaming
5. **Historial**: Conversaciones se cargan desde DB al iniciar

## Patrón de Arquitectura

- **Clean Architecture**: Separación en capas (presentation, domain, data)
- **Riverpod**: State management reactivo
- **Real-time subscriptions**: Supabase Realtime para actualizaciones en vivo
- **Responsive**: Adaptación automática web/mobile

## Plataformas

- **Web**: Flutter Web (Chrome, Safari, Firefox)
- **Mobile**: iOS y Android desde el mismo código base
