# Maze Ball Game

Игра-лабиринт, разработанная на Flutter с использованием Flame engine.

## Особенности

- Процедурная генерация лабиринтов
- Настраиваемая сложность
- Ограниченная видимость с настраиваемым радиусом
- Таймер для отслеживания времени прохождения
- Простое управление с помощью стрелок

## Как играть

1. Нажмите "Начать новую игру"
2. Настройте параметры игры:
   - Сложность: определяет размер лабиринта
   - Ограниченная видимость: включает/выключает туман войны
   - Радиус видимости: настраивает размер видимой области
3. Используйте стрелки для перемещения шарика к зеленой точке финиша
4. Постарайтесь пройти лабиринт за минимальное время!

## Технологии

- Flutter
- Flame engine
- Bloc для управления состоянием
- Canvas для отрисовки игрового поля

## Запуск проекта

```bash
flutter pub get
flutter run
```

## Сборка для web

```bash
flutter build web
```
