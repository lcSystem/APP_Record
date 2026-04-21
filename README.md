#APP-Registro: Gemelo Digital Financiero

**APP-Record** es una innovadora aplicación móvil diseñada para funcionar como un "gemelo digital" de tus finanzas personales. Pensada bajo una filosofía *Offline-First*, permite a los usuarios interactuar con sus presupuestos, ingresos y gastos de forma inmediata y en cualquier momento, sincronizando la información en segundo plano cuando se disponga de internet.

---

## Características Principales

### 1. Operación 100% Offline (Desconectado)
La tranquilidad del usuario es primero. Gracias a la integración con SQLite (`sqflite`), APP-Record permite realizar transacciones incluso en zonas de nula cobertura (modo avión, subterráneos, viajes). La aplicación guarda todo en el celular y realiza una **sincronización transparente asíncrona** hacia la nube en cuanto la conexión a internet sea restablecida.

### 2. Sincronización Segura en Tiempo Real
El cerebro backend, impulsado por Node.js y **MySQL**, es el custodio de la información validada. En toda comunicación con la API se incluye protección criptográfica mediante **JWT (Json Web Tokens)** y contraseñas protegidas por **Bcrypt**.

### 3. Panel Interactivo y "Alertas Inteligentes"
No es sólo un libro contable; es un asesor de bolsillo:
- Interfaz moderna, minimalista con animaciones reactivas al añadir movimientos financieros (Arquitectura Flutter Premium).
- **Módulo de Metas y Alertas:** El backend procesa el umbral mensual de gasto y devuelve notificaciones o alertas en caso de que un presupuesto esté cerca de llegar a su límite.

---

## 🛠Arquitectura Tecnológica

- **Frontend:** Flutter (Móvil/Web), `sqflite` para caché persistente fuera de línea, enrutamiento MVC limpio.
- **API de backend:** Node.js, Express.js.
- **Seguridad:** JWT (JSON Web Tokens), `bcryptjs`.
- **Base de Datos Persistente:** MySQL (para el backend alojado, capaz de manejar grandes volúmenes de consultas de sincronización asíncrona).

---

## 🚀 Flujo de Trabajo (El "Record")
1. **El Usuario (El Twin)**: Inicia sesión (obtiene un Token Seguro).
2. **Registro Instantáneo**: Realiza compras, añade un "Record" (Gasto) usando la UI interactiva que responde en 0 ms porque se guarda primero de forma local en la SD del celular.
3. **Ghost-Sync**: Tras guardar exitosamente en el móvil, la aplicación empuja automáticamente un POST al servidor. Si el servidor Node.js/MySQL está disponible y el Token es válido, se asegura la copia remota.

---
*Construyendo el futuro del manejo personal contable con tecnología rápida, reactiva y elegante.*