# Applicant Showcase Report

Video de demostración de funcionalidad: https://drive.google.com/file/d/1ZixlFroYkUIAZtJmnZQidu3klIsWtEir/view?usp=drivesdk


## 1 Introducción

Soy Nikolas Martínez, un joven de 17 años apasionado por la tecnología y con una gran motivación por crecer en el mundo del desarrollo de software. Desde hace aproximadamente tres años he venido explorando el campo de la programación, un área que despertó mi curiosidad desde muy temprano y que con el tiempo se ha convertido en una de mis principales pasiones.

A lo largo de este proceso de aprendizaje he desarrollado conocimientos en tecnologías como Java, HTML, CSS, JavaScript y SQL, además de contar con experiencia trabajando con Flutter, Firebase, Supabase y Agora para el desarrollo de aplicaciones. Durante este tiempo he buscado mejorar constantemente mis habilidades, aprender nuevas herramientas y aplicar buenas prácticas de programación en los proyectos que realizo.

Mi objetivo es seguir creciendo como desarrollador, enfrentar nuevos desafíos y continuar ampliando mis conocimientos en el desarrollo de software.

## 2 Learning Process

En este proyecto, mi curva de aprendizaje fue intensa pero muy gratificante. Pasé de conceptos teóricos a una implementación robusta.

**Qué no sabía:**

*   **Clean Architecture:** Entendía el concepto general, pero no sabía cómo conectar las capas (Data, Domain, Presentation) usando inyección de dependencias con GetIt para que realmente quedaran desacopladas.
*   **BLoC:** No tenía experiencia manejando flujos de eventos y estados complejos. Solía usar setState para todo, lo que ensuciaba el código.
*   **Firebase Storage & Firestore:** No sabía cómo coordinar la subida de un archivo binario (imagen) y luego usar esa URL resultante para crear un registro en base de datos de manera atómica.
*   **Supabase:** No había trabajado nunca con Supabase. No entendía cómo funcionaban sus tablas relacionales, su sistema de autenticación, ni cómo integrar Supabase con un proyecto Flutter que ya usaba Firebase. Tuve que aprender desde cero cómo configurar el cliente, manejar las queries y combinar ambos backends sin que se pisaran.
*   **Agora (Live Streaming):** No tenía idea de cómo funcionaba un servicio de streaming en tiempo real. No sabía qué era un canal de Agora, cómo se generaban los tokens, ni cómo manejar el ciclo de vida de una transmisión en vivo (iniciar, unirse, salir, manejar desconexiones). Todo el concepto de video en tiempo real era completamente nuevo para mí.
*   **Floor (Persistencia local):** No había trabajado con ORMs en Flutter. No entendía cómo Floor generaba código a partir de anotaciones, ni cómo diseñar las entidades locales para que fueran compatibles con los modelos remotos de Firebase y Supabase.
*   **Scroll infinito con PageView:** No sabía cómo implementar un sistema de scroll vertical tipo TikTok/Tinder en Flutter. Desconocía cómo manejar la paginación, la precarga de contenido y la gestión de memoria para que la experiencia fuera fluida sin consumir recursos excesivos.

**Cómo lo aprendí:**

*   Investigué a fondo el patrón de Inversión de Control, entendiendo que la capa de Domain define las reglas y la capa de Data las obedece.
*   Para BLoC, practiqué separando estrictamente la lógica (el bloc) de la vista (los widgets), obligándome a no tener lógica de negocio dentro de los archivos de UI.
*   Para Supabase, leí la documentación oficial y experimenté conectando tablas, haciendo queries con filtros y manejando las respuestas asíncronas. Aprendí a usar el cliente de Supabase en Flutter y a diseñar las tablas pensando en cómo se consumirían desde la app.
*   Para Agora, estudié su SDK de Flutter, entendí el flujo de creación de canales y tokens, y practiqué construyendo un prototipo funcional de live streaming antes de integrarlo en la arquitectura principal del proyecto.

**Qué fue difícil:**

