#= require jquery
#= require mustache
#= require config
#= require juego
#= require juego.ui

config = new Config
$ ()->
	screens =
		config: $('#config')
		game: $('#game')

	cfg =
		jugadores: $('#jugadores'),
		puntos: $('#puntos')

	game = new Game(config)
	$('#game-name').text(game.name())
	config.on 'game.number', ()->
		$('#game-name').text(game.name())

	window.saveConfig = (check=true)->
		console.log "saving config"
		if (check && (parseInt(cfg.jugadores.val(),10) != game.playerCount) && game.started)
			console.log "checking"
			if (!confirm('Hay un juego en curso, deseas comenzar uno nuevo?'))
				cfg.jugadores.val(config.get('players.qty'));
				return false;
			console.log "changing player qty"
			config.set 'players.qty', parseInt(cfg.jugadores.val(), 10)	

		console.log "config saved"	
		config.set 'game.maxPoints', parseInt(cfg.puntos.val(), 10)

	window.addScore = (player, points)->
		game = game.addPoints(player, points);
		if game.started
			$("#player-#{player} .score").text(game.player(player).score());
	
	cfg.jugadores.val(config.get('players.qty')||2);
	cfg.puntos.val(config.get('game.maxPoints')||100);
	config.on 'players.qty', (ahora, antes)->
		game = game.restart()
		$('#game-name').text(game.name())



	$('[role=action-button]').on 'click', (evt)->
		evt.preventDefault();
		el = $(this)
		target = $(el.data('modifies'))
		action = el.data('action')
		val = target.attr('step') || target.val();
		val = parseInt(val, 10)
		newVal = parseInt(target.val(), 10)
		max = target.attr('max') && parseInt(target.attr('max'), 10) || false
		min = target.attr('min') && parseInt(target.attr('min'), 10) || false

		switch action
			when 'plus'
				newVal += val
				return false if max && newVal > max
			when 'minus'
				newVal -= parseInt(val, 10)
				return false if min && newVal < min
			when 'ok'
				return false;

		target.val(newVal);

	$('#restart-game').on 'click', (evt)->
		evt.preventDefault();
		if (confirm "Seguro que deseas volver a empezar?")
			window.saveConfig(false)
			game = game.restart()
			$('#game-name').text(game.name())
			screens.config.removeClass('shown')
			screens.game.addClass('shown')

	$('#finish-game').on 'click', (evt)->
		evt.preventDefault();
		max = 0
		for id, player of game.players
			count = player.scores.length
			max = count if max < count

		for id, player of game.players
			if player.scores.length < max
				player.addPoints(0)

		game = game.next()


	$('.nav-icon').on 'click', (evt)->
		evt.preventDefault();
		visible = $('.screen.shown')
		invisible = $('.screen:not(.shown)')
		visible.removeClass('shown');
		invisible.addClass('shown');
		if (cb = $(this).data('action'))
			window[cb]();
		return false