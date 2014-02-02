Config = ()->
	@ds = window.localStorage;
	@callbacks = {}
	Config.instance = this
	this

Config.instance = null

Config::on = (key, cb)->
	@callbacks[key] = @callbacks[key] || [cb]
	true

Config::set = (key, value)->
	@ds.setItem(key, value);
	evt_cbs = @callbacks[key] || []
	for cb in evt_cbs
		cb(value)
	value

Config::unset = (key)->
	@ds.removeItem(key)
	evt_cbs = @callbacks[key] || []
	for cb in evt_cbs
		cb(key)
	key

Config::get = (key)->
	@ds.getItem(key);
	
window.Config = Config;