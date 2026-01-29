# Bookstore-app
Простое CRUD-приложение (create,read,update,delete) со статикой в виде html-страниц + css, которое выводит на экран список книг, позволяет добавить книгу, редактировать книгу, удалить книгу.



 ## Требования

- python 3.12
- postgresql 16

## Запуск
Для запуска проекта выполнить:
```bash
git clone https://gitlab.com/khodyrev-ivan/diplom.git
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

## Ansible
Для первоначальной раскатки приложения на новой машине реализованы ansible roles:
- ./ansible/roles/install-docker
- ./ansible/roles/setup-bookstore-app

### install-docker
Устанавливает docker на ВМ (работает только с ubuntu)

### setup-bookstore-app
Создает директорию для проекта, клонирует репозиторий, генерирует .env на основе переменных 
- `app_image` - docker image для bookstore-app
- `db_user` - пользователь для БД
- `db_name` - имя базы данных
- `db_host` - хост, где находится postgres
- `db_password` - пароль пользователя `db_user`
и запускает проект с помощью docker compose

## GitlabCI
Для основной раскатки приложения на новой машине выбран инструмент GitlabCI:
- ./deployment/.gitlab-ci.yml

### .gitlab-ci.yml
Собирает образ, тестирует его и деплоит. Так же релизована функция роллбэка.
- `linter-app:job` - джоба для проверки кода приложения linter`ом
- `linter-docker:job` - джоба для проверки Dockerfile linter`ом
- `build:job` - джоба сборки image и дальнейшего пуша его в dockerhub
- `test:job` - джоба тестирования собранного image
- `prepare:job` - джоба подготовки рабочей дериктории проекта и файла `.env` на целевой машине для дальнейшего deploy
- `deploy-compose:job` - джоба для деплоя приложения  на целевой машине
- `rollback:job` - джоба для отката приложения на целевой машине к версии image с указанным TAG
- `telegram_notify_success:job` - джоба уведомления от телеграм-бота об успешной сборке
- `telegram_notify_failure:job` - джоба уведомления от телеграм-бота о неуспешной сборке
