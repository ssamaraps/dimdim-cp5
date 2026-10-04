package br.com.fiap.dimdim.controllers;

import br.com.fiap.dimdim.models.Cliente;
import br.com.fiap.dimdim.repositories.ClienteRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/clientes")
public class ClienteController {
    private final ClienteRepository repo;
    public ClienteController(ClienteRepository repo) { this.repo = repo; }

    private String view(Model m, Cliente c) {
        m.addAttribute("clientes", repo.findAll());
        m.addAttribute("cliente", c);
        return "clientes";
    }

    @GetMapping public String listar(Model m) { return view(m, new Cliente()); }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable Long id, Model m) { return view(m, repo.findById(id).orElseThrow()); }

    @PostMapping   // cria (id nulo) ou atualiza (id preenchido)
    public String salvar(@Valid @ModelAttribute("cliente") Cliente c, BindingResult br, Model m) {
        if (br.hasErrors()) { m.addAttribute("clientes", repo.findAll()); return "clientes"; }
        repo.save(c);
        return "redirect:/clientes";
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable Long id) { repo.deleteById(id); return "redirect:/clientes"; }
}
