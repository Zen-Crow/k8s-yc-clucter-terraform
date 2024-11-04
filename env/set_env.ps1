$env:TF_VAR_cloud_id=$(yc config get cloud-id)
$env:TF_VAR_folder_id=$(yc config get folder-id)
$env:TF_VAR_yc_token=$(yc iam create-token)

Write-Host "Переменные окружения установлены."