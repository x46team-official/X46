package com.x46.backend.common;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

class GlobalExceptionHandlerTest {

    private MockMvc mockMvc;

    @RestController
    static class TestController {

        @GetMapping("/test/not-found")
        void notFound() {
            throw new NotFoundException("Organization or branch not found");
        }

        @GetMapping("/test/conflict")
        void conflict() {
            throw new ConflictException("Duplicate organization code");
        }

        @GetMapping("/test/validation")
        void validation() {
            throw new ValidationException("organizationName is required");
        }

        @GetMapping("/test/unmapped")
        void unmapped() {
            throw new RuntimeException("boom");
        }
    }

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
            .setControllerAdvice(new GlobalExceptionHandler())
            .build();
    }

    @Test
    void notFoundExceptionMapsTo404() throws Exception {
        mockMvc.perform(get("/test/not-found"))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.error").value("Organization or branch not found"))
            .andExpect(jsonPath("$.data").doesNotExist())
            .andExpect(jsonPath("$.message").doesNotExist());
    }

    @Test
    void conflictExceptionMapsTo409() throws Exception {
        mockMvc.perform(get("/test/conflict"))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.error").value("Duplicate organization code"));
    }

    @Test
    void validationExceptionMapsTo400() throws Exception {
        mockMvc.perform(get("/test/validation"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.error").value("organizationName is required"));
    }

    @Test
    void unmappedExceptionMapsTo500() throws Exception {
        mockMvc.perform(get("/test/unmapped"))
            .andExpect(status().isInternalServerError())
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.error").value("Internal server error"));
    }
}
