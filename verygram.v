module verygram

import skrtdev.vlogger
import net.http
import json
// import verygram.types.Message

/*#flag -l.
#include "td/tdlib/include/td/telegram/Client.h"*/
/*
#flag -I .
#flag -I td
#flag -I td/tdlib/include
#flag -I td/td
#flag -I td/td/telegram
//#flag -l cstddef
//#flag -l cstd
//#flag -D CFLAGS=-stdlib=libc++
//#include "td/td/telegram/td_json_client.h"
#flag -L "td/build/"
//#flag -l libtdjson
//#flag -l libtdjson.dylib
#include "td/td/telegram/td_json_client.h"
*/

pub struct Bot {
	token string
mut:
	dispatcher Dispatcher = Dispatcher{}
}

struct Dispatcher {
mut:
	//on_update  []UpdateHandler
	on_message []MessageHandler
}

/*
struct UpdateHandler {
	handler fn (Bot, Update) ?
}


fn (mut h UpdateHandler) handle(bot Bot, update Update) ? {
	h.handler(bot, update) ?
}
*/

struct MessageHandler {
	handler fn (Bot, Message) ?
	filters Filter
}

fn (mut h MessageHandler) handle(bot Bot, update Update) ? {
	if update.message.message_id != 0 && h.filters.evaluate(update) {
		h.handler(bot, update.message) ?
	}
}

/*
fn (mut b Bot) on_update(handler fn (Bot, Update)) {
	mut d := &b.dispatcher
	d.on_update << UpdateHandler{
		handler: handler
	}
}
*/

fn (mut b Bot) on_message(filters Filter, handler fn (Bot, Message)) {
	mut d := &b.dispatcher
	d.on_message << MessageHandler{
		filters: filters
		handler: handler
	}
}

fn (b Bot) handle_update(update Update) {
	b.dispatcher.handle_update(b, update)
}

fn (d Dispatcher) handle_update(bot Bot, update Update) {
	/*for handler in d.on_update {
		mut h := handler
		h.handle(bot, update) or { println(err) }
	}*/
	for handler in d.on_message {
		mut h := handler
		h.handle(bot, update) or { println(err) }
	}
}

pub struct Update {
pub:
	update_id int
	message   Message
}

pub struct Message {
pub:
	message_id int
	from       User
	chat       Chat
	text       string
}

struct Result<T> {
pub:
	ok bool
	//
	result      T
	description string
	// result Obj
	// result Message
}

struct User {
pub:
	id       int
	username string
}

struct Chat {
	bot Bot [skip]
pub:
	@type      string
	first_name string
	username   string
}

// type Custom = int | string | bool | []string

// interface Config{}
// struct EmptyConfig{}
/*
fn (b Bot) method<T> (method string, parameters string) ?T {
	//res := http.post('https://api.telegram.org/bot$b.token/$method', parameters) ?
	res := http.post_json('https://api.telegram.org/bot$b.token/$method', parameters) ?
	//return AnObject{}
	print(res.text)
	a := json.decode(Result<T>, res.text) ?
	if a.ok {
		return a.result
	}
	else{
		return error('error')
	}

}
*/

fn (b Bot) method_string(method string, parameters string) ?string {
	// res := http.post('https://api.telegram.org/bot$b.token/$method', parameters) ?
	vlogger.debug('Calling $method with payload:')
	vlogger.debug(parameters)
	res := http.post_json('https://api.telegram.org/bot$b.token/$method', parameters) ?
	vlogger.debug('$method response:')
	vlogger.debug(res.text)
	return res.text
	// return json.decode(Result<T>, res.text)
}

fn (b Bot) get_me() ?User {
	// return b.method<User>('getMe', '{}')
	res := b.method_string('getMe', '{}') ?
	a := json.decode(Result<User>, res) ?
	return a.result
}

struct GetUpdatesConfig {
	offset          int      = -1
	limit           int      = 100
	timeout         int      = 300
	allowed_updates []string = []string{}
}

fn (b Bot) get_updates(config GetUpdatesConfig) ?[]Update {
	/*
	res := b.method<[]Update>('getUpdates', map{
		'offset': Custom(offset),
		'limit': Custom(limit),
		'timeout': Custom(timeout),
		'allowed_updates': Custom(allowed_updates),
	}) ?
	*/
	// res := b.method<[]Update>('getUpdates', json.encode(config)) ?
	// exit(1)
	res := b.method_string('getUpdates', json.encode(config)) ?
	a := json.decode(Result<[]Update>, res) ?
	return a.result
	// a := json.decode(Result<[]Update>, res) ?
	// return a.result
}

//*/
pub struct SendMessageConfig {
	chat_id int
	text    string
}

fn (b Bot) send_message(config SendMessageConfig) ?Message {
	// res := b.method<Message>('sendMessage', json.encode(config)) ?
	// return res
	res := b.method_string('sendMessage', json.encode(config)) ?
	a := json.decode(Result<Message>, res) ?
	return a.result
	/*
	if a.ok {
		println('herea')
		return a.result
	}
	else{
		println('hereas')
		return error('Error $a.description')
	}*/
	/*
	af := b.after<Message>(a) ?
	println('here')
	return af
	*/
}

fn (b Bot) start() {
	vlogger.info('Starting bot')
	mut last_id := 0
	for {
		// println('here')
		updates := b.get_updates(GetUpdatesConfig{
			offset: last_id
			limit: 100
		}) or { continue }
		// println(updates)
		for update in updates {
			go b.handle_update(update)
			last_id = update.update_id + 1
		}
		// println(last_id)
	}
}

// fn C.td_json_client_create()
