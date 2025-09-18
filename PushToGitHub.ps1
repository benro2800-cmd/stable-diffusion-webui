# Configuración
$localPath = "C:\Users\Renato\Desktop\stable-diffusion-webui-github"  # Carpeta del proyecto
$repoURL = "https://github.com/benro2800-cmd/stable-diffusion-webui.git" # Tu repo en GitHub
$branchName = "main"  # Cambia a "master" si tu GitHub usa master

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
