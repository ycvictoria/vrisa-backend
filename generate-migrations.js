const fs = require("fs");
const path = require("path");

// Rutas base
const MIGRATIONS_DIR = path.join(__dirname, "supabase/migrations");
const BASE_DIR = path.join(__dirname, "sql");

// Carpetas dentro de /sql que se deben procesar
const DIRECTORIES = ["00_schema", "01_functions", "02_triggers", "03_procedures","04_views","05_indexes"];

// Timestamp para el nombre de archivos

function timestamp() {
  const now = new Date();
  return now.toISOString().replace(/[-T:.Z]/g, "") + now.getMilliseconds();
}
// Paso 1: limpiar carpeta de migraciones anteriores
function clearMigrations() {
  if (!fs.existsSync(MIGRATIONS_DIR)) {
    fs.mkdirSync(MIGRATIONS_DIR, { recursive: true });
    return;
  }

  const files = fs.readdirSync(MIGRATIONS_DIR);

  files.forEach(f => {
    fs.unlinkSync(path.join(MIGRATIONS_DIR, f));
  });

  console.log("🧹 Carpeta de migraciones limpiada.");
}

// Paso 2: copiar todas las migraciones nuevas desde /sql
function generateNewMigrations() {
  DIRECTORIES.forEach(dirName => {
    const dirPath = path.join(BASE_DIR, dirName);

    if (!fs.existsSync(dirPath)) {
      console.log(`⚠️ No existe carpeta: ${dirPath}`);
      return;
    }

    const files = fs.readdirSync(dirPath);

    files.forEach(file => {
      if (!file.endsWith(".sql")) return;

      const srcPath = path.join(dirPath, file);
      const dstName = `${timestamp()}_${dirName}_${file}`;
      const dstPath = path.join(MIGRATIONS_DIR, dstName);

      fs.copyFileSync(srcPath, dstPath);

      console.log(`✔ Migración generada: ${dstName}`);
    });
  });
}

// Ejecutar todo
clearMigrations();
generateNewMigrations();

console.log("✅ Todas las migraciones han sido regeneradas.");