*   Entender dónde colocar la lógica de transformación de datos (¿en el BLoC o en el Repositorio?).
*   Manejar las excepciones de Firebase y transformarlas en errores legibles para el usuario en la capa de presentación.
*   Integrar Agora con la arquitectura Clean del proyecto. El SDK de Agora maneja su propio estado interno (conexión al canal, estado del video, usuarios conectados), y encajar eso dentro del patrón BLoC sin romper la separación de capas fue un reto importante.
*   Combinar Supabase y Firebase en el mismo proyecto sin generar conflictos. Tuve que definir claramente qué responsabilidad tenía cada backend y asegurarme de que los data sources estuvieran bien separados en la capa de Data.

**Cómo lo resolví:**

*   Establecí una regla estricta: Los Repositories manejan los datos y errores crudos (try-catch), los Use Cases encapsulan la lógica de negocio pura, y los BLoCs solo mapean resultados a estados de la UI.
*   Para Agora, creé un data source dedicado que encapsula toda la lógica del SDK (inicialización del engine, join/leave de canales, manejo de eventos de streaming) y expone solo los datos que el BLoC necesita. Así, la capa de presentación no sabe nada de Agora directamente.
*   Para Supabase, seguí el mismo patrón: un data source específico que maneja las queries y la conexión, y un repositorio que abstrae los detalles. Si mañana cambio Supabase por otro servicio, solo toco la capa de Data.

## 3 Architecture Overview

Estructuré el proyecto siguiendo estrictamente Clean Architecture para garantizar escalabilidad y mantenibilidad.

**Separación en capas:**

1.  **Presentation (lib/features/.../presentation):** Contiene los Widgets y los BLoCs. Aquí solo vive la lógica visual y de estado.
2.  **Domain (lib/features/.../domain):** Es el núcleo de la aplicación. Contiene las Entities (modelos puros) y los Use Cases (contratos de lo que la app puede hacer). No tiene dependencias externas (ni de Flutter, ni de bases de datos).
3.  **Data (lib/features/.../data):** Implementación de los repositorios. Aquí están los Models (que extienden de Entities y saben convertirse a JSON) y los Data Sources (conexión con Firebase, Supabase y Agora).

**Flujo de dependencias:**

*   La UI conoce al BLoC.
*   El BLoC conoce al UseCase (Domain).
*   El UseCase conoce a la interfaz del Repository (Domain).
*   La implementación del Repository (Data) es inyectada mediante GetIt.
*   **Clave:** La capa de Domain no sabe nada de Data ni de Presentation.

**Organización de carpetas:**

Organicé el código por Features (features/daily_news, features/upload_article, features/live_news), lo que hace que el proyecto sea modular. Si quiero borrar la funcionalidad de live streaming o de subir artículos, solo borro esa carpeta y no rompo el resto de la app.

## 4 Backend – Schema Design

El proyecto utiliza un backend híbrido: Cloud Firestore para los artículos y Supabase para el sistema de live streaming y datos relacionales.

**Firestore – Artículos:**

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

**Supabase – Live Streaming:**

Para el sistema de noticias en vivo utilicé Supabase como backend relacional. Diseñé tablas para gestionar las sesiones de streaming (canal de Agora, estado de la transmisión, metadata del stream) aprovechando las ventajas de un esquema relacional para queries más complejas y relaciones entre datos que Firestore no maneja de forma natural.

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

Creé casos de uso específicos como UploadArticleUseCase, StartLiveStreamUseCase y JoinLiveStreamUseCase. Cada clase tiene una única responsabilidad (principio SRP).
*   Ejemplo: UploadArticleUseCase recibe un ArticleInput, y su único trabajo es llamar al repositorio. No sabe si los datos van a Firebase o a una API REST.
*   Ejemplo: StartLiveStreamUseCase se encarga de crear la sesión en Supabase e inicializar el canal de Agora. El BLoC solo le dice "iniciar transmisión" y el use case orquesta todo el flujo.

**Desacoplamiento:**

Gracias a esto, si mañana cambiamos Firebase por un servidor SQL o Agora por otro servicio de streaming, no tengo que tocar ni una línea de la UI. Solo cambio la implementación en la capa de Data. La UI solo llama a "Subir Artículo" o "Iniciar Live" y no le importa cómo sucede.

## 7 Presentation Layer (BLoC / Cubits)

