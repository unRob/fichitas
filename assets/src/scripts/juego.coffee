Game = (config)->
	@players = {}
	$('#players').empty();
	playerCount = (config.get('players.qty') || 2)
	console.log playerCount
	@playerCount = parseInt(playerCount)
	for id in [1..@playerCount]
		id = id
		p = new Player(id)
		p.name = config.get("players.player.#{id}.name") || @defaultName(id, @playerCount)
		p.scores = JSON.parse(config.get("players.player.#{id}.scores")) || []

		@players[id] = p
		$('#players').append(p.dom())

	@maxPoints = ()->
		parseInt config.get('game.maxPoints'), 10

	$('#players').attr('class', '').addClass("player-count-#{@playerCount}")
	window.refreshPlayersUI()
	@started = config.get('game.started') || false
	@gameNo = config.get('game.number') || 0
	@gameNo = parseInt(@gameNo)
	Game.instance = this
	this

Game.numbers = ['primer', 'segundo', 'tercer', 'cuarto', 'quinto', 'sexto', 'séptimo', 'octavo', 'noveno'];

Game.instance = null

Game::restart = ()->
	Config.instance.unset('game.started')
	Config.instance.set('game.number', '0')
	@gameNo = 0 #porque se caga muy duro si no
	for id, player of @players
		Config.instance.unset("players.player.#{id}.scores")
	game = new Game(Config.instance)
	Game.instance = game
	game

Game::player = (id)->
	@players[id]

Game::addPoints = (id, points)->
	if !@started
		@started = true
		Config.instance.set('game.started', true)

	player = @player(id)
	player.addPoints(points)
	if player.score() >= @maxPoints()
		console.log("lost", player.score(), @maxPoints())
		@started = false
		name = "#{player.name} "
		verbo = 'perdió'
		verbo = 'perdimos' if player.name.match(/nosotros/i)
		if player.name.match(/ustedes/i)
			verbo = 'Ganamos'
			name = ""

		return @ended("#{name}#{verbo}")

	if @playerCount == 2
		oid = if id == 1 then 2 else 1
		other = @player(oid);
		other.addPoints(0)
		@next()

	return this

Game::ended = (phrase)->
	if (confirm("¡#{phrase}! ¿Volvemos a jugar?"))
		return @restart()
	this

Game::defaultName = (id, count)->
	if (count == 2)
		return "Nosotros" if id==1
		return "Ustedes" if id==2
	else
		return "Jugador #{id}"

Game::next = ()->
	@gameNo += 1
	config = Config.instance
	config.set('game.number', @gameNo)
	for id, player of @players
		config.set("players.player.#{player.id}.scores", JSON.stringify(player.scores))
	return this

Game::name = ()->
	if str = Game.numbers[@gameNo]
		return "#{str} juego"
	else
		return "Juego #{@gameNo+1}" 

window.Game = Game;

##########
# Player #
##########

Player = (id)->
	@id = id;
	@name = "Jugador #{@id}"
	@scores = []
	this

Player.template = Mustache.compile($('#player-tpl').get(0).innerText); 

Player::addPoints = (points)->
	@scores.push(points)

Player::score = ()->
	s = 0;
	for score in @scores
		s+=score
	str = s.toString()
	str = "0#{str}" while (str.length < 2)
	str

Player::renderScore = ()->
	(nil, r)=>
		r(@score())

Player::lost = (qty)->

Player::dom = ()->
	Player.template(this)