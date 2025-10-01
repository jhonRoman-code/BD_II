// backend/server.js
const express = require("express");
const cors = require("cors");
const { sql, poolPromise } = require("./db");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const app = express();
app.use(cors());
app.use(express.json());

// Carpeta para guardar archivos subidos
const uploadPath = path.join(__dirname, "uploads");
if (!fs.existsSync(uploadPath)) fs.mkdirSync(uploadPath);

// Servir archivos subidos
app.use("/uploads", express.static(uploadPath));

// Configuración de multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadPath),
  filename: (req, file, cb) => {
    const name = Date.now() + "-" + file.originalname.replace(/\s+/g, "_");
    cb(null, name);
  }
});
const upload = multer({ storage });

/* === LOGIN === */
app.post("/login", async (req, res) => {
  try {
    const { usuario, contrasena } = req.body;
    const pool = await poolPromise;
    const result = await pool.request()
      .input("Usuario", sql.NVarChar, usuario)
      .input("Contrasena", sql.NVarChar, contrasena)
      .query("SELECT Id, Usuario, Rol FROM Usuarios WHERE Usuario=@Usuario AND Contrasena=@Contrasena");

    if (result.recordset.length > 0) {
      res.json({ success: true, rol: result.recordset[0].Rol });
    } else {
      res.json({ success: false, message: "Credenciales incorrectas" });
    }
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* === SUBIR ARCHIVO === */
app.post("/subir/:semana", upload.single("archivo"), async (req, res) => {
  try {
    const { semana } = req.params;
    const archivo = req.file;
    if (!archivo) return res.status(400).json({ success: false, message: "No se recibió archivo" });

    const rutaPublica = `/uploads/${archivo.filename}`;
    const pool = await poolPromise;

    await pool.request()
      .input("NumeroSemana", sql.Int, semana)
      .input("NombreArchivo", sql.NVarChar, archivo.originalname)
      .input("RutaArchivo", sql.NVarChar, rutaPublica)
      .query("INSERT INTO Semanas (NumeroSemana, NombreArchivo, RutaArchivo) VALUES (@NumeroSemana, @NombreArchivo, @RutaArchivo)");

    res.json({ success: true, message: "Archivo subido con éxito", ruta: rutaPublica });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* === LISTAR ARCHIVOS === */
app.get("/archivos/:semana", async (req, res) => {
  try {
    const { semana } = req.params;
    const pool = await poolPromise;
    const result = await pool.request()
      .input("NumeroSemana", sql.Int, semana)
      .query("SELECT * FROM Semanas WHERE NumeroSemana=@NumeroSemana ORDER BY FechaSubida DESC");

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* === ELIMINAR ARCHIVO === */
app.delete("/archivo/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const pool = await poolPromise;

    const sel = await pool.request()
      .input("Id", sql.Int, id)
      .query("SELECT RutaArchivo FROM Semanas WHERE Id=@Id");

    if (sel.recordset.length === 0) return res.status(404).json({ success: false, message: "Archivo no encontrado" });

    const ruta = sel.recordset[0].RutaArchivo;
    const filename = path.basename(ruta);
    const filePath = path.join(uploadPath, filename);

    await pool.request()
      .input("Id", sql.Int, id)
      .query("DELETE FROM Semanas WHERE Id=@Id");

    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

    res.json({ success: true, message: "Archivo eliminado" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Iniciar servidor
const PORT = process.env.PORT || 3000; // 👈 IMPORTANTE para Azure
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en el puerto ${PORT}`);
});
