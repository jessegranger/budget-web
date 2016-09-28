
$(document).ready ->
		
		$.log "bling is ready"
		$.date.defaultUnit = "ms"
		$.date.defaultFormat = "yyyy-mm-dd"
		
		$(window).bind 'storage', (evt) ->
			$.log "storage:", evt
		
		$("#repeat_once").bind("click touchend", (evt) ->
			if evt.target.checked is true
				$(".repeat-reveal").addClass("hide")
				$(".once-reveal").removeClass("hide")
			else
				$(".once-reveal").addClass("hide")
				$(".repeat-reveal").removeClass("hide")
		).trigger("click")
		
		$("#repeat_many").bind("click touchend", (evt) ->
			if evt.target.checked is true
				$(".once-reveal").addClass("hide")
				$(".repeat-reveal").removeClass("hide")
			else
				$(".repeat-reveal").addClass("hide")
				$(".once-reveal").removeClass("hide")
		)
		
		generateForm = (inputs) ->
			form = $("<form><table></table></form>")
			table = form.find("table").first()
			for input in inputs
				label = input[0]
				id = $.stubize label
				type = input[1]
				value = input[2]
				row = $(table.insertRow())
				$.synth("td '#{label}'").appendTo(row)
				$.synth("td input[id=#{id}][type=#{type}][value=#{value}]").appendTo(row)
			form
		
		generateButtons = (actions) ->
			buttons = $("<div class='button-bar'></div>")
				.css({
					width: "100%"
					height: "48px"
					"border-top": "1px solid #666"
				})
			for button in actions
				$("<button>#{button[0]}</button>").css({
					height: "40px",
					width: "80px",
					margin: "4px 2px"
					"border-radius": "0px"
				}).appendTo(buttons)
			buttons

		showModal = (title, inputs, actions) ->
			closeModal = ->
				console.log "closeModal()"
				$('#modal-background').html('').css('display','none')
			if $("#modal-background").length is 0
				$("<div id='modal-background'></div>").css({
					position: "fixed"
					width: "100%"
					height: "100%"
					display: "block"
					"z-index": "9999"
					background: "rgba(0,0,0,.5)"
					margin: 0
					padding: 0
				})
				.appendTo("body")
				.bind 'click touchstart', (evt) ->
					if evt.target.id is 'modal-background'
						console.log "closing modal from background click"
						closeModal()
					else
						console.log evt.target
			
			console.log "showing modal"
			modal = $("#modal-background").css('display', 'block')
			$.synth("div.modal-content div.modal-title '#{title}'")
				.css({
					width: "320px"
					margin: "8px auto"
					background: "white"
					"border-radius": "8px"
					padding: "6px"
				})
				.append(generateForm(inputs))
				.append(generateButtons(actions))
				.appendTo(modal)
				.find(".modal-title")
				.css({
					"text-align": "center"
					"border-bottom": "1px solid #666"
					"margin-bottom": "6px"
				})
			
			modal.find("[type=date]").each(window.initDatePicker)
		
			$("#modal-background .button-bar button").bind "click", (evt) ->
				console.log "button clicked",
				label = evt.target.innerText
				data = {}
				$(evt.target.parentNode.parentNode)
					.find('form input')
					.each (node) ->
						data[node.id] = node.value
				for action in actions
					if action[0] is label
						action[1].apply {
							close: -> closeModal()
						}, [ data ]
		
		startingDate = $.TNET.parse(localStorage.getItem('startingDate'))
		startingBalance = parseFloat localStorage.getItem('startingBalance') or '0.00'
		
		transactions = $.TNET.parse(localStorage.getItem('transactions')) or {}
		
		unless startingDate
				showModal "Starting Balance", [
					[ "Date", "date", $.date.format $.now ]
					[ "Balance", "number", 0.00 ]
				],[
					[ "OK", (data) ->
						console.log "Setting starting conditions", data.date, data.balance
						parsedDate = $.date.parse(data.date)
						parsedBalance = parseFloat data.balance
						# localStorage.setItem('startingDate', $.TNET.stringify(parsedDate))
						# localStorage.setItem('startingBalance', $.TNET.stringify(parsedBalance))
					],
					[ "Cancel", -> @close() ]
				]
		
		$(".action-add").click ->
				showModal "New Activity", [
					[ "Date", "date", $.date.format $.now ],
					[ "Amount", "number", 0.00 ],
					[ "Description", "text", "" ],
				],[
					[ "OK", (data) ->
						console.log "Inserting activity", data.date, data.amount, data.description
						dateKey = $.date.format($.date.parse(data.date))
						transactions[dateKey] or= []
						transactions[dateKey].push [parseFloat(data.amount), String(data.description)]
					],
					[ "Cancel", -> @close() ]
				]