Utilicé BLoC para una gestión de estado predecible en todos los flujos de la app.

**Estados manejados (Upload Article):**

*   `UploadArticleInitial`: Estado virgen del formulario.
*   `UploadArticleLoading`: Cuando se presiona enviar. Bloquea la UI y muestra un spinner.
*   `UploadArticleSuccess`: Dispara un feedback positivo (SnackBar) y navega hacia atrás.
*   `UploadArticleError`: Captura fallos y muestra el mensaje de error sin borrar lo que el usuario escribió.

**Lógica vs UI:**

La vista (UploadArticlePage) es totalmente pasiva. No decide cuándo navegar ni cuándo mostrar errores; solo reacciona a los estados que emite el BLoC. Usé BlocConsumer para separar la reconstrucción de la UI (builder) de los efectos secundarios como mostrar alertas (listener).

**Scrolling estilo TikTok/Tinder:**

Uno de los retos más interesantes de la capa de presentación fue implementar un sistema de scroll infinito vertical inspirado en TikTok y Tinder. La idea era que el usuario pudiera consumir noticias haciendo swipe, con cada artículo ocupando la pantalla completa y transiciones fluidas entre ellos. Para lograr esto utilicé un PageView con scroll vertical y un controlador personalizado que se encarga de precargar los artículos siguientes antes de que el usuario llegue al final, creando una experiencia de scroll infinito sin interrupciones. El BLoC gestiona la paginación: cuando el usuario se acerca al final de la lista cargada, se dispara automáticamente una petición para traer más artículos, y la UI se actualiza sin que el usuario perciba ningún corte. Ajustar la física del scroll, las animaciones de transición y la precarga de imágenes para que todo se sintiera natural y rápido fue un proceso iterativo que requirió mucha prueba y error.

**Persistencia local (Floor):**

Implementé almacenamiento local usando Floor para cachear artículos y datos de usuario en el dispositivo. Esto permite que la app muestre contenido inmediatamente al abrirse sin esperar a que la red responda, y que los datos del usuario persistan entre sesiones. El local data source actúa como una primera fuente de datos: el BLoC primero carga lo que hay en Floor y luego actualiza con los datos frescos del backend, logrando una experiencia de carga casi instantánea.

## 8 Data Layer

Aquí ocurre la magia de la conexión real con los tres servicios externos: Firebase, Supabase y Agora.

**Conexión con Firebase:**

Implementé UploadArticleRemoteDataSourceImpl.

**Manejo de subida de imágenes:**

Es un proceso en dos pasos que orquesté cuidadosamente:

1.  **Storage:** Primero subo la imagen a Firebase Storage (putFile).
2.  **Obtención de URL:** Espero la respuesta (await) y obtengo la downloadURL.
3.  **Firestore:** Con esa URL y los datos del formulario, creo el documento en Firestore.

**Conexión con Supabase:**

Implementé un data source dedicado para las operaciones de live streaming. Este se encarga de crear y consultar sesiones de transmisión en las tablas de Supabase, manejar el estado del stream y almacenar la metadata de cada sesión en vivo.

**Conexión con Agora:**

Creé un data source que encapsula el SDK de Agora para el manejo de video en tiempo real. Este gestiona la inicialización del RtcEngine, la conexión y desconexión de canales, el manejo de eventos del stream (usuarios entrando/saliendo, calidad de conexión) y la configuración de video. Toda esta complejidad queda oculta detrás de una interfaz limpia que el repositorio consume.

**Persistencia local con Floor:**

Implementé un local data source usando Floor (ORM basado en SQLite) para almacenar artículos y datos de usuario en el dispositivo. Esto permite que la app funcione con datos cacheados al abrirse, sin depender de una conexión de red inmediata. Los repositorios coordinan ambas fuentes: primero consultan Floor para mostrar datos al instante, y luego sincronizan con el backend remoto (Firebase/Supabase) para actualizar la información.

**Manejo de errores:**

Envuelvo estas llamadas en bloques try-catch. Si falla la subida de la imagen, ni siquiera intento crear el registro en base de datos, manteniendo la consistencia. Para el live streaming, si falla la conexión con Agora o con Supabase, el error se propaga de forma controlada al BLoC para informar al usuario sin crashear la app. Lanzo excepciones personalizadas que luego el BLoC captura.

