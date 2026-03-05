# Applicant Showcase Report

https://drive.google.com/file/d/1ZixlFroYkUIAZtJmnZQidu3klIsWtEir/view?usp=drivesdk


## 1 Introducción

Soy Nikolas Martínez, un joven de 17 años apasionado por la tecnología y con una gran motivación por crecer en el mundo del desarrollo de software. Desde hace aproximadamente tres años he venido explorando el campo de la programación, un área que despertó mi curiosidad desde muy temprano y que con el tiempo se ha convertido en una de mis principales pasiones.

A lo largo de este proceso de aprendizaje he desarrollado conocimientos en tecnologías como Java, HTML, CSS, JavaScript y SQL, además de contar con experiencia inicial trabajando con Flutter para el desarrollo de aplicaciones. Durante este tiempo he buscado mejorar constantemente mis habilidades, aprender nuevas herramientas y aplicar buenas prácticas de programación en los proyectos que realizo.

Mi objetivo es seguir creciendo como desarrollador, enfrentar nuevos desafíos y continuar ampliando mis conocimientos en el desarrollo de software.

## 2 Learning Process

En este proyecto, mi curva de aprendizaje fue intensa pero muy gratificante. Pasé de conceptos teóricos a una implementación robusta.

**Qué no sabía:**

*   **Clean Architecture:** Entendía el concepto general, pero no sabía cómo conectar las capas (Data, Domain, Presentation) usando inyección de dependencias con GetIt para que realmente quedaran desacopladas.
*   **BLoC:** No tenía experiencia manejando flujos de eventos y estados complejos. Solía usar setState para todo, lo que ensuciaba el código.
*   **Firebase Storage & Firestore:** No sabía cómo coordinar la subida de un archivo binario (imagen) y luego usar esa URL resultante para crear un registro en base de datos de manera atómica.

**Cómo lo aprendí:**

*   Investigué a fondo el patrón de Inversión de Control, entendiendo que la capa de Domain define las reglas y la capa de Data las obedece.
*   Para BLoC, practiqué separando estrictamente la lógica (el bloc) de la vista (los widgets), obligándome a no tener lógica de negocio dentro de los archivos de UI.

**Qué fue difícil:**

*   Entender dónde colocar la lógica de transformación de datos (¿en el BLoC o en el Repositorio?).
*   Manejar las excepciones de Firebase y transformarlas en errores legibles para el usuario en la capa de presentación.

**Cómo lo resolví:**

*   Establecí una regla estricta: Los Repositories manejan los datos y errores crudos (try-catch), los Use Cases encapsulan la lógica de negocio pura, y los BLoCs solo mapean resultados a estados de la UI.

## 3 Architecture Overview

Estructuré el proyecto siguiendo estrictamente Clean Architecture para garantizar escalabilidad y mantenibilidad.

**Separación en capas:**

1.  **Presentation (lib/features/.../presentation):** Contiene los Widgets y los BLoCs. Aquí solo vive la lógica visual y de estado.
2.  **Domain (lib/features/.../domain):** Es el núcleo de la aplicación. Contiene las Entities (modelos puros) y los Use Cases (contratos de lo que la app puede hacer). No tiene dependencias externas (ni de Flutter, ni de bases de datos).
3.  **Data (lib/features/.../data):** Implementación de los repositorios. Aquí están los Models (que extienden de Entities y saben convertirse a JSON) y los Data Sources (conexión con Firebase/APIs).

**Flujo de dependencias:**

*   La UI conoce al BLoC.
*   El BLoC conoce al UseCase (Domain).
*   El UseCase conoce a la interfaz del Repository (Domain).
*   La implementación del Repository (Data) es inyectada mediante GetIt.
*   **Clave:** La capa de Domain no sabe nada de Data ni de Presentation.

**Organización de carpetas:**

Organicé el código por Features (features/daily_news, features/upload_article), lo que hace que el proyecto sea modular. Si quiero borrar la funcionalidad de subir artículos, solo borro esa carpeta y no rompo el resto de la app.

