# Установка кластера Kubernetes в Yandex Cloud с использованием Terraform

## Описание

Этот проект позволяет развернуть зональный кластер Kubernetes в Yandex Cloud с использованием Terraform. Мы будем использовать модуль `all-zones-vpc-module` для создания необходимых сетевых ресурсов, с поддержкой сетевых политик и контроллером сетевой политики Calico, а также настраивать группы узлов и логирование.

## Содержание

- [Установка](#установка)
- [Настройка переменных окружения](#настройка-переменных-окружения)
- [Запуск проекта](#запуск-проекта)
- [Подключение к кластеру](#подключение-к-кластеру)

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

    Необходимо установить следующие командные утилиты:

    kubectl 

    yc

    Команда для подключения к кластеру:

    yc managed-kubernetes cluster get-credentials --id <claster_id> --external

    kubectl cluster-info

### Удалить ресурсы

    terraform destroy