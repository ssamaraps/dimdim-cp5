package br.com.fiap.dimdim.controllers;

import br.com.fiap.dimdim.models.Conta;
import br.com.fiap.dimdim.repositories.ClienteRepository;
import br.com.fiap.dimdim.repositories.ContaRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/contas")
public class ContaController {
    private final ContaRepository repo;
    private final ClienteRepository clientes;
    public ContaController(ContaRepository repo, ClienteRepository clientes) { this.repo = repo; this.clientes = clientes; }

    private String view(Model m, Conta c) {
        m.addAttribute("contas", repo.findAll());
        m.addAttribute("clientes", clientes.findAll());
        m.addAttribute("conta", c);
        return "contas";
    }

    @GetMapping public String listar(Model m) { return view(m, new Conta()); }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable Long id, Model m) { return view(m, repo.findById(id).orElseThrow()); }

    @PostMapping
    public String salvar(@Valid @ModelAttribute("conta") Conta c, BindingResult br, Model m) {
        if (c.getCliente() == null || c.getCliente().getId() == null)
            br.rejectValue("cliente.id", "required", "Selecione um cliente");
        if (br.hasErrors()) return view(m, c);
        repo.save(c);
        return "redirect:/contas";
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable Long id) { repo.deleteById(id); return "redirect:/contas"; }
}
