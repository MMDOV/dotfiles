# دات‌فایل‌های شخصی لینوکس

> [!WARNING]
> این ترجمه توسط هوش مصنوعی تولید شده است و ممکن است دقیق یا کامل نباشد. نسخه انگلیسی در [`README.md`](README.md) مرجع اصلی است و استفاده از آن توصیه می‌شود.

> [!IMPORTANT]
> این مخزن روند کاری و سلیقه شخصی من را منعکس می‌کند. می‌تواند به‌عنوان مرجع برای Hyprland، اتوماسیون Bash و مدیریت محیط دسکتاپ مفید باشد، اما قبل از اجرا روی سیستم دیگر باید بررسی شود.

این مخزن یک مجموعه فنی از دات‌فایل‌ها برای یک دسکتاپ Wayland بر پایه Hyprland است. در اینجا تنظیمات ماژولار دسکتاپ، قوانین Hyprland با Lua، اسکریپت‌های نصب پکیج، ابزارهای کمکی محلی، مدیریت session در tmux و تم‌های GTK/Qt/SDDM در یک setup قابل بازتولید کنار هم قرار گرفته‌اند.

این setup به‌جای اینکه به آن گفته شود روی چه سیستمی اجرا می‌شود، خودش آن را تشخیص می‌دهد. سطح توزیع (Arch معمولی در برابر مخازن بهینه‌شده CachyOS)، سازنده GPU، توان CPU، نوع دستگاه، وجود backlight و چیدمان نمایشگرها همگی در زمان اجرا کشف می‌شوند؛ بنابراین یک مخزن واحد بدون flag یا شاخه‌بندی جداگانه، هم لپ‌تاپ و هم دسکتاپ را پیکربندی می‌کند.

## تصاویر

### دسکتاپ Hyprland

![تصویر دسکتاپ Hyprland](assets/screenshots/Hyprland_Desktop.png)

### دسکتاپ Hyprland ۲

![تصویر دسکتاپ Hyprland ۲](assets/screenshots/Nvim_btop.png)

### ادیتور Neovim

![تصویر ادیتور Neovim](assets/screenshots/Nvim_Editor.png)

### Dolphin

![تصویر Dolphin](assets/screenshots/Dolphin.png)

## پیش‌نیازها

این مخزن یک سیستم را **پیکربندی** می‌کند، نه اینکه آن را نصب کند. قبل از اجرای هر چیزی در اینجا، موارد زیر باید از قبل برقرار باشند.

### الزامی

- **یک سیستم Arch Linux یا مبتنی بر Arch که از قبل نصب و boot شده باشد.** CachyOS، EndeavourOS و مشابه‌ها همگی کار می‌کنند. فایل `install/core/base.sh` مرحله `pacstrap` از روی ISO است و عمداً از اجرای پیش‌فرض حذف شده — bootloader، پارتیشن‌بندی، locale و تنظیم فایل‌سیستم همگی خارج از حوزه این مخزن هستند.
- **یک حساب کاربری معمولی با دسترسی `sudo`**، نه root. ماژول‌ها در `$HOME` می‌نویسند و خودشان برای عملیات‌های لازم `sudo` صدا می‌زنند؛ اجرای کل مجموعه با root فایل‌ها را در مسیر اشتباه قرار می‌دهد.
- **اتصال شبکه فعال.** همه ماژول‌ها پکیج نصب می‌کنند.
- **نصب بودن `git`، `base-devel` و `sudo`.** برای build کردن `paru` از AUR به `base-devel` نیاز است.
- **systemd.** این setup سرویس‌ها را فعال می‌کند و از `hostnamectl` می‌خواند.

### به‌صورت خودکار انجام می‌شود

- **`multilib`** اگر فعال نباشد توسط ماژول `pacman` فعال می‌شود. برای کتابخانه‌های ۳۲ بیتی گیمینگ لازم است.
- **`paru`** اگر نصب نباشد توسط ماژول `paru` ساخته می‌شود.
- **`aria2`** همراه با drop-in مربوط به `makepkg` که به آن وابسته است نصب می‌شود.
- **مخازن CachyOS** در صورت وجود استفاده می‌شوند. هرگز به‌صورت ضمنی اضافه نمی‌شوند — برای افزودن آن‌ها از طریق installer خود CachyOS باید `--with-cachyos` را پاس بدهید. بدون آن‌ها setup به سطح Arch معمولی برمی‌گردد که کار می‌کند اما build های بهینه‌شده، `proton-cachyos-slr`، `chwd` و `game-performance` را ندارد.

