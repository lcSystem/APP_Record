const express = require('express');
const Transaction = require('../models/Transaction');

module.exports = function (verifyToken) {
    const router = express.Router();

    // Crear una nueva transacción o sincronización masiva
    router.post('/', verifyToken, async (req, res) => {
        try {
            const { transacciones } = req.body;
            let count = 0;

            // Si mandan un arreglo (ej: "Ghost-Sync" offline masivo)
            if (Array.isArray(transacciones)) {
                for (let t of transacciones) {
                    t.user_id = req.userId; // Garantizar asociación segura
                    await Transaction.create(t);
                    count++;
                }
            } else {
                const t = req.body;
                t.user_id = req.userId;
                await Transaction.create(t);
                count = 1;
            }

            res.status(201).json({ message: `${count} transacciones sincronizadas con éxito` });
        } catch (error) {
            console.error('Error sincronizando transacciones:', error);
            res.status(500).json({ message: 'Error interno guardando la transacción' });
        }
    });

    // Obtener sumatoria de gastos para panel/alertas
    router.get('/reports/monthly', verifyToken, async (req, res) => {
        try {
            const { year, month } = req.query;

            if (!year || !month) {
                return res.status(400).json({ message: "Se requieren parámetros year y month" });
            }

            const totalGastos = await Transaction.getMonthlyTotalExpenses(req.userId, year, month);

            res.json({
                year,
                month,
                gastosTotales: totalGastos,
                alertaCritica: totalGastos > 2000 // Ejemplo de regla de negocio
            });
        } catch (error) {
            console.error('Error reportes financieros:', error);
            res.status(500).json({ message: 'Error interno generando el reporte' });
        }
    });

    return router;
};
