# verygram, much telegram

```v
module main

import verygram { Bot, SendMessageConfig, Message, private, command}

mut bot := Bot{token: 'TOKEN'}

bot.on_message(private + command('start'), fn(bot Bot, message Message) ? {
    bot.send_message(SendMessageConfig{message.from.id, 'Hello'}) ?
})

bot.start()
```