## 4 Backend – Schema Design

Diseñé un esquema NoSQL en Cloud Firestore optimizado para lectura rápida.

**Cómo diseñé el schema:**

Creé una colección principal llamada articles. Cada documento representa una noticia completa.

**Qué campos agregaste:**

*   `author` (String): Autor de la nota.
*   `title` (String): Título principal.
*   `description` (String): Resumen para el feed.
*   `content` (String): Contenido completo.
*   `urlToImage` (String): URL pública de la imagen.
*   `publishedAt` (String): Fecha ISO 8601 para ordenamiento.

**Decisiones técnicas:**

*   **Separación Storage/Database:** Guardar imágenes en base de datos (Base64) es una mala práctica porque infla el tamaño del documento y hace las consultas lentas y costosas. Por eso, uso Firebase Storage para el archivo físico (media/articles/{filename}) y guardo solo la referencia (url) en Firestore.
*   **ThumbnailURL:** Se obtiene dinámicamente tras la subida exitosa de la imagen al Storage antes de crear el documento en Firestore.

## 5 Backend – Firestore Rules

No dejé la base de datos abierta. Implementé reglas de seguridad (firestore.rules) para validar la integridad de los datos en el servidor.

**Validaciones implementaste:**

*   Creé una función auxiliar isValidArticle(data) en las reglas.
*   **Validación de tipos:** Aseguro que title, description, etc., sean siempre string.
*   **Campos obligatorios:** Un artículo no puede crearse si le falta el título, el autor o la imagen (data.keys().hasAll([...])).
*   **Longitud:** Valido que los campos no estén vacíos (size() > 0).

**Integridad de datos:**

Esto previene que un cliente malicioso o un error en el código inserte "artículos basura" o incompletos que rompan la aplicación móvil al intentar leerlos.

## 6 Business Layer (Domain)

Esta capa es la "verdad" de mi aplicación.

**Diseño de Use Cases:**

Creé casos de uso específicos como UploadArticleUseCase. Cada clase tiene una única responsabilidad (principio SRP).
*   Ejemplo: UploadArticleUseCase recibe un ArticleInput, y su único trabajo es llamar al repositorio. No sabe si los datos van a Firebase o a una API REST.

**Desacoplamiento:**

Gracias a esto, si mañana cambiamos Firebase por un servidor SQL, no tengo que tocar ni una línea de la UI. Solo cambio la implementación en la capa de Data. La UI solo llama a "Subir Artículo" y no le importa cómo sucede.

## 7 Presentation Layer (BLoC / Cubits)

Utilicé BLoC para una gestión de estado predecible en UploadArticleBloc.

**Estados manejados:**

*   `UploadArticleInitial`: Estado virgen del formulario.
*   `UploadArticleLoading`: Cuando se presiona enviar. Bloquea la UI y muestra un spinner.
*   `UploadArticleSuccess`: Dispara un feedback positivo (SnackBar) y navega hacia atrás.
*   `UploadArticleError`: Captura fallos y muestra el mensaje de error sin borrar lo que el usuario escribió.

**Lógica vs UI:**

La vista (UploadArticlePage) es totalmente pasiva. No decide cuándo navegar ni cuándo mostrar errores; solo reacciona a los estados que emite el BLoC. Usé BlocConsumer para separar la reconstrucción de la UI (builder) de los efectos secundarios como mostrar alertas (listener).

## 8 Data Layer

Aquí ocurre la magia de la conexión real.

**Conexión con Firebase:**

Implementé UploadArticleRemoteDataSourceImpl.

**Manejo de subida de imágenes:**

Es un proceso en dos pasos que orquesté cuidadosamente:

1.  **Storage:** Primero subo la imagen a Firebase Storage (putFile).
2.  **Obtención de URL:** Espero la respuesta (await) y obtengo la downloadURL.
3.  **Firestore:** Con esa URL y los datos del formulario, creo el documento en Firestore.

**Manejo de errores:**

