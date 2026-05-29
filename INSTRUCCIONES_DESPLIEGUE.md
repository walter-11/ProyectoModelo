# Guía de Despliegue en Render e Inserción de Datos

Este documento explica paso a paso cómo se configuró y desplegó el backend de **ProyectoModelo** en Render usando una base de datos en memoria (H2), cómo se gestionan las tablas y la inserción de datos, y qué correcciones son necesarias en el backend.

---

## 1. Configuración de la Base de Datos H2 (En memoria)

Para simplificar el despliegue sin necesidad de configurar y pagar por una base de datos MySQL en la nube, se migró a **H2 Database** (una base de datos relacional que vive en la memoria RAM del servidor).

### A. Modificaciones en el `pom.xml`
Se comentó la dependencia de MySQL y se añadió la de H2:

```xml
<!-- H2 In-Memory Database -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

### B. Modificaciones en `application.properties`
Se configuraron las siguientes propiedades para H2:

```properties
# Base de datos H2 en memoria
spring.datasource.url=jdbc:h2:mem:marketdb;DB_CLOSE_DELAY=-1
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# Hibernate: Creación automática de tablas
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Consola de H2 (opcional para depuración local)
spring.h2.console.enabled=true

# Diferir inicialización de datos para que data.sql se ejecute después de crear las tablas
spring.jpa.defer-datasource-initialization=true
```

> [!NOTE]
> **Detalle Técnico Clave (para explicar en tu video):**
> El parámetro `;DB_CLOSE_DELAY=-1` en la URL de H2 es crítico. Por defecto, una base de datos H2 en memoria se borra por completo cuando la última conexión se cierra. Este parámetro le dice a H2 que mantenga la base de datos viva mientras el servidor Spring Boot esté ejecutándose.

---

## 2. Creación de Tablas e Inserción de Datos Automática

### ¿Cómo se crean las tablas?
Gracias a la propiedad `spring.jpa.hibernate.ddl-auto=update`, **Hibernate** analiza las clases anotadas con `@Entity` (como `Producto` y `Categoria`) y genera de manera automática las sentencias SQL `CREATE TABLE` en H2 al iniciar la aplicación. No tienes que escribir código SQL manual para crear las tablas.

### ¿Cómo se insertan datos de prueba automáticamente?
Para que el frontend en Angular muestre productos inmediatamente al desplegarse (en lugar de una pantalla vacía), creamos un archivo llamado `data.sql` en la carpeta `src/main/resources/`.

Spring Boot detecta este archivo y ejecuta los `INSERT` automáticamente en el arranque, pero únicamente **después** de que Hibernate haya creado las tablas (gracias a `spring.jpa.defer-datasource-initialization=true`).

---

## 3. Lo que se corrigió en tu Backend (Inconsistencia de Tipos)

> [!TIP]
> **Corrección de Tipos en Producto (¡Ya corregido en el código!):**
> Originalmente, en tu clase `Producto.java` (Entidad JPA), el campo `idProducto` estaba declarado como `String`:
> ```java
> private String idProducto;
> ```
> Sin embargo:
> 1. En `Product.java` (Dominio) estaba como `int productId`.
> 2. En `ProductoCrudRepository.java` se extiende `CrudRepository<Producto, Integer>`, indicando que la llave primaria de la entidad es un entero (`Integer`).
> 
> **Estado:** **Ya fue corregido** en este espacio de trabajo (se cambió el tipo a `Integer` en `Producto.java` junto con sus getters/setters). Esto solucionó el error de H2 y MySQL al crear la tabla e insertar los datos. Puedes usar esto en tu video como explicación de "Troubleshooting" o resolución de problemas.

---

## 4. Paso a Paso para Desplegar en Render

Render es una plataforma excelente para desplegar aplicaciones Spring Boot de forma gratuita. Sigue estos pasos para subir tu backend:

### Paso 1: Preparar tu código
1. Asegúrate de tener tu proyecto en un repositorio de **GitHub** (público o privado).
2. Modifica el puerto de tu servidor en `application.properties` para que tome el puerto dinámico de Render. Cambia `server.port=80` por:
   ```properties
   server.port=${PORT:8080}
   ```

### Paso 2: Crear el servicio en Render
1. Inicia sesión en [Render.com](https://render.com/).
2. Haz clic en **New +** y selecciona **Web Service**.
3. Conecta tu cuenta de GitHub y selecciona el repositorio de tu backend (`ProyectoModelo`).

### Paso 3: Configurar el despliegue
En la pantalla de configuración de Render, rellena los siguientes campos:

*   **Name:** `proyecto-modelo-backend` (o el nombre que prefieras).
*   **Region:** Selecciona la más cercana (ej. *Oregon* o *Ohio*).
*   **Branch:** `main` (o la rama donde esté tu código).
*   **Language:** Selecciona **Docker** (esto le indica a Render que use el archivo `Dockerfile` que creamos en la raíz del proyecto).
*   **Instance Type:** `Free` (Gratuito).

### ¿Cómo funciona el Dockerfile que agregamos? (Para tu video 💡)
El `Dockerfile` utiliza una técnica llamada **Multi-stage build** (Construcción en varias etapas) para optimizar la imagen resultante:
1.  **Etapa 1 (build):** Usa una imagen de `maven` con Java 21 para compilar el proyecto (`mvn clean package -DskipTests`) y empaquetar el archivo `.jar`.
2.  **Etapa 2 (final):** Usa una imagen ligera de Java (`eclipse-temurin:21-jre`), copia únicamente el archivo `.jar` generado en la etapa anterior y lo ejecuta. Esto hace que la imagen final desplegada en Render sea extremadamente ligera y rápida de arrancar.

### Paso 4: Desplegar
Haz clic en **Create Web Service**. Render detectará el `Dockerfile`, compilará la imagen de Docker y la arrancará en un contenedor. Al terminar, te dará una URL pública (ej. `https://proyecto-modelo-backend.onrender.com`).

