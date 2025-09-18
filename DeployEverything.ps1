# Configuración
$localPath = "C:\Users\Renato\Desktop\stable-diffusion-webui-github"
$repoURL = "https://github.com/benro2800-cmd/stable-diffusion-webui.git"
$branchName = "main"

# Ir a la carpeta del proyecto
Set-Location $localPath

# Inicializar Git si no está
if (!(Test-Path ".git")) {
    git init
    git remote add origin $repoURL
}

# Cambiar nombre del branch si es necesario
git branch -M $branchName

# Limpiar todos los submódulos
Write-Output "Limpiando submódulos..."
git submodule foreach --recursive git reset --hard
git submodule foreach --recursive git clean -fdx

# Crear carpeta docs/ si no existe
$docsPath = "$localPath\docs"
if (!(Test-Path $docsPath)) {
    New-Item -ItemType Directory -Path $docsPath
}

# Crear index.html en docs/
$indexFile = "$docsPath\index.html"
$indexContent = @"
<!DOCTYPE html>
<html lang='es'>
<head>
  <meta charset='UTF-8'>
  <title>Stable Diffusion WebUI</title>
  <style>
    body { font-family: Arial; text-align: center; padding: 50px; background: #f0f0f0; }
    h1 { color: #333; }
    a { color: #0066cc; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>Stable Diffusion WebUI</h1>
  <p>Proyecto subido a GitHub Pages con deploy automático.</p>
  <p>
    <a href='$repoURL' target='_blank'>Ver repositorio en GitHub</a>
  </p>
</body>
</html>
"@
Set-Content -Path $indexFile -Value $indexContent

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
        path: './docs'

    - name: Deploy to GitHub Pages
      uses: actions/deploy-pages@v1
"@
Set-Content -Path $workflowFile -Value $workflowContent

# Añadir todos los cambios (ignora submódulos)
git add . --ignore-errors

# Commit de cambios
git commit -m "Limpiar submódulos y subir docs con workflow de Pages"

# Push al repo remoto
git push -u origin $branchName
