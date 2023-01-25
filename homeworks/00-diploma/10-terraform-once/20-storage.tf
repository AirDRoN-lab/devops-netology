// Use keys to create bucket
resource "yandex_storage_bucket" "tf-bucket" {
  access_key = yandex_iam_service_account_static_access_key.tf-sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf-sa-static-key.secret_key
  bucket = "tf-bucket"
}

# resource "yandex_storage_object" "sigal" {
#   access_key = yandex_iam_service_account_static_access_key.tf-sa-static-key.access_key
#   secret_key = yandex_iam_service_account_static_access_key.tf-sa-static-key.secret_key
#   bucket = "ya-bucket-001"
#   key    = "sigal.jpg"
#   source = "pic/sigal.jpg"
#   depends_on = [time_sleep.wait_60_seconds]
# }
