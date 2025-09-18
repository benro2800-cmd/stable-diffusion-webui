# Configuración
$localPath = "C:\Users\Renato\Desktop\stable-diffusion-webui-github"  # Carpeta de tu proyecto
$repoURL = "https://github.com/benro2800-cmd/stable-diffusion-webui.git" # Tu repo en GitHub
$branchName = "main"  # Cambia a master si tu GitHub usa master

# Ir a la carpeta del proyecto
Set-Location $localPath

# Inicializar Git si no está
if (!(Test-Path ".git")) {
    git init
    git remote add origin $repoURL
}

# Cambiar nombre del branch si es necesario
git branch -M $branchName

# Quitar submódulos del índice (no se subirán)
$submodules = git submodule status --quiet 2>$null
if ($submodules) {
    $submodulesList = git submodule foreach --quiet 'echo $sm_path' 2>$null
    foreach ($sm in $submodulesList) {
        git rm --cached $sm
    }
}

# Añadir todos los demás archivos
git add .

# Hacer commit
git commit -m "Subida automática desde PowerShell"

# Subir a GitHub
git push -u origin $branchName

# Crear workflow de GitHub Actions para GitHub Pages
$workflowPath = "$localPath\.github\workflows"
if (!(Test-Path $workflowPath)) {
    New-Item -ItemType Directory -Path $workflowPath -Force
}

$workflowFile = "$workflowPath\deploy.yml"

$workflowContent = @"
name: GitHub Pages Deploy

on:
  push:
    branches:
      - $branchName

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Pages
      uses: actions/configure-pages@v3

    - name: Upload artifact
      uses: actions/upload-pages-artifact@v1
      with:
        path: '.'  # Carpeta raíz del repo, cambia a './docs' si usas docs/

    - name: Deploy to GitHub Pages
      uses: actions/deploy-pages@v1
"@

# Guardar workflow
Set-Content -Path $workflowFile -Value $workflowContent

# Añadir y subir workflow a GitHub
git add $workflowFile
git commit -m "Agregar workflow de GitHub Actions para Pages"
git push
