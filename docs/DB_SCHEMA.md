# Database Schema (Diseño del Esquema de Base de Datos)

##  Overview / Resumen General

This project uses a **hybrid multi-database architecture** combining:
- **Local Storage**: SQLite (via Floor ORM)
- **Remote Storage**: Firestore & Supabase
- **File Storage**: Supabase Storage

---

## 1 LOCAL DATABASE (SQLite / Floor)

### AppDatabase Configuration
- **Location**: `frontend/lib/features/daily_news/data/data_sources/local/app_database.dart`
- **Version**: 3
- **Type**: Floor ORM with SQLite

### Tables

####  `article` Table
**Uso**: Almacena artículos descargados localmente para lectura offline

La tabla `article` contiene todos los campos necesarios para almacenar información de artículos obtenidos de APIs externas. Cada artículo tiene un identificador único (`id`) que es la clave primaria. El campo `author` es de tipo texto pero opcional, almacenando el nombre del autor del artículo. El `title` es obligatorio y contiene el título principal del artículo. El campo `description` es opcional y proporciona un resumen breve del contenido. La `url` es opcional y guarda la URL de la fuente original del artículo, útil para artículos que provienen de NewsAPI o GNews. El campo `urlToImage` es opcional y contiene la dirección de la imagen principal del artículo, que puede ser redimensionada por la API proveedora. El `publishedAt` es un timestamp opcional en formato ISO 8601 que indica cuándo fue publicado el artículo. Finalmente, `content` es un campo de texto opcional que almacena el contenido textual completo del artículo.

**DAO Operations**: [ArticleDao](frontend/lib/features/daily_news/data/data_sources/local/DAO/article_dao.dart)
- `insertArticle()` - Add article (REPLACE on conflict)
- `deleteArticle()` - Remove by ID
- `deleteArticleByTitle()` - Remove by title
- `getArticles()` - Retrieve all articles

**Supported APIs**:
- NewsAPI: Returns `urlToImage`
- GNews: Returns `image` (mapped to `urlToImage`)

---

####  `draft` Table
**Uso**: Almacena borradores de artículos creados por el usuario

La tabla `draft` está diseñada para almacenar los borradores de artículos que los usuarios crean pero aún no publican. El campo `id` es un identificador único de auto-incremento que sirve como clave primaria. El campo `author` es opcional y guarda el nombre del autor del borrador. El `title` es opcional y contiene el título que el usuario ha asignado al borrador. El `content` es un campo de texto opcional que almacena el contenido del artículo borrador. El campo `imagePath` es una ruta de archivo local opcional, obtenida del selector de imágenes del dispositivo, que perimite referenciar una imagen guardada localmente en el dispositivo del usuario. El `createdAt` es obligatorio y almacena el timestamp en formato ISO 8601 del momento en que se creó el borrador. El `updatedAt` es también obligatorio y se actualiza cada vez que el borrador se modifica, guardando el timestamp más reciente en formato ISO 8601.

**DAO Operations**: [DraftDao](frontend/lib/features/daily_news/data/data_sources/local/DAO/draft_dao.dart)
- `getDrafts()` - Get all drafts (ordered by `updatedAt DESC`)
- `getDraftById(int id)` - Get specific draft
- `insertDraft()` - Create new draft
- `updateDraft()` - Update existing draft
- `deleteDraftById(int id)` - Delete draft

---

####  `favorite_article` Table
**Uso**: Almacena los artículos marcados como favoritos por el usuario

La tabla `favorite_article` mantiene registro de todos los artículos que un usuario ha marcado como favoritos. El campo `id` es un identificador único de auto-incremento que actúa como clave primaria en la base de datos local. El `externalId` es un campo único y opcional que almacena una referencia al artículo original (puede ser una URL o un identificador externo), permitiendo rastrear qué artículos remotos están marcados como favoritos. Los campos `author`, `title`, `description`, `url`, `urlToImage`, `publishedAt` y `content` son todos opcionales y almacenan los mismos datos que se guardan en la tabla `article`, creando una copia local del artículo marcado como favorito. El campo `publishedAt` es un timestamp en formato ISO 8601 que indica cuándo se publicó el artículo original. El `saved At` es obligatorio y contiene el timestamp en formato ISO 8601 del momento exacto en que el usuario marcó el artículo como favorito.

