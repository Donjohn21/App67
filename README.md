# Vehicle Manager App

Aplicación móvil desarrollada en Flutter para la gestión integral de vehículos. Permite a los usuarios registrar sus vehículos, dar seguimiento a mantenimientos, controlar gastos de combustible, monitorear el estado de las gomas, registrar ingresos y acceder a contenido automotriz.

---

## Descripción

El objetivo de esta aplicación es centralizar toda la información relacionada con el manejo y mantenimiento de vehículos en una sola plataforma, facilitando el control financiero y técnico del mismo, además de ofrecer contenido educativo y comunitario.

---

## Funcionalidades

### Módulos públicos
- Dashboard con slider y accesos rápidos
- Noticias automotrices
- Videos educativos
- Catálogo de vehículos
- Foro comunitario en modo lectura
- Sección "Acerca de"

### Módulos privados
- Registro y activación de usuario
- Inicio de sesión
- Recuperación de contraseña
- Perfil de usuario
- Gestión de vehículos
- Registro de mantenimientos
- Control de combustible y aceite
- Estado de gomas
- Gestión de gastos e ingresos
- Participación en el foro

---

## Tecnologías utilizadas

- Flutter
- Dart
- API REST
- JSON
- Almacenamiento local
- Manejo de imágenes (cámara y galería)

---

## Arquitectura del proyecto

El proyecto sigue una arquitectura modular organizada de la siguiente manera:

lib/
 ┣ core/
 ┣ features/
 ┣ routes/
 ┗ main.dart

- core: funcionalidades globales como API, almacenamiento y utilidades  
- features: módulos separados por funcionalidad  
- routes: navegación entre pantallas  

---

## Consumo de API

La aplicación consume una API REST documentada en Swagger.

Consideraciones:
- Los datos POST se envían en formato form-encoded  
- El JSON se envía dentro del campo "datax"  
- Las imágenes se envían mediante multipart/form-data  

---

## Instalación

1. Clonar el repositorio:
git clone https://github.com/Donjohn21/App67.git

2. Acceder al proyecto:
cd App67

3. Instalar dependencias:
flutter pub get

4. Ejecutar la aplicación:
flutter run

---

## Integrantes del proyecto

- Randy Alexander Mejia Moscoso - (2020-10307) 
- Adrian Alexander Reyes - (2023-1100)  
- Angel Isaac Mejia Martinez - (2024-1176)  
- Jayslen Rojas Serrano - (2023-1887)
- John Wilbert Aquino Disla - (2022-0417)

---

## Video demostrativo

Enlace al video: [(Enlace)](https://youtu.be/e1aWphBU6dU)

---

## Documentación

El proyecto incluye un documento PDF con:
- Capturas de pantalla de cada módulo  
- Información del equipo  
- Enlace al repositorio  
- Código QR del video  

---

## Extras implementados

- Interfaz limpia y organizada  
- Manejo de estados (carga, error y vacío)  
- Navegación intuitiva  

---

## Estado del proyecto

Completo      
