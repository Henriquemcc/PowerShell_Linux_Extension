using module .\CompressedArchiveType.psm1

function Compress-File {
    param(
        [Parameter(Mandatory = $true)][System.String[]]$Path,
        [Parameter(Mandatory = $false)][System.String]$DestinationPath,
        [Parameter(Mandatory = $false)][System.Int32]$CompressionLevel,
        [Parameter(Mandatory = $false)][CompressedArchiveType]$ArchiveType,
        # [Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$Encrypt,
        [Parameter(Mandatory = $false)][System.Security.SecureString]$Password,
        [Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$WhatIf,
        [Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$Confirm,
        [Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$Recurse,
        [Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$Force
    )

    # Exiting if destination path exist
    if (!$Force -and (Test-Path -Path $DestinationPath)) {
        throw "Destination path $DestinationPath already exist."
    }

    # Getting Archive Type
    if (!$ArchiveType) {
        $extension = [System.IO.Path]::GetExtension($DestinationPath).ToLower()

        # 7z
        if ($extension -eq ".7z") {
            $ArchiveType = [CompressedArchiveType]::_7z
        }

        # tar.xz or xz
        elseif ($extension -eq ".xz") {
            $secondExtension = [System.IO.Path]::GetExtension([System.IO.Path]::GetFileNameWithoutExtension($DestinationPath)).ToLower()
            if ($secondExtension -eq ".tar") {
                $ArchiveType = [CompressedArchiveType]::TAR_XZ
            }
            else {
                $ArchiveType = [CompressedArchiveType]::XZ
            }
        }

        # tar.bz2 or bz2
        elseif ($extension -eq ".bz2") {
            $secondExtension = [System.IO.Path]::GetExtension([System.IO.Path]::GetFileNameWithoutExtension($DestinationPath)).ToLower()
            if ($secondExtension -eq ".tar") {
                $ArchiveType = [CompressedArchiveType]::TAR_BZIP2
            }
            else {
                $ArchiveType = [CompressedArchiveType]::BZIP2
            }
            
        }

        # tar.gz or gz
        elseif ($extension -eq ".gz") {
            $secondExtension = [System.IO.Path]::GetExtension([System.IO.Path]::GetFileNameWithoutExtension($DestinationPath)).ToLower()
            if ($secondExtension -eq ".tar") {
                $ArchiveType = [CompressedArchiveType]::TAR_GZIP
            }
            else {
                $ArchiveType = [CompressedArchiveType]::GZIP
            }
        }

        # tar.lz or lz
        elseif ($extension -eq ".lz") {
            $secondExtension = [System.IO.Path]::GetExtension([System.IO.Path]::GetFileNameWithoutExtension($DestinationPath)).ToLower()
            if ($secondExtension -eq ".tar") {
                $ArchiveType = [CompressedArchiveType]::TAR_LZ
            }
            else {
                $ArchiveType = [CompressedArchiveType]::LZ
            }
        }

        # tar.lzo or lzo
        elseif ($extension -eq ".lzo") {
            $secondExtension = [System.IO.Path]::GetExtension([System.IO.Path]::GetFileNameWithoutExtension($DestinationPath)).ToLower()
            if ($secondExtension -eq ".tar") {
                $ArchiveType = [CompressedArchiveType]::TAR_LZO
            }
            else {
                $ArchiveType = [CompressedArchiveType]::LZO
            }
        }

        # tar.zst or zst
        elseif ($extension -eq ".zst") {
            $secondExtension = [System.IO.Path]::GetExtension([System.IO.Path]::GetFileNameWithoutExtension($DestinationPath)).ToLower()
            if ($secondExtension -eq ".tar") {
                $ArchiveType = [CompressedArchiveType]::TAR_ZST
            }
            else {
                $ArchiveType = [CompressedArchiveType]::ZST
            }
        }


        # tar
        elseif ($extension -eq ".tar") {
            $ArchiveType = [CompressedArchiveType]::TAR
        }

        # zip
        elseif ($extension -eq ".zip") {
            $ArchiveType = [CompressedArchiveType]::ZIP
        }

        # wim
        elseif ($extension -eq ".wim") {
            $ArchiveType = [CompressedArchiveType]::WIM
        }
    }

    # Compressing 7-Zip
    if ($ArchiveType -eq [CompressedArchiveType]::_7z) {

        $command = [System.Text.StringBuilder]::new()

        # Command 7z
        $command.Append("7z")

        # Add files to archive
        $command.Append(" a")

        # switches

        # Overwrite All existing files without prompt
        if ($Force) {
            $command.Append(" -aoa")
        }

        # set Password
        if ($Password) {
            $command.Append(" -p $Password")
        }

        # Recurse subdirectories
        if ($Recurse) {
            $command.Append(" -r")
        }

        # archive name
        $command.Append(" $DestinationPath")

        # file names
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing XZ
    elseif ($ArchiveType -eq [CompressedArchiveType]::XZ) {

        $command = [System.Text.StringBuilder]::new()

        # Command xz
        $command.Append("xz")

        # force compression
        $command.Append(" --compress")

        # keep (don't delete) input files
        $command.Append(" --keep")

        # FILE
        $command.Append(" $($Path[0])")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command

        # Renaming destination file
        Move-Item -Path "$($Path[0]).xz" -Destination $DestinationPath
    }

    # Compressing BZIP2
    elseif ($ArchiveType -eq [CompressedArchiveType]::BZIP2) {

        $command = [System.Text.StringBuilder]::new()

        # Command bzip2
        $command.Append("bzip2")

        # force compression
        $command.Append(" --compress")

        # keep (don't delete) input files
        $command.Append(" --keep")

        # FILE
        $command.Append(" $($Path[0])")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command

        # Renaming destination file
        Move-Item -Path "$($Path[0]).bz2" -Destination $DestinationPath
    }

    # Compressing GZIP
    elseif ($ArchiveType -eq [CompressedArchiveType]::GZIP) {

        $command = [System.Text.StringBuilder]::new()

        # Command gzip
        $command.Append("gzip")

        # force compression
        $command.Append(" --compress")

        # keep (don't delete) input files
        $command.Append(" --keep")

        # FILE
        $command.Append(" $($Path[0])")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command

        # Renaming destination file
        Move-Item -Path "$($Path[0]).gz" -Destination $DestinationPath
    }

    # Compressing TAR
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR XZ
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_XZ) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through xz
        $command.Append(" --xz")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR GZ
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_GZIP) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through gzip
        $command.Append(" --gzip")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR BZ2
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_BZIP2) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")
        
        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through bzip2
        $command.Append(" --bzip2")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR LZ
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_LZ) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through lzip
        $command.Append(" --lzip")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR XZ with LZMA
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_LZMA) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through xz --format=lzma
        $command.Append(" --lzma")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR LZO
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_LZO) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through lzop
        $command.Append(" --lzop")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing TAR ZST
    elseif ($ArchiveType -eq [CompressedArchiveType]::TAR_ZST) {

        $command = [System.Text.StringBuilder]::new()

        # Command tar
        $command.Append("tar")

        # create a new archive
        $command.Append(" --create")

        # recurse into directories (default)
        if ($Recurse) {
            $command.Append(" --recursion")
        }

        # avoid descending automatically in directories
        else {
            $command.Append(" --no-recursion")
        }

        # filter the archive through zstd
        $command.Append(" --zstd")

        # use archive file or device ARCHIVE
        $command.Append(" --file=$DestinationPath")

        # FILE
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing ZIP
    elseif ($ArchiveType -eq [CompressedArchiveType]::ZIP) {

        $command = [System.Text.StringBuilder]::new()

        # Command zip
        $command.Append("zip")

        # recurse into directories
        if ($Recurse) {
            $command.Append(" -r")
        }

        # -0    store only
        # -1    compress faster
        # -9    compress better
        if ($CompressionLevel) {
            $command.Append(" -$CompressionLevel")
        }

        # zip file
        $command.Append(" $DestinationPath")

        # file
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }

    # Compressing WIM
    elseif ($ArchiveType -eq [CompressedArchiveType]::WIM) {

        $command = [System.Text.StringBuilder]::new()

        # Command 7z
        $command.Append("7z")

        # Add files to archive
        $command.Append(" a")

        # switches

        # Overwrite All existing files without prompt
        if ($Force) {
            $command.Append(" -aoa")
        }

        # set Password
        if ($Password) {
            $command.Append(" -p $Password")
        }

        # Recurse subdirectories
        if ($Recurse) {
            $command.Append(" -r")
        }

        # archive name
        $command.Append(" $DestinationPath")

        # file names
        $command.Append(" $($Path -join ' ')")

        # Converting to string
        $command = $command.ToString()

        # Running command
        Invoke-Expression -Command $command
    }
}