using module ./Compress-File.psm1

# Creating a file called hello.txt
$string = "Hello World!"
$pathFile = [System.IO.Path]::Combine($env:HOME, "hello.txt")
Out-File -Path $pathFile -InputObject $string

# Compressing hello.txt
$pathCompressedFile = "$($pathFile).xz"
Compress-File -Path $pathFile -DestinationPath  $pathCompressedFile -Force