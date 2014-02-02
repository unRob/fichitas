/*global $,jQuery,window,console,confirm,alert*/
var storage = {
	ls: window.localStorage,
	callback: null,
	set: function(k,v) {
		var ahora = JSON.stringify(v);
		this.ls[k]=ahora;
		if (storage.callback) {
			storage.callback({key:k,newValue:v});
		}
		return v;
	},
	get: function(k) {
		var v = null;
		try {
			v = JSON.parse(this.ls[k]);
		} catch (err) {
			console.error(err);
		}
		return v;
	},
	change: function(cb) {
		storage.callback = cb;
	}
};



$(function(){
	$('#no-webapp').hide();
	var juegos_numerados = ['primer', 'segundo', 'tercer', 'cuarto', 'quinto', 'sexto', 'séptimo', 'octavo', 'noveno'];
	var cb = {
		juego: function(actual) {
			var t = '';
			if (juegos_numerados[actual]) {
				t = juegos_numerados[actual]+' juego';
			} else {
				t = actual+1;
				t = "juego "+t;
			}
			$('#numero-juego').text(t);
		},
		score: function(id, score) {
			var newScore = score < 9? '0'+score : score;
			$('#'+id).text(newScore);
		},
		table: function(id, scores) {
			if (scores.length === 0) {
				$('#'+id).html('');
			} else {
				var html = "";
				scores.forEach(function(i){
					html += "<li>"+i+"</li>";
				});
				$('#'+id).html(html);
			}
		}
	};
	var setupGame = function(){
		storage.set('numero-juego', 0);
	};
	
	if (!storage.get('setup')) {
		storage.set('numero-juego', null);
		storage.set('player-1', null);
		storage.set('player-2', null);
		storage.set('scores-player-1', []);
		storage.set('scores-player-2', []);
		storage.set('setup', true);
	}
	
	if (storage.get('numero-juego') > 0){
		cb.juego(storage.get('numero-juego'));
		cb.score('player-1', storage.get('player-1'));
		cb.score('player-2', storage.get('player-2'));
		cb.table('scores-player-1', storage.get('scores-player-1'));
		cb.table('scores-player-2', storage.get('scores-player-2'));
	}
	
	
	
	storage.change(function(evt){
		var key = evt.key;
		var ahora = evt.newValue;
		//var antes = evt.oldValue;
		switch (key) {
			case 'numero-juego':
				cb.juego(ahora);
				
				if (ahora === 0) {
					storage.set('player-1', 0);
					storage.set('player-2', 0);
					storage.set('scores-player-1', []);
					storage.set('scores-player-2', []);
				}
			break;
			case 'player-1':
			case 'player-2':
				cb.score(key, ahora);
				if (ahora >= 100) {
					var mensaje =  key==='player-1' ? 'Perdimos :(' : 'Ganamos!';
					mensaje += ' Jugamos otra vez?';
					if (confirm(mensaje)) {
						setupGame();
					}
				}
			break;
			case 'scores-player-1':
			case 'scores-player-2':
				cb.table(key, ahora);
			break;
		}
	}, false);
	
	
	
	
	$('#activa-resultados').click(function(evt){
		$('#juego').addClass('flip');
		$('#resultado').removeClass('flip');
	});
	
	$('#guardar').click(function(evt){
		evt.preventDefault();
		var p1 = Number($('#score-player-1').val());
		var p2 = Number($('#score-player-2').val());
		
		if (p1 === p2 && p1 === 0) {
			return false;
		}
		
		var tp1 = storage.get('player-1');
		var tp2 = storage.get('player-2');
		var sp1 = storage.get('scores-player-1');
		var sp2 = storage.get('scores-player-2');
		
		sp1.push(p1);
		sp2.push(p2);
		storage.set('scores-player-1', sp1);
		storage.set('scores-player-2', sp2);
		storage.set('player-1', tp1+p1);
		storage.set('player-2', tp2+p2);
		storage.set('numero-juego', storage.get('numero-juego')+1);
		$('#juego').removeClass('flip');
		$('#resultado').addClass('flip');
		$('#score-player-1').val('');
		$('#score-player-2').val('');
	});
	
	$('#cancelar').click(function(evt){
		evt.preventDefault();
		$('#juego').removeClass('flip');
		$('#resultado').addClass('flip');
	});
	
	$('.activa-input').click(function(evt){
		evt.preventDefault();
		var id = $(this).data('input');
		console.log(id);
		$(id).focus();
		$(id).click();
	});
	
	$('#terminar').click(function(evt){
		evt.preventDefault();
		if (confirm('Seguro?')) {
			setupGame();
		}
	});
});