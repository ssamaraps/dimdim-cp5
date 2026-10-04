package br.com.fiap.dimdim.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;

@Getter @Setter
@Entity @Table(name = "contas")
public class Conta {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @NotBlank @Size(max = 20) private String numero;
    @NotNull @PositiveOrZero private BigDecimal saldo;
    @ManyToOne(optional = false) @JoinColumn(name = "cliente_id")
    private Cliente cliente = new Cliente();
}
