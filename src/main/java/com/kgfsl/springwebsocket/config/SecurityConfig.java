package com.kgfsl.springwebsocket.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter{

	@Autowired
	  public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
		auth.inMemoryAuthentication().withUser("user").password("user").roles("USER");
		auth.inMemoryAuthentication().withUser("Aravind").password("Aravind").roles("USER");
		auth.inMemoryAuthentication().withUser("Reka").password("Reka").roles("USER");
		auth.inMemoryAuthentication().withUser("Raji").password("Raji").roles("USER");
		auth.inMemoryAuthentication().withUser("Sathya").password("Sathya").roles("USER");
		auth.inMemoryAuthentication().withUser("Somu").password("Somu").roles("USER");
		auth.inMemoryAuthentication().withUser("Baranee").password("Baranee").roles("USER");
		auth.inMemoryAuthentication().withUser("Naren").password("Naren").roles("USER");
		auth.inMemoryAuthentication().withUser("Guna").password("Guna").roles("USER");
		auth.inMemoryAuthentication().withUser("Saravanan").password("Saravanan").roles("USER");
		auth.inMemoryAuthentication().withUser("Mani").password("Mani").roles("USER");
		auth.inMemoryAuthentication().withUser("Charles").password("Charles").roles("USER");
		auth.inMemoryAuthentication().withUser("Vijayabaskar").password("Vijayabaskar").roles("USER");
		auth.inMemoryAuthentication().withUser("Justin").password("Justin").roles("USER");
		auth.inMemoryAuthentication().withUser("Kavitha").password("Kavitha").roles("USER");
		auth.inMemoryAuthentication().withUser("Nithya").password("Nithya").roles("USER");
		auth.inMemoryAuthentication().withUser("Ramu").password("Ramu").roles("USER");
		auth.inMemoryAuthentication().withUser("admin").password("admin").roles("ADMIN");
	}
	
	@Override
	protected void configure(HttpSecurity http) throws Exception {

		http.csrf().disable();
		http.authorizeRequests()
	  
		.antMatchers("/get/").access("hasRole('ROLE_ADMIN')")
		.antMatchers("/list/agent/**").access("hasRole('ROLE_USER')")
		.anyRequest().authenticated()
		.and().formLogin();
		
		/*http.authorizeRequests()
        .antMatchers("/", "/home").permitAll()
        .and().formLogin().loginPage("/login")
        .usernameParameter("ssoId").passwordParameter("password")
        .and().csrf()
        .and().exceptionHandling().accessDeniedPage("/Access_Denied");*/
		
	}
}
