package pt.ulusofona.productservice.controller;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for GlobalExceptionHandler.
 */
class GlobalExceptionHandlerTest {

    private GlobalExceptionHandler handler;

    @BeforeEach
    void setUp() {
        handler = new GlobalExceptionHandler();
    }

    @Test
    void handleRuntimeException_ShouldReturnBadRequestWithMessage() {
        RuntimeException ex = new RuntimeException("Produto não encontrado com ID: 999");

        ResponseEntity<Map<String, String>> response = handler.handleRuntimeException(ex);

        assertNotNull(response);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Produto não encontrado com ID: 999", response.getBody().get("message"));
        assertEquals("400", response.getBody().get("status"));
    }

    @Test
    void handleValidationExceptions_ShouldReturnBadRequestWithFieldErrors() {
        pt.ulusofona.productservice.dto.ProductRequest target =
                new pt.ulusofona.productservice.dto.ProductRequest("", "", null, null);
        BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(target, "productRequest");
        bindingResult.rejectValue("name", "NotBlank", "Nome é obrigatório");
        bindingResult.rejectValue("price", "DecimalMin", "Preço deve ser maior que zero");
        MethodArgumentNotValidException ex = new MethodArgumentNotValidException(null, bindingResult);

        ResponseEntity<Map<String, String>> response = handler.handleValidationExceptions(ex);

        assertNotNull(response);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Nome é obrigatório", response.getBody().get("name"));
        assertEquals("Preço deve ser maior que zero", response.getBody().get("price"));
        assertEquals("400", response.getBody().get("status"));
    }
}