### چیزهایی که بهتر است قبل از اجرا بدانید

- **NVIDIA روی Arch معمولی نیاز به تصمیم دارد.** شاخه درایور به نسل GPU بستگی دارد (`nvidia-open-dkms` برای Turing و جدیدتر، و یک شاخه legacy مثل `nvidia-580xx-dkms` برای Maxwell/Pascal/Volta) و انتخاب اشتباه شما را بدون تصویر رها می‌کند. ماژول `drivers` حدس نمی‌زند: در صورت وجود کار را به `chwd` می‌سپارد و در غیر این صورت گزینه‌ها و PCI ID های شما را چاپ می‌کند. AMD و Intel نیازی به تصمیم ندارند.
- **مسیر clone تبدیل به `DOTFILES_ROOT` می‌شود.** ماژول `hyprland` آن را به‌صورت یک بلوک مدیریت‌شده در `~/.profile` می‌نویسد. مثال‌های اینجا `~/personal` را فرض می‌کنند.
- **SDDM و NetworkManager را فعال می‌کند** و unit سیستمی `triggerhappy` را به نفع نسخه per-session غیرفعال می‌کند.
- **چیدمان نمایشگر برای دستگاه جدید.** نمایشگرها بر اساس description مربوط به EDID تطبیق داده می‌شوند، بنابراین دستگاهی با مانیتورهای ناشناخته به `preferred`/`auto` برمی‌گردد و قابل استفاده بالا می‌آید. برای ثابت کردن یک چیدمان، نمایشگر را با استفاده از رشته `description:` از خروجی `hyprctl monitors` به `dotfiles/config/hypr/hyprland/monitors.lua` اضافه کنید.

اول `./scripts/utils/facts.sh --report` را اجرا کنید. بدون تغییر دادن چیزی به شما می‌گوید setup چه چیزی را تشخیص می‌دهد و کدام سطح را انتخاب می‌کند.

## نمای کلی معماری

این مخزن حول یک نسخه کنترل‌شده از محیط کاربری لینوکس سازمان‌دهی شده است:

- `dotfiles/config/` معادل `~/.config/` است و تنظیمات Hyprland، Waybar، Neovim، Yazi، ترمینال‌ها، input method، اعلان‌ها و برنامه‌ها را نگه می‌دارد.
- `dotfiles/local/` معادل `~/.local/` است و desktop entry ها و لانچرهای سطح کاربر را نگه می‌دارد.
- `dotfiles/system/` شامل تنظیمات سیستمی است. پوشه `makepkg.conf.d/` شامل drop-in هایی است که در `/etc/makepkg.conf.d/` قرار می‌گیرند؛ و `pacman.conf.reference` یک **snapshot فقط-خواندنی** است که هرگز deploy نمی‌شود، چون `/etc/pacman.conf` متعلق به سیستم است و مخازنی را نگه می‌دارد که این مخزن نباید بازنویسی‌شان کند.
- `lib/facts.sh` لایه تشخیص سخت‌افزار و توزیع است. همه ماژول‌های نصب آن را source می‌کنند و به‌جای نام توزیع، بر اساس قابلیت‌ها تصمیم می‌گیرند.
- `install/core/` ماژول‌های نصب برای پکیج‌های پایه، درایورها، PipeWire، NetworkManager، environment، Hyprland، Neovim، tmux، گیمینگ و extras را نگه می‌دارد.
- `install/desktop/` شامل راه‌اندازی display manager و تم است.
- `scripts/utils/` ابزارهای هماهنگ‌کننده برای تشخیص (`facts.sh`)، گزارش drift (`check-drift.sh`)، sync کردن config ها، نصب پکیج و workflow های Obsidian/brain را نگه می‌دارد.
- `scripts/helpers/` شامل ابزارهای مستقل runtime برای VPN routing، file manager ها، Yazi، مرورگرها، mount کردن و دیالوگ‌های GUI است. این‌ها توسط keybind ها و compositor صدا زده می‌شوند، نه توسط installer.
- `themes/`، `assets/` و `tmux/` شامل asset های تصویری، screenshot ها، تم‌های SDDM/Qt، تنظیمات tmux و اسکریپت‌های ساخت session هستند.