## 9 Challenges

No todo fue fácil, enfrenté varios retos técnicos.

**Problemas y Soluciones:**

*   **Gestión de Asincronía:** Al principio, intentaba guardar el artículo antes de tener la URL de la imagen. Tuve que refactorizar para usar await correctamente y asegurar la secuencialidad.
*   **Contexto de Inyección:** Configurar GetIt fue complejo al principio, especialmente registrar los BLoCs como "Factory" (uno nuevo por vista) y los Repositorios como "LazySingleton" (uno para toda la app). Cometí el error de registrar todo como Singleton y el estado se quedaba "pegado". Lo corregí entendiendo el ciclo de vida de cada objeto.
*   **Integración de Agora desde cero:** Nunca había trabajado con video en tiempo real. El SDK de Agora tiene su propio ciclo de vida y manejo de estado que no encaja naturalmente con BLoC. Tuve que diseñar un wrapper que tradujera los callbacks de Agora (onUserJoined, onUserOffline, onConnectionStateChanged) a un stream de datos que el BLoC pudiera consumir de forma reactiva, manteniendo la separación de capas.
*   **Supabase + Firebase en el mismo proyecto:** Coordinar dos backends fue un reto inesperado. Tuve que asegurarme de que cada servicio tuviera su propio data source bien aislado y que las dependencias estuvieran correctamente registradas en GetIt sin conflictos. También tuve que aprender la sintaxis de queries de Supabase desde cero, que es muy diferente a las consultas de Firestore.
*   **Manejo de estado del Live Stream:** Una transmisión en vivo tiene muchos estados posibles (conectando, en vivo, reconectando, desconectado, error) y transiciones complejas entre ellos. Diseñar el BLoC para manejar todas estas transiciones de forma predecible y sin dejar recursos abiertos (como el engine de Agora) fue uno de los retos más complejos del proyecto.
*   **Scroll infinito estilo TikTok/Tinder:** Lograr que el PageView vertical se sintiera fluido y natural fue más difícil de lo que esperaba. Los problemas principales fueron: la precarga de contenido (si no precargas, el usuario ve pantallas en blanco al hacer swipe rápido), la gestión de memoria (mantener demasiados artículos en memoria crashea la app), y la paginación coordinada con el BLoC para pedir más datos antes de que el usuario llegue al final. Fue un proceso de prueba y error constante hasta encontrar el balance correcto entre rendimiento y fluidez.
*   **Persistencia local con Floor:** Integrar Floor como caché local añadió una capa de complejidad al flujo de datos. El reto fue coordinar correctamente cuándo leer de la base local y cuándo del backend remoto, y cómo sincronizar ambas fuentes sin mostrar datos inconsistentes al usuario. También tuve que diseñar las entidades de Floor para que fueran compatibles con los modelos de Firestore y Supabase sin duplicar código.

## 10 Overdelivery

Para superar las expectativas (Symmetry), fui más allá de los requisitos básicos:

*   **Sistema de Noticias en Vivo (Live News):** Implementé un sistema completo de live streaming utilizando Agora como servicio de video en tiempo real y Supabase como backend para gestionar las sesiones. Los usuarios pueden iniciar y unirse a transmisiones en vivo directamente desde la app.
*   **Barra de Búsqueda:** Agregué una funcionalidad de búsqueda que permite a los usuarios filtrar y encontrar artículos de forma rápida y eficiente.
*   **Scrolling estilo TikTok/Tinder:** Diseñé una experiencia de navegación basada en swipe vertical, similar a TikTok y Tinder, que hace el consumo de noticias más dinámico e intuitivo para el usuario.
*   **Sistema de Autenticación:** Implementé un flujo completo de autenticación de usuarios con Firebase Auth, incluyendo registro, inicio de sesión y manejo de sesiones.
*   **Sistema Markdown para Artículos:** Integré un editor y renderizador de Markdown que permite a los periodistas crear y editar artículos con formato enriquecido (negritas, cursivas, encabezados, listas, etc.) de forma sencilla y profesional.
*   **Image Picker Integrado:** Implementé la funcionalidad para seleccionar imágenes desde la galería del dispositivo, con previsualización inmediata en la UI antes de subirla.
*   **Validación de Formulario:** Antes de molestar al backend, valido en el cliente que todos los campos estén llenos, mejorando la UX y ahorrando llamadas innecesarias.
*   **Feedback Visual:** Agregué SnackBars para confirmar el éxito o avisar del error, algo vital para que el usuario sepa qué está pasando.
*   **Diseño Limpio:** Usé un AppTheme centralizado para mantener consistencia en tipografías y colores en toda la app.
*   **Persistencia Local con Floor:** Implementé almacenamiento local usando Floor para cachear artículos y datos de usuario, logrando una experiencia de carga instantánea y permitiendo que la app funcione incluso al abrirse sin conexión inmediata.
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

