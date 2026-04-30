## 🚀 Скрипт автоматического обновления zapret-discord-youtube

### 📦 Назначение

Скрипты для бесшовного обновления уже установленной версии [zapret-discord-youtube](https://github.com/flowseal/zapret-discord-youtube).
Скачайте новую версию, распакуйте содержимое в папку `update` внутри основного каталога и запустите `update.bat`.

### ✨ Что делает update.bat

- **Проверяет папку `update`** — если пустая или не хватает важных файлов, останавливается с подсказкой.
- **Сохраняет состояние сервиса** — если zapret запущен как служба, запоминает стратегию, останавливает сервис, а после обновления перезапускает с той же стратегией.
- **Запускает `update_script.ps1`**, который:
  - объединяет текстовые списки из папок `update/lists` и `update/utils` с существующими;
  - заменяет все `.bat`-файлы (кроме `update.bat`);
  - обновляет папку `bin`;
  - заменяет `test zapret.ps1` в `utils`;
  - удаляет временные файлы и очищает папку `update`.

### 🛠 Что делает warp_masque.bat

Отдельный скрипт для перевода туннеля Cloudflare WARP на протокол **MASQUE**. Запускается независимо от обновления.

### ⚙️ Требования

- **ОС:** Windows 10/11
- **Права администратора** — обязательны (скрипт запросит сам)
- **Основная программа:** установленный [zapret-discord-youtube](https://github.com/flowseal/zapret-discord-youtube/releases)
- [**Cloudflare WARP**](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/cloudflare-one-client/download) — опционально, только для `warp_masque.bat`
- **PowerShell 5.1+** (есть из коробки в Windows 10/11)

### 📥 Установка и использование

1. Скачайте [релиз](https://github.com/flowseal/zapret-discord-youtube/releases) этого скрипта. Распакуйте его **прямо в корень установленной** утилиты zapret-discord-youtube.
   В результате там появятся файлы `update.bat`, `update_core.bat`, `update_script.ps1`, `warp_masque.bat` и пустая папка `update`.

2. Скачайте новую версию [zapret-discord-youtube](https://github.com/flowseal/zapret-discord-youtube/releases) и распакуйте содержимое архива **внутрь папки `update`**.

3. Запустите `update.bat`. Права администратора запросятся автоматически.

### 📁 Состав

| Файл | Назначение |
|------|------------|
| `update.bat` | Главный скрипт обновления |
| `update_core.bat` | Служебный скрипт управления сервисом |
| `update_script.ps1` | PowerShell-скрипт обновления файлов |
| `warp_masque.bat` | Скрипт настройки WARP MASQUE |
| `update/` | Папка для размещения новой версии |
