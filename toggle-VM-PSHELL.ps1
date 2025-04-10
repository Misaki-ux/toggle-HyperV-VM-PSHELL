# Ce script doit être enregistré avec l'extension .ps1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Auto-élévation des privilèges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Configuration du service
$serviceName = "vmms"  # Hyper-V Virtual Machine Management

# Configuration des couleurs
$darkBg = [System.Drawing.Color]::FromArgb(32, 32, 32)
$titleBg = [System.Drawing.Color]::FromArgb(48, 48, 48)
$redButton = [System.Drawing.Color]::FromArgb(237, 28, 36)
$greenButton = [System.Drawing.Color]::FromArgb(40, 167, 69)
$blueOutline = [System.Drawing.Color]::FromArgb(65, 173, 255)
$hoverColor = [System.Drawing.Color]::FromArgb(55, 55, 65)

# Creation de la fenetre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Hyper-V Toggle"
$form.Size = New-Object System.Drawing.Size(230, 120)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $darkBg
$form.TopMost = $true

# Barre de titre
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Dock = "Top"
$titleBar.Height = 25
$titleBar.BackColor = $titleBg
$form.Controls.Add($titleBar)

# Texte titre
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Hyper-V Toggle"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(10, 5)
$titleBar.Controls.Add($titleLabel)

# Bouton Reduire
$minimizeButton = New-Object System.Windows.Forms.Button
$minimizeButton.Text = "-"
$minimizeButton.FlatStyle = "Flat"
$minimizeButton.FlatAppearance.BorderSize = 0
$minimizeButton.Size = New-Object System.Drawing.Size(25, 25)
$minimizeButton.Location = New-Object System.Drawing.Point(170, 0)
$minimizeButton.ForeColor = [System.Drawing.Color]::White
$minimizeButton.BackColor = $titleBg
$minimizeButton.Add_Click({ $form.WindowState = "Minimized" })
$minimizeButton.Add_MouseEnter({ $this.BackColor = $hoverColor })
$minimizeButton.Add_MouseLeave({ $this.BackColor = $titleBg })
$titleBar.Controls.Add($minimizeButton)

# Bouton Fermer
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "X"
$closeButton.FlatStyle = "Flat"
$closeButton.FlatAppearance.BorderSize = 0
$closeButton.Size = New-Object System.Drawing.Size(25, 25)
$closeButton.Location = New-Object System.Drawing.Point(195, 0)
$closeButton.ForeColor = [System.Drawing.Color]::White
$closeButton.BackColor = $titleBg
$closeButton.Add_Click({ $form.Close() })
$closeButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(232, 17, 35) })
$closeButton.Add_MouseLeave({ $this.BackColor = $titleBg })
$titleBar.Controls.Add($closeButton)

# Fonction pour deplacer la fenetre
$lastPoint = $null
$titleBar.Add_MouseDown({
    $script:lastPoint = $_.Location
})
$titleBar.Add_MouseMove({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $form.Location = New-Object System.Drawing.Point(
            ($form.Location.X + $_.X - $script:lastPoint.X),
            ($form.Location.Y + $_.Y - $script:lastPoint.Y))
    }
})

# Label statut
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Etat du service:"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.ForeColor = [System.Drawing.Color]::LightGray
$statusLabel.Location = New-Object System.Drawing.Point(15, 40)
$statusLabel.Size = New-Object System.Drawing.Size(90, 20)
$form.Controls.Add($statusLabel)

# Label valeur statut
$statusValue = New-Object System.Windows.Forms.Label
$statusValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$statusValue.ForeColor = [System.Drawing.Color]::LightGreen
$statusValue.Location = New-Object System.Drawing.Point(105, 40)
$statusValue.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($statusValue)

# Bouton d'action
$toggleButton = New-Object System.Windows.Forms.Button
$toggleButton.Size = New-Object System.Drawing.Size(100, 30)
$toggleButton.Location = New-Object System.Drawing.Point(65, 70)
$toggleButton.FlatStyle = "Flat"
$toggleButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$toggleButton.ForeColor = [System.Drawing.Color]::White
$toggleButton.FlatAppearance.BorderColor = $blueOutline
$toggleButton.FlatAppearance.BorderSize = 1
$toggleButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($toggleButton)

# Fonction pour mettre a jour l'etat
function Update-ServiceStatus {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($null -eq $service) {
        $statusValue.Text = "Non trouve"
        $statusValue.ForeColor = [System.Drawing.Color]::Yellow
        $toggleButton.Enabled = $false
        return
    }
    
    if ($service.Status -eq "Running") {
        $statusValue.Text = "ACTIF"
        $statusValue.ForeColor = [System.Drawing.Color]::LightGreen
        $toggleButton.Text = "OFF"
        $toggleButton.BackColor = $redButton
    } else {
        $statusValue.Text = "INACTIF"
        $statusValue.ForeColor = [System.Drawing.Color]::Gray
        $toggleButton.Text = "ON"
        $toggleButton.BackColor = $greenButton
    }
}

# Action du bouton
$toggleButton.Add_Click({
    $service = Get-Service -Name $serviceName
    
   # Changer le curseur pendant l'operation
    $oldCursor = [System.Windows.Forms.Cursor]::Current
    [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
        
    try {
        if ($service.Status -eq "Running") {
            # Arreter le service
            Stop-Service -Name $serviceName -Force
            Set-Service -Name $serviceName -StartupType Disabled
            [System.Windows.Forms.MessageBox]::Show("Service Hyper-V arrete et desactive.", "Succes", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            # Demarrer le service
            Set-Service -Name $serviceName -StartupType Automatic
            Start-Service -Name $serviceName
            [System.Windows.Forms.MessageBox]::Show("Service Hyper-V demarre et active.", "Succes", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur: Impossible de modifier le service.", "Erreur", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } finally {
    
        # Restaurer le curseur
        [System.Windows.Forms.Cursor]::Current = $oldCursor
    }
    
    # Mettre a jour l'affichage
    Update-ServiceStatus
})

# Initialiser l'etat
Update-ServiceStatus

# Afficher la fenetre
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
