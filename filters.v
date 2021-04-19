module verygram

pub struct Filter {
    // handler fn (update Update, args array) bool = fn (update Update, args array) bool { return true }
	handler fn (update Update, args array) bool 
	//and []Filter
	args array
}

const private = Filter{handler: fn(update Update, args array) bool {
    return update.message.chat.@type == 'private'
}}

const has_sender = Filter{handler: fn(update Update, args array) bool {
    return update.message.from.id != 0 // workaround
}}

const text = Filter{handler: fn(update Update, args array) bool {
    return update.message.text != '' // workaround
}}

pub fn command(commands ...string) Filter {
	return Filter{args: commands, handler: fn (update Update, commands []string) bool {
		for command in commands {
			if update.message.text.starts_with("/$command"){
				return true
			}
		}
		return false
	}}
}

const empty = Filter{handler: fn(update Update, args array) bool {
    return true
}}

pub fn users(ids ...int) Filter {
	return Filter{args: ids, handler: fn (update Update, ids []int) bool {
		return update.message.from.id in ids
	}}
}


fn (f Filter) evaluate(update Update) bool {
	return f.handler(update, f.args)
	/*if !f.handler(update, f.args){
		return false
	}
	for filter in f.and{
		if !filter.evaluate(update){
			return false
		}
	}
	return true*/
}

fn (a Filter) + (b Filter) Filter {
	return Filter{args: [a, b], handler: fn (update Update, filters []Filter) bool {
		return filters[0].evaluate(update) && filters[1].evaluate(update)
	}}
}

fn (a Filter) - (b Filter) Filter {
	return Filter{args: [a, b], handler: fn (update Update, filters []Filter) bool {
		return filters[0].evaluate(update) && !filters[1].evaluate(update)
	}}
}

fn (a Filter) / (b Filter) Filter {
	return Filter{args: [a, b], handler: fn (update Update, filters []Filter) bool {
		return filters[0].evaluate(update) || filters[1].evaluate(update)
	}}
}