**2. Seguridad y autenticación avanzada**

Para mejorar la seguridad del sistema implementaría:

*   Roles de usuario (Admin, Periodista, Lector) en Firestore Rules
*   Autenticación de dos factores (2FA)
*   Gestión de dispositivos conectados
*   Cambio de contraseña y panel de seguridad

También integraría:

*   Sign in with Apple, importante para el ecosistema iOS
*   Multi-cuenta (Account Switcher) para alternar entre perfiles personales y profesionales sin cerrar sesión.

**3. Búsqueda avanzada y filtrado contextual**

Ampliaría el motor de búsqueda para incluir filtros más granulares como:

*   idioma
*   ubicación geográfica (noticias locales vs globales)
*   rango horario o fecha exacta

También aplicaría estos metadatos durante la creación de noticias, permitiendo que los periodistas etiqueten sus artículos con información contextual como: ciudad o país, hora del evento, categoría temática.
Esto permitiría a los usuarios encontrar información relevante de forma más precisa.

**4. Asistente de Inteligencia Artificial integrado**

Una mejora estratégica sería integrar un asistente basado en LLMs, similar a un chatbot tipo Notion.

**Copiloto de escritura para periodistas**
El asistente podría: generar títulos atractivos, sugerir mejoras de estilo, resumir fuentes y ayudar en la redacción de artículos.

**Búsqueda conversacional para lectores**
Los usuarios podrían hacer preguntas en lenguaje natural como: "¿Qué pasó con las elecciones locales esta semana?"
El sistema respondería con: un resumen contextual y enlaces a artículos relevantes. Esto mejoraría la accesibilidad a la información.

**5. Internacionalización (i18n)**

Para convertir la app en una plataforma global implementaría:
*   soporte multilingüe nativo (español, inglés, portugués)
*   cambio de idioma en tiempo real sin reiniciar la aplicación

También integraría traducción automática de artículos, permitiendo a los usuarios leer noticias extranjeras en su idioma.

**Conclusión**

Estas mejoras no son simplemente nuevas funcionalidades, sino evoluciones estratégicas del producto.
Con estas implementaciones, la aplicación podría transformarse de un MVP de noticias a un ecosistema inteligente impulsado por IA y eventualmente una plataforma global de información preparada para competir con aplicaciones modernas del mercado.

## 12 Alignment with Symmetry Core Values

**Truth is King:**

Defendí el uso de Clean Architecture aunque implica escribir más "boilerplate" al inicio. Sabía que la verdad técnica es que sin separación de capas, el proyecto se vuelve inmantenible en semanas. Preferí hacerlo bien desde el día 1.

**Total Accountability:**

Me hice responsable de todo el flujo, desde el píxel en la pantalla hasta el byte en Firebase y Supabase. Cuando la subida de imágenes fallaba, no culpé a la librería; depuré mi código hasta entender que faltaban permisos en las reglas de Storage y lo arreglé. Cuando Agora no conectaba, investigué hasta entender el flujo de tokens y permisos del SDK en lugar de buscar atajos.

**Maximally Overdeliver:**

No solo entregué una app que "funciona". Entregué una base de código profesional, modular y lista para un equipo de desarrollo real, con un sistema de live streaming con Agora y Supabase, un editor Markdown completo, autenticación, búsqueda, navegación estilo TikTok, y validaciones de seguridad en el backend que nadie pidió explícitamente pero que son necesarias para un producto real.