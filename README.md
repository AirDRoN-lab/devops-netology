# devops-netology
Пора выйти из зоны комфорта!
Новая строка в файле в ветке fix

# любые файлы в директориях и субдиректориях .terraform.  
**/.terraform/*

# все файлы с раширением tfstate, а также с расширением начинающимся на tfstate.
*.tfstate 
*.tfstate.*

# файл crash.log в текущей директории
crash.log

# любые файлы с расширением tfcars в текущей директории
*.tfvars

# файл override.tf, override.tf.json, а также любые файлы с окончанием _override.tf И _override.tf.json в текущей директории 
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# файл ..terraformrc и terraform.rc 
.terraformrc
terraform.rc
