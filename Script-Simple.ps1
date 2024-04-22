
# Verificar si el usuario tiene permisos de administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Si no tiene permisos de administrador, solicitar elevación de privilegios
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
    exit  # Salir del script actual
}


Set-ExecutionPolicy Unrestricted
#Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoNewWindow', '-File', 'C:\Users\Script-Simple.ps1'
# Validar si ya estamos en la ubicación C:\Users\
if ($PWD.Path -ne 'C:\Users') {
    Set-Location 'C:\Users'
}
Set-Location 'C:\Users'
# Especificar la ubicación donde queremos guardar el archivo de usuarios seleccionados
Get-ChildItem -Directory | Select-Object -ExpandProperty Name | Out-File -FilePath "C:\Users\Usuarios_Seleccionados.txt"

# Obtener la lista de usuarios en la ruta Users
$usuarios = Get-ChildItem -Path "C:\Users" -Directory

# Mostrar el número de usuarios
Write-Host "El número de Usuarios es de: $($usuarios.Count)"
Write-Host ""
Write-Host "Iniciando eliminación de archivos temporales..."
Write-Host "-----------------------------------------------------------"
"_____________________________________________________________________________________"

# Ruta del archivo de texto
$rutaArchivo = "C:\Users\Usuarios_Seleccionados.txt"
$fecha = Get-Date 

# Leer el contenido del archivo
$listaUsuarios = Get-Content -Path $rutaArchivo
$Master = $env:USERNAME

# Crear la carpeta Usuarios_Limpiados si no existe
if (!(Test-Path "C:\Users\Usuarios_Limpiados")) { 
    mkdir "C:\Users\Usuarios_Limpiados"
    Write-Host "La carpeta fue creada"
}

# Mostrar la lista de usuarios y realizar acciones según el usuario
foreach ($usuario in $listaUsuarios) {
    if ($usuario -eq "Public" -or $usuario -eq $Master -or $usuario -eq "Publico" -or $seleccion -eq "Usuarios_Limpiados") {
        Write-Host "No se eliminarán los archivos de: $usuario"
    } else {
        $PathCarpeta = "C:\Users\Usuarios_Limpiados"
        $TemporalUsuario = "C:\Users\$usuario\AppData\Local\Temp\"

        # Validar la existencia de la carpeta temporal del usuario
        if (Test-Path  $TemporalUsuario) {
            Set-Location $TemporalUsuario
            $dir = Get-ChildItem

            # Guardar información de usuarios en el archivo de texto
            $rutaUsuario = "C:\Users\$usuario.txt"
            $dir | Out-File -FilePath $rutaUsuario

            # Agregar un divisor al final del archivo
            "----------------$fecha---------------------------" | Out-File -FilePath $rutaUsuario -Append

            $Validar ="C:\Users\Usuarios_Limpiados\$usuario.txt"
            if (Test-Path $Validar) {
                Remove-Item "C:\Users\Usuarios_Limpiados\$usuario.txt" -Force -ErrorAction SilentlyContinue
                Move-Item "C:\Users\$usuario.txt" "C:\Users\Usuarios_Limpiados\$usuario.txt"
            } else {
                Move-Item "C:\Users\$usuario.txt" "C:\Users\Usuarios_Limpiados\$usuario.txt"
            }
        }
    }
}

"_____________________________________________________________________________________"

# Iterar sobre cada usuario para limpiar archivos temporales
foreach ($usuario in $usuarios) {
    $nombreUsuario = $usuario.Name

    Write-Output "Limpiando archivos temporales de usuario: $nombreUsuario"

    if ($nombreUsuario -eq "Public" -or $nombreUsuario -eq $env:USERNAME -or $nombreUsuario -eq "Publico" -or $seleccion -eq "Usuarios_Limpiados") {
        Write-Host "Este usuario no es válido para la limpieza de temporales"
    } else {
        $tempPath = "C:\Users\$nombreUsuario\AppData\Local\Temp"

        # Verificar si la ruta de temporales existe y eliminar archivos temporales
        if (Test-Path $tempPath) {
            Get-ChildItem -Path $tempPath | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "Archivos temporales eliminados para el usuario: $nombreUsuario"
        } else {
            Write-Host "La ruta de temporales no existe para el usuario: $nombreUsuario"
        }
    }
}

Set-Location C:\Users\
Write-Host "//////////////////////////////////////////////////////////////////////////"
Write-Host "Ejecución finalizada||||Todos los archivos temporales fueron eliminados."
Write-Host "//////////////////////////////////////////////////////////////////////////"
