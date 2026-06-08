# Деплой на Render через Docker Compose

Render теж підтримує Docker Compose. Ось як налаштувати деплой.

## Крок 1: Підготувати репозиторій

```bash
git add docker-compose.yml docker-compose.prod.yml
git commit -m "Add prod compose config for Render"
git push origin main
```

## Крок 2: Логін на Render та створити новий проєкт

1. Перейдіть на [render.com](https://render.com)
2. Логіньтесь (GitHub, Google тощо)
3. Натисніть **New** → **Web Service**
4. Виберіть **Docker** → вкажіть ваш репозиторій

## Крок 3: Налаштувати Docker Compose

На Render Docker Compose **не підтримується нативно** як на Railway. Замість цього:

### Варіант А: Деплоїти окремо (рекомендується)

Создайте **два вебсервісу** на Render:

#### 1. Frontend сервіс
- **Name:** `my-fullstack-frontend`
- **Image Registry:** ghcr.io
- **Image:** `ghcr.io/anton0886/my-fullstack-frontend:latest`
- **Port:** 80
- **Environment Variables:**
  ```env
  VITE_API_URL=https://my-fullstack-backend.onrender.com
  ```

#### 2. Backend сервіс
- **Name:** `my-fullstack-backend`
- **Image Registry:** ghcr.io
- **Image:** `ghcr.io/anton0886/my-fullstack-backend:latest`
- **Port:** 5000
- **Environment Variables:**
  ```env
  DATABASE_URL=your-postgresql-url
  NODE_ENV=production
  ```

### Варіант Б: Використовувати `docker-compose.yml` через `render.yaml` (Advanced)

Створіть `render.yaml` у корені репозиторія:

```yaml
services:
  - type: web
    name: my-fullstack-frontend
    runtime: docker
    dockerfilePath: ./frontend/Dockerfile
    dockerBuildArgs:
      VITE_API_URL: https://my-fullstack-backend.onrender.com
    envVars:
      - key: NODE_ENV
        value: production
    port: 80
    healthCheckPath: /health

  - type: web
    name: my-fullstack-backend
    runtime: docker
    dockerfilePath: ./backend/Dockerfile
    envVars:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: postgres
          property: connectionString
    port: 5000

  - type: pserv
    name: postgres
    plan: free
    ipAllowList: []
```

Потім натисніть **Deploy** — Render прочитає `render.yaml`.

## Крок 4: Налаштувати Database

### На Render:
1. У вашому сервісі натисніть **Add Service** → **PostgreSQL**
2. Render автоматично створить базу і додасть `DATABASE_URL` до environment

### Альтернатива: Зовнішня БД
Якщо у вас вже є PostgreSQL (Neon, Supabase тощо):
- Додайте `DATABASE_URL=postgres://user:pass@host:5432/db` у Environment Variables

## Крок 5: Оновити Frontend Nginx Config

Ваш `nginx.conf` жорстко використовує `http://backend:5000`. На Render це не працює.

**Рішення:** Зробіть конфіг параметричним через `envsubst`.

### Оновіть `frontend/Dockerfile` (prod stage):

```dockerfile
FROM nginx:alpine AS prod
RUN apk upgrade --no-cache
WORKDIR /app

# Copy nginx config template
COPY nginx/nginx.conf /etc/nginx/nginx.conf.template

# Create entrypoint that substitutes variables
RUN echo '#!/bin/sh\n\
export BACKEND_HOST=${BACKEND_HOST:-backend}\n\
export BACKEND_PORT=${BACKEND_PORT:-5000}\n\
envsubst '\''$${BACKEND_HOST},$${BACKEND_PORT}'\'' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf\n\
exec nginx -g "daemon off;"' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["/app/entrypoint.sh"]
```

### Оновіть `frontend/nginx/nginx.conf`:

Замініть жорстко закодований `backend`:
```nginx
# OLD:
proxy_pass         http://backend:5000;

# NEW:
proxy_pass         http://${BACKEND_HOST}:${BACKEND_PORT};
```

### На Render додайте Environment Variables:
```env
BACKEND_HOST=my-fullstack-backend.onrender.com
BACKEND_PORT=5000
```

## Крок 6: Деплоїти

1. Натисніть **Deploy**
2. Render завантажить образи та стартує контейнери
3. Отримайте публічний URL: `https://my-fullstack-frontend.onrender.com`

## Моніторинг

- **Логи:** натисніть на сервіс → **Logs**
- **Shell:** натисніть на сервіс → **Shell**
- **Перезагрузка:** натисніть на сервіс → **Restart**

## Усунення неполадок

### `host not found in upstream`
- Зробіть конфіг параметричним (див. вище)
- Передавайте `BACKEND_HOST=your-backend.onrender.com`

### Образи не знаходяться
- Переконайтесь, що образи в `ghcr.io` публічні
- Або налаштуйте Render читати з приватного реєстру (через CLI)

### Database connexion failed
- Переконайтесь, що `DATABASE_URL` коректна
- На Render PostgreSQL по замовчуванню на `localhost`, в compose потрібно `db`

---

## Рекомендація

**Railway краще для Docker Compose деплою** — нативна підтримка.  
**Render краще для окремих сервісів** — але потребує більше налаштування.

Якщо хочете максимальної простоти — **виберіть Railway**.

---

**Next step:** [Див. також деплой на Railway](DEPLOY_RAILWAY.md)
