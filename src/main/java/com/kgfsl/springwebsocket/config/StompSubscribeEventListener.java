package com.kgfsl.springwebsocket.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

@Component
public class StompSubscribeEventListener implements ApplicationListener<SessionSubscribeEvent> {

 private static final Logger logger = LoggerFactory.getLogger(StompSubscribeEventListener.class);

 @Override
 public void onApplicationEvent(SessionSubscribeEvent sessionSubscribeEvent) {
  StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(sessionSubscribeEvent.getMessage());
  logger.info(headerAccessor.getSessionAttributes().get("HTTPSESSIONID").toString());
  logger.info(headerAccessor.getSessionAttributes().toString());

 }
}
