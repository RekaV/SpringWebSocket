<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page session="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Chat Window</title>
<link href='<c:url value="/resources/bootstrap.css"></c:url>'
	rel="stylesheet" />
<link href='<c:url value="/resources/tabcontent.css"></c:url>'
	rel="stylesheet" />
 
 <!-- <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"> -->
<script src='<c:url value="/resources/jquery-2.1.0.min.js"></c:url>'></script>
<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
<script src='<c:url value="/resources/sockjs-0.3.4.js"></c:url>'></script>
<script src='<c:url value="/resources/stomp.js"></c:url>'></script>
<script src='<c:url value="/resources/tabcontent.js"></c:url>'></script>
<script type="text/javascript">
	var stompClient = null;

	
		/** SOCKET OPEN **/
		var socket = new SockJS("/springwebsocket/hello");
		stompClient = Stomp.over(socket);
		stompClient.connect({}, function(frame) {
			whoami = frame.headers['user-name'];
			
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
				 	ischatDiv(suser);
	                showGreeting(JSON.parse(greeting.body).sender_name,JSON.parse(greeting.body).content);
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
		//receiver
		stompClient.send("/app/hello", {}, JSON.stringify({
			'name' : message,
			'receiver' : receiver
		}));
		showGreeting(receiver,message); 
	
 	}
	/** BIND MSG TO PAGE WHILE SUBSCRIBING **/
	 function showGreeting(sender_name,message) {
		
		var layout = '#layout_'+sender_name;
		//var listLen = $('#layout_'+sender_name+' '+'li').size();
		var listLen = $('#layout_'+sender_name+' '+'li[id^=chat_list_'+sender_name+']').length;
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
	    }
	/** GET CURRENT ACTIVE MEMBERS **/
	function showActive(activeMembers) {
		
		renderActive(activeMembers.body);
		stompClient.send('/app/activeUsers', {}, '');
	}
	
	/** GET RECEIVER NAME WHEN ACTIVE USER LIST ITEM CLICK **/
	function getReceiver(receiver){
		//alert(receiver);
		$("#receiver").text(receiver);
		$("#chatmsgs").empty();
		$("#notify_"+receiver).text(parseInt(0)).css("visibility","hidden");
 		
		sessionStorage.setItem('current_user',receiver);
		
		var ids = $.map($('#main_body div'), function(n,i) {
            return n.id
        });
		 console.log("DIV IDS::::"+ids);
		if($.inArray('layout_'+receiver,ids) < 0 ){
			createChatDiv(receiver);
		}
		else{
			console.log("DO NOTHING...");
		}
		$("#chat_div").children().hide();
		$("#layout_"+receiver).show();
		

	}
	/** CHECK CHAT DIV IS CREATED OR NOT **/
	function ischatDiv(receiver){
		var ids = $.map($('#main_body div'), function(n,i) {
            return n.id
        });
		 console.log("DIV IDS::::"+ids);
		if($.inArray('layout_'+receiver,ids) < 0 ){
			createChatDiv(receiver);
			$("#layout_"+receiver).hide();
		}
		else{
			console.log("DO NOTHING...");
		}
	}
	/** BIND ACTIVE USER INTO PAGE **/
	function renderActive(activeMembers) {
		var arr=activeMembers.replace(/"/g, '').slice(1, -1);
		console.log("arr::"+arr)
		var arrayList=arr.split(',');
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
				//var listids = $('#onlineusers li:last-child').attr('id').substr(4);
				//var listids = $("#onlineusers li[id^=list]").length;
				//console.log("LAST LIST IDS:::"+listids);
				var ids = $("#onlineusers li[id]").map(function() {
   				// return parseInt(this.id, 10);
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
			}).attr('class','media')
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
			.attr('onclick','getReceiver($(this).children("h5").text())')
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
	function createChatDiv(id){
		jQuery('<div/>', {
		    id: 'layout_'+id
		}).attr('class','col-md-8').appendTo('#chat_div');
		
		jQuery('<div/>', {
		    id: 'panel_'+id
		}).attr('class','panel panel-info').appendTo('#layout_'+id);
		
		jQuery('<div/>', {
		    id: 'panel_heading_'+id
		}).attr('class','panel-heading').appendTo('#panel_'+id);
		
		jQuery('<label/>', {
		    id: 'receiver_'+id,
		    text: id
		}).appendTo('#panel_heading_'+id);
		
		jQuery('<div/>', {
		    id: 'panel_body_'+id
		}).attr('class','panel-body').appendTo('#panel_'+id);
		
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
		}).attr('class','form-control').appendTo('#panel_input_group_'+id);
		
		jQuery('<span/>', {
			id:'span_'+id
		}).attr('class','input-group-btn').appendTo('#panel_input_group_'+id);
		
		jQuery('<button/>', {
		    id: 'send_'+id,
		    type:'button',
		    text:'SEND'
		}).attr('class','btn btn-info').attr('onclick', 'sendName(id)').appendTo('#span_'+id);
	}
	
		
	
</script>
</head>
<body style="font-family: Verdana">
	<div class="container">
	
		<div class="row" id="main_body" style="padding-top: 40px;">
			<h3 class="text-center">WEBSOCKET CHAT APPLICATION</h3>
			<br /> <br />
					
			<div class="col-md-4">
				<div class="panel panel-primary">
					<div class="panel-heading">ONLINE USERS
					</div>
					
					<div class="panel-body">
						<ul class="media-list" id="onlineusers">
						</ul>
					</div>
				</div>
			</div>
			
			<div class="col-md-8" id="chat_div">
			</div>
			
			        
		
		</div>
	 </div> 
</body>

</html>