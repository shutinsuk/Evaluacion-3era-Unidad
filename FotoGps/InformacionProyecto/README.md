# README - Proyecto FotoGps

Sistema de gestión de entregas con evidencia fotográfica y geolocalización en tiempo real.

1. DESCRIPCIÓN GENERAL

---

FotoGps es una aplicación para agentes de paquetería que combina:

* Frontend: App Flutter (carpeta "flutterfotogps").
* Backend: API REST con FastAPI (carpeta "api").
* Base de datos: MySQL (script SQL en FlutterFoto/sql.sql y GPS/sql.sql).

Flujo general de uso:

1. El agente inicia sesión con usuario y contraseña.

2. Ve la lista de paquetes asignados.

3. Selecciona un paquete, toma una foto de evidencia y captura su ubicación GPS.

4. Marca el paquete como entregado.

5. Consulta el historial de entregas (mapa + foto).

6. REQUISITOS PREVIOS

---

Software necesario:

Backend:

* Python 3.9 o superior.
* MySQL Server 5.7 o 8.x.

Frontend:

* Flutter SDK (canal stable).
* Un dispositivo o entorno de ejecución:

  * Emulador o dispositivo Android.
  * Windows Desktop.
  * Navegador (Chrome) para Flutter Web.
  * (Opcional) iOS si trabajas en macOS.

Herramientas recomendadas:

* Cliente MySQL (MySQL Workbench, consola, phpMyAdmin, etc.).
* Editor de código (VS Code, PyCharm, Android Studio, etc.).

3. CONFIGURACIÓN DE LA BASE DE DATOS

---

1. Asegúrate de que MySQL esté instalado y ejecutándose.

2. Localiza el script SQL (es el mismo contenido en ambas rutas):

   * FlutterFoto/sql.sql
   * GPS/sql.sql

3. Ejecuta el script en tu servidor MySQL. Puedes usar:

   * MySQL Workbench (abres el archivo y lo ejecutas).
   * Consola de MySQL, por ejemplo:

     mysql -u root -p
     SOURCE ruta/completa/a/FlutterFoto/sql.sql;

4. El script creará:

   * Base de datos: delivery_app
   * Tablas: users, packages, deliveries
   * Usuario de prueba:

     * username: agent1
     * contraseña en texto: 123456
       (En la base solo se almacena el hash; la contraseña en texto es para que la uses en el login).

5. Si tu usuario y contraseña de MySQL no son "root" o cambiaste algo:

   * Abre el archivo api/core/database.py.
   * Ajusta usuario, contraseña, host y nombre de la base según tu entorno (por ejemplo, usuario "root" y contraseña vacía o la que uses normalmente).

6. INSTALACIÓN Y EJECUCIÓN DEL BACKEND (FASTAPI)

---

Ubicación: carpeta "api" dentro del proyecto.

4.1 Crear y activar entorno virtual (ejemplo en Windows):

Desde la raíz del proyecto:

python -m venv api/venv
api\venv\Scripts\activate

En Linux/macOS (ejemplo):

python3 -m venv api/venv
source api/venv/bin/activate

4.2 Instalación de dependencias:

Con el entorno virtual ACTIVO y ubicado en la raíz del proyecto, ejecuta:

pip install -r requirements.txt

El archivo requirements.txt incluye, entre otras:

* fastapi
* uvicorn
* sqlalchemy
* pymysql o mysqlclient
* python-jose[cryptography]
* passlib[bcrypt]
* pydantic
* python-multipart

4.3 Creación de carpeta de uploads:

En la carpeta api, asegúrate de que exista:

api/uploads/

Esta carpeta se usará para guardar las fotos de evidencia. Debe tener permisos de escritura.

4.4 Ejecutar el servidor FastAPI:

Desde la raíz del proyecto (con el entorno virtual activado):

uvicorn api.main:app --reload

Por defecto, la API quedará disponible en:

