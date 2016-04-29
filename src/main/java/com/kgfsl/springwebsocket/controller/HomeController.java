package com.kgfsl.springwebsocket.controller;

import java.security.Principal;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.kgfsl.springwebsocket.service.ActiveUserService;

/**
 * Handles requests for the application home page.
 */
@Controller
public class HomeController {
	
	private static final Logger logger = LoggerFactory.getLogger(HomeController.class);
	private ActiveUserService activeUserService;
	@Autowired
	private  SimpMessagingTemplate messagingTemplate;
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		return "chat_new_tab";
	}
	@RequestMapping(value = "/Access_Denied", method = RequestMethod.GET)
    public String accessDeniedPage(ModelMap model) {
        model.addAttribute("user", getPrincipal());
        return "accessDenied";
    }
	@RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginPage() {
        return "login";
    }
 
    @RequestMapping(value="/logout", method = RequestMethod.GET)
    public String logoutPage (HttpServletRequest request, HttpServletResponse response) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null){    
            new SecurityContextLogoutHandler().logout(request, response, auth);
        }
        return "redirect:/login?logout";
    }
 
    private String getPrincipal(){
        String userName = null;
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
 
        if (principal instanceof UserDetails) {
            userName = ((UserDetails)principal).getUsername();
        } else {
            userName = principal.toString();
        }
        return userName;
    }
	/*@MessageMapping("/hello")
	@SendTo("/queue/greetings")
	public Greetings greeting(HelloMessage message) throws InterruptedException{
		Thread.sleep(1000);
		return new Greetings("Hello,"+message.getName()+"!!!!");
		
	}
*/	
	
	@MessageMapping("/hello")
	@SendToUser("/queue/greetings")
	public void greeting(HelloMessage message,Principal principal,MessageHeaders headers) throws InterruptedException{
		Thread.sleep(1000);
		System.out.println("MESSAGE HEADERS::"+headers.toString());
		System.out.println("NAME:::::"+principal.getName());
		System.out.println("RECEIVER::::::::::::::"+message.getReceiver());
		List<String> receiver=message.getReceiver();
		messagingTemplate.convertAndSendToUser(receiver.get(0), "/queue/greetings", new Greetings(principal.getName() + " "+ ":" + " " + message.getContent(),principal.getName().toString()));
		
	}
	
	@MessageMapping("/groupmsg")
	public void sendGroupMessage(HelloMessage message,Principal principal,MessageHeaders headers){
		System.out.println("MESSAGE HEADERS::"+headers.toString());
		System.out.println("NAME:::::"+principal.getName());
		System.out.println("RECEIVER::::::::::::::"+message.getReceiver()+message.getContent());
	
		List<String> receiver=message.getReceiver();
		for(int i=0;i<receiver.size();i++){
				System.out.println("MESSAGE SEND TO:::::"+receiver.get(i));
				if(!receiver.get(i).equals(principal.getName())){
				messagingTemplate.convertAndSendToUser(receiver.get(i), "/queue/group/msg",new GroupGreetings(principal.getName() + " "+ ":" + " " + message.getContent(),principal.getName().toString(),message.getGroup_name().toString(),message.getReceiver()));
				System.out.println("SENDED::::"+messagingTemplate.toString());
				}
		}
			
	}

	@MessageMapping("/listuser")
	@SendTo("/topic/listuser")
	public List<String> listUser(){
		
		List<String> listUser = new ArrayList<String>();
		listUser.add("Reka");
		listUser.add("Raji");
		listUser.add("Aravind");
		listUser.add("Somu");
		return listUser;
	}
	@MessageMapping("/group/create")
	public void createGroup(Group group,Principal principal){
		List<String> userList=group.getUserList();
		userList.add(principal.getName());
		System.out.println("USER LIST::::"+userList.size());
		if(userList.size()!=0){
			for(int i=0;i<userList.size();i++){
				System.out.println("USER LIST::::::::::"+userList.get(i));
				messagingTemplate.convertAndSendToUser(userList.get(i),"/queue/group/get/",group);
			}
		}
	}
	@MessageMapping("/send/images")
	public void sendImage(Message<byte[]> message){
		System.out.println("CALLING:::::::::::::::::::;;;");
		
		/*String file_name=imageFile.getFile_name();
		System.out.println("FILE NAME::::::::"+file_name);
		byte[] file_content = imageFile.getFile_content();
		System.out.println("FILE CONTENT:::::::"+file_content);*/
		
	}
	@RequestMapping(value = "/chat", method = RequestMethod.GET)
	public ModelAndView chat() {
		return new ModelAndView("chat");
	}
}
