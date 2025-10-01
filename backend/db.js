const sql = require("mssql");

// Tomar la cadena de conexión definida en Azure App Service
const connectionString = process.env.conexionprueba;

const poolPromise = new sql.ConnectionPool(connectionString)
  .connect()
  .then(pool => {
    console.log("✅ Conectado a Azure SQL Database");
    return pool;
  })
  .catch(err => {
    console.error("❌ Error de conexión a Azure SQL:", err);
  });

module.exports = { sql, poolPromise };
