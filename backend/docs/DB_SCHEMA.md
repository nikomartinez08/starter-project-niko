# Database Schema

## Articles Collection
- **Collection Name:** `articles`
- **Document ID:** Auto-generated unique ID (string)

### Fields

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `number` | (Optional) Unique identifier, can be used for sorting or legacy purposes. |
| `author` | `string` | The name of the author of the article. |
| `title` | `string` | The title of the article. |
| `description` | `string` | A brief summary or description of the article. |
| `url` | `string` | (Optional) URL to the original article source. |
| `urlToImage` | `string` | URL to the article's thumbnail image. This image is stored in Firebase Cloud Storage under `media/articles/{filename}`. |
| `publishedAt` | `string` | ISO 8601 formatted date string representing when the article was published. |
| `content` | `string` | The full content of the article. |

## Storage Schema

### Articles Media
- **Path:** `media/articles/{filename}`
- **Content Type:** Image (e.g., `image/jpeg`, `image/png`)
- **Access Control:** Public read access for authenticated users (or public depending on requirements).

## Notes
- `urlToImage` should be a valid download URL obtained after uploading the image to Cloud Storage.
