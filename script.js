// Datos de cada semana (puedes personalizar el contenido)
const contenidoSemanas = {
  1: "Introducción a bases de datos, conceptos fundamentales y modelos de datos.",
  2: "Modelo relacional y álgebra relacional básica.",
  3: "Normalización y dependencias funcionales.",
  4: "SQL: consultas SELECT, filtros y ordenamiento.",
  5: "SQL: joins, subconsultas y funciones agregadas.",
  6: "Diseño lógico y físico de bases de datos.",
  7: "Transacciones y propiedades ACID.",
  8: "Control de concurrencia y bloqueo de registros.",
  9: "Recuperación ante fallos y respaldo de datos.",
  10: "Índices, vistas y optimización de consultas.",
  11: "Bases de datos distribuidas y replicación.",
  12: "Tendencias modernas: NoSQL, Big Data y bases en la nube."
};

// Elementos
const home = document.getElementById("home");
const contenido = document.getElementById("contenido-semana");
const tituloSemana = document.getElementById("titulo-semana");
const textoSemana = document.getElementById("texto-semana");
const volverBtn = document.getElementById("volver");

// Manejador de clic en las tarjetas
document.querySelectorAll(".card").forEach(card => {
  card.addEventListener("click", () => {
    const semana = card.dataset.semana;
    home.classList.add("hidden");
    contenido.classList.remove("hidden");
    tituloSemana.textContent = `Semana ${semana}`;
    textoSemana.textContent = contenidoSemanas[semana] || "Contenido próximamente.";
  });
});

// Botón volver
volverBtn.addEventListener("click", () => {
  contenido.classList.add("hidden");
  home.classList.remove("hidden");
});
