const { dbPool } = require('../config/db');

class Transaction {
    // Obtener todas las transacciones de un usuario en un mes
    static async getMonthlyByUser(userId, year, month) {
        // Retornamos lo del mes elegido (1-12)
        const query = `
      SELECT * FROM transactions 
      WHERE user_id = ? 
      AND YEAR(date) = ? 
      AND MONTH(date) = ?
      ORDER BY date DESC
    `;
        const [rows] = await dbPool.query(query, [userId, year, month]);
        return rows;
    }

    // Guardar una nueva transacción
    static async create(transactionData) {
        const { id, user_id, amount, type, category, date, note } = transactionData;
        const query = `
      INSERT INTO transactions (id, user_id, amount, type, category, date, note)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
        const [result] = await dbPool.query(query, [
            id,
            user_id,
            amount,
            type,
            category,
            date,
            note
        ]);
        return result;
    }

    // Obtener sumatoria para Alertas (Ejemplo: gastos totales del mes actual)
    static async getMonthlyTotalExpenses(userId, year, month) {
        const query = `
      SELECT SUM(amount) as total FROM transactions 
      WHERE user_id = ? 
      AND type = 'expense'
      AND YEAR(date) = ? 
      AND MONTH(date) = ?
    `;
        const [rows] = await dbPool.query(query, [userId, year, month]);
        return rows[0].total || 0;
    }
}

module.exports = Transaction;
