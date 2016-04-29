<%@tag description="Site layout template" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@attribute name="header" fragment="true" %>
<%@attribute name="footer" fragment="true" %>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="<c:url value='/resources/images/rsz_chat_icon.png'/>" type="image/x-icon" />
    <link rel="SHORTCUT ICON" href="<c:url value='/resources/images/favico.ico'/>" /> 
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.css" />
 

    <!-- Bootstrap core CSS -->
    
    <link href="<c:url value='/resources/css/bootstrap.css'/>" rel="stylesheet" />
    <link href="<c:url value='/resources/css/bootstrap.min.css'/>" rel="stylesheet" />
   	<link href="<c:url value='/resources/css/bootstrap-theme.min.css'/>" rel="stylesheet">
	<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
	<link href='<c:url value="/resources/tabcontent.css"></c:url>' rel="stylesheet" />
	<link href='<c:url value="/resources/css/font-awesome.css"></c:url>' rel="stylesheet" />
	<link href="<c:url value='/resources/css/bootstrap-multiselect.css'/>" rel="stylesheet" />
 	<link href="<c:url value='/resources/css/app.css'/>" rel="stylesheet"> 
 	  <!-- Begin emoji-picker Stylesheets -->
  <link href="<c:url value='/resources/css/nanoscroller.css'/>" rel="stylesheet">
  <link href="<c:url value='/resources/css/emoji.css'/>" rel="stylesheet">
  <!-- End emoji-picker Stylesheets -->
 	
 	
 	<jsp:invoke fragment="header"/>
	
    <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
    <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
<!--     <script src="../../assets/js/ie-emulation-modes-warning.js"></script> -->

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    
	<style type="text/css" >
		.navbar-inverse .navbar-nav > li > a {color: #E2E4CA;}
	</style>
  </head>
<!-- NAVBAR
================================================== -->
  <body>

      <div class="container">		
        <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
          <div class="container">
            <div class="navbar-header">
              <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target=".navbar-collapse">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
              
              <div style="margin-top:-12px;"><a class="navbar-brand" href="#" >
			  	<img src="<c:url value='/resources/images/rsz_chat_icon.png'/>" style="width:50px;height:50px;margin-top:-1px;" alt="logo" title="" />
			  </a></div>
            </div>
            <div class="navbar-collapse collapse" >
               &nbsp;
	          <div class="navbar-right" style="margin-top:12px; color:#fff;">
	              Welcome, 
	              <span id="login_user"></span>
            	  <%--  <span id="base_url">${base_url}</span> --%>
             	  
             	  &nbsp;&nbsp;&nbsp;&nbsp;	
	                <!-- <a href=<c:url value='/login'/> id="logout" style="color:#ECEC89;"> -->
	               <a href='/springwebsocket/login' id="logout" style="color:#ECEC89;"> 
	              <span class="glyphicon glyphicon-log-out"></span>
	              Logout</a>
	          </div>		  
		     </div>
          </div>
        </div>
      </div>
      
      <div id="body">
      		<jsp:doBody/>      
      </div>
      
      <div class="container">
	       <!-- FOOTER -->
	      <footer>
	        <p class="pull-right"></p>
	        <p>
	        	<small>&copy; 2016 All rights reserved. &middot; <a href="#">Privacy</a> &middot; <a href="#">Terms</a> Version 1.0.0
	        	</small>
	        </p>
	      </footer>
      </div>
      
       <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
     <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> -->
     <script src='<c:url value="/resources/jquery-2.1.0.min.js"></c:url>'></script>
	 <script src='<c:url value="/resources/sockjs-0.3.4.js"></c:url>'></script>
	 <script src='<c:url value="/resources/stomp.js"></c:url>'></script>
     <script src="<c:url value='/resources/js/bootstrap.min.js'/>"></script>
     <script src="<c:url value='/resources/js/app.js'/>"></script>
     <script src="<c:url value='/resources/js/bootstrap-multiselect.js'/>"></script>
       <!-- Begin emoji-picker JavaScript -->
  <script src="<c:url value='/resources/js/nanoscroller.min.js'/>"></script>
  <script src="<c:url value='/resources/js/tether.min.js'/>"></script>
  <script src="<c:url value='/resources/js/config.js'/>"></script>
  <script src="<c:url value='/resources/js/util.js'/>"></script>
  <script src="<c:url value='/resources/js/jquery.emojiarea.js'/>"></script>
  <script src="<c:url value='/resources/js/emoji-picker.js'/>"></script>
  <!-- End emoji-picker JavaScript -->
     
       
  
   
     
    <jsp:invoke fragment="footer"/>  
</body>
</html>   
