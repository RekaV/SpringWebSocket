package com.kgfsl.springwebsocket.controller;

import java.util.List;

public class GroupGreetings {

	String content;
	String sender_name;
	String group_name;
	List<String> listUsers;
	
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
	public String getGroup_name() {
		return group_name;
	}
	public void setGroup_name(String group_name) {
		this.group_name = group_name;
	}
	
	public List<String> getListUsers() {
		return listUsers;
	}
	public void setListUsers(List<String> listUsers) {
		this.listUsers = listUsers;
	}
	public GroupGreetings(String content, String sender_name, String group_name, List<String> listUsers) {
		this.content = content;
		this.sender_name = sender_name;
		this.group_name = group_name;
		this.listUsers = listUsers;
	}
	
	
	
}
