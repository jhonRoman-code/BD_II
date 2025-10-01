const sql = require("mssql");

const config = {
  connectionString: process.env.conexionprueba // nombre exacto en Azure
};

const poolPromise = new sql.ConnectionPool(config.connectionString)
  .connect()
  .then(pool => {
    console.log("✅ Conectado a Azure SQL Database");
    return pool;
  })
  .catch(err => {
    console.error("❌ Error de conexión a Azure SQL:", err);
  });

module.exports = { sql, poolPromise };
