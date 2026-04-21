const mysql = require('mysql2/promise');

// Configuración de la conexión a la base de datos MySQL
const dbPool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '', // Colocar password si es necesario
    database: process.env.DB_NAME || 'app_record_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Inicializar y crear la tabla si no existe
const initDb = async () => {
    try {
        const connection = await dbPool.getConnection();

        // Crear base de datos si no existe
        await connection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || 'app_record_db'}\`;`);

        // Seleccionar la DB
        await connection.query(`USE \`${process.env.DB_NAME || 'app_record_db'}\`;`);

        // Crear tabla de Transacciones (Gastos/Ingresos)
        await connection.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(50) PRIMARY KEY,
        user_id INT NOT NULL,
        amount DECIMAL(10, 2) NOT NULL,
        type ENUM('income', 'expense') NOT NULL,
        category VARCHAR(100) NOT NULL,
        date DATETIME NOT NULL,
        note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

        console.log('✅ Tablas MySQL inicializadas y verificadas (Transactions).');
        connection.release();
    } catch (error) {
        console.error('❌ Error inicializando base de datos MySQL:', error);
    }
};

module.exports = { dbPool, initDb };