## تشخیص دستگاه

فایل `lib/facts.sh` یک بار سیستم را بررسی می‌کند و متغیرهای `FACT_*` را در اختیار ماژول‌های نصب می‌گذارد:

| فاکت | چه چیزی را تعیین می‌کند |
| --- | --- |
| وجود مخازن CachyOS و سطح آن (`v3` / `v4` / `znver4`) | اینکه کدام stack گیمینگ و ابزار درایور استفاده شود |
| سازنده GPU و ترتیب کارت‌های DRM | پکیج‌های درایور، `AQ_DRM_DEVICES`، متغیر shader cache |
| سازنده CPU و تعداد thread ها | microcode، و اینکه آیا `game-performance` ارزش استفاده دارد یا نه |
| نوع دستگاه، وجود backlight و باتری | اینکه کدام ماژول‌های keybind load شوند |

قاعده اصلی این است که تصمیم‌گیری بر اساس **قابلیت باشد، نه نام توزیع**: دستور `pacman-conf --repo-list | grep -q cachyos` دقیق‌تر از خواندن `ID=` از `/etc/os-release` است، چون برای Arch معمولی که مخازن CachyOS روی آن اضافه شده هم درست جواب می‌دهد — و هر دو دستگاه من دقیقاً همین وضعیت را دارند.

نتیجه تشخیص در ابتدا و انتهای هر اجرای `setup.sh` گزارش می‌شود. افت خاموش و بی‌صدا به سطح پایین‌تر، خطر واقعی تشخیص خودکار است؛ بنابراین هر اجرا اعلام می‌کند به کدام سطح رسیده و چه چیزی از آن نتیجه شده است.

## مهاجرت Hyprland به Lua

از نسخه ۰٫۵۵ به بعد، Hyprland به‌جای hyprlang با Lua پیکربندی می‌شود. فایل `hyprland.lua` به‌عنوان entrypoint عمل می‌کند و ماژول‌های جداگانه را از `dotfiles/config/hypr/` import می‌کند:

- `hyprland/general.lua` رفتار input، gesture ها، layout پیش‌فرض، border ها، blur، shadow و استایل group ها را تعریف می‌کند.
- `hyprland/monitors.lua` نمایشگرها را تعریف می‌کند و آن‌ها را بر اساس **description مربوط به EDID** تطبیق می‌دهد، نه نام connector.
- `hyprland/roles.lua` نقش primary/secondary را از روی نمایشگرهای متصل تعیین می‌کند و جای‌گذاری workspace ها را از روی آن می‌سازد.
- `hyprland/rules.lua` رفتارهای مشترک window ها را تعریف می‌کند و سپس rule های مخصوص هر برنامه را load می‌کند.
- `hyprland/execs.lua` orchestration شروع session را از طریق hook مربوط به `hyprland.start` ثبت می‌کند؛ مثل سرویس launcher، input method، تاریخچه clipboard، authentication agent، network applet، ترمینال، مرورگر، file manager و workspace های مرتبط با VPN.
- `hyprland/keybinds.lua` ماژول‌های keybind مربوط به مدیریت window، کلیدهای مالتی‌مدیا، کنترل playback و shortcut های برنامه‌ها را ترکیب می‌کند.
- `hyprland/apps/*.lua` قوانین پیشرفته window را بر اساس دامنه برنامه جدا می‌کند: مرورگرها، Steam/game ها، Discord/Vesktop، TeamSpeak، Spotify، ترمینال‌ها، VPN client ها، QEMU، MPV، picture-in-picture، popup های RTL، دیالوگ‌های پیشرفت Dolphin/Thunar و پنجره‌های Zenity/Tkinter.
- `hyprland/facts.lua` توسط `scripts/utils/facts.sh --write-lua` **تولید می‌شود** و track نمی‌شود. به config اجازه می‌دهد بر اساس سخت‌افزار تصمیم بگیرد، بدون اینکه لازم باشد سیستم از داخل compositor بررسی شود.