Envuelvo estas llamadas en bloques try-catch. Si falla la subida de la imagen, ni siquiera intento crear el registro en base de datos, manteniendo la consistencia. Lanzo excepciones personalizadas que luego el BLoC captura.

## 9 Challenges

No todo fue fácil, enfrenté varios retos técnicos.

**Problemas y Soluciones:**

*   **Gestión de Asincronía:** Al principio, intentaba guardar el artículo antes de tener la URL de la imagen. Tuve que refactorizar para usar await correctamente y asegurar la secuencialidad.
*   **Contexto de Inyección:** Configurar GetIt fue complejo al principio, especialmente registrar los BLoCs como "Factory" (uno nuevo por vista) y los Repositorios como "LazySingleton" (uno para toda la app). Cometí el error de registrar todo como Singleton y el estado se quedaba "pegado". Lo corregí entendiendo el ciclo de vida de cada objeto.

## 10 Overdelivery

Para superar las expectativas (Symmetry), fui más allá de los requisitos básicos:

*   **Image Picker Integrado:** Implementé la funcionalidad para seleccionar imágenes desde la galería del dispositivo, con previsualización inmediata en la UI antes de subirla.
*   **Validación de Formulario:** Antes de molestar al backend, valido en el cliente que todos los campos estén llenos, mejorando la UX y ahorrando llamadas innecesarias.
*   **Feedback Visual:** Agregué SnackBars para confirmar el éxito o avisar del error, algo vital para que el usuario sepa qué está pasando.
*   **Diseño Limpio:** Usé un AppTheme centralizado para mantener consistencia en tipografías y colores en toda la app.
*   **Arquitectura Escalable:** Dejé preparada la estructura (core, config) para que el proyecto pueda crecer a cientos de features sin volverse un espagueti.

## 11 Future Improvements

Si tuviera más tiempo para seguir iterando sobre este producto, mi objetivo sería evolucionarlo desde un MVP funcional hacia una Plataforma Inteligente de Periodismo y Utilidad Pública, integrando herramientas avanzadas para periodistas, lectores y comunidades.

A continuación detallo las principales mejoras que implementaría.

**1. Testing y calidad del software**

Para fortalecer la estabilidad del sistema implementaría:

*   Unit Testing para los BLoCs y UseCases
*   Tests de integración para flujos críticos como autenticación y publicación de artículos

La estructura del proyecto ya está preparada con la carpeta test/, lo que facilitaría implementar pruebas automatizadas.
Esto permitiría: detectar errores tempranamente, mejorar la confiabilidad del sistema y facilitar futuras refactorizaciones.

**2. Modo offline y persistencia local**

Implementaría un modo offline completo utilizando floor, que ya está incluido en las dependencias del proyecto.
Esto permitiría:

*   guardar borradores de artículos sin conexión
*   leer contenido previamente descargado
*   sincronizar automáticamente cuando la conexión se restablezca

Esta funcionalidad es especialmente útil para periodistas que trabajan en movilidad o con conexión inestable.

**3. Seguridad y autenticación avanzada**

Para mejorar la seguridad del sistema implementaría:

*   Roles de usuario (Admin, Periodista, Lector) en Firestore Rules
*   Autenticación de dos factores (2FA)
*   Gestión de dispositivos conectados
*   Cambio de contraseña y panel de seguridad

También integraría:

*   Sign in with Apple, importante para el ecosistema iOS
*   Multi-cuenta (Account Switcher) para alternar entre perfiles personales y profesionales sin cerrar sesión.

**4. Optimización de imágenes**

Para mejorar el rendimiento y reducir costos de almacenamiento implementaría:

*   compresión automática de imágenes antes de subirlas
*   redimensionamiento inteligente para thumbnails
*   optimización para conexiones móviles

Esto reduciría: consumo de datos, tiempos de carga y costos de almacenamiento en la nube.

**5. Búsqueda avanzada y filtrado contextual**

Ampliaría el motor de búsqueda para incluir filtros más granulares como:

*   idioma
*   ubicación geográfica (noticias locales vs globales)
*   rango horario o fecha exacta