**DAO Operations**: [FavoriteDao](frontend/lib/features/favorites/data/data_sources/local/favorites_dao.dart)
- `getFavorites()` - Get all favorites
- `getFavoriteByExternalId(String id)` - Get specific favorite by external ID
- `insertFavorite()` - Add to favorites
- `deleteFavorite()` - Remove from favorites
- `deleteFavoriteByExternalId(String id)` - Remove by external ID

---

## 2 FIRESTORE (Remote Database)

### Authentication & User Data
**Provider**: Firebase Authentication
- Supported methods: Email/Password, Google Sign-In, Supabase Auth
- User ID: Firebase UID or Supabase UUID

### Collections

####  `articles` Collection
**Uso**: Artículos subidos por usuarios del sistema

**Document Structure**:
```
articles/{articleId}
├── author (string) - Author name
├── userId (string) - Firebase/Supabase user ID
├── title (string) - Article title
├── description (string) - Short description
├── content (string) - Full article content
├── urlToImage (string) - Public URL from Supabase Storage
├── publishedAt (timestamp) - Publication date/time
└── createdAt (timestamp) - Firestore server timestamp
```

**Indices**: None currently configured in `firestore.indexes.json`

**Security Rules**: [firestore.rules](backend/firestore.rules)
- Articles can be read by authenticated users
- Articles can only be written by their author

---

## 3 SUPABASE (Remote Database)

### Authentication
- **Provider**: Supabase Auth (JWT tokens)
- Supports email/password authentication
- Integration with existing Supabase project

### Tables

####  `profiles` Table
**Uso**: Perfil de usuario con información pública

```sql
CREATE TABLE profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id),
  email             TEXT NOT NULL,
  name              TEXT,
  title             TEXT,
  photo_url         TEXT,
  updated_at        TIMESTAMP WITH TIME ZONE
)
```

**Fields Description**:

El campo `id` es un identificador único de tipo UUID que actúa como clave primaria en la tabla de perfiles. Este ID hace referencia a la tabla `auth.users` del sistema de autenticación de Supabase, vinculando el perfil del usuario con su cuenta autenticada. El campo `email` es obligatorio y almacena la dirección de correo electrónico del usuario. El `name` es un campo opcional que contiene el nombre completo o el nombre para mostrar del usuario en la aplicación. El `title` es también opcional y permite al usuario proporcionar información adicional como un título profesional o una biografía corta. El campo `photo_url` es opcional y almacena una URL pública que apunta a la foto de perfil del usuario, accesible públicamente a través de la red. Finalmente, `updated_at` es un timestamp que registra la última vez que se modificó la información del perfil.

**Used In**: [UserProfileDataEntity](frontend/lib/features/profile/domain/entities/profile_entities.dart)

---

####  `articles` Table (Supabase)
**Uso**: Artículos creados por usuarios (alternativa a Firestore)

```sql
CREATE TABLE articles (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id         UUID NOT NULL REFERENCES profiles(id),
  title             TEXT NOT NULL,
  content           TEXT NOT NULL,
  description       TEXT,
  url_to_image      TEXT,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
```

**Fields Description**:

El campo `id` es un identificador único de tipo UUID que actúa como clave primaria, siendo generado automáticamente mediante la función `uuid_generate_v4()` para garantizar su unicidad. El campo `author_id` es obligatorio y es una clave foránea que referencia el campo `id` de la tabla `profiles`, estableciendo la relación entre el artículo y su autor. El `title` es obligatorio y contiene el título del artículo. El `content` es también obligatorio y almacena el texto completo y completo del artículo. El `description` es un campo opcional que proporciona un resumen breve del contenido del artículo. El campo `url_to_image` es opcional y almacena la dirección URL de la imagen asociada al artículo, almacenada típicamente en el bucket de almacenamiento de Supabase. El `created_at` es un timestamp que se establece automáticamente con la fecha y hora actual cuando se crea el artículo. El `updated_at` es un timestamp que se actualiza automáticamente cada vez que se modifica el artículo, registrando la última actualización.

