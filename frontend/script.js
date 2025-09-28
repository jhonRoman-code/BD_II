// === Toggle menú hamburguesa ===
const menuToggle = document.getElementById("menu-toggle");
const menuList = document.getElementById("menu-list");

if (menuToggle && menuList) {
  menuToggle.addEventListener("click", () => {
    menuList.style.display = menuList.style.display === "block" ? "none" : "block";
  });
}

// === Contenido de cada semana ===
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
    <button class="custom-button" onclick="mostrarIframe('docs/S02/modelo01.png')">
      ⚙️ Desarrollo Enunciado 1
    </button>
    <button class="custom-button" onclick="mostrarIframe('docs/S02/modelo02.png')">
      ⚙️ Desarrollo Enunciado 2
    </button>
  `,
  3: `
    <p>Contenido próximamente...</p>
  `
};

// === Referencias ===
const tituloSemana = document.getElementById("titulo-semana");
const contenido = document.getElementById("contenido-semana");

// === Mostrar PDFs ===
function mostrarIframe(url) {
  const visor = document.getElementById("visor");
  const visorMensaje = document.getElementById("visor-mensaje");
  if (visor) {
    visor.src = url;
    visor.style.display = "block";
  }
  if (visorMensaje) {
    visorMensaje.style.display = "none";
  }
}

// === Mostrar mensajes ===
function mostrarMensaje(texto) {
  const visor = document.getElementById("visor");
  const visorMensaje = document.getElementById("visor-mensaje");
  if (visor) {
    visor.src = "";
    visor.style.display = "none";
  }
  if (visorMensaje) {
    visorMensaje.textContent = texto;
    visorMensaje.style.display = "block";
  }
}

// === Mostrar contenido de semana ===
function mostrarSemana(num) {
  if (tituloSemana) {
    tituloSemana.textContent = `Contenido semana ${num}`;
  }
  if (contenido) {
    contenido.innerHTML = `
      ${contenidoSemanas[num] || "<p>Contenido próximamente...</p>"}
      <div id="visor-contenedor">
        <iframe id="visor" class="visor"></iframe>
        <div id="visor-mensaje" class="visor-mensaje">Selecciona un archivo para verlo aquí</div>
      </div>
    `;
  }
}