También aplicaría estos metadatos durante la creación de noticias, permitiendo que los periodistas etiqueten sus artículos con información contextual como: ciudad o país, hora del evento, categoría temática.
Esto permitiría a los usuarios encontrar información relevante de forma más precisa.

**6. Herramientas de productividad y lectura activa**

Para mejorar la experiencia del lector implementaría:
**Subrayador de texto (Highlighter)**

Permitiría a los usuarios:
*   resaltar fragmentos importantes
*   guardar citas clave
*   compartir partes específicas de un artículo

Esto transformaría la app de un simple lector de noticias en una herramienta útil para estudio, investigación o análisis.

**7. Ecosistema social y networking**

Para fomentar comunidad e interacción implementaría:

**Sistema de seguimiento (Social Graph)**
Los usuarios podrían seguir periodistas o creadores y recibir notificaciones cuando publiquen contenido nuevo. Esto fomentaría comunidades alrededor de temas específicos y aumentaría el engagement.

**Chat privado seguro (P2P)**
Un sistema de mensajería permitiría crear conexiones directas entre usuarios.
Casos de uso:
*   contacto entre reclutadores y candidatos en noticias de empleo
*   comunicación con especialistas médicos tras leer un artículo de salud
*   contacto entre fuentes y periodistas de forma confidencial

Este tipo de networking transformaría las noticias en oportunidades reales de conexión.

**8. Asistente de Inteligencia Artificial integrado**

Una mejora estratégica sería integrar un asistente basado en LLMs, similar a un chatbot tipo Notion.

**Copiloto de escritura para periodistas**
El asistente podría: generar títulos atractivos, sugerir mejoras de estilo, resumir fuentes y ayudar en la redacción de artículos.

**Búsqueda conversacional para lectores**
Los usuarios podrían hacer preguntas en lenguaje natural como: "¿Qué pasó con las elecciones locales esta semana?"
El sistema respondería con: un resumen contextual y enlaces a artículos relevantes. Esto mejoraría la accesibilidad a la información.

**9. Dashboard de analíticas personales**

Implementaría un panel de métricas para entender mejor el impacto del contenido.
*   **Para lectores:** hábitos de lectura, temas favoritos, tiempo semanal de consumo de noticias.
*   **Para periodistas:** retención de lectores, mapas de calor de lectura, demografía de la audiencia, rendimiento de artículos.

Esto permitiría optimizar contenido basándose en datos reales.

**10. Internacionalización (i18n)**

Para convertir la app en una plataforma global implementaría:
*   soporte multilingüe nativo (español, inglés, portugués)
*   cambio de idioma en tiempo real sin reiniciar la aplicación

También integraría traducción automática de artículos, permitiendo a los usuarios leer noticias extranjeras en su idioma.

**Conclusión**

Estas mejoras no son simplemente nuevas funcionalidades, sino evoluciones estratégicas del producto.
Con estas implementaciones, la aplicación podría transformarse de un MVP de noticias a:
*   una plataforma social de periodismo
*   un ecosistema inteligente impulsado por IA
*   y eventualmente una plataforma global de información y networking preparada para competir con aplicaciones modernas del mercado.

## 12 Alignment with Symmetry Core Values

**Truth is King:**

Defendí el uso de Clean Architecture aunque implica escribir más "boilerplate" al inicio. Sabía que la verdad técnica es que sin separación de capas, el proyecto se vuelve inmantenible en semanas. Preferí hacerlo bien desde el día 1.

**Total Accountability:**

Me hice responsable de todo el flujo, desde el píxel en la pantalla hasta el byte en Firebase. Cuando la subida de imágenes fallaba, no culpé a la librería; depuré mi código hasta entender que faltaban permisos en las reglas de Storage y lo arreglé.

**Maximally Overdeliver:**

No solo entregué una app que "funciona". Entregué una base de código profesional, modular y lista para un equipo de desarrollo real, con validaciones de seguridad en el backend que nadie pidió explícitamente pero que son necesarias para un producto real.


