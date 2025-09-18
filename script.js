// Datos de cada semana con botones dinámicos
const contenidoSemanas = {
  1: `
    <button class="custom-button" onclick="mostrarIframe('docs/S01/Manual Crear Cuenta en GitHub.pdf')">
      📄 Manual Crear Cuenta en GitHub
    </button>
    <button class="custom-button" onclick="mostrarIframe('docs/S01/Manual Subir Pagina Web GitHub.pdf')">
      🌐 Manual Subir Página Web GitHub
    </button>
    <button class="custom-button" onclick="mostrarIframe('docs/S01/Informe Tecnico.pdf')">
      📝 Informe Técnico
    </button>
  `,
  2: `
    <button class="custom-button" onclick="mostrarIframe('docs/S02/Manual SQL Server.pdf')">
      🗄️ Manual SQL Server
    </button>
    <button class="custom-button" onclick="mostrarMensaje('Contenido en construcción...')">
      ⚙️ Desarrollo Ejemplo 01
    </button>
  `
};

// Referencias a elementos
const home = document.getElementById("home");
const contenido = document.getElementById("contenido-semana");
const tituloSemana = document.getElementById("titulo-semana");
const volverBtn = document.getElementById("volver");
const botonesSemana = document.getElementById("botones-semana");
const visor = document.getElementById("visor");
const visorMensaje = document.getElementById("visor-mensaje");

// Mostrar PDF en iframe
function mostrarIframe(url) {
  visor.src = url;
  visorMensaje.style.display = "none"; // Oculta el mensaje
  visor.style.background = "white"; // Para que el PDF sea visible
}

// Mostrar mensaje cuando no hay contenido
function mostrarMensaje(texto) {
  visor.src = "";
  visor.style.background = "transparent";
  visorMensaje.textContent = texto;
  visorMensaje.style.display = "block";
}

// Mostrar el contenido de cada semana
document.querySelectorAll(".card").forEach(card => {
  card.addEventListener("click", () => {
    const semana = card.dataset.semana;
    home.classList.add("hidden");
    contenido.classList.remove("hidden");
    tituloSemana.textContent = `Semana ${semana}`;
    botonesSemana.innerHTML = contenidoSemanas[semana] || "Contenido próximamente.";
    visor.src = "";
    visor.style.background = "transparent";
    visorMensaje.style.display = "block"; // Muestra mensaje por defecto
    visorMensaje.textContent = "Aquí podrás ver el contenido que selecciones";
  });
});

// Botón volver
volverBtn.addEventListener("click", () => {
  contenido.classList.add("hidden");
  home.classList.remove("hidden");
  visor.src = "";
  visorMensaje.style.display = "block";
  visorMensaje.textContent = "Aquí podrás ver el contenido que selecciones";
});