---

## 5. Integración y Despliegue de Angular en Vercel

Tu frontend de Angular está listo para ser desplegado en **Vercel** y conectarse con el backend en Render.

### Paso 1: Configurar la URL de Producción en Angular
Antes de subir el frontend a Vercel, debes actualizar la URL del backend en tu servicio de Angular:
1. Abre el archivo [product.service.ts](file:///c:/Users/user/Documents/CICLO7/WEB%20INTEGRADO/Proyecto%20a%20desplegar/ProyectoModelo_semana8/Frontend-proyectomodelo/src/app/services/product.service.ts).
2. Modifica la variable `apiUrl` reemplazando la URL local por la URL pública que te dio Render:
   ```typescript
   // En desarrollo local (actual):
   // private apiUrl = 'http://localhost:8080/market/api/products';
   
   // Para producción (Render):
   private apiUrl = 'https://tu-proyecto-backend.onrender.com/market/api/products';
   ```

### Paso 2: Configuración para el enrutamiento (`vercel.json`)
El proyecto frontend ya incluye un archivo [vercel.json](file:///c:/Users/user/Documents/CICLO7/WEB%20INTEGRADO/Proyecto%20a%20desplegar/ProyectoModelo_semana8/Frontend-proyectomodelo/vercel.json) en su raíz. Este archivo es necesario para que el enrutamiento de Angular (como ir a `/home` o `/products`) funcione correctamente en producción sin lanzar errores 404:
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### Paso 3: Desplegar en Vercel
1. Ve al panel de [Vercel.com](https://vercel.com/) e inicia sesión.
2. Haz clic en **Add New** > **Project**.
3. Selecciona tu repositorio de GitHub.
4. Vercel detectará automáticamente que es un proyecto de Angular. Deja la configuración por defecto y haz clic en **Deploy**.
5. Vercel compilará tu aplicación y te dará una URL pública (ej. `https://proyecto-modelo-frontend.vercel.app`).

---

## 6. Estado Actual del Proyecto (Listo para pruebas locales)

Actualmente, ambos proyectos están configurados para comunicarse de manera local de inmediato:

*   **Backend (Spring Boot):** Está corriendo localmente en el puerto **`8080`** con base de datos H2 y datos pre-cargados (`data.sql`). Su documentación interactiva Swagger está accesible en:
    👉 `http://localhost:8080/market/api/swagger-ui/index.html`
*   **Frontend (Angular):** Está modificado para hacer peticiones a `http://localhost:8080/market/api/products` (a través de `product.service.ts`). Está ejecutándose con `npx ng serve`.
    👉 Puedes acceder a él de forma local para interactuar con los productos de prueba.

