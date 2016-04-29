<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html>
<head>
	<title>Home</title>
	<script src='<c:url value="/resources/jquery-2.1.0.min.js"></c:url>'></script>
	<script src='<c:url value="/resources/sockjs-0.3.4.js"></c:url>'></script>
	<script src='<c:url value="/resources/stomp.js"></c:url>'></script>
	
	<script type="text/javascript">
	
	var stompClient=null;
	
	function setConnected(connected){
		document.getElementById('connect').disabled=connected;
		document.getElementById('disconnect').disabled= !connected;
		document.getElementById('conversationDiv').style.visibility = connected ? 'visible' : 'hidden';
        document.getElementById('response').innerHTML = '';	
	}
	
	function connect(){
		var socket = new SockJS("/springwebsocket/hello");
		stompClient = Stomp.over(socket);
		stompClient.connect({}, function(frame) {
			 whoami = frame.headers['user-name'];
            setConnected(true);
            console.log('Connected: ' + frame);
            stompClient.subscribe('/user/queue/greetings', function(greeting){
                showGreeting(JSON.parse(greeting.body).content);
            });
            stompClient.subscribe('/topic/active', function(activeMembers) {
                showActive(activeMembers);
              });
           
        });
	}
	
	function disconnect() {
        if (stompClient != null) {
            stompClient.disconnect();
        }
        setConnected(false);
        console.log("Disconnected");
    }
    
    function sendName() {
        var name = document.getElementById('name').value;
        var receiver = document.getElementById('receiver').value;
        //receiver
        stompClient.send("/app/hello", {}, JSON.stringify({ 'name': name , 'receiver': receiver }));
    }
    function showActive(activeMembers) {
    	  renderActive(activeMembers.body);
    	  //alert(activeMembers.body);
    	  stompClient.send('/app/activeUsers', {}, '');
    }
    function renderActive(activeMembers) {
    	  var previouslySelected = $('.user-selected').text();
    	  var usersWithPendingMessages = new Object();
    	  $.each($('.pending-messages'), function(index, value) {
    	    usersWithPendingMessages[value.id.substring(5)] = true; // strip the user-
    	  });
    	  var members = $.parseJSON(activeMembers);
    	  var userDiv = $('<div>', {id: 'users'});
    	  $.each(members, function(index, value) {
    	    if (value === whoami) {
    	      return true;
    	    }
    	    var userLine = $('<div>', {id: 'user-' + value});
    	    userLine.addClass('user-entry');
    	    if (previouslySelected === value) {
    	      userLine.addClass('user-selected');
    	    }
    	    else {
    	      userLine.addClass('user-unselected');
    	    }
    	    var userNameDisplay = $('<span>');
    	    userNameDisplay.html(value);
    	    userLine.append(userNameDisplay);
    	    userLine.click(function() {
    	      var foo = this;
    	      $('.chat-container').hide();
    	      $('.user-entry').removeClass('user-selected');
    	      $('.user-entry').addClass('user-unselected');
    	      userLine.removeClass('user-unselected');
    	      userLine.removeClass('pending-messages');
    	      userLine.addClass('user-selected');
    	      userLine.children('.newmessage').remove();
    	      var chatWindow = getChatWindow(value);
    	      chatWindow.show();
    	    });
    	    if (value in usersWithPendingMessages) {
    	      userLine.append(newMessageIcon());
    	      userLine.addClass('pending-messages');
    	    }
    	    userDiv.append(userLine);
    	  });
    	  $('#userList').html(userDiv);
    	}

    function showGreeting(message) {
    	//alert(message);
        var response = document.getElementById('response');
        var p = document.createElement('p');
        p.style.wordWrap = 'break-word';
        p.appendChild(document.createTextNode(message));
        response.appendChild(p);
    }
   /*   function showActive(active)
    {
    	alert(active);
    } 
 */   
 </script>
</head>
<body onload="disconnect()">
<noscript><h2 style="color: #ff0000">Seems your browser doesn't support Javascript! Websocket relies on Javascript being enabled. Please enable
    Javascript and reload this page!</h2></noscript>

<h1>
	Hello world!  
</h1>
<P>  The time on the server is ${serverTime}. </P>
<div>
	<div>
		<button id="connect" onclick="connect();">CONNECT</button>
		<button id="disconnect" disabled="disabled" onclick="disconnect();">DISCONNECT</button>
	</div>
	<div id="conversationDiv">
		<label>What is your name?</label>
		<input type="text" id="name">
		<input type="text" id="receiver">
		<button id="sendName" onclick="sendName();">SEND</button> 
		<p id="response">response</p>
	</div>
	<div>
		<!-- <button id="activeuser" onclick="getActive();">ACTIVE USER</button> -->
	</div>
	<div id="userList">
    </div>
</div>
</body>
</html>
