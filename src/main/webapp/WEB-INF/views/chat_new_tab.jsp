<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<%@ page session="false"%>
<t:sitelayout>
	<jsp:attribute name="header">
    	<title>Chat App</title>
      	<!-- Custom styles for this template -->
    	<link href="<c:url value='/resources/css/home.css'/>" rel="stylesheet">
    </jsp:attribute>

 
<jsp:attribute name="footer">

<%-- <script src='<c:url value="/resources/js/jquery.emoji.js"></c:url>' type="text/javascript"></script> --%>
<script src='<c:url value="/resources/js/list.js"></c:url>' type="text/javascript"></script>

<script type="text/javascript">
	var stompClient = null;

	
		/** SOCKET OPEN **/
		var socket = new SockJS("/springwebsocket/hello");
		stompClient = Stomp.over(socket);
		stompClient.binaryType = "arraybuffer";
		stompClient.connect({}, function(frame) {
			whoami = frame.headers['user-name'];
			$("#login_user").text(whoami);
			console.log('Connected: ' + frame);
			stompClient.subscribe('/topic/active', function(activeMembers) {
			showActive(activeMembers);
			});
			
			 stompClient.subscribe('/user/queue/greetings', function(greeting){
				 	var cuser=sessionStorage.getItem('current_user');
				 	console.log("cuser:::"+cuser);
				 	var suser = JSON.parse(greeting.body).sender_name;
				 	if(cuser != suser || cuser == '' || cuser == null){
				 		var c = $("#notify_"+suser).text();
				 		console.log("notify:::::"+c);
				 		$("#notify_"+suser).text(parseInt(c)+1);
				 		$("#notify_"+suser).css("visibility","visible");
				 	}
				 	ischatDiv(suser,suser);
	                showGreeting(JSON.parse(greeting.body).sender_name,JSON.parse(greeting.body).content);
	         });
			 stompClient.subscribe('/topic/listuser', function(listUser){
				console.log("LIST USERS::::::"+listUser); 
				createListInGroupChatmodal(listUser.body);
			 });
			 stompClient.subscribe("/user/queue/group/get/", function(groupname){
				console.log("GROUP NAME::::::::::::"+groupname.body.group_name); 
				createGroupNameList(JSON.parse(groupname.body).group_name,JSON.parse(groupname.body).userList);
			 });
			 stompClient.subscribe("/user/queue/group/msg",function(greeting){
				  console.log("GROUP:::::::::"+JSON.parse(greeting.body).content);
				  var cuser=sessionStorage.getItem('current_user');
				 	console.log("cuser:::"+cuser);
				 	var suser = JSON.parse(greeting.body).group_name;
				 	if(cuser != suser || cuser == '' || cuser == null){
				 		var c = $("#notify_"+suser).text();
				 		console.log("notify:::::"+c);
				 		$("#notify_"+suser).text(parseInt(c)+1);
				 		$("#notify_"+suser).css("visibility","visible");
				 	}
				 	ischatDiv(suser,JSON.parse(greeting.body).listUsers);
	                showGreeting(JSON.parse(greeting.body).group_name,JSON.parse(greeting.body).content);
			 });
			 
		});
	
	/** SOCKET CLOSE **/
	function disconnect() {
		if (stompClient != null) {
			stompClient.disconnect();
		}
		console.log("Disconnected");
	}

	/** SEND MSG FROM BROWSER WHEN SEND BUTTON CLICK **/
	function sendName(id) {
		var res_id = id.substr(5);
		console.log("ID::::"+res_id);
		var message = $("#name_"+res_id).val();//document.getElementById('name_'+id).value;
		var receiver = $("#receiver_"+res_id).text();
		
		var receiverArray=receiver.split(',');
		console.log('RECEIVE::::::::'+receiverArray.length);
		$("#name_"+res_id).val('');
		
		if(receiverArray.length>1){
			stompClient.send("/app/groupmsg", {}, JSON.stringify({
				'content' : message,
				'receiver' : receiverArray,
				'group_name':res_id
			}));
			showGreeting(res_id,message);
		}
		else{
			stompClient.send("/app/hello", {}, JSON.stringify({
				'content' : message,
				'receiver' : receiverArray
			}));
			showGreeting(receiver,message);
	    }
		$("#name_"+sender_name).focus();
		
		 
	
 	}
	/** BIND MSG TO PAGE WHILE SUBSCRIBING **/
	 function showGreeting(sender_name,message) {
	 
		var layout = '#tab_'+sender_name;
		//var listLen = $('#layout_'+sender_name+' '+'li').size();
		var listLen = $('#tab_'+sender_name+' '+'li[id^=chat_list_'+sender_name+']').length;
		console.log("iii::::"+listLen);
	
		
		
		// var listLen=$("li").size();
		 
			jQuery('<li>', {
			id:'chat_list_'+sender_name+'_'+listLen
			}).attr('class','media')
			.appendTo('#ul_media_list_'+sender_name);
			
			jQuery('<br />', {
			}).appendTo('#chat_list_'+sender_name+'_'+listLen); //$('#layout_'+sender_name+' '+'li'));

			jQuery('<div/>', {
			    id: 'msg_content_body_'+sender_name+'_'+listLen
			    
			}).attr('class','media-body').appendTo('#chat_list_'+sender_name+'_'+listLen); //$('#layout_'+sender_name+' '+'li'));
			
			jQuery('<div/>', {
			    id: 'msg_content_map_'+sender_name+'_'+listLen
			    
			}).attr('class','media').appendTo('#msg_content_body_'+sender_name+'_'+listLen);
			
			jQuery('<a>', {
			    id: 'msg_a_'+sender_name+'_'+listLen,
			    href:"#",
			    
			}).attr('class','pull-left').appendTo('#msg_content_map_'+sender_name+'_'+listLen);
			
			jQuery('<img>', {
			    id: 'msg_image_'+sender_name+'_'+listLen,
			    src:'<c:url value="/resources/profile_icon-circle.png" ></c:url>',
			}).attr('class','media-object img-circle').css('max-height','40px').appendTo('#msg_a_'+sender_name+'_'+listLen);
				
			jQuery('<div/>', {
			    id: 'msg_content_'+sender_name+'_'+listLen,
			    text: message  
			    }).attr('class','media-body').appendTo('#msg_content_map_'+sender_name+'_'+listLen); 
			
			$("#tab_"+sender_name).each(function(i, d){
		          $(d).emoji();
	        });
			
			$(".panel-body").animate({ scrollTop: $(document).height() }, "fast");	  
			$("#name_"+sender_name).focus();
		}
	/** GET CURRENT ACTIVE MEMBERS **/
	function showActive(activeMembers) {
		
		renderActive(activeMembers.body);
		stompClient.send('/app/activeUsers', {}, '');
	}
	
	/** GET RECEIVER NAME WHEN ACTIVE USER LIST ITEM CLICK **/
	function getReceiver(receiver,user){
		$("#notify_"+receiver).text(parseInt(0)).css("visibility","hidden");
		sessionStorage.setItem('current_user',receiver);
		var ids = $.map($('#main_body div'), function(n,i) {
            return n.id
        });
		var tab_ids = $.map($('#tab_ul li'),function(n,i){
			return n.id;
		});
		 console.log("DIV IDS::::"+ids);
		 console.log("TAB IDS::::"+tab_ids);
		if($.inArray('tab_'+receiver,ids) < 0 ){
			createChatDiv(receiver,user);
		}
		else{
			console.log("DO NOTHING...");
		} 
		$("#tab_view_div").css('visibility','visible');
		if($.inArray('tab_list_'+receiver,tab_ids) < 0 ){
			createTabView(receiver);
			sessionStorage.setItem('current_user',receiver);
			showChatDiv(receiver);
		}
		else{
			sessionStorage.setItem('current_user',receiver);
			$("#tab_list_"+receiver).tab('show');
			$(".tab-content").children().attr('class','tab-pane fade');
			$("#tab_"+receiver).attr('class','tab-pane fade active in');
			console.log("DO NOTHING...");
		}
	}
	/** CHECK CHAT DIV IS CREATED OR NOT **/
	function ischatDiv(receiver,users){
		var ids = $.map($('#main_body div'), function(n,i) {
            return n.id
        });
		 console.log("DIV IDS::::"+ids);
		if($.inArray('tab_'+receiver,ids) < 0 ){
			createChatDiv(receiver,users);
		}
		else{
			console.log("DO NOTHING...");
		}
	}
	/** BIND ACTIVE USER INTO PAGE **/
	function renderActive(activeMembers) {
		console.log('WHO AM I:::'+whoami);
		var arr=activeMembers.replace(/"/g, '').slice(1, -1);
		console.log("arr::"+arr)
		var arrayList=arr.split(',');
		arrayList = jQuery.grep(arrayList, function(value) {
			  return value != whoami;
			});
		console.log('arrayList::'+arrayList.length);
		console.log('List length:::'+$("#onlineusers li").length);
		var arrayLength = arrayList.length;
		var listLength =  $("#onlineusers li").length;
		//$('#onlineuser').append( $('<li>').attr('class','media'));
		
		if(arrayLength != listLength){
			if(listLength == 0){
				$('#onlineusers').text("");
				for(var i=0;i<arrayList.length;i++){
					if(arrayList[i] != ''){
						createActiveUser(i,arrayList[i]);
					}
				}
			}
			else{
				var ids = $("#onlineusers li[id]").map(function() {
   				var sub_id = this.id.substr(4);
   				return parseInt(sub_id, 10);
				}).get();
				console.log("ids:::"+ids);
				var highest = Math.max.apply(Math, ids);
				var lowest = Math.min.apply(Math, ids);
				console.log("highest::"+highest);
				console.log("lowest::"+lowest);

				var userlistarray = $("#onlineusers li").find("h5").map(function() { return $(this).text() }).get();
				$.each(arrayList,function(i,arrayvalue){
					if($.inArray(arrayvalue,userlistarray) < 0){
						console.log("ADDED:::"+arrayvalue);
						createActiveUser(highest+1,arrayvalue);
						
					}
				});
				
			}
			
		}
		if(arrayLength < listLength){
			var userlistarray = $("#onlineusers li").find("h5").map(function() { return $(this).text() }).get();
			/* $("#onlineusers li").map(function() { return $(this).text() }).get(); */
			console.log("array::"+arrayList);
			console.log("userlistarray::"+userlistarray);
			$.each(userlistarray,function(i,userlistvalue){
				console.log("userlistvalue::"+userlistvalue);
				if($.inArray(userlistvalue,arrayList) < 0){
					console.log("MISSING:::"+userlistvalue);
					//$('#onlineusers li').remove();
					$('#onlineusers li:contains("'+userlistvalue+'")').remove();
				}
			});
		}
		
	}
	/** CREATE ACTIVE USERS LIST **/
	function createActiveUser(id,user){
		jQuery('<li>', {
    		id: 'list'+id
			}).attr('class','media').css('cursor','pointer')
			.appendTo('#onlineusers');
		jQuery('<div/>', {
    		id: 'content_body'+id
			}).attr('class','media-body')
			.appendTo('#list'+id);
		jQuery('<div/>', {
    		id: 'content_map'+id
			}).attr('class','media')
			.appendTo('#content_body'+id);
		jQuery('<a>', {
    		id: 'a'+id,
    		href:"#"
			}).attr('class','pull-left')
			.appendTo('#content_map'+id);
		jQuery('<img>', {
    		id: 'image'+id,
    		src:'<c:url value="/resources/profile_icon-circle.png" ></c:url>',
			}).attr('class','media-object img-circle')
			.css('max-height','40px')
			.appendTo('#a'+id);
		jQuery('<div/>', {
    		id: 'content'+id
			}).attr('class','media-body')
			.attr('onclick','getReceiver($(this).children("h5").text(),$(this).children("h5").text())')
			.appendTo('#content_map'+id); 
		jQuery('<h5/>', {
		    id: 'head'+id,
    		text: user
			}).appendTo('#content'+id);
		 jQuery('<span/>',{
			id:'notify_'+user,
			text:0
		}).attr('class','badge').
		css("visibility","hidden")
		.css('background-color','#ff3399')
		.css('color','#ffffff').appendTo('#content'+id);  
	}
	/** CREATE CHAT DIVS **/
	function createChatDiv(id,user){
		jQuery('<div/>', {
		    id: 'tab_'+id
		}).attr('class','tab-pane fade').appendTo('#tab-content'); //.attr('class','col-md-8') //appendTo('#chat_div');attr('class','tab-pane fade').
		
		jQuery('<div/>', {
		    id: 'panel_'+id
		}).attr('class','panel panel-info').appendTo('#tab_'+id);
		
		jQuery('<div/>', {
		    id: 'panel_heading_'+id
		}).attr('class','panel-heading').appendTo('#panel_'+id);
		
		jQuery('<label/>', {
		    id: 'receiver_'+id,
		    text: user
		}).appendTo('#panel_heading_'+id);

		jQuery('<div/>', {
		    id: 'panel_body_'+id
		}).attr('class','panel-body').height('300px').css('overflow-y','auto').appendTo('#panel_'+id);
		
		jQuery('<ul/>', {
		    id: 'ul_media_list_'+id
		}).attr('class','media-list').appendTo('#panel_body_'+id);
		
		jQuery('<div/>', {
		    id: 'panel_footer_'+id
		}).attr('class','panel-footer').appendTo('#panel_'+id);
		
		jQuery('<div/>', {
		    id: 'panel_input_group_'+id
		}).attr('class','input-group').appendTo('#panel_'+id);
 
		jQuery('<input/>', {
		    id: 'name_'+id,
		    type: 'text',
		    placeholder:'Enter Message'
		}).attr('class','form-control')
		.attr('onkeypress','enter_key(event,id)')/* .attr('data-emojiable','true').appendTo('#emoji_span_'+id); */
		.appendTo('#panel_input_group_'+id);

			
		jQuery('<span/>', {
			id:'span_'+id
		}).attr('class','input-group-btn').appendTo('#panel_input_group_'+id);
		
		 //fa fa-smile-o
		jQuery('<button/>', {
		    id: 'emoji_'+id,
		    type:'button'
		}).attr('class','btn btn-success').attr('onclick', 'addEmoji()').appendTo('#span_'+id);
		 
		jQuery('<i/>',{
			id:'i_emoji_'+id
		}).attr('class','fa fa-smile-o').appendTo('#emoji_'+id);
		
		jQuery('<button/>', {
		    id: 'send_'+id,
		    type:'button',
		    text:'SEND'
		}).attr('class','btn btn-info').attr('onclick', 'sendName(id)').appendTo('#span_'+id);
		
	}
	
	function enter_key(event,id)
	{
		var ids=id.substr(5);
		if(event.keyCode == 13){
			$("#send_"+ids).click();
		}
	}
	/** CREATE TAB VIEW FOR EACH USERS **/
	function createTabView(id){
		jQuery('<li/>', {
		    id: 'tab_list_'+id
		}).attr('color','black').attr('onclick','listClick(id);').appendTo('#tab_ul');
		 jQuery('<a/>',{
			id:'tab_a_'+id,
			href:"#tab_"+ id,
			text:id
		}).attr('data-toggle','tab').appendTo('#tab_list_'+id);//attr('onclick','showChatDiv($(this).text())').css('color','#000000').css('font-size','120%').appendTo('#tab_list_'+id);//attr('onclick','showChatDiv($(this).text())')//
		
		 jQuery('<span/>',{
				id:'tab_close_'+id
			}).attr('class','close glyphicon glyphicon-remove-circle').attr('onclick','closeTab(id.substr(10));event.cancelBubble=true;').css('margin-top','1px').css('margin-right','2px')
		    .appendTo('#tab_a_'+id);
		 $('#tab_ul a:last').tab('show');
	}
	function showChatDiv(id){
		console.log("ID::::::::"+id);
		sessionStorage.setItem('current_user',id);
	}
	function closeTab(id){
		$("#emojiMenu").hide();
		$("#tab_list_"+id).remove();
		$('.tab-content').find("#tab_"+id).remove();

		var lastID = $('#tab_ul').find('a:last').map(function(){
			return this.id.substr(6);
		}).get();
		
		console.log("last_id:::::::::::::::"+lastID);
		sessionStorage.setItem('current_user',lastID);
		//display first tab
        var tabFirst = $('#tab_ul a:last');
        console.log('tab_final::'+tabFirst.map(function(){return this.id;}));
		if(lastID != ''){
			 tabFirst.tab('show');
			 
		}else{
			sessionStorage.setItem('current_user','nouser');
			$("#tab_view_div").css('visibility','hidden');
		}
 	}
	function listClick(id){
		var list_id =id.substr(9);
		console.log("LIST CLICKED:::::::::;;;")
		sessionStorage.setItem('current_user',list_id);
	}
	
	(function($){
		  $.fn.emoji = function(){
		    var keys = '\\+1|-1|100|109|1234|8ball|a|ab|abc|abcd|accept|aerial_tramway|airplane|alarm_clock|alien|ambulance|anchor|angel|anger|angry|anguished|ant|apple|aquarius|aries|arrow_backward|arrow_double_down|arrow_double_up|arrow_down|arrow_down_small|arrow_forward|arrow_heading_down|arrow_heading_up|arrow_left|arrow_lower_left|arrow_lower_right|arrow_right|arrow_right_hook|arrow_up|arrow_up_down|arrow_up_small|arrow_upper_left|arrow_upper_right|arrows_clockwise|arrows_counterclockwise|art|articulated_lorry|astonished|atm|b|baby|baby_bottle|baby_chick|baby_symbol|baggage_claim|balloon|ballot_box_with_check|bamboo|banana|bangbang|bank|bar_chart|barber|baseball|basketball|bath|bathtub|battery|bear|bee|beer|beers|beetle|beginner|bell|bento|bicyclist|bike|bikini|bird|birthday|black_circle|black_joker|black_nib|black_square|black_square_button|blossom|blowfish|blue_book|blue_car|blue_heart|blush|boar|boat|bomb|book|bookmark|bookmark_tabs|books|boom|boot|bouquet|bow|bowling|bowtie|boy|bread|bride_with_veil|bridge_at_night|briefcase|broken_heart|bug|bulb|bullettrain_front|bullettrain_side|bus|busstop|bust_in_silhouette|busts_in_silhouette|cactus|cake|calendar|calling|camel|camera|cancer|candy|capital_abcd|capricorn|car|card_index|carousel_horse|cat|cat2|cd|chart|chart_with_downwards_trend|chart_with_upwards_trend|checkered_flag|cherries|cherry_blossom|chestnut|chicken|children_crossing|chocolate_bar|christmas_tree|church|cinema|circus_tent|city_sunrise|city_sunset|cl|clap|clapper|clipboard|clock1|clock10|clock1030|clock11|clock1130|clock12|clock1230|clock130|clock2|clock230|clock3|clock330|clock4|clock430|clock5|clock530|clock6|clock630|clock7|clock730|clock8|clock830|clock9|clock930|closed_book|closed_lock_with_key|closed_umbrella|cloud|clubs|cn|cocktail|coffee|cold_sweat|collision|computer|confetti_ball|confounded|confused|congratulations|construction|construction_worker|convenience_store|cookie|cool|cop|copyright|corn|couple|couple_with_heart|couplekiss|cow|cow2|credit_card|crocodile|crossed_flags|crown|cry|crying_cat_face|crystal_ball|cupid|curly_loop|currency_exchange|curry|custard|customs|cyclone|dancer|dancers|dango|dart|dash|date|de|deciduous_tree|department_store|diamond_shape_with_a_dot_inside|diamonds|disappointed|dizzy|dizzy_face|do_not_litter|dog|dog2|dollar|dolls|dolphin|door|doughnut|dragon|dragon_face|dress|dromedary_camel|droplet|dvd|e-mail|ear|ear_of_rice|earth_africa|earth_americas|earth_asia|egg|eggplant|eight|eight_pointed_black_star|eight_spoked_asterisk|electric_plug|elephant|email|end|envelope|es|euro|european_castle|european_post_office|evergreen_tree|exclamation|expressionless|eyeglasses|eyes|facepunch|factory|fallen_leaf|family|fast_forward|fax|fearful|feelsgood|feet|ferris_wheel|file_folder|finnadie|fire|fire_engine|fireworks|first_quarter_moon|first_quarter_moon_with_face|fish|fish_cake|fishing_pole_and_fish|fist|five|flags|flashlight|floppy_disk|flower_playing_cards|flushed|foggy|football|fork_and_knife|fountain|four|four_leaf_clover|fr|free|fried_shrimp|fries|frog|frowning|fuelpump|full_moon|full_moon_with_face|game_die|gb|gem|gemini|ghost|gift|gift_heart|girl|globe_with_meridians|goat|goberserk|godmode|golf|grapes|green_apple|green_book|green_heart|grey_exclamation|grey_question|grimacing|grin|grinning|guardsman|guitar|gun|haircut|hamburger|hammer|hamster|hand|handbag|hankey|hash|hatched_chick|hatching_chick|headphones|hear_no_evil|heart|heart_decoration|heart_eyes|heart_eyes_cat|heartbeat|heartpulse|hearts|heavy_check_mark|heavy_division_sign|heavy_dollar_sign|heavy_exclamation_mark|heavy_minus_sign|heavy_multiplication_x|heavy_plus_sign|helicopter|herb|hibiscus|high_brightness|high_heel|hocho|honey_pot|honeybee|horse|horse_racing|hospital|hotel|hotsprings|hourglass|hourglass_flowing_sand|house|house_with_garden|hurtrealbad|hushed|ice_cream|icecream|id|ideograph_advantage|imp|inbox_tray|incoming_envelope|information_desk_person|information_source|innocent|interrobang|iphone|it|izakaya_lantern|jack_o_lantern|japan|japanese_castle|japanese_goblin|japanese_ogre|jeans|joy|joy_cat|jp|key|keycap_ten|kimono|kiss|kissing|kissing_cat|kissing_closed_eyes|kissing_face|kissing_heart|kissing_smiling_eyes|koala|koko|kr|large_blue_circle|large_blue_diamond|large_orange_diamond|last_quarter_moon|last_quarter_moon_with_face|laughing|leaves|ledger|left_luggage|left_right_arrow|leftwards_arrow_with_hook|lemon|leo|leopard|libra|light_rail|link|lips|lipstick|lock|lock_with_ink_pen|lollipop|loop|loudspeaker|love_hotel|love_letter|low_brightness|m|mag|mag_right|mahjong|mailbox|mailbox_closed|mailbox_with_mail|mailbox_with_no_mail|man|man_with_gua_pi_mao|man_with_turban|mans_shoe|maple_leaf|mask|massage|meat_on_bone|mega|melon|memo|mens|metal|metro|microphone|microscope|milky_way|minibus|minidisc|mobile_phone_off|money_with_wings|moneybag|monkey|monkey_face|monorail|moon|mortar_board|mount_fuji|mountain_bicyclist|mountain_cableway|mountain_railway|mouse|mouse2|movie_camera|moyai|muscle|mushroom|musical_keyboard|musical_note|musical_score|mute|nail_care|name_badge|neckbeard|necktie|negative_squared_cross_mark|neutral_face|new|new_moon|new_moon_with_face|newspaper|ng|nine|no_bell|no_bicycles|no_entry|no_entry_sign|no_good|no_mobile_phones|no_mouth|no_pedestrians|no_smoking|non-potable_water|nose|notebook|notebook_with_decorative_cover|notes|nut_and_bolt|o|o2|ocean|octocat|octopus|oden|office|ok|ok_hand|ok_woman|older_man|older_woman|on|oncoming_automobile|oncoming_bus|oncoming_police_car|oncoming_taxi|one|open_file_folder|open_hands|open_mouth|ophiuchus|orange_book|outbox_tray|ox|page_facing_up|page_with_curl|pager|palm_tree|panda_face|paperclip|parking|part_alternation_mark|partly_sunny|passport_control|paw_prints|peach|pear|pencil|pencil2|penguin|pensive|performing_arts|persevere|person_frowning|person_with_blond_hair|person_with_pouting_face|phone|pig|pig2|pig_nose|pill|pineapple|pisces|pizza|plus1|point_down|point_left|point_right|point_up|point_up_2|police_car|poodle|poop|post_office|postal_horn|postbox|potable_water|pouch|poultry_leg|pound|pouting_cat|pray|princess|punch|purple_heart|purse|pushpin|put_litter_in_its_place|question|rabbit|rabbit2|racehorse|radio|radio_button|rage|rage1|rage2|rage3|rage4|railway_car|rainbow|raised_hand|raised_hands|ram|ramen|rat|recycle|red_car|red_circle|registered|relaxed|relieved|repeat|repeat_one|restroom|revolving_hearts|rewind|ribbon|rice|rice_ball|rice_cracker|rice_scene|ring|rocket|roller_coaster|rooster|rose|rotating_light|round_pushpin|rowboat|ru|rugby_football|runner|running|running_shirt_with_sash|sa|sagittarius|sailboat|sake|sandal|santa|satellite|satisfied|saxophone|school|school_satchel|scissors|scorpius|scream|scream_cat|scroll|seat|secret|see_no_evil|seedling|seven|shaved_ice|sheep|shell|ship|shipit|shirt|shit|shoe|shower|signal_strength|six|six_pointed_star|ski|skull|sleeping|sleepy|slot_machine|small_blue_diamond|small_orange_diamond|small_red_triangle|small_red_triangle_down|smile|smile_cat|smiley|smiley_cat|smiling_imp|smirk|smirk_cat|smoking|snail|snake|snowboarder|snowflake|snowman|sob|soccer|soon|sos|sound|space_invader|spades|spaghetti|sparkler|sparkles|sparkling_heart|speak_no_evil|speaker|speech_balloon|speedboat|squirrel|star|star2|stars|station|statue_of_liberty|steam_locomotive|stew|straight_ruler|strawberry|stuck_out_tongue|stuck_out_tongue_closed_eyes|stuck_out_tongue_winking_eye|sun_with_face|sunflower|sunglasses|sunny|sunrise|sunrise_over_mountains|surfer|sushi|suspect|suspension_railway|sweat|sweat_drops|sweat_smile|sweet_potato|swimmer|symbols|syringe|tada|tanabata_tree|tangerine|taurus|taxi|tea|telephone|telephone_receiver|telescope|tennis|tent|thought_balloon|three|thumbsdown|thumbsup|ticket|tiger|tiger2|tired_face|tm|toilet|tokyo_tower|tomato|tongue|top|tophat|tractor|traffic_light|train|train2|tram|triangular_flag_on_post|triangular_ruler|trident|triumph|trolleybus|trollface|trophy|tropical_drink|tropical_fish|truck|trumpet|tshirt|tulip|turtle|tv|twisted_rightwards_arrows|two|two_hearts|two_men_holding_hands|two_women_holding_hands|u5272|u5408|u55b6|u6307|u6708|u6709|u6e80|u7121|u7533|u7981|u7a7a|uk|umbrella|unamused|underage|unlock|up|us|v|vertical_traffic_light|vhs|vibration_mode|video_camera|video_game|violin|virgo|volcano|vs|walking|waning_crescent_moon|waning_gibbous_moon|warning|watch|water_buffalo|watermelon|wave|wavy_dash|waxing_crescent_moon|waxing_gibbous_moon|wc|weary|wedding|whale|whale2|wheelchair|white_check_mark|white_circle|white_flower|white_square|white_square_button|wind_chime|wine_glass|wink|wink2|wolf|woman|womans_clothes|womans_hat|womens|worried|wrench|x|yellow_heart|yen|yum|zap|zero|zzz';

		    return this.each(function(){
		      var regex = new RegExp(':(' + keys + '):', 'g');
		      $(this).html($(this).html().replace(regex, $.fn.emoji.replace));
		    });
		  };

		  $.fn.emoji.replace = function(){
		    var key = arguments[1];
		    var url = '<c:url value="/resources/images/emojis"></c:url>';
		    var extension = '.png';
		    var src = url + '/' + key + extension;
		    return '<img class="emoji" width="20" height="20" align="absmiddle" src="' + src + '" alt="' + key + '" title="' + key + '" />';
		  };
		})(jQuery);
	
	
	$(document).ready(function(){

		$("#group_icon").click(function(){
			stompClient.send("/app/listuser", {},'');
		});
		$("#create_group").click(function(){
			var group_name=$("#txtGroupName").val();
			var users=$(".multiSel").text();
			
			var lastChar = users.slice(-1);
			if(lastChar == ',') {
				users = users.slice(0, -1);
			} 
			var users_arr = users.split(",");
			stompClient.send("/app/group/create", {}, JSON.stringify({
				'group_name' : group_name,
				'userList' : users_arr
			}));
		});
		
		$('img').click(function () {
			 var alt = $(this).attr("alt")
			 //alert(alt);
			 var user=sessionStorage.getItem('current_user');
			 var title = $("#name_"+user).val();
			 $("#name_"+user).val(title + alt);
		});

	});
	function addEmoji(){
		$("#emojiMenu").toggle();
	}
	$('#groupchatModal').on('hidden.bs.modal', function (e) {
		  $(this)
		    .find("input,textarea,select")
		       .val('')
		       .end()
		    .find("input[type=checkbox], input[type=radio]")
		       .prop("checked", "")
		       .end();
		  $(".svalue").text('');
		  $(".hida").show();
		  
	});
	function createGroupNameList(groupname,userList){
		
		var ids = $("#groupusers li[id]").map(function() {
				// return parseInt(this.id, 10);
				var sub_id = this.id.substr(4);
				return sub_id;
			}).get();
		if($.inArray(groupname,ids) < 0 ){
			jQuery('<li>', {
	    		id: 'list'+groupname
				}).attr('class','media').css('cursor','pointer')
				.appendTo('#groupusers');
			jQuery('<div/>', {
	    		id: 'content_body'+groupname
				}).attr('class','media-body')
				.appendTo('#list'+groupname);
			jQuery('<div/>', {
	    		id: 'content_map'+groupname
				}).attr('class','media')
				.appendTo('#content_body'+groupname);
			jQuery('<a>', {
	    		id: 'a'+groupname,
	    		href:"#"
				}).attr('class','pull-left')
				.appendTo('#content_map'+groupname);
			jQuery('<img>', {
	    		id: 'image'+groupname,
	    		src:'<c:url value="/resources/profile_icon-circle.png" ></c:url>',
				}).attr('class','media-object img-circle')
				.css('max-height','40px')
				.appendTo('#a'+groupname);
			jQuery('<div/>', {
	    		id: 'content'+groupname
				}).attr('class','media-body')
				.attr('onclick','getReceiver($(this).children("h5").text(),$(this).children("small").text())')
				.appendTo('#content_map'+groupname); 
			jQuery('<h5/>', {
			    id: 'head'+groupname,
	    		text: groupname
				}).appendTo('#content'+groupname);
			jQuery('<small/>',{
				id:'small'+groupname,
				text:userList
			}).attr('class','text-muted').appendTo('#content'+groupname);
			 jQuery('<span/>',{
				id:'notify_'+groupname,
				text:0
			}).attr('class','badge').
			css("visibility","hidden")
			.css('background-color','#ff3399')
			.css('color','#ffffff').appendTo('#content'+groupname);
		}
	}
  	function createListInGroupChatmodal(listUser)
	{
		var userArray=listUser.replace(/"/g, '').slice(1, -1);
		console.log("userArray::"+userArray)
		var userarrayList=userArray.split(',');
		userarrayList = jQuery.grep(userarrayList, function(value) {
			  return value != whoami;
			});
		console.log('userarrayList::'+userarrayList.length);
		$("#multi_ul li").remove();
		$.each( userarrayList, function( i, l ){
			 jQuery('<li/>',{
	            	id:'user_li_'+i
	            }).appendTo('#multi_ul');
				
	            jQuery('<input/>',{
	            	id:'user_check_'+i,
	            	type:'checkbox',
	            	value:l
	            }).attr('onclick','checkboxClick(id);').appendTo('#user_li_'+i);
	            
	            jQuery('<label/>', {
	    		    id: 'user_label_'+i,
	    		    text: l
	    		}).appendTo('#user_li_'+i);
			}); 
	}	
  	
  	$("#select_user").on('click', function() {
  	  $("#multi_ul").slideToggle('fast');
  	});

  	$(".dropdown dd ul li a").on('click', function() {
  	  $(".dropdown dd ul").hide();
  	});

  	function checkboxClick(id){
  		var title = $('#'+id).val(),
  	    title = $('#'+id).val() + ",";

  		//var t=$(".multiSel").text();
  		//alert(t);
  		
  	  if ($('#'+id).is(':checked')) {
  	    var html = '<span title="' + title + '" class="svalue">' + title + '</span>';
  	    $('.multiSel').append(html);
  	    $(".hida").hide();
  	  } else {
  	    $('span[title="' + title + '"]').remove();
  	    var ret = $(".hida");
  	    $('.dropdown a').append(ret);
  	  }
  	}
  	$(document).bind('click', function(e) {
  	  var $clicked = $(e.target);
  	  if (!$clicked.parents().hasClass("dropdown")) $("#multi_ul").hide();
  	
  	  
  	});

  	 /** FILE HANDLING **/
  	/*var handleFileSelect = function(evt) {
  	    var files = evt.target.files;
  	    var file = files[0];

  	    if (files && file) {
  	        var reader = new FileReader();

  	        reader.onload = function(readerEvt) {
  	            var binaryString = readerEvt.target.result;
  	            document.getElementById("base64textarea").value = btoa(binaryString);
  	        };

  	        reader.readAsBinaryString(file);
  	    }
  	};

  	if (window.File && window.FileReader && window.FileList && window.Blob) {
  	    document.getElementById('filePicker').addEventListener('change', handleFileSelect, false);
  	} else {
  	    alert('The File APIs are not fully supported in this browser.');
  	}
  	
  	function dataURItoBlob(dataURI) {
  	    // convert base64/URLEncoded data component to raw binary data held in a string
  	    var byteString;
  	    if (dataURI.split(',')[0].indexOf('base64') >= 0)
  	        byteString = atob(dataURI.split(',')[1]);
  	        else
  	        byteString = unescape(dataURI.split(',')[1]);

  	    // separate out the mime component
  	    var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

  	    // write the bytes of the string to a typed array
  	    var ia = new Uint8Array(byteString.length);
  	    for (var i = 0; i < byteString.length; i++) {
  	        ia[i] = byteString.charCodeAt(i);
  	    }

  	   return new Blob([ia], {type:mimeString});
  	}
  	$("#send_image").click(function(){
  		var r=$("#base64textarea").val();
  		 var ctx =   canvas.get()[0].getContext('2d');
  		 ctx.drawImage(img, 0, 0, 320, 240);
  		 var data  = canvas.get()[0].toDataURL('image/jpeg', 1.0);
  		 newblob = dataURItoBlob(data);
  		newblob = dataURItoBlob(data);
  		stompClient.send("/app/send/images", {}, newblob);
  	});
  	
 */
 </script>
</jsp:attribute>

<jsp:body>
	<div class="container">
	
		<div class="row" id="main_body" style="padding-top: 40px;"><br>
				<div class="col-sm-4">
				<div class="panel panel-primary">
					<div class="panel-heading">ONLINE USERS
					<span class="fa fa-user" id="group_chat" style="padding-left: 200px;padding-right:10px;cursor:pointer;"></span>
					</div>
					<div class="panel-body">
						<ul class="media-list" id="onlineusers">
						</ul>
					
					</div>
					
					<div class="panel-heading">GROUP CHATS
					<a href="#" id="group_icon"
							title="Create Group" data-toggle="modal" data-backdrop="false"  data-target="#groupchatModal" class="fa fa-users" style="padding-left: 200px;color:#ffffff;"> 
					
					</a>
					<!-- <span class="fa fa-users" id="group_chat"  style="padding-left: 200px;padding-right:10px;cursor:pointer;"></span> -->
					</div>
					<div class="panel-body">
						<ul class="media-list" id="groupusers">
						</ul>
					</div>
				</div>
			</div>
			<!-- <div class="col-md-8" id="chat_div">
			</div> -->
			
			<div id="tab_view_div" style="visibility: hidden;" class="col-md-8">
			 <ul class="nav nav-tabs" id="tab_ul">
			 <!-- <li id="tab_list_messenger" class="active"><a href="#tab_messenger" role="tab" data-toggle="tab">Messenger</a></li> -->
        	</ul>
        	<div class="tab-content" id="tab-content">
    	     	<!-- <div class="tab-pane fade in active" id="tab_messenger">
	    	           <h3>WELCOME..!</h3>
        		</div> -->
			</div>
		</div>
		
		<%-- <div>
    		<div>
        		<label for="filePicker">Choose or drag a file:</label><br>
        		<input type="file" id="filePicker">
    		</div>
    		<br>
    		<div>
        		<h1>Base64 encoded version</h1>
        		<textarea id="base64textarea" placeholder="Base64 will appear here" cols="50" rows="15"></textarea>
        		<input type="button" id="send_image" value="SEND IMAGE">
    		</div>
    		
		</div> --%>
		
				<!-- Emoji Menu Div -->
		<div id="emojiMenu">
			<div>
				<table style="width:15%">
 			  		<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/smile.png" />' alt=":smile:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/smiley.png" />' alt=":smiley:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/wink.png" />' alt=":wink:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/bowtie.png" />' alt=":bowtie:"  ></img></a></td>
    
  					</tr>
  					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/relaxed.png"/>' alt=":relaxed:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/sweat_smile.png"/>' alt=":sweat_smile:"  ></img></a></td>	
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/yum.png"/>' alt=":yum:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/angel.png"/>' alt=":angel:"  ></img></a></td>
  					</tr>
  					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/stuck_out_tongue.png" />'alt=":stuck_out_tongue:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/stuck_out_tongue_closed_eyes.png" />'alt=":stuck_out_tongue_closed_eyes:"  ></img></a></td>		
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/stuck_out_tongue_winking_eye.png"/>' alt=":stuck_out_tongue_winking_eye:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/sunglasses.png" />' alt=":sunglasses:"  ></img></a></td>
  					</tr>
  					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/speak_no_evil.png"/>' alt=":speak_no_evil:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/skull.png"/>' alt=":skull:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/sleeping.png"/>' alt=":sleeping:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/sleepy.png"/>' alt=":sleepy:"  ></img></a></td>
  					</tr>
  					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/smile_cat.png"/>' alt=":smile_cat:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/smiley_cat.png"/>' alt=":skull:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/smirk.png"/>' alt=":smirk:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/sleeping.png"/>' alt=":sleeping:"  ></img></a></td>
  					</tr>
  					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/expressionless.png"/>' alt=":expressionless:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/grimacing.png"/>' alt=":grimacing:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/grin.png"/>' alt=":grin:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/grinning.png"/>' alt=":grinning:"  ></img></a></td>
  					</tr>
  					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/flushed.png"/>' alt=":flushed:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/dizzy_face.png"/>' alt=":dizzy_face:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/frowning.png"/>' alt=":frowning:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/fearful.png"/>' alt=":grinning:"  ></img></a></td>
  					</tr>
   					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/baby.png"/>' alt=":baby:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/blush.png"/>' alt=":blush:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/cold_sweat.png"/>' alt=":cold_sweat:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/disappointed.png"/>' alt=":disappointed:"  ></img></a></td>
  					</tr>
   					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/boy.png" />' alt=":boy:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/bride_with_veil.png" />' alt=":bride_with_veil:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/girl.png"/>' alt=":girl:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/confounded.png" />' alt=":confounded:"  ></img></a></td>
  					</tr>
   					<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/guardsman.png"/>' alt=":guardsman:"  ></img></a></td>
    					<td><a href="#"class="img_a"><img src='<c:url value="/resources/images/emojis/man.png"/>' alt=":man:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/man_with_gua_pi_mao.png"/>' alt=":man_with_gua_pi_mao:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/person_with_blond_hair.png"/>' alt=":person_with_blond_hair:"  ></img></a></td>
  					</tr>
     				<tr>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/kissing_cat.png"/>' alt=":kissing_cat:"  ></img></a></td>
    					<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/kissing_closed_eyes.png"/>' alt=":kissing_closed_eyes:"  ></img></a></td>    
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/kissing_heart.png"/>' alt=":kissing_heart:"  ></img></a></td>
   						<td><a href="#" class="img_a"><img src='<c:url value="/resources/images/emojis/kissing_smiling_eyes.png"/>' alt=":kissing_smiling_eyes:"  ></img></a></td>
  					</tr>
			</table>
		</div>
</div>
		
		<!-- End Emoji Menu Div -->
		

	 </div> 
 </div>
	 <!-- Group Chat Modal -->
	 <div id="groupchatModal" class="modal fade" role="dialog">
		  <div class="modal-dialog" role="document">
		    <!-- Modal content-->
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close">&times;</button>
		        <h4 class="modal-title">Create Group</h4>
		      </div>
		      <div class="modal-body">
		         <form>		         
		          <div class="form-group">
		            <label for="groupname" class="control-label">Group Name</label>
		            <input type="text" class="form-control input-sm" placeholder="Enter Group Name" id="txtGroupName">
		          </div>
		           <div class="form-group" id="list_div">
		            <label for="userlist" class="control-label">Users</label><br />
		            <br/>
		            <div class="dropdown"> 
		            <a href="#" id="select_user">
      					<span class="hida">Select</span>    
      						<p class="multiSel"></p>  
    				</a>
    				<dd>
        			<div class="mutliSelect">
            			<ul id="multi_ul">
            			</ul>
        			</div>
    				</div>
    				</dd>
		         </div>		          
		        </form>
		      </div>
		      <div class="modal-footer">
		        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        		<button type="button" class="btn btn-primary" id="create_group">CREATE</button>
		      </div>
		    </div>		
		  </div>
		</div>
		<!-- End Group chat Modal -->
		
</jsp:body>


</t:sitelayout>