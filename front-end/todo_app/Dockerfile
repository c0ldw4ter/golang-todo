# Используем официальный образ Flutter
FROM cirrusci/flutter:latest

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем все файлы проекта в контейнер
COPY . .

# Устанавливаем зависимости
RUN flutter pub get

# Команда, которая будет выполняться при запуске контейнера
CMD ["sh", "-c", "flutter run -d chrome --web-port 14888 --web-hostname 0.0.0.0"]