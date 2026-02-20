# Bookstore-app
Простое CRUD-приложение (create,read,update,delete) со статикой в виде html-страниц + css, которое выводит на экран список книг, позволяет добавить книгу, редактировать книгу, удалить книгу.

![notify](/attachments/app.png)

Проект состоит из двух репозиториев:
- **[bookstore-app-ci-cd](https://gitlab.com/khodyrev-ivan/bookstore-app-ci-cd)** — код приложения и его CI/CD пайплайн
- **[IaC-terraform-ansible](https://gitlab.com/khodyrev-ivan/IaC-terraform-ansible)** — инфраструктурный код для создания ВМ в Yandex Cloud

## Требования

- python 3.12
- postgresql 16

## Запуск
Для локального запуска проекта выполнить:
```bash
git clone https://gitlab.com/khodyrev-ivan/bookstore-app-ci-cd.git
cd diplom/
cp env.example .env #заменить значения переменных
docker compose up -d --build
docker compose ps
```

### Проверка
```bash
# Добавить книгу
curl -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "title=Зачем нужны эмоции и что с ними делать? Как сделать эмоции и чувства своими друзьями&author=Мусихин Александр&price=578&count=7" \
  http://localhost:8000/create
# Получить список книг
curl -s http://localhost:8000/books | \
  grep -E 'book-title|book-author|book-price|book-stock' | \
  sed 's/.*<h3 class="book-title">\(.*\)<\/h3>/\1/' | \
  sed 's/.*<strong>Автор:<\/strong> \(.*\)<\/p>/\1/' | \
  sed 's/.*<strong>Цена:<\/strong> \(.*\) руб\.<\/p>/\1/' | \
  sed 's/.*<strong>В наличии:<\/strong> \(.*\) шт\.<\/p>/\1/'
# Отредактировать книгу
curl -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "title=Зачем нужны эмоции&author=Мусихин Александр&price=600&count=10" \
  http://localhost:8000/edit/23
# Удалить книгу
curl http://localhost:8000/delete/23
```
или перейти в браузере по адресу 127.0.0.1:8000/

## GitLabCI
Для автоматизации развертывания приложения используется GitLab CI/CD. 
Пайплайн описан в файле `./deployment/.gitlab-ci.yml`:

### .gitlab-ci.yml
Пайплайн собирает Docker-образ, тестирует его и выполняет деплой. Также реализована возможность отката (rollback).

- `linter-app:job` - проверка кода приложения (pylint)
- `linter-docker:job` - проверка Dockerfile (hadolint)
- `build:job` - сборка образа и публикация в DockerHub
- `test:job` - тестирование собранного образа
- `prepare:job` - подготовка рабочей директории и файла `.env` на целевой ВМ
- `deploy-compose:job` - деплой приложения (ручной запуск)
- `rollback:job` - откат к указанной версии образа (ручной запуск)
- `post:job` - уведомление в Telegram при падении пайплайна

### GitLab Variables

- `DB_PASS` - пароль для БД
- `DB_PASS_TST` - пароль для тестовой БД
- `DOCKER_TOKEN` - токен для доступа к dockerhub
- `HOST` - PUB_IP целевой машины
- `SSH_KEY` - Приватный SSH-ключ. Для подключения к целевой машине.
- `TELEGRAM_BOT_TOKEN` - Токен бота для отправки уведомлений о результате деплоя
- `TELEGRAM_CHAT_ID` - ID чата, куда бот отправляет сообщения

## IaC

### Инструменты
- Terraform
- Ansible

### Terraform
- `main.tf` - Провайдер, бэкенд
- `vars.tf` - Переменные
- `instances.tf` - Описание ВМ, загрузочного диска, сети

State-файл хранится в S3 хранилище Yandex Cloud.
Доступ настраивается через сервисный аккаунт и переменные `YC_ACCESS_KEY` и `YC_SECRET_KEY`.

### Ansible
Для установки docker на новой машине реализована ansible roles:
- ./ansible/roles/install-docker

#### install-docker
Устанавливает docker на ВМ (работает только с ubuntu)

### GitLabCI

В репозитории реализовано два pipelines:

#### tf-pipeline.yml
Отвечает за управление инфраструктурой:
- `linter:job` - проверка Terraform кода
- `validate:job` - валидация конфигурации
- `plan:job` - создание плана изменений
- `apply:job` - применение изменений (ручной запуск)
- `destroy:job` - уничтожение инфраструктуры (ручной запуск)
- `trigger:ansible` - запуск Ansible пайплайна после успешного apply

#### ansible-pipeline.yml
Отвечает за установку Docker на созданной ВМ:
- `syntax:check` - проверка синтаксиса playbook
- `apply-playbook` - применение playbook (ручной запуск)

### Screenshots

#### IaC-pipeline
![notify](/attachments/setup_infra.png)

#### IaC-notify
![notify](/attachments/setup_infra_notify.png)

#### Deploy
![notify](/attachments/build.png)

#### Rollback
![notify](/attachments/rollback.png)

#### DeployandRollback-notify
![notify](/attachments/build_notify.png)

#### App in browser
![notify](/attachments/app.png)

#### Destroy
![notify](/attachments/destroy.png)

#### Destroy-notify
![notify](/attachments/destroy_infra_notify.png)