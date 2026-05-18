# دات‌فایل‌های شخصی لینوکس

> [!IMPORTANT]
> این مخزن در اصل برای استفاده شخصی خودم ساخته شده است. تنظیمات آن بر اساس سخت‌افزار، روند کاری، سلیقه‌ها و setup آرچ لینوکس من نوشته شده، پس قرار نیست یک نصب‌کننده آماده و ساده برای همه باشد. با این حال اگر خواستید می‌توانید از آن استفاده کنید، بخش‌هایی از آن را بردارید یا از ایده‌هایش الهام بگیرید؛ فقط قبل از اجرا روی سیستم خودتان حتما فایل‌ها و اسکریپت‌ها را بررسی کنید.

این یک مخزن شخصی برای راه‌اندازی Arch Linux و یک محیط دسکتاپ بر پایه Hyprland است.

این مخزن شامل تنظیمات Hyprland، Waybar، Neovim، tmux، Yazi، Kitty/Foot، SDDM، تم‌های GTK/Qt و چندین اسکریپت برای نصب برنامه‌ها و کپی کردن کانفیگ‌ها در مسیرهای مناسب است.

## محتویات

- `config/` - تنظیمات برنامه‌ها، بیشتر برای مسیر `~/.config/`
- `home/` - فایل‌های مربوط به پوشه home، مثل `.tmux.conf`
- `local/` - فایل‌های محلی و desktop entry ها برای `~/.local/`
- `scripts/` - اسکریپت‌های نصب، راه‌اندازی، آپدیت و ابزارهای کمکی
- `sddm/` - تنظیمات و فایل‌های تم SDDM
- `system/` - فایل‌های سیستمی Arch مثل `pacman.conf` و `makepkg.conf`
- `tmux/` - پلاگین‌ها و تم‌های tmux
- `tokyonight-qt/` - فایل‌های تم Tokyonight برای Qt/Kvantum

## اسکریپت‌های اصلی

- `scripts/setup.sh` - اجرای ماژول‌های اصلی برای راه‌اندازی سیستم
- `scripts/update-config.sh` - کپی کردن کانفیگ‌های داخل مخزن به مسیرهای محلی
- `scripts/install.sh` - نصب یک پکیج با `paru` و کپی کردن کانفیگ مربوط به آن
- اسکریپت‌هایی مثل `hyprland.sh`، `nvim.sh`، `tmux.sh`، `browsers.sh`، `pipewire.sh` و `bluetooth.sh` برای نصب و تنظیم بخش‌های جداگانه سیستم هستند

## روش استفاده

مخزن را در مسیر `~/personal` کلون کنید:

```bash
git clone <repo-url> ~/personal
cd ~/personal
```

اول dry run اجرا کنید:

```bash
./scripts/setup.sh --dry-run
```

برای اجرای کامل نصب:

```bash
./scripts/setup.sh
```

برای اجرای فقط چند ماژول مشخص:

```bash
./scripts/setup.sh --only hyprland,nvim,tmux
```

برای رد کردن چند ماژول:

```bash
./scripts/setup.sh --skip drivers,sddm
```

برای کپی کردن کانفیگ‌ها بعد از تغییر دادن آن‌ها در مخزن:

```bash
./scripts/update-config.sh
```

برای کپی کردن فقط یک پوشه کانفیگ، مثلا Neovim:

```bash
./scripts/update-config.sh config nvim
```

## نکته‌ها

- این setup بیشتر برای Arch Linux نوشته شده و از `pacman` و `paru` استفاده می‌کند.
- بعضی اسکریپت‌ها به `sudo` نیاز دارند و ممکن است سرویس‌های سیستمی را فعال کنند.
- بعضی اسکریپت‌ها فایل‌های کانفیگ موجود را در مسیرهایی مثل `~/.config`، `~/.local` و `/etc` بازنویسی می‌کنند.
- قبل از اجرا روی یک سیستم جدید، بهتر است اسکریپت‌ها را بررسی کنید؛ مخصوصا `scripts/setup.sh`، `scripts/pacman.sh`، `scripts/drivers.sh` و `scripts/sddm.sh`.

## نسخه انگلیسی

نسخه انگلیسی در [`README.md`](README.md) موجود است.
