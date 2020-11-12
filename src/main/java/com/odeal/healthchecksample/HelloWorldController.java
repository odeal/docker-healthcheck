package com.odeal.healthchecksample;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value="")
public class HelloWorldController {

	@GetMapping(value="")
	public String helloWorld() {
		return "Merhaba dünya, ben sağlık kontrolüne geldim.";
	}

}