**Used In**: [UserPostEntity](frontend/lib/features/profile/domain/entities/profile_entities.dart)

---

## 4 FILE STORAGE (Supabase Storage)

### Bucket: `media`
**Uso**: Almacenamiento de imágenes de artículos

**Path Structure**:
```
media/
└── articles/
    ├── {timestamp}_{filename_1}.jpg
    ├── {timestamp}_{filename_2}.png
    └── {timestamp}_{filename_n}.{ext}
```

**Features**:
- **Naming Convention**: `{timestamp}_{filename}` to prevent collisions
- **File Types**: JPEG, PNG, WebP, and other common image formats
- **Access Control**: Public read, authenticated write
- **URL Format**: Generated public URLs after successful upload
- **Related Firestore Field**: `urlToImage` contains public URL

**Supported Formats**: `image/jpeg`, `image/png`, `image/webp`

**Upload Flow**:
1. User selects image via ImagePicker
2. Image uploaded to `media/articles/{timestamp}_{filename}`
3. Public URL returned by Supabase
4. URL stored in Firestore `articles.urlToImage` or local SQLite

---

## 5 DOMAIN ENTITIES & MODELS

### User Management

####  UserEntity / UserModel
**File**: [user_entity.dart](frontend/lib/features/auth/domain/entities/user_entity.dart), [user_model.dart](frontend/lib/features/auth/data/models/user_model.dart)

```dart
class UserEntity {
  final String? id;          // Firebase UID / Supabase UUID
  final String? email;       // User email
  final String? name;        // Display name
}
```

**Serialization Methods**:
- `fromFirebaseUser()` - Convert Firebase User to UserModel
- `fromSupabaseUser()` - Convert Supabase User to UserModel
- `fromJson()` / `toJson()` - JSON conversion

---

### Article Management

####  ArticleEntity / ArticleModel
**File**: [article.dart](frontend/lib/features/daily_news/domain/entities/article.dart), [article.dart](frontend/lib/features/daily_news/data/models/article.dart)

```dart
class ArticleEntity {
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;  // ISO 8601
  final String? content;
}
```

**Sources**:
- NewsAPI: `https://newsapi.org/v2/everything`
- GNews: `https://gnewsapi.io/api/search`
- Both APIs mapped to common ArticleEntity structure
- `image` field (GNews) → `urlToImage` (standardized)

---

####  DraftEntity / DraftModel
**File**: [draft.dart](frontend/lib/features/daily_news/domain/entities/draft.dart), [draft.dart](frontend/lib/features/daily_news/data/models/draft.dart)

```dart
class DraftEntity {
  final int? id;
  final String? author;
  final String? title;
  final String? content;
  final String? imagePath;     // Local device file path
  final String? createdAt;     // ISO 8601
  final String? updatedAt;     // ISO 8601
}
```

---

####  FavoriteArticleEntity / FavoriteArticleModel
**File**: [favorite_article.dart](frontend/lib/features/favorites/domain/entities/favorite_article.dart)

```dart
class FavoriteArticleEntity {
  final int? id;                // Local DB ID
  final String? externalId;     // Remote source ID/URL
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final DateTime? savedAt;       // When favorited
}
```

---

### Profile Management

#### 👤 UserProfileDataEntity
**File**: [profile_entities.dart](frontend/lib/features/profile/domain/entities/profile_entities.dart)

```dart
class UserProfileDataEntity {
  final String uid;              // User ID
  final String name;             // Display name
  final String email;            // Email address
  final String? title;           // Bio/title
  final String? photoUrl;        // Profile photo URL
  final int followersCount;      // (Not yet implemented)
  final int followingCount;      // (Not yet implemented)
  final List<UserPostEntity> posts;  // User's articles
}
```