این ساختار Lua تنظیمات دسکتاپ را نسبت به config ساده Hyprland قابل‌برنامه‌نویسی‌تر می‌کند. با function call هایی مثل `hl.window_rule`، `hl.workspace_rule`، `hl.bind` و `hl.exec_cmd` می‌شود routing logic، matcher های قابل استفاده مجدد، اندازه و موقعیت پویا، special workspace ها، جای‌گذاری startup، tag ها، opacity، pin شدن، حالت floating و workspace های وابسته به مانیتور را دقیق‌تر تعریف کرد.

نمونه‌هایی از مدل routing:

- workspace های `1-3` روی نمایشگر primary و بقیه روی نمایشگرهای secondary قرار می‌گیرند؛ این تقسیم در زمان اجرا تعیین می‌شود و به نام connector گره نخورده است. نقش‌ها با رویدادهای `monitor.added` و `monitor.removed` دوباره محاسبه می‌شوند، بنابراین dock کردن، جدا کردن و وصل کردن تلویزیون همگی بدون reload درست تخصیص داده می‌شوند. با یک نمایشگر، همه چیز روی همان جمع می‌شود.
- پنجره‌های مرورگر به‌صورت tiled روی workspace `2` می‌روند، در حالی که web app های موسیقی به workspace `6` فرستاده می‌شوند.
- game ها و پنجره‌های Steam به workspace `1` می‌روند و opacity کامل و رفتار مناسب بازی می‌گیرند.
- ابزارهای ارتباطی مثل Discord، Vesktop و TeamSpeak به workspace `5` هدایت می‌شوند.
- ابزارهای VPN tag می‌شوند و به special workspace با نام `special:vpn` می‌روند.
- پنجره‌های picture-in-picture tag، float، pin و resize می‌شوند و در موقعیت قابل پیش‌بینی روی صفحه قرار می‌گیرند.

## Orchestration با Bash

روند setup عمداً ماژولار است و به‌صورت یک installer تک‌فایلی بزرگ نوشته نشده:

- `install/setup.sh` مقدار `REPO_ROOT` را تشخیص می‌دهد، مشخصات دستگاه تشخیص‌داده‌شده را چاپ می‌کند، ترتیب اجرای ماژول‌ها را تعریف می‌کند، از `--dry-run`، `--only`، `--skip` و `--with-cachyos` پشتیبانی می‌کند و هر ماژول نصب را از `install/core/` یا `install/desktop/` اجرا می‌کند.
- ماژول‌های نصب بر اساس مسئولیت جدا شده‌اند تا نصب پکیج، سرویس‌ها، اجزای دسکتاپ و setup برنامه‌ها مستقل‌تر تست شوند.
- `scripts/utils/update-config.sh` درخت config های track شده را به مقصد runtime کپی می‌کند و در صورت امکان Hyprland را reload می‌کند. قبل از بازنویسی، تغییرات محلی متعارض را گزارش می‌دهد.
- `scripts/utils/install.sh` وجود `paru` را تضمین می‌کند، پکیج درخواستی را نصب می‌کند و سپس پوشه config متناظر را کپی می‌کند.

### idempotent بودن از پایه

حالت جداگانه‌ای به نام «update mode» وجود ندارد. هر ماژول چه در نصب تازه و چه در اجرای صدم، یکسان رفتار می‌کند و به همان وضعیت می‌رسد؛ چون مسیری که هر روز استفاده می‌شود همان مسیر سیستم از قبل پیکربندی‌شده است و نباید شاخه کم‌تست‌شده باشد. مراحلی که واقعاً فقط بار اول لازم‌اند، مثل `pacstrap` در `base`، بر اساس تشخیص کنترل می‌شوند نه با flag.

در عمل یعنی هیچ ماژولی فایل سیستمی‌ای را که کاملاً مالکش نیست بازنویسی نمی‌کند، append ها با نشانه‌گذاری مشخص جایگزین می‌شوند نه تکرار، و installer های ریموت فقط وقتی دانلود می‌شوند که هدفشان موجود نباشد. اجرای `./install/setup.sh` بدون آرگومان، در هر زمان امن است.

## دستورهای اصلی

کلون کردن مخزن:

```bash
git clone https://github.com/MMDOV/dotfiles.git ~/personal
cd ~/personal
```

دیدن اینکه دستگاه چطور تشخیص داده می‌شود:

