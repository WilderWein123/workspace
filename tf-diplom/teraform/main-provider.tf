terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = "b1gcd1nmr4tl1hd9duc8"
  folder_id = "b1gj6ia0559mol9ufg9k"
  zone      = "ru-central1-a"
}

variable "yandex_cloud_token" {
  type        = string
  description = "Данная переменная потребует ввести секретный токен в консоли при запуске terraform plan/apply"
}
