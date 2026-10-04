package br.com.fiap.dimdim.repositories;

import br.com.fiap.dimdim.models.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> { }
