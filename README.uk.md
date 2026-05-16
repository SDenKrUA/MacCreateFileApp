# Mac Create File

Mac Create File — це macOS утиліта, яка додає у Finder меню правої кнопки для створення нових файлів у поточній папці. Проєкт створений з нуля на Swift як native macOS app + Finder Sync extension.

## Можливості

- Додає підменю `Створити файл` у контекстне меню Finder.
- Створює типи файлів: `txt`, `md`, `rtf`, `csv`, `json`, `html`, `css`, `js`, `py`, `swift`, `sh`, `pdf`, `docx`, `xlsx`, `pptx`.
- Не перезаписує існуючі файли, а автоматично додає номер, наприклад `Новий текстовий файл 2.txt`.
- Виділяє створений файл у Finder.
- Копіює шляхи вибраних файлів або папок.
- Відкриває Terminal у поточній папці Finder.
- Має англійську та українську локалізації.

## Вимоги

- macOS 13 або новіша.
- Для локальної збірки потрібен повний Xcode або Command Line Tools з macOS SDK.

## Встановлення

1. Завантаж `.zip` з GitHub Releases.
2. Розпакуй його.
3. Перемісти `Mac Create File.app` у `Applications`.
4. Відкрий `Applications/Mac Create File.app`.
5. Натисни `Увімкнути Finder Extension`.
6. Натисни `Відкрити налаштування extension` і вручну увімкни `Mac Create File Finder Extension`, якщо macOS попросить це зробити.
7. Перезапусти Finder з додатку або перелогінься.
8. Натисни правою кнопкою у папці Finder і вибери `Створити файл`.

macOS не завжди дозволяє стороннім додаткам повністю автоматично вмикати Finder extensions, тому ручне підтвердження в System Settings може бути обовʼязковим.

## Видалення

Перед видаленням додатку спочатку вимкни Finder extension:

1. Відкрий `Mac Create File.app`.
2. Натисни `Вимкнути Finder Extension`.
3. Перемісти `Mac Create File.app` у Trash.

У release zip також є `uninstall.command`. Його можна запустити, щоб вимкнути Finder extension, перезапустити Finder і видалити службові файли:

```sh
./uninstall.command
```

macOS може залишити частину sandbox container metadata захищеною після видалення. Це не тримає меню Finder активним, якщо extension вже вимкнено.

Якщо меню Finder залишилось після видалення додатку, виконай:

```sh
pluginkit -e ignore -i com.sdenkrua.MacCreateFileApp.FinderExtension
killall Finder
```

## Якщо macOS блокує запуск

Локальна збірка підписується ad-hoc і не проходить Apple notarization. При першому запуску macOS може показати попередження про невідомого розробника.

Як відкрити:

1. Натисни правою кнопкою на `Mac Create File.app`.
2. Вибери `Open`.
3. У діалозі ще раз підтвердь `Open`.

Також можна дозволити запуск у `System Settings > Privacy & Security`.

## Локальна збірка

```sh
scripts/build_app.sh
```

Готовий додаток буде тут:

```text
dist/Mac Create File.app
```

Локальне встановлення:

```sh
scripts/install_local.sh
```

## Релізний пакет

```sh
VERSION=1.0.6 scripts/package_release.sh
```

Файли релізу створюються у `dist/`:

```text
MacCreateFile-1.0.6-mac-<arch>.zip
```

## Що всередині

Контекстне меню Finder реалізоване через Finder Sync extension. Extension реєструє корінь файлової системи як область моніторингу, щоб меню могло зʼявлятися в Finder по всій системі. Коли користувач обирає тип файлу, extension створює файл у цільовій папці та просить Finder показати його.

## Ліцензія

MIT. Код чужого додатку не копіювався.
