# Archivo: paso1_crear_mv_virtualbox.ps1

# Parámetros de Entrada del script .ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$VBoxManagePath,
    
    [Parameter(Mandatory=$true)]
    [string]$VmName,
    
    [Parameter(Mandatory=$false)]
    [int]$DiskMb = 25000,
    
    [Parameter(Mandatory=$false)]
    [int]$RamMb = 4096,
    
    [Parameter(Mandatory=$false)]
    [int]$Cpus = 2,
    
    [Parameter(Mandatory=$false)]
    [string]$NetworkAdapter = ""  # Nombre del adaptador de red, vacío = auto-detectar
)

# Parámetros con la configuración de la MV
$Os_Type = "Ubuntu_64"
$Disk_Path = "$HOME\VirtualBox VMs\$VmName\$VmName.vdi"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creando la MV: $VmName" -ForegroundColor Cyan
Write-Host "RAM: $RamMb MB | Disk: $DiskMb MB | CPUs: $Cpus" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    # Cambiar al directorio de VirtualBox
    Set-Location $VBoxManagePath
    
    # Si no se especificó adaptador, detectar el activo
    if ([string]::IsNullOrEmpty($NetworkAdapter)) {
        Write-Host "Detectando adaptador de red activo..." -ForegroundColor Yellow
        
        # Obtener adaptadores de red activos
        $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        
        if ($activeAdapters.Count -gt 0) {
            # Usar el primer adaptador activo
            $NetworkAdapter = $activeAdapters[0].Name
            Write-Host "Adaptador detectado: $NetworkAdapter" -ForegroundColor Green
        } else {
            Write-Host "[ADVERTENCIA] No se detectó adaptador activo. Usando configuración por defecto." -ForegroundColor Yellow
            # Listar todos los adaptadores disponibles
            Write-Host "`nAdaptadores disponibles:" -ForegroundColor Cyan
            .\VBoxManage.exe list bridgedifs | Select-String "^Name:"
            throw "Por favor, ejecute nuevamente especificando el parámetro -NetworkAdapter"
        }
    }
    
    Write-Host "`n[1/6] Creando máquina virtual..." -ForegroundColor Cyan
    .\VBoxManage.exe createvm --name $VmName --ostype $Os_Type --register
    
    Write-Host "[2/6] Configurando especificaciones (RAM y CPU)..." -ForegroundColor Cyan
    .\VBoxManage.exe modifyvm $VmName --memory $RamMb --cpus $Cpus
    
    Write-Host "[3/6] Configurando red en modo Adaptador Puente..." -ForegroundColor Cyan
    .\VBoxManage.exe modifyvm $VmName --nic1 bridged --bridgeadapter1 $NetworkAdapter
    
    Write-Host "[4/6] Creando controlador SATA..." -ForegroundColor Cyan
    .\VBoxManage.exe storagectl $VmName --name "SATA Controller" --add sata --controller IntelAhci
    
    Write-Host "[5/6] Creando disco duro virtual ($DiskMb MB)..." -ForegroundColor Cyan
    .\VBoxManage.exe createmedium disk --filename $Disk_Path --size $DiskMb --format VDI
    
    Write-Host "[6/6] Adjuntando disco duro a la VM..." -ForegroundColor Cyan
    .\VBoxManage.exe storageattach $VmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $Disk_Path
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "[OK] VM '$VmName' creada exitosamente!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "`nConfiguración de red:" -ForegroundColor Cyan
    Write-Host "  Tipo: Adaptador Puente" -ForegroundColor White
    Write-Host "  Adaptador: $NetworkAdapter" -ForegroundColor White
    
} catch {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "[ERROR] Error al crear la VM: $_" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}