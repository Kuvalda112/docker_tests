# --- Этап 1: Сборка зависимостей (builder) ---
FROM python:3.11-slim AS builder

WORKDIR /build

# Создаем виртуальное окружение и добавляем его в PATH
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Копируем и устанавливаем зависимости (кэшируется отдельным слоем)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# --- Этап 2: Финальный образ ---
FROM python:3.11-slim

# Отключаем буферизацию вывода Python (логи сразу видны в docker logs)
ENV PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Создаем системного пользователя без домашней директории и пароля
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Копируем готовое виртуальное окружение из этапа builder
COPY --from=builder /opt/venv /opt/venv

# Копируем код приложения и сразу назначаем владельцем appuser
COPY --chown=appuser:appgroup server.py .

# Переключаемся на непривилегированного пользователя
USER appuser

EXPOSE 5000

CMD ["python3", "server.py"]