**Data Source**: Maps from Supabase `profiles` and `articles` tables

---

#### 📄 UserPostEntity
**File**: [profile_entities.dart](frontend/lib/features/profile/domain/entities/profile_entities.dart)

```dart
class UserPostEntity {
  final String id;               // Post ID (UUID)
  final String authorId;         // Author user ID
  final String title;            // Post title
  final String content;          // Post content
  final String? description;     // Description
  final String? urlToImage;      // Image URL
  final DateTime createdAt;      // Creation date
}
```

**Maps to**: Supabase `articles` table

---

### Recommendation Engine

#### 🎯 UserPreferencesEntity / UserPreferencesModel
**File**: [user_preferences.dart](frontend/lib/features/recommendation/domain/entities/user_preferences.dart)

```dart
class UserPreferencesEntity {
  final List<String> likedCategories;      // Preferred content categories
  final List<String> dislikedCategories;   // Disliked content categories
  final Map<String, int> tagScores;        // Category scoring map
}
```

**JSON Serialization**:
```json
{
  "liked_categories": ["technology", "science"],
  "disliked_categories": ["sports"],
  "tag_scores": {"technology": 5, "science": 3}
}
```

---

### Live Streaming

#### 🎥 LiveStreamEntity / LiveStreamModel
**File**: [live_stream_entity.dart](frontend/lib/features/streaming/domain/entities/live_stream_entity.dart), [live_stream_model.dart](frontend/lib/features/streaming/data/models/live_stream_model.dart)

```dart
class LiveStreamEntity {
  final String? id;                // Stream unique ID
  final String? channelName;       // Channel name
  final String? hostId;            // Host user ID
  final String? hostName;          // Host display name
  final String? title;             // Stream title
  final String? thumbnailUrl;      // Thumbnail URL
  final int? viewerCount;          // Current viewers
  final bool? isLive;              // Live status
  final DateTime? startedAt;       // Stream start time
  final DateTime? endedAt;         // Stream end time (null if ongoing)
}
```

**JSON Serialization** (snake_case):
```json
{
  "id": "stream-123",
  "channel_name": "Tech News Daily",
  "host_id": "user-456",
  "host_name": "John Doe",
  "title": "Breaking Tech News",
  "thumbnail_url": "https://...",
  "viewer_count": 1250,
  "is_live": true,
  "started_at": "2026-03-05T14:30:00Z",
  "ended_at": null
}
```

---

### Article Upload

#### 📤 ArticleInput
**File**: [article_input.dart](frontend/lib/features/upload_article/domain/entities/article_input.dart)

```dart
class ArticleInput {
  final String? author;          // Author name
  final String? title;           // Article title
  final String? description;     // Short description
  final String? content;         // Full content
  final String? imagePath;       // Local device path (ImagePicker)
}
```

**Upload Workflow**:
1. Image uploaded to Supabase Storage (`media/articles/{ts}_{filename}`)
2. Public URL obtained from Supabase
3. Article data + image URL sent to Firestore `articles` collection
4. Draft optionally saved to local SQLite `draft` table

---

## 6 RELATIONSHIPS & DATA FLOW

###  Entity Relationship Diagram (Text Format)

