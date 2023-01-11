// Create SA
resource "yandex_iam_service_account" "sa" {
  name      = "sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.yc_folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  # depends_on = [
  #   yandex_iam_service_account.sa,
  # ]
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

# // Create SA
# resource "yandex_iam_service_account" "sa-ig" {
#   name      = "tf-sa-ig"
# }

# // Grant permissions
# resource "yandex_resourcemanager_folder_iam_member" "sa-igeditor" {
#   role      = "editor"
#   member    = "serviceAccount:${yandex_iam_service_account.sa-ig.id}"
#   depends_on = [
#     yandex_iam_service_account.sa-ig,
#   ]
# }