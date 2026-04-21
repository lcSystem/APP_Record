# 🚀 Guía de Despliegue en Producción

## Opciones de Despliegue

### 1. **Heroku** (Recomendado para principiantes)

#### Requisitos
- Cuenta en heroku.com
- Heroku CLI instalado

#### Pasos

1. **Conectar repositorio Git**
```bash
cd server-nodejs
git init
heroku login
heroku create app-record-api
```

2. **Crear Procfile**
```bash
echo "web: node server.js" > Procfile
```

3. **Configurar variables de entorno**
```bash
heroku config:set JWT_SECRET="tu_clave_secreta_super_segura"
heroku config:set NODE_ENV="production"
```

4. **Desplegar**
```bash
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

5. **Verificar**
```bash
heroku logs --tail
heroku open
```

Tu URL será: `https://app-record-api.herokuapp.com`

---

### 2. **Railway** (Fácil y moderno)

1. Conecta tu repositorio GitHub
2. Nueva aplicación
3. Selecciona Node.js
4. Configura variables:
   - `JWT_SECRET`
   - `NODE_ENV=production`
5. Deploy automático

---

### 3. **Render** (Gratis con limitaciones)

1. Crea cuenta en render.com
2. New Web Service
3. Conecta repositorio GitHub
4. Configurar:
   - Runtime: Node
   - Build: `npm install`
   - Start: `npm start`
5. Agrega variables de entorno
6. Deploy

---

### 4. **AWS EC2** (Más control)

#### Paso 1: Crear instancia EC2
```bash
# Ubuntu 22.04
# Type: t3.micro (gratis con free tier)
# Security Group: Abre puertos 80, 443, 3000
```

#### Paso 2: Conectar SSH
```bash
ssh -i key.pem ubuntu@tu-instancia-ec2.com
```

#### Paso 3: Instalar Node.js y PM2
```bash
sudo apt update
sudo apt install nodejs npm
sudo npm install -g pm2
```

#### Paso 4: Clonar repositorio
```bash
git clone https://github.com/tu-usuario/app-record.git
cd app-record/server-nodejs
npm install
```

#### Paso 5: Configurar PM2
```bash
pm2 start server.js --name "app-record-api"
pm2 startup
pm2 save
```

#### Paso 6: Configurar Nginx (proxy reverso)
```bash
sudo apt install nginx

sudo nano /etc/nginx/sites-available/default
```

Contenido:
```nginx
server {
    listen 80 default_server;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
sudo nginx -t
sudo systemctl restart nginx
```

#### Paso 7: SSL con Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d tu-dominio.com
```

---

### 5. **DigitalOcean App Platform** (Recomendado)

1. Conecta GitHub
2. Selecciona repo
3. Autodetecta Node.js
4. Configura variables de entorno
5. Deploy

---

### 6. **Docker + Cualquier servidor**

#### Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

#### docker-compose.yml
```yaml
version: '3.8'

services:
  app-record-api:
    build: .
    ports:
      - "3000:3000"
    environment:
      JWT_SECRET: tu_clave_secreta
      NODE_ENV: production
```

#### Ejecutar
```bash
docker-compose up
```

---

## Configuración de Producción

### 1. **Variables de Entorno** (.env)
```bash
NODE_ENV=production
PORT=3000
JWT_SECRET=una-clave-muy-segura-cambiar-esto
CORS_ORIGIN=https://tuapp.com
```

### 2. **Base de Datos** (Cambiar de array a DB real)

#### MongoDB
```bash
npm install mongoose
```

```javascript
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGODB_URI);

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String
});

module.exports = mongoose.model('User', userSchema);
```

#### PostgreSQL
```bash
npm install pg sequelize
```

---

## Checklist de Seguridad

- [ ] JWT_SECRET es fuerte y secreto
- [ ] HTTPS está habilitado
- [ ] CORS está configurado correctamente
- [ ] Rate limiting implementado
- [ ] Validación de entrada en servidor
- [ ] Contraseñas con hash (bcryptjs)
- [ ] Variables sensibles en .env
- [ ] No loguear datos sensibles
- [ ] Headers de seguridad configurados
- [ ] SQL Injection prevention (si usas DB)

### Agregar Headers de Seguridad
```bash
npm install helmet
```

```javascript
const helmet = require('helmet');
app.use(helmet());
```

---

## Monitoreo

### 1. **Error Tracking** (Sentry)
```bash
npm install @sentry/node
```

```javascript
const Sentry = require("@sentry/node");
Sentry.init({ dsn: "https://..." });
```

### 2. **Logs** (Winston)
```bash
npm install winston
```

### 3. **Uptime Monitoring** (Uptime Robot)
- Agrega tu URL al dashboard
- Alertas si cae

---

## Domain y SSL

### 1. **Comprar dominio**
- Namecheap, GoDaddy, Route 53

### 2. **Apuntar a tu servidor**
- Actualizar registros DNS
- CNAME o A record

### 3. **SSL Gratuito** (Let's Encrypt)
```bash
sudo certbot certonly --standalone -d tudominio.com
```

---

## CI/CD Automatizado

### GitHub Actions

Crear `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Heroku

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.13.15
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "app-record-api"
          heroku_email: "${{secrets.HEROKU_EMAIL}}"
```

---

## Performance

### 1. **Cacheo**
```bash
npm install redis
```

### 2. **Compresión**
```javascript
const compression = require('compression');
app.use(compression());
```

### 3. **Rate Limiting**
```bash
npm install express-rate-limit
```

---

## Rollback

Si algo sale mal:

### Heroku
```bash
heroku releases
heroku rollback v123
```

### Git
```bash
git revert HEAD
git push
```

---

## URLs de Ejemplo

**Desarrollo:**
```
http://localhost:3000
```

**Heroku:**
```
https://app-record-api.herokuapp.com
```

**Dominio personalizado:**
```
https://api.tuapp.com
```

---

## Actualizar URL en Flutter

Una vez desplegado, actualiza `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://api.tuapp.com';
```

---

## Support

Para problemas:
- Revisa logs: `heroku logs --tail`
- Monitoreo: New Relic, DataDog
- Alerts: PagerDuty