```bash
./scripts/utils/facts.sh --report
```

پیش‌نمایش setup بدون اعمال تغییر:

```bash
./install/setup.sh --dry-run
```

اجرای کامل setup:

```bash
./install/setup.sh
```

اضافه کردن مخازن بهینه‌شده CachyOS در حین setup. این کار هرگز ضمنی نیست: از `cachyos-repo.sh` خود CachyOS استفاده می‌کند که سطح متناسب با CPU را انتخاب می‌کند و همراه با مخزن `[cachyos]` یک `pacman` فورک‌شده هم می‌آورد.

```bash
./install/setup.sh --with-cachyos
```

گزارش اینکه سیستم زنده کجا از چیزی که مخزن track می‌کند فاصله گرفته:

```bash
./scripts/utils/check-drift.sh
```

اجرای فقط چند ماژول مشخص:

```bash
./install/setup.sh --only hyprland,nvim,tmux
```

رد کردن چند ماژول:

```bash
./install/setup.sh --skip drivers,sddm
```

sync کردن همه config ها بعد از ویرایش:

```bash
./scripts/utils/update-config.sh
```

sync کردن فقط یک پوشه config، مثلا Neovim:

```bash
./scripts/utils/update-config.sh config nvim
```

## اعتبارسنجی

تست رسمی برای این مخزن تعریف نشده، چون بیشتر شامل تنظیمات سیستم است؛ اما چند بررسی عملی وجود دارد:

```bash
find scripts install lib -name '*.sh' -print0 | xargs -0 bash -n
find dotfiles/config/hypr -name '*.lua' -exec luac -p {} +
hyprctl reload
```

بررسی‌های دستی پیشنهادی:

- قبل از نصب روی سیستم جدید، `./install/setup.sh --dry-run` را اجرا کنید و مطمئن شوید سطح گزارش‌شده همان چیزی است که انتظار دارید.
- `./install/setup.sh` را دو بار پشت سر هم اجرا کنید؛ اجرای دوم باید هیچ تغییری گزارش نکند. این معیار پذیرش idempotent بودن است.
- بعد از اجرای ماژول `pacman`، مطمئن شوید بلوک‌های مخزن در `/etc/pacman.conf` دست‌نخورده مانده‌اند.
- بعد از تغییرات Lua یا تنظیمات compositor، Hyprland را reload کنید.
- تغییرات مربوط به نمایشگر را هم در حالت dock شده و هم جدا تست کنید و با جدا و وصل کردن مطمئن شوید نقش‌ها دوباره محاسبه می‌شوند.
- برنامه مرتبط را باز کنید تا workspace routing و window rule ها بررسی شوند.
- بعد از تغییرات Waybar، tmux یا Neovim همان ابزار را restart یا reload کنید.
- اسکریپت‌هایی را که از `sudo` استفاده می‌کنند، پکیج نصب می‌کنند، سرویس فعال می‌کنند یا فایل‌های `~/.config`، `~/.local` و `/etc` را بازنویسی می‌کنند با دقت بررسی کنید.

## نکته‌ها

- برای Arch Linux و توزیع‌های مبتنی بر Arch نوشته شده و وجود `pacman`، `paru`، systemd، Wayland و Hyprland را فرض می‌کند. مخازن CachyOS در صورت وجود استفاده می‌شوند و الزامی نیستند.
- بعضی اسکریپت‌ها سرویس‌هایی مثل SDDM و NetworkManager را فعال می‌کنند.
- مقادیر وابسته به دستگاه بیرون از فایل‌های track شده نگه داشته می‌شوند. این‌ها یا در خروجی تولیدشده قرار دارند (`hyprland/facts.lua` و `~/.config/uwsm/env-hyprland`) یا بر اساس description نمایشگر تعیین می‌شوند.
- همیشه دقیقاً یک مکانیزم مدیریت اولویت پردازش فعال است. هر دوی `gamemode` و `ananicy-cpp` مقدار niceness پردازش‌ها را تغییر می‌دهند و با هم تداخل دارند، بنابراین ماژول گیمینگ بر اساس تعداد thread های CPU یکی را انتخاب و دیگری را غیرفعال می‌کند.
- نسخه انگلیسی در [`README.md`](README.md) موجود است.
