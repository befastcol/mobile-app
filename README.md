# Be Fast

## Descripción

"Be Fast" es una aplicación diseñada para optimizar y agilizar los servicios de entrega en moto. Esta plataforma conecta a usuarios que necesitan un servicio de entrega con conductores de motocicleta registrados y verificados.

## Funcionalidades de la Aplicación

### 1. Administrador

- **Aprobación de Usuarios:** Gestiona el registro de nuevos usuarios, aprobándolos para usar la app.
- **Seguimiento en Tiempo Real:** Permite ver la ubicación actual de las motocicletas.
- **Acceso a Bitácoras:** Visualiza el historial de servicios solicitados por los usuarios.
- **Notificación de Servicios Finalizados:** Recibe alertas cuando un servicio de entrega se completa.

### 2. Usuario de Moto 🏍️

- **Registro y Aprobación:** Se registra en la app y espera la aprobación para comenzar a recibir solicitudes de servicio.
- **Aceptación de Servicios:** Elige aceptar servicios de entrega y los completa siguiendo las instrucciones del GPS de la app.
- **Visibilidad en Mapa GPS:** Su ubicación y movimientos son rastreables en tiempo real por el administrador y el usuario solicitante.

### 3. Usuario Solicitante

- **Registro y Aprobación:** Debe registrarse y ser aprobado para solicitar servicios.
- **Solicitud de Servicios:** Utiliza la app para pedir entregas, indicando los puntos de recogida y entrega.
- **Notificaciones y Contacto:** Recibe notificaciones al finalizar la entrega y tiene acceso al número de teléfono del motorista.

## Pagos y Tarifas

- Los pagos se realizan en efectivo directamente al motorista.
- La aplicación no cobra comisiones por servicio.
- Los dueños de "Be Fast" cobran una mensualidad por el uso de la app.

## Proceso de Registro

### Para Motoristas

- Nombre completo.
- Foto de la INE.
- Foto de la licencia de conducir.
- Número de teléfono.
- Dirección.
- Aceptación de políticas de la empresa.

### Para Usuarios

- Nombre de la empresa o persona.
- Número de teléfono.
- Dirección.
- Aceptación de términos de servicio y políticas de la empresa.

## Administración

El administrador tiene la facultad de eliminar perfiles de motoristas y usuarios en caso de ser necesario.

---

_Nota: Esta información se enviará al administrador para su evaluación y aprobación._

## Instrucciones para clonar este repo

### Paso 1: Clone el repo corriendo este comando

```
git clone https://github.com/befastcol/mobile-app.git
```

### Paso 2: Crea un archivo .env en la raíz del proyecto

```
mkdir .env
```

### Paso 3: Agrega la api de google al .env

```
GOOGLE_API_KEY=AIzaSyAml********************ZArxGGOdIA
```

#### Nota:

Puedes encontrar esta clave en la Google Cloud Platform usando el correo

```
befastcol@gmail.com
```

Y la contraseña:

```
B***********
```

### Paso 4: Crea un archivo Config.swift dentro de ios > Runner

```
struct Config {
    static let googleMapsApiKey = "AIzaSyAml********************ZArxGGOdIA"
}
```

### Paso 4: Instala las dependencias del proyecto

```
flutter pub get
```

### Paso 5: Listo
