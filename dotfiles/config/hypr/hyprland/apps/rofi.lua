-- rofi (launcher and dialogs) is translucent and blurs what is behind it.
hl.layer_rule({ match = { namespace = "^rofi$" }, blur = true, ignore_alpha = 0.1 })
