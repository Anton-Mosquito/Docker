# Деплой на Railway через Docker Compose

Railway підтримує нативний `docker-compose.yml` деплой. Це найпростіший спосіб розгорнути весь стек одразу.

## Крок 1: Підготувати репозиторій

Переконайтеся, що у вас в гілці `main`:
```bash
git add docker-compose.yml docker-compose.prod.yml
git commit -m "Add prod compose config for Railway"
git push origin main
```

## Крок 2: Логін на Railway та створити новий проєкт

1. Перейдіть на [railway.app](https://railway.app)
2. Логіньтесь (GitHub, Google тощо)
3. Натисніть **New Project** → **Deploy from GitHub**
4. Виберіть ваш репозиторій

## Крок 3: Налаштувати Docker Compose деплой

Railway **автоматично** детектує `docker-compose.yml`. Якщо цього не сталося:

1. У проєкті натисніть **Add Service** → **Docker Compose**
2. Виберіть гілку `main`
3. Railway прочитає `docker-compose.yml`

## Крок 4: Налаштувати змінні середовища (Environment Variables)

Натисніть **Variables** і додайте:

```env
# Frontend
VITE_API_URL=https://your-backend-url.railway.app
REGISTRY=ghcr.io
IMAGE_OWNER=anton0886
FRONTEND_TAG=latest

# Backend
BACKEND_HOST=backend
BACKEND_PORT=5000
DATABASE_URL=postgres://postgres:${DB_PASSWORD}@db:5432/postgres
DB_PASSWORD=your-secure-password

# Database
POSTGRES_PASSWORD=your-secure-password
NODE_ENV=production
```

**Важно:** На Railway `backend`, `frontend`, `db` будуть спілкуватися через внутрішню мережу за назвами сервісів!

## Крок 5: Натискайте Deploy

1. Натисніть **Deploy** 
2. Railway збудує / натягне образи
3. Контейнери стартуватимуться за залежностями

## Як додати публічні URL

### Для Frontend (NGINX)
1. Натисніть на сервіс `frontend`
2. **Settings** → **Networking**
3. Виберіть **Public URL** → отримайте `https://your-app.railway.app`

### Для Backend (опціонально)
Якщо хочете публічний API:
1. Натисніть на `backend`
2. **Settings** → **Networking**
3. Виберіть **Public URL** → отримайте `https://your-api.railway.app`

## Крок 6: Оновити VITE_API_URL

Коли у вас є публічний URL для backend, оновіть змінну:
```env
VITE_API_URL=https://your-api.railway.app
```

## Моніторинг та логи

- **Логи:** натисніть на сервіс → **View Logs**
- **Метрики:** натисніть на сервіс → **Metrics**
- **Перезагрузка:** натисніть на сервіс → **Restart**

## Усунення неполадок

### `host not found in upstream "backend"`
- Переконайтесь, що `backend` сервіс **запущено** (в Railway dashboard)
- Переконайтесь, що змінна `BACKEND_HOST=backend` встановлена

### Образи не завантажуються
- Переконайтесь, що `REGISTRY=ghcr.io`, `IMAGE_OWNER=anton0886`
- Образи мають бути публічні або ви мусите залогінитися через Railway CLI

### Database помилки
- Railway створює `postgres-data` том автоматично
- `db` має статус **Running** перед тим як `backend` стартує

## Обновлення коду

Кожен раз, коли ви пушите в `main`:
```bash
git push origin main
```

Railway **автоматично** перебудує образи і перезагрузить контейнери.

---

**Next step:** [Див. також деплой на Render](DEPLOY_RENDER.md)
