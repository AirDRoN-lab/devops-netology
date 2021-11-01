# devops-netology
Пора выйти из зоны комфорта!

# любые файлы в директориях и субдиректориях .terraform (начиная с текущей директории)  
**/.terraform/*

# все файлы с раширением tfstate, а также все файлы с .tfstate. в середине имени файла (в текущей директории)
*.tfstate 
*.tfstate.*

# файл crash.log (в текущей директории)
crash.log

# любые файлы с расширением tfvars (в текущей директории)
*.tfvars

# файл override.tf, override.tf.json, а также любые файлы с окончанием _override.tf и _override.tf.json (в текущей директории) 
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# файл .terraformrc и terraform.rc (в текущей директории)
.terraformrc
terraform.rc
