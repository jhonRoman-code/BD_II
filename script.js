// Datos de cada semana
const contenidoSemanas = {
  1: "Aquí puedes acceder a los recursos de la Semana 1 usando los botones.",
  2: "Contenido de la semana 2 próximamente.",
  3: "Contenido de la semana 3 próximamente.",
  4: "Contenido de la semana 4 próximamente."
};

// Elementos
const home = document.getElementById("home");
const contenido = document.getElementById("contenido-semana");
const tituloSemana = document.getElementById("titulo-semana");
const textoSemana = document.getElementById("texto-semana");
const volverBtn = document.getElementById("volver");
const botonesSemana = document.getElementById("botones-semana");
const visor = document.getElementById("visor");

// Manejador de clic en las tarjetas
document.querySelectorAll(".card").forEach(card => {
  card.addEventListener("click", () => {
    const semana = card.dataset.semana;
    home.classList.add("hidden");
    contenido.classList.remove("hidden");
    tituloSemana.textContent = `Semana ${semana}`;
    textoSemana.textContent = contenidoSemanas[semana] || "Contenido próximamente.";

    // Mostrar botones solo en Semana 1
    if (semana === "1") {
      botonesSemana.innerHTML = `
        <button class="custom-button" onclick="mostrarEnlace('https://miro.com/app/board/uXjVIFahQhU=/?share_link_id=310199185276')">Ver en Miro</button>
        <button class="custom-button" onclick="mostrarEnlace('https://www.canva.com/design/DAGji3nxKrI/gE5sHO90rC7vXzM64YdERA/view')">Ver en Canva</button>
      `;
    } else {
      botonesSemana.innerHTML = "";
      visor.classList.add("hidden");
    }
  });
});

// Función para mostrar contenido en iframe
function mostrarEnlace(url) {
  visor.src = url;
  visor.classList.remove("hidden");
}

// Botón volver
volverBtn.addEventListener("click", () => {
  contenido.classList.add("hidden");
  home.classList.remove("hidden");
  visor.classList.add("hidden");
  visor.src = "";
});
