# SERVER FINDER

Script Luau para executor Roblox, criado por **mateus_15600**.

## Recursos

- Interface com abas laterais: Buscar, Chat Bot e Scripts, com Info no cabeçalho
- Janela arrastável, minimizável e com avatar do criador
- Tela de carregamento personalizada com saída manual e fallback anti-travamento
- Busca de servidores e tentativa de teleporte
- Blacklist temporária de servidores que falharam
- Consulta de usuário com selo azul, presença online e Brookhaven
- Chatbot local apenas conversacional, sem iniciar teleporte

## Arquivo principal

- [server_finder_tabs_chat.lua](./server_finder_tabs_chat.lua)

## Observações

- O botão English Server fica desativado porque a API pública do Roblox não informa a região ou o idioma real do servidor.
- A aba Scripts permanece reservada para scripts personalizados que serão adicionados em breve.
- O ícone do Discord usa PNG estático e fallback de asset local quando o executor não aceita URLs externas em `ImageLabel`.
- A busca de usuário verificado exige um username específico.
- O usuário precisa estar online em um servidor de Brookhaven no momento da consulta.
- O executor precisa suportar requisições HTTP GET e POST.
- Este script foi feito para um ambiente de executor Luau, não para Roblox Studio.

Use por sua conta e respeite as regras do Roblox e do executor utilizado.
