# Diseño del Esquema de Base de Datos

## Colección de Artículos (Articles)
- **Nombre de la Colección:** `articles`
- **ID del Documento:** ID único generado automáticamente (string)

### Campos

| Nombre del Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `number` | (Opcional) Identificador único numérico, puede usarse para ordenamiento o propósitos heredados. |
| `author` | `string` | El nombre del autor que redactó el artículo. |
| `title` | `string` | El título principal del artículo. |
| `description` | `string` | Un resumen breve o descripción corta del contenido del artículo. |
| `url` | `string` | (Opcional) URL hacia la fuente original del artículo. |
| `urlToImage` | `string` | URL pública de la imagen de portada del artículo. Esta imagen se almacena físicamente en **Supabase Storage**. |
| `publishedAt` | `string` | Cadena de fecha en formato ISO 8601 que representa el momento de publicación. |
| `content` | `string` | El contenido textual completo del artículo. |

## Esquema de Almacenamiento (Nota de Migración)

Originalmente, el proyecto contemplaba el uso de **Firebase Cloud Storage** para el almacenamiento de thumbnails y archivos multimedia. Sin embargo, durante la fase de implementación se detectaron obstáculos persistentes relacionados con la creación de buckets y la configuración de permisos IAM en la consola de Firebase, lo cual impactaba negativamente en el flujo de desarrollo y la estabilidad del entorno de pruebas.

Ante esta situación, y priorizando la entrega de valor ("Maximally Overdeliver"), se tomó la decisión estratégica de migrar la capa de almacenamiento a **Supabase Storage**, manteniendo una arquitectura híbrida eficiente.

### Implementación Actual: Supabase Storage
- **Nombre del Bucket:** `media`
- **Estructura de Ruta:** `articles/{timestamp}_{filename}`
    - Se utiliza un timestamp para garantizar unicidad y evitar colisiones de nombres.
- **Tipo de Contenido:** Imagen (e.g., `image/jpeg`, `image/png`)
- **Control de Acceso:** Lectura pública a través de URLs generadas.

Esta migración garantiza una subida y recuperación de archivos fiable y rápida, manteniendo el resto de la infraestructura del backend (Base de datos Firestore y Autenticación) en Firebase, aprovechando así lo mejor de ambos ecosistemas.

## Notas Adicionales
- El campo `urlToImage` almacena la URL pública directa proporcionada por Supabase tras una subida exitosa.
- No se guarda el archivo binario (base64) en Firestore para optimizar el rendimiento de lectura y reducir costos de ancho de banda.

