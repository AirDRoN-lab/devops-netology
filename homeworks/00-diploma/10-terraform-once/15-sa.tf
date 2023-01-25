// Create SA
resource "yandex_iam_service_account" "tf-sa" {
  folder_id = var.YC_FOLDER_ID
  name      = "tf-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id =  var.YC_FOLDER_ID
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.tf-sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "tf-sa-static-key" {
  service_account_id = yandex_iam_service_account.tf-sa.id
  description        = "static access key"
}
