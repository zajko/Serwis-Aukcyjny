/*
 * jQuery timepicker addon
 * By: Trent Richardson [http://trentrichardson.com]
 * Version 0.1
 * Last Modified: 4/19/2010
 * 
 * Copyright 2010 Trent Richardson
 * Dual licensed under the MIT and GPL licenses.
 * http://trentrichardson.com/Impromptu/GPL-LICENSE.txt
 * http://trentrichardson.com/Impromptu/MIT-LICENSE.txt
 * 
 * HERES THE CSS:
 * #ui-timepicker-div dl{ text-align: left; }
 * #ui-timepicker-div dl dt{ height: 25px; }
 * #ui-timepicker-div dl dd{ margin: -25px 0 10px 65px; }
 */
(function($){
	function Timepicker() {}

	Timepicker.prototype = {
		$input : null,
		$timeObj : null,
		inst : null,
		hour_slider : null,
		minute_slider : null,
		second_slider : null,
		hour : 0,
		minute : 0,
		second : 0,
		ampm : '',
		formattedDate : '',
		formattedTime : '',
		formattedDateTime : '',
		defaults: { 
			holdDatepickerOpen: true,
			showButtonPanel: true, 
			timeOnly: false, 
			showHour: true,
			showMinute: true,
			showSecond: false,
			stepHour: .05, 
			stepMinute: .05, 
			stepSecond: .05, 
			ampm: false, 
			hour: 0, 
			minute: 0, 
			second: 0, 
			timeFormat: 'hh:mm tt'
		},
		
		//########################################################################
		// add our sliders to the calendar
		//########################################################################
		addTimePicker : function(){
			var inst = this;
			var currDT = this.$input.val();
			var regstr = this.defaults.timeFormat.toString()
							.replace(/h{1,2}/ig, '(\\d?\\d)')
							.replace(/m{1,2}/ig, '(\\d?\\d)')
							.replace(/s{1,2}/ig, '(\\d?\\d)')
							.replace(/t{1,2}/ig, '(am|pm|a|p)?')
							.replace(/\s/g,'\\s?');
							
			var order = this.getFormatPositions();
			var treg = currDT.match(new RegExp(regstr,'i'));
			
			if(treg){
				if(order.t !== -1)
					this.ampm = ((treg[order.t] == undefined)? '': (treg[order.t].charAt(0).toUpperCase()=='A')? 'AM':'PM').toUpperCase();	
				
				if (order.h !== -1) {
					if (this.ampm == 'AM' && treg[order.h] == '12') 
						this.hour = 0; // 12am = 0 hour
					else if (this.ampm == 'PM' && treg[order.h] != '12') 
						this.hour = (parseFloat(treg[order.h]) + 12).toFixed(0); //12pm = 12 hour, any other pm = hour + 12
					else 
						this.hour = treg[order.h];
				}
				
				if(order.m !== -1)			
					this.minute = treg[order.m];
				
				if(order.s !== -1)
					this.second = treg[order.s];
			}
			
			// wait for datepicker to create itself.. 60% of the time it works every time..
			setTimeout(function(){
				inst.injectTimePicker(inst);
			},10);
		},
		
		//########################################################################
		// figure out position of time elements.. cause js cant do named captures
		//########################################################################
		getFormatPositions: function(){
			var finds = this.defaults.timeFormat.toLowerCase().match(/(h{1,2}|m{1,2}|s{1,2}|t{1,2})/g);
			var orders = { h: -1, m: -1, s: -1, t: -1 };
			
			if(finds){
				for(var i=0; i < finds.length; i++){
					if(orders[finds[i].toString().charAt(0)] == -1)
						orders[finds[i].toString().charAt(0)] = i+1;
				}
			}
			
			return orders;
		},
		
		//########################################################################
		// generate and inject html for timepicker into ui datepicker
		//########################################################################
		injectTimePicker: function(inst){ 
			var $theDP = $('#'+ $.datepicker._mainDivId);
			
			var html = '<div id="ui-timepicker-div">'+
					'<dl>'+
						'<dt id="ui_tpicker_time_label">Time</dt>'+
						'<dd id="ui_tpicker_time"></dd>'+
						'<dt id="ui_tpicker_hour_label"'+ ((inst.defaults.showHour)? '':' style="display:none;"') +'>Hour</dt>'+
						'<dd id="ui_tpicker_hour"'+ ((inst.defaults.showHour)? '':' style="display:none;"') +'></dd>'+
						'<dt id="ui_tpicker_minute_label"'+ ((inst.defaults.showMinute)? '':' style="display:none;"') +'>Minute</dt>'+
						'<dd id="ui_tpicker_minute"'+ ((inst.defaults.showMinute)? '':' style="display:none;"') +'></dd>'+
						'<dt id="ui_tpicker_second_label"'+ ((inst.defaults.showSecond)? '':' style="display:none;"') +'>Second</dt>'+
						'<dd id="ui_tpicker_second"'+ ((inst.defaults.showSecond)? '':' style="display:none;"') +'></dd>'+
					'</dl>'+
				'</div>';
				
			$tp = $(html);
			
			if (inst.defaults.timeOnly == true) { // if we only want time picker
				$tp.prepend('<div class="ui-widget-header ui-helper-clearfix ui-corner-all"><div class="ui-datepicker-title">Choose Time</div></div>');
				$theDP.find('.ui-datepicker-header, .ui-datepicker-calendar, .ui-datepicker-current').hide();
			}
			
			inst.hour_slider = $tp.find('#ui_tpicker_hour').slider({ orientation: "horizontal", value: inst.hour, max: 23, step: inst.defaults.stepHour, slide: function(){	inst.onTimeChange(inst); } });
			inst.minute_slider = $tp.find('#ui_tpicker_minute').slider({ orientation: "horizontal", value: inst.minute, max: 59, step: inst.defaults.stepMinute, slide: function(){	inst.onTimeChange(inst); } });
			inst.second_slider = $tp.find('#ui_tpicker_second').slider({ orientation: "horizontal", value: inst.second, max: 59, step: inst.defaults.stepSecond, slide: function(){	inst.onTimeChange(inst); } });
			
			$theDP.find('.ui-datepicker-calendar').after($tp);
			inst.$timeObj = $('#ui_tpicker_time');
			
			inst.onTimeChange(inst);
		},
		
		//########################################################################
		// when a slider moves..
		//########################################################################
		onTimeChange : function(inst){
			inst.hour = parseFloat(inst.hour_slider.slider('value')).toFixed(0);
			inst.minute = parseFloat(inst.minute_slider.slider('value')).toFixed(0);
			inst.second = parseFloat(inst.second_slider.slider('value')).toFixed(0);
			inst.ampm = (inst.hour < 12)? 'AM':'PM';
			
			inst.formatTime(inst);
			
			inst.$timeObj.text(inst.formattedTime);
		},
		
		//########################################################################
		// format the time all pretty...
		//########################################################################
		formatTime: function(inst){
			var tmptime = inst.defaults.timeFormat.toString();
			var hour12 = ((inst.ampm == 'AM')? (inst.hour) : (inst.hour % 12));
			hour12 = (hour12 == 0)? 12: hour12;
			
			if (inst.defaults.ampm == true) {
				tmptime = tmptime.toString()
					.replace(/hh/g, ((hour12 < 10) ? '0' : '') + hour12)
					.replace(/h/g, hour12)
					.replace(/mm/g, ((inst.minute < 10) ? '0' : '') + inst.minute)
					.replace(/m/g, inst.minute)
					.replace(/ss/g, ((inst.second < 10) ? '0' : '') + inst.second)
					.replace(/s/g, inst.second)
					.replace(/TT/g, inst.ampm.toUpperCase())
					.replace(/tt/g, inst.ampm.toLowerCase())
					.replace(/T/g, inst.ampm.charAt(0).toUpperCase())
					.replace(/t/g, inst.ampm.charAt(0).toLowerCase());
			}
			else {
				tmptime = tmptime.toString()
					.replace(/hh/g, ((inst.hour < 10) ? '0' : '') + inst.hour)
					.replace(/h/g, inst.hour)
					.replace(/mm/g, ((inst.minute < 10) ? '0' : '') + inst.minute)
					.replace(/m/g, inst.minute)
					.replace(/ss/g, ((inst.second < 10) ? '0' : '') + inst.second)
					.replace(/s/g, inst.second);
				tmptime = $.trim(tmptime.replace(/t/gi, ''));
			}
			
			inst.formattedTime = tmptime;
			return inst.formattedTime;
		},
		
		//########################################################################
		// update our input with the new date time..
		//########################################################################
		updateDateTime : function(dp_inst, tp_inst){
				var dt = this.$input.datepicker('getDate');
				
				if(dt == null)
					this.formattedDate = $.datepicker.formatDate($.datepicker._get(dp_inst, 'dateFormat'), new Date(), $.datepicker._getFormatConfig(dp_inst));
				else this.formattedDate = $.datepicker.formatDate($.datepicker._get(dp_inst, 'dateFormat'), dt, $.datepicker._getFormatConfig(dp_inst));
				
				this.formattedDateTime = this.formattedDate +' '+ this.formattedTime;
				
				if (this.defaults.timeOnly == true)
					this.$input.val(this.formattedTime);
				else this.$input.val(this.formattedDateTime);
		}
	};	
	
	//########################################################################
	// extend timepicker to datepicker
	//########################################################################		
	jQuery.fn.datetimepicker = function(o){ 
		var tp = new Timepicker();
		
		if(o == undefined)
			o = {};
			
		tp.defaults = $.extend({}, tp.defaults, o);
		
		tp.defaults = $.extend({}, tp.defaults, {
			beforeShow: function(input, inst){
				tp.hour = tp.defaults.hour;
				tp.minute = tp.defaults.minute;
				tp.second = tp.defaults.second;
				tp.ampm = '';
				tp.$input = $(input);
				tp.inst = inst;
				
				tp.addTimePicker();	
				
				if($.isFunction(o['beforeShow'])) o.beforeShow(input, inst);			
			},
			onChangeMonthYear: function(year, month, inst){
				tp.addTimePicker();
				
				if($.isFunction(o['onChangeMonthYear'])) o.onChangeMonthYear(year, month, inst);	
			},
			onClose: function(dateText, inst){ 				
				tp.updateDateTime(inst, tp);
				
				if($.isFunction(o['onClose'])) o.onClose(dateText, inst);	
			}
		});
		
		$(this).datepicker(tp.defaults);
	};

	//########################################################################
	// shorthand just to use timepicker..
	//########################################################################
	jQuery.fn.timepicker = function(o){ 
		o = $.extend(o, { timeOnly: true });		
		
		$(this).datetimepicker(o);
	};

	//########################################################################
	// the bad hack :/ override datepicker so it doesnt close on select
	//########################################################################
	$.datepicker._selectDate = function(id, dateStr) {
		var target = $(id);
		var inst = this._getInst(target[0]);
		var holdDatepickerOpen = (this._get(inst, 'holdDatepickerOpen')===true)? true:false; // this line for timepicker..
		dateStr = (dateStr != null ? dateStr : this._formatDate(inst));
		
		if (inst.input)
			inst.input.val(dateStr);
		this._updateAlternate(inst);
		var onSelect = this._get(inst, 'onSelect');
		if (onSelect)
			onSelect.apply((inst.input ? inst.input[0] : null), [dateStr, inst]);  // trigger custom callback
		else if (inst.input)
			inst.input.trigger('change'); // fire the change event
		if (inst.inline)
			this._updateDatepicker(inst);
		else if(holdDatepickerOpen){} // this line for timepicker..
		else{
			this._hideDatepicker();
			this._lastInput = inst.input[0];
			if (typeof(inst.input[0]) != 'object')
				inst.input.focus(); // restore focus
			this._lastInput = null;
		}
	};

})(jQuery);