```
┌─────────────────────────────────────────────────────┐
│  AUTH LAYER (Firebase / Supabase)                   │
│  ├─ Firebase User ID / Supabase UUID                │
│  └─ Manages authentication                          │
└────────────────┬────────────────────────────────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
┌───▼──────────────────┐   ┌──▼───────────────────┐
│ FIRESTORE            │   │ SUPABASE             │
├──────────────────────┤   ├──────────────────────┤
│ articles/{id}        │   │ profiles             │
│ ├─ author            │   │ └─ id (FK: auth)     │
│ ├─ userId (FK)       │   │    ├─ name          │
│ ├─ title             │   │    ├─ email         │
│ ├─ urlToImage ───────┼───┼──→ photo_url       │
│ ├─ content           │   │                      │
│ └─ publishedAt       │   │ articles            │
└────────────────────┘   │ ├─ id                │
                         │ ├─ author_id (FK)    │
                         │ ├─ title             │
                         │ ├─ url_to_image ─────┼──→ Supabase Storage
                         │ └─ created_at        │    (media bucket)
                         └──────────────────────┘
                                  │
                         ┌────────┴─────────┐
                         │                  │
                    ┌────▼────────┐   ┌────▼────────┐
                    │ LOCAL SQLite │   │ Preferences │
                    ├─────────────┤   └─────────────┘
                    │ article     │
                    │ draft       │   (In-memory/
                    │ favorite_   │    Cloud)
                    │ article     │
                    └─────────────┘
```

###  Data Sync Flow

**Local ↔ Remote Sync**:
1. **Articles**: Downloaded from NewsAPI/GNews → Cached in SQLite `article` table
2. **Drafts**: Created locally in SQLite → Optional sync to Firestore
3. **Favorites**: Stored in SQLite → Can be synced to Supabase (future)
4. **User Preferences**: Stored locally → Synced to cloud for ML recommendations
5. **Profiles**: Fetched from Supabase → Displayed in profile feature

---

## 7 SECURITY RULES & ACCESS CONTROL

### Firestore Security
- Read: Authenticated users only
- Write: Author only (via userId field)
- Delete: Author only

### Supabase RLS (Row Level Security)
- Profiles: Users can read all, update only own
- Articles: Users can read all, create own, update own, delete own

---

## 8 MIGRATION NOTES

### Firebase Storage Migration
Originally Firebase Cloud Storage was planned for image uploads. Due to IAM configuration challenges, the project successfully migrated to **Supabase Storage** while keeping Firestore for metadata and Supabase PostgreSQL as an alternative data layer.

**Current Setup** (Hybrid):
- ✅ Firebase: User authentication + Firestore metadata
- ✅ Supabase: PostgreSQL tables + Storage for images
- ✅ Each service handles its own data

---

## 9 PERFORMANCE CONSIDERATIONS

**Large Content Fields**: Los campos de contenido grande, como el texto completo de los artículos, se desnormalizan en los documentos de la base de datos para permitir lecturas rápidas y eficientes sin necesidad de uniones adicionales. Esto es especialmente importante en aplicaciones móviles donde el rendimiento es crítico.

**Image Optimization**: La optimización de imágenes es manejada directamente por las APIs proveedoras (NewsAPI y GNews). Estas plataformas externas se encargan de redimensionar y optimizar las imágenes según sea necesario, lo que reduce la carga de procesamiento en el backend y del lado del cliente.

**Offline Support**: Para mejorar la experiencia del usuario en contextos de baja conectividad, la aplicación mantiene una caché local en SQLite que almacena artículos descargados recientemente, borradores en progreso y artículos marcados como favoritos. Esto permite a los usuarios acceder al contenido incluso cuando no tienen conexión a internet.

**Real-time Sync**: Actualmente, la sincronización entre dispositivos se implementa mediante modelos de consultas bajo demanda (fetch-on-demand). Esto significa que los datos se actualizan cuando el usuario solicita explícitamente una actualización, en lugar de usar sincronización en tiempo real. Este enfoque es más eficiente en términos de consumo de batería y datos.

**Batch Operations**: Los Objetos de Acceso a Datos (DAOs) soportan operaciones en lotes, permitiendo ejecutar múltiples operaciones de base de datos de manera más eficiente que ejecutarlas una por una.

**Indexing**: Firestore proporciona indexación automática en campos simples, mejorando el rendimiento de consultas comunes. Supabase también indexa automáticamente las claves primarias, aunque se pueden crear índices adicionales en columnas que se consultan frecuentemente para optimizar aún más el rendimiento.

---

```
Last Updated: March 5, 2026
Schema Version: 3.0
```
 