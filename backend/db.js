// backend/db.js
const sql = require("mssql/msnodesqlv8");

const config = {
  connectionString: "Driver={ODBC Driver 17 for SQL Server};Server=localhost;Database=BD_Proyecto;Trusted_Connection=Yes;"
};

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log("✅ Conectado a SQL Server con Windows Authentication");
    return pool;
  })
  .catch(err => {
    console.error("❌ Error de conexión:", err);
  });

module.exports = { sql, poolPromise };