[http://127.0.0.1:8000](http://127.0.0.1:8000)

Endpoints principales (solo referencia):

* POST /token                → Login (devuelve access_token).
* GET  /packages/assigned   → Listar paquetes asignados al agente autenticado.
* POST /deliveries/         → Registrar entrega con foto y GPS.
* GET  /deliveries/history  → Historial de entregas del agente.
* GET  /uploads/{archivo}   → Acceder a la foto almacenada.

5. INSTALACIÓN Y EJECUCIÓN DEL FRONTEND (FLUTTER)

---

Ubicación: carpeta "flutterfotogps".

5.1 Obtener dependencias de Flutter:

En una terminal nueva, navega a la carpeta:

cd flutterfotogps

Luego ejecuta:

flutter pub get

Esto descargará las dependencias definidas en pubspec.yaml, como:

* http
* image_picker
* geolocator
* flutter_map
* latlong2

5.2 Configurar la URL del backend en ApiService:

Abra el archivo:

flutterfotogps/lib/services/api_service.dart

Dentro de la clase ApiService, localiza la línea donde se define la baseUrl:

static const String baseUrl = '[http://127.0.0.1:8000](http://127.0.0.1:8000)';

Si vas a ejecutar la app en el mismo equipo que el backend y usas:

* Web (Chrome) o Windows → 127.0.0.1 está bien.
* Android en emulador → puede necesitar [http://10.0.2.2:8000](http://10.0.2.2:8000) (si usas emulador de Android Studio).
* Android en dispositivo físico → usa la IP de tu PC en la red, por ejemplo:
  [http://192.168.1.50:8000](http://192.168.1.50:8000)

Guarda los cambios.

5.3 Ejecutar la app Flutter:

Asegúrate de que el backend (FastAPI) esté corriendo.

Luego, en la carpeta flutterfotogps, ejecuta uno de los siguientes comandos:

Para ejecutar en Chrome (Flutter Web):

flutter run -d chrome

Para ejecutar en Windows Desktop:

flutter run -d windows

Para ejecutar en un dispositivo/emulador Android:

flutter devices   (para ver los dispositivos disponibles)
flutter run -d <id_del_dispositivo>

6. INICIO DE SESIÓN Y USO BÁSICO

---

6.1 Credenciales de prueba:

Después de ejecutar el script SQL, tendrás:

Usuario:     agent1
Contraseña:  123456

6.2 Flujo básico dentro de la app:

1. Inicio de sesión:

   * Abre la app Flutter.
   * En la pantalla "Inicio de sesión", ingresa:

     * Usuario: agent1
     * Contraseña: 123456
   * Pulsa el botón "Ingresar".
   * La app enviará la petición de login al endpoint /token.
   * Si todo es correcto, guardará el access_token y te llevará a la pantalla principal.

2. Pantalla principal (Home):

   * Verás el título "Paquetes asignados".
   * La app llamará al endpoint /packages/assigned usando el token en la cabecera Authorization.
   * Se mostrará una lista de paquetes pendientes asignados al usuario.
   * Cada elemento mostrará, por ejemplo:

     * Número de guía (tracking_number).
     * Dirección.
     * Estado (pending, delivered, etc.).
   * Toca un paquete para ir a la pantalla de entrega de ese paquete.

3. Pantalla de entrega (Delivery):

   * Se mostrará la información del paquete seleccionado:

     * Dirección de entrega.
     * Mapa con la ubicación del destino (usando las coordenadas del paquete).
   * Botón "Tomar foto":

     * Se abrirá la cámara o la galería (según plataforma).
     * Al tomar o elegir una foto, aparecerá una vista previa en la pantalla.
   * Botón "Obtener ubicación actual":

     * La app solicitará al dispositivo la posición GPS actual (latitud y longitud).
     * Mostrará los valores en pantalla.
   * Botón "Paquete entregado":

     * La app enviará al backend:

       * ID del paquete.
       * Latitud y longitud reales de entrega.
       * Foto como archivo (multipart/form-data).
     * El backend guardará:

       * Registro en la tabla deliveries.
       * Foto en la carpeta api/uploads/.
       * Actualizará el estado del paquete a delivered.
     * La app puede regresar al Home y/o mostrar un mensaje de éxito.

4. Historial de entregas:

   * Desde la pantalla principal, habrá un botón o icono para acceder al "Historial".
   * La app llamará a /deliveries/history usando el token.
   * Se mostrará una lista de entregas realizadas por el usuario actual.
   * Al tocar una entrega:

     * Se abrirá una pantalla de detalle.
     * Verás un mapa centrado en gps_latitude / gps_longitude (ubicación real de la entrega).
     * Verás la foto de evidencia usando la URL devuelta por la API (por ejemplo, [http://127.0.0.1:8000/uploads/archivo.jpg](http://127.0.0.1:8000/uploads/archivo.jpg)).

5. NOTAS Y PROBLEMAS COMUNES

---

1. Problemas de login:

   * Verifica que el backend esté corriendo en la URL configurada en ApiService.
   * Asegúrate de haber ejecutado el script SQL sin errores.
   * Comprueba que estás usando las credenciales correctas: agent1 / 123456.

2. Problemas de conexión a la API:

   * Revisa que la IP configurada en baseUrl sea accesible desde el dispositivo donde corre Flutter.
   * Si usas emulador Android, puede requerir la IP especial 10.0.2.2 en lugar de 127.0.0.1.

3. Mapa no cargando:

   * flutter_map usa OpenStreetMap y requiere acceso a internet.
   * Verifica que el dispositivo/emulador tenga conexión.

4. Problemas con la cámara o galería:

   * En Web, puede que la cámara requiera HTTPS o permisos especiales; usar "galería" (selección de archivo) suele ser más estable.
   * En Android/iOS, revisa que los permisos de cámara y almacenamiento estén declarados en los archivos de configuración.

5. Fotos no visibles desde la app:

   * Revisa que:

     * La carpeta api/uploads exista y tenga permisos.
     * El servidor FastAPI esté montando correctamente la ruta estática /uploads.
     * La URL devuelta por la API coincida con la baseUrl que estás usando.

6. RESUMEN RÁPIDO DE INSTALACIÓN

---

1. Instalar requisitos: Python 3, MySQL, Flutter, herramientas de desarrollo.
2. Ejecutar el script SQL (FlutterFoto/sql.sql o GPS/sql.sql) en MySQL.
3. Configurar conexión a la base de datos en api/core/database.py si es necesario.
4. Crear entorno virtual en api/venv, activarlo e instalar dependencias con:

   * pip install -r requirements.txt
5. Crear carpeta api/uploads.
6. Levantar el backend con:

   * uvicorn api.main:app --reload
7. En flutterfotogps:

   * Configurar ApiService.baseUrl con la URL del backend.
   * Ejecutar flutter pub get.
   * Ejecutar la app con flutter run (chrome, windows o android).
8. Iniciar sesión en la app con:

   * Usuario: agent1
   * Contraseña: 123456
9. Probar:

   * Ver paquetes asignados.
   * Tomar foto y obtener GPS.
   * Registrar una entrega.
   * Consultar el historial con mapa + foto.
