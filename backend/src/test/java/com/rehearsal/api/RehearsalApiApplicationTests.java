package com.rehearsal.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import com.rehearsal.api.service.EmbeddingService;

@SpringBootTest
@TestPropertySource(locations="classpath:application-test.properties")
class RehearsalApiApplicationTests {

    @MockitoBean
    private EmbeddingService embeddingService;

	@Test
	void contextLoads() {
	}

}
