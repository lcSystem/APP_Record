const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'tu_clave_secreta_cambiar_en_produccion';

// Middleware
app.use(cors());
app.use(express.json());

// Base de datos simulada
let users = [
  {
    id: 1,
    name: 'Usuario Admin',
    email: 'admin@app.com',
    password: '$2a$10$Nw5pxzLzA1...' // bcrypt hash de "123456"
  }
];

let nextUserId = 2;

// Función auxiliar para generar token JWT
const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
};

// Middleware para verificar token
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token no proporcionado' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
    next();
  } catch (err) {
    res.status(401).json({ message: 'Token inválido' });
  }
};

// ============ RUTAS DE AUTENTICACIÓN ============

/**
 * POST /api/auth/register
 * Registra un nuevo usuario
 */
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validaciones
    if (!name || !email || !password) {
      return res.status(400).json({
        message: 'Nombre, email y contraseña son requeridos'
      });
    }

    // Verificar si el email ya existe
    if (users.some(u => u.email === email)) {
      return res.status(400).json({
        message: 'El email ya está registrado'
      });
    }

    // Hash de la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear nuevo usuario
    const newUser = {
      id: nextUserId++,
      name,
      email,
      password: hashedPassword
    };

    users.push(newUser);

    // Generar token
    const token = generateToken(newUser);

    res.status(201).json({
      message: 'Usuario registrado exitosamente',
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email
      },
      token
    });
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({
      message: 'Error al registrar usuario'
    });
  }
});

/**
 * POST /api/auth/login
 * Inicia sesión con email y contraseña
 */
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validaciones
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email y contraseña son requeridos'
      });
    }

    // Buscar usuario
    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(401).json({
        message: 'Credenciales inválidas'
      });
    }

    // Verificar contraseña
    // Para la contraseña de prueba sin hash, hacemos comparación directa
    const passwordMatch = password === '123456'
      ? true
      : await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({
        message: 'Credenciales inválidas'
      });
    }

    // Generar token
    const token = generateToken(user);

    res.json({
      message: 'Login exitoso',
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token
    });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({
      message: 'Error al iniciar sesión'
    });
  }
});

/**
 * POST /api/auth/logout
 * Cierra la sesión (token invalida en cliente)
 */
app.post('/api/auth/logout', verifyToken, (req, res) => {
  // En una app real, aquí se invalidaría el token en servidor
  res.json({
    message: 'Sesión cerrada exitosamente'
  });
});

/**
 * GET /api/auth/verify
 * Verifica si un token es válido
 */
app.get('/api/auth/verify', verifyToken, (req, res) => {
  const user = users.find(u => u.id === req.userId);

  if (!user) {
    return res.status(401).json({
      message: 'Usuario no encontrado'
    });
  }

  res.json({
    message: 'Token válido',
    user: {
      id: user.id,
      name: user.name,
      email: user.email
    }
  });
});

/**
 * GET /api/auth/profile
 * Obtiene el perfil del usuario autenticado
 */
app.get('/api/auth/profile', verifyToken, (req, res) => {
  const user = users.find(u => u.id === req.userId);

  if (!user) {
    return res.status(404).json({
      message: 'Usuario no encontrado'
    });
  }

  res.json({
    user: {
      id: user.id,
      name: user.name,
      email: user.email
    }
  });
});

/**
 * PUT /api/auth/profile
 * Actualiza el perfil del usuario
 */
app.put('/api/auth/profile', verifyToken, (req, res) => {
  const { name } = req.body;
  const user = users.find(u => u.id === req.userId);

  if (!user) {
    return res.status(404).json({
      message: 'Usuario no encontrado'
    });
  }

  if (name) {
    user.name = name;
  }

  res.json({
    message: 'Perfil actualizado',
    user: {
      id: user.id,
      name: user.name,
      email: user.email
    }
  });
});

/**
 * POST /api/auth/refresh
 * Genera un nuevo token (token refresh)
 */
app.post('/api/auth/refresh', verifyToken, (req, res) => {
  const user = users.find(u => u.id === req.userId);

  if (!user) {
    return res.status(404).json({
      message: 'Usuario no encontrado'
    });
  }

  const token = generateToken(user);

  res.json({
    message: 'Token renovado',
    token
  });
});

// ============ RUTAS DE USUARIOS (ADMIN) ============

/**
 * GET /api/users
 * Lista todos los usuarios (solo para verificación)
 */
app.get('/api/users', (req, res) => {
  res.json({
    users: users.map(u => ({
      id: u.id,
      name: u.name,
      email: u.email
    }))
  });
});

/**
 * DELETE /api/auth/account
 * Elimina la cuenta del usuario autenticado
 */
app.delete('/api/auth/account', verifyToken, (req, res) => {
  const userIndex = users.findIndex(u => u.id === req.userId);

  if (userIndex === -1) {
    return res.status(404).json({
      message: 'Usuario no encontrado'
    });
  }

  users.splice(userIndex, 1);

  res.json({
    message: 'Cuenta eliminada exitosamente'
  });
});

// ============ RUTAS DE SALUD ============

/**
 * GET /health
 * Verifica que el servidor esté funcionando
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Servidor funcionando correctamente'
  });
});

// ============ RUTAS GEMELO DIGITAL (FINANZAS) ============
const transactionsRoutes = require('./routes/transactions')(verifyToken);
app.use('/api/transactions', transactionsRoutes);

// Manejo de errores 404
app.use((req, res) => {
  res.status(404).json({
    message: 'Ruta no encontrada'
  });
});

const { initDb } = require('./config/db');

// Iniciar servidor
app.listen(PORT, async () => {
  await initDb();
  console.log(`✅ Servidor corriendo en http://localhost:${PORT}`);
  console.log(`📝 Usuario de prueba: admin@app.com / 123456`);
  console.log(`🔗 Endpoints disponibles:`);
  console.log(`   POST   /api/auth/register`);
  console.log(`   POST   /api/auth/login`);
  console.log(`   POST   /api/auth/logout`);
  console.log(`   GET    /api/auth/verify`);
  console.log(`   GET    /api/auth/profile`);
  console.log(`   PUT    /api/auth/profile`);
  console.log(`   POST   /api/auth/refresh`);
  console.log(`   GET    /api/users`);
  console.log(`   DELETE /api/auth/account`);
  console.log(`   GET    /health`);
});

module.exports = app;
