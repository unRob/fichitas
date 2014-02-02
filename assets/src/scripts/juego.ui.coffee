$ ()->
	scrollTO = null
	config = Config.instance

	isNumber = (n)->
	  !isNaN(parseInt(n)) && isFinite(n);

	finishScroll = (el)->
		return false if el.hasClass('animating')
		clearTimeout scrollTO
		sl = el.scrollLeft()
		w = el.width()
		pc = Math.round sl/w*100;
		if pc >= 50
			to = w
			fn = 'focus'
		else
			to = 0
			fn = 'blur'

		falta = (100-pc)/100;
		el.addClass('animating');
		el.animate({scrollLeft: to}, (300*falta), ()->
			el.removeClass('active animating')
			el.find('input')[fn]();
		)

	scrollFn = (evt)->
		el = $(this)
		el.addClass('active')
		clearTimeout scrollTO
		pc = Math.round el.scrollLeft()/el.width()*100;
		el.css('background', "rgba(242,242,242,#{pc/100})")
		fs = ()->
			finishScroll(el)
		scrollTO = setTimeout fs, 100
		true

	changeName = (evt)->
		el = $(this)
		newName = prompt("¿Cómo se llama este jugador?", el.text())
		newName = $.trim(newName)
		id = el.parent().attr('id').replace('player-', '');
		if newName==''
			newName = Game.instance.defaultName(id, Game.instance.playerCount)
			config.unset("players.player.#{id}.name");
		else
			config.set("players.player.#{id}.name", newName);
		el.text(newName);
		

	sumaPlayer = (evt)->
		evt.preventDefault()
		target = $($(this).data('modifies'))
		val = target.val()
		return false if !isNumber(val)
		target.siblings('.suma').append("<li>#{val}</li>")
		target.val('').focus();

	guardaPlayer = (evt)->
		evt.preventDefault()
		target = $($(this).data('modifies'))
		id = parseInt(target.attr('id').replace(/\D+/, ''), 10);
		el = $(this).parents('.player')
		val = parseInt(target.val(), 10);
		fichas = el.find('.suma li')
		if (fichas.length > 0)
			fichas.each (i, ficha)->
				val += parseInt(ficha.innerText, 10)
			el.find('.suma').remove()

		target.blur();
		el.addClass('active animating').animate({scrollLeft: 0}, 300, ()->
			setTimeout(()-> 
				el.removeClass('active animating')
			, 500)
			
		)
		target.val('');
		window.addScore id, (val||0)

	window.refreshPlayersUI = ()->
		$('.player:not(.animating)').off 'scroll'
		$('.player-name').off 'click'
		$('.player:not(.animating)').on 'scroll', scrollFn
		$('.player-name').on 'click', changeName
		$('.player-add').on 'click', sumaPlayer
		$('.player-save').on 'click', guardaPlayer
		$('.suma').on 'click', 'li', ()->
			$(this).remove();

	$('#players').on 'click', '.score', (evt)->
		evt.preventDefault();
		el = $(this).parents('.player')
		el.addClass('active animating').animate({scrollLeft: el.width()}, 300, ()->
			el.removeClass('active animating')
		)
		