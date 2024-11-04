# Установка кластера Kubernetes в Yandex Cloud с использованием Terraform

## Описание

Этот проект позволяет развернуть кластер Kubernetes в Yandex Cloud с использованием Terraform. Мы будем использовать модуль `all-zones-vpc-module` для создания необходимых сетевых ресурсов, с поддержкой сетевых политик и контроллером сетевой политики Calico, а также настраивать группы узлов и логирование.

## Содержание

- [Требования](#требования)
- [Установка](#установка)
- [Настройка переменных окружения](#Настройка переменных окружения)
- [Запуск проекта](#Запуск проекта)
- [Подключение к кластеру](#Подключение к кластеру)

## Требования

- Terraform 1.0 или выше
- Учетная запись Yandex Cloud
- Установленный `yc` (CLI для Yandex Cloud)
- Права доступа к Yandex Cloud для создания ресурсов

## Установка

1. **Клонируйте репозиторий:**

   git clone https://github.com/Zen-Crow/k8s-yc-clucter-terraform.git

   cd k8s-yc-clucter-terraform/

## Настройка переменных окружения

    команда powershell:

    . .\set_env.ps1

    команда linux:
    
    chmod +x set_env.sh && ./set_env.sh

## Запуск проекта 

из папки k8s/ выполнить команды:

    terraform init

    terraform plan

    terraform apply

## Подключение к кластеру

    terraform output
    
    введите в терминал команду "k8s_connection"

### Удалить ресурсы

    terraform destroy