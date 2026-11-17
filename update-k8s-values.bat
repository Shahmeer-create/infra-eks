@echo off
echo Getting Terraform outputs...

for /f "tokens=*" %%i in ('.\terraform output -raw ecr_repository_url') do set ECR_URL=%%i
for /f "tokens=*" %%i in ('.\terraform output -raw s3_photos_bucket') do set S3_BUCKET=%%i
for /f "tokens=*" %%i in ('.\terraform output -raw backend_app_role_arn') do set BACKEND_ROLE=%%i
for /f "tokens=*" %%i in ('.\terraform output -raw karpenter_node_role_name') do set KARPENTER_ROLE=%%i
for /f "tokens=*" %%i in ('.\terraform output -raw alb_security_group_id') do set ALB_SG=%%i

echo ECR URL: %ECR_URL%
echo S3 Bucket: %S3_BUCKET%
echo Backend Role: %BACKEND_ROLE%
echo Karpenter Role: %KARPENTER_ROLE%
echo ALB SG: %ALB_SG%

echo.
echo Updating kubernetes YAML files...

powershell -Command "(Get-Content kubernetes\05-backend.yaml) -replace 'REPLACE_WITH_BACKEND_APP_ROLE_ARN', '%BACKEND_ROLE%' -replace 'REPLACE_WITH_ECR_REPOSITORY_URL', '%ECR_URL%' -replace 'REPLACE_WITH_S3_PHOTOS_BUCKET', '%S3_BUCKET%' | Set-Content kubernetes\05-backend.yaml"

powershell -Command "(Get-Content kubernetes\02-karpenter-nodepool.yaml) -replace 'KARPENTER_NODE_ROLE_NAME', '%KARPENTER_ROLE%' | Set-Content kubernetes\02-karpenter-nodepool.yaml"

powershell -Command "(Get-Content kubernetes\06-ingress.yaml) -replace 'REPLACE_WITH_ALB_SECURITY_GROUP_ID', '%ALB_SG%' | Set-Content kubernetes\06-ingress.yaml"

echo Done. Now manually update REPLACE_WITH_PUBLIC_SUBNET_IDS in kubernetes\06-ingress.yaml
echo Run: .\terraform output public_subnet_ids
