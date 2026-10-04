package br.com.fiap.dimdim.repositories;

import br.com.fiap.dimdim.models.Conta;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ContaRepository extends JpaRepository<Conta, Long> { }
