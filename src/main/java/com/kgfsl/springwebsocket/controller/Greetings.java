package com.kgfsl.springwebsocket.controller;

public class Greetings {

	String content;
	String sender_name;
	



	public Greetings(String content,String sender_name) {

		this.content = content;
		this.sender_name=sender_name;
		
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
		
	}

	public String getSender_name() {
		return sender_name;
	}

	public void setSender_name(String sender_name) {
		this.sender_name = sender_name;
	}
}
