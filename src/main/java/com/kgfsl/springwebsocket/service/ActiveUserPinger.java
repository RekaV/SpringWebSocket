package com.kgfsl.springwebsocket.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;

public class ActiveUserPinger {
	private SimpMessagingTemplate template;
	private ActiveUserService activeUserService;

	public ActiveUserPinger(SimpMessagingTemplate template, ActiveUserService activeUserService) {
		this.template = template;
		this.activeUserService = activeUserService;
	}

	@Scheduled(fixedDelay = 2000)
	public void pingUsers() {
		Set<String> activeUser = activeUserService.getActiveUsers();
		System.out.println("SET USERS:::"+activeUser);
		List<String> activeUsers = new ArrayList<String>(activeUser);
		System.out.println("LIST USERS:::"+activeUsers);
		template.convertAndSend("/topic/active", activeUsers);
		
	}
